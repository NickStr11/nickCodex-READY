param(
    [int]$StaleDays = 90,
    [switch]$Json
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$now = Get-Date

function Get-RelativePath {
    param([string]$Path)
    return $Path.Substring($repoRoot.Length + 1).Replace('\', '/')
}

function Get-FrontMatterValue {
    param(
        [string]$Content,
        [string]$Name
    )

    $match = [regex]::Match($Content, "(?m)^$([regex]::Escape($Name)):\s*(.+)$")
    if ($match.Success) {
        return $match.Groups[1].Value.Trim().Trim('"')
    }

    return ''
}

function Test-ExternalReference {
    param([string]$Value)
    return $Value -match '^(https?://|mailto:|#|~|[A-Za-z]:[\\/]|/)'
}

function Should-CheckReference {
    param([string]$Value)

    if ([string]::IsNullOrWhiteSpace($Value)) { return $false }
    if ($Value -match '\s') { return $false }
    if (Test-ExternalReference -Value $Value) { return $false }
    if ($Value.StartsWith('$')) { return $false }
    if ($Value -match '^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$') { return $false }

    return $Value -match '(\*|\.md$|\.toml$|\.ps1$|\.json$|\.ya?ml$|\.py$|\.sh$|\.env\.example$)'
}

function Test-LocalReference {
    param(
        [string]$Reference,
        [string]$SourceDir
    )

    $clean = $Reference.Trim().TrimEnd('.', ',', ':', ';')
    $clean = $clean.Split('#')[0]
    $clean = $clean.Split('?')[0]
    if ([string]::IsNullOrWhiteSpace($clean)) { return $true }

    foreach ($base in @($SourceDir, $repoRoot) | Select-Object -Unique) {
        try {
            if ($clean.Contains('*')) {
                if (Get-ChildItem -Path (Join-Path $base $clean) -ErrorAction SilentlyContinue) {
                    return $true
                }
            }
            elseif (Test-Path -LiteralPath (Join-Path $base $clean)) {
                return $true
            }
        }
        catch {
            continue
        }
    }

    return $false
}

$skillFiles = Get-ChildItem -LiteralPath (Join-Path $repoRoot 'skills') -Recurse -File -Filter 'SKILL.md' -ErrorAction SilentlyContinue
$skills = foreach ($file in $skillFiles) {
    $content = Get-Content -LiteralPath $file.FullName -Raw -Encoding UTF8
    [pscustomobject]@{
        path = Get-RelativePath -Path $file.FullName
        dir = Get-RelativePath -Path $file.DirectoryName
        name = Get-FrontMatterValue -Content $content -Name 'name'
        description = Get-FrontMatterValue -Content $content -Name 'description'
        modified = $file.LastWriteTime
        stale_days = [int]($now - $file.LastWriteTime).TotalDays
    }
}

$staleSkills = $skills |
    Where-Object { $_.stale_days -ge $StaleDays } |
    Sort-Object stale_days -Descending |
    Select-Object path,name,stale_days,modified

$duplicateSkillNames = $skills |
    Where-Object { -not [string]::IsNullOrWhiteSpace($_.name) } |
    Group-Object { $_.name.ToLowerInvariant() } |
    Where-Object { $_.Count -gt 1 } |
    ForEach-Object {
        [pscustomobject]@{
            name = $_.Name
            paths = @($_.Group | ForEach-Object { $_.path })
        }
    }

$conceptWords = @{}
foreach ($skill in $skills) {
    $text = ($skill.name + ' ' + $skill.description).ToLowerInvariant()
    $words = [regex]::Matches($text, '[a-z0-9][a-z0-9-]{3,}') |
        ForEach-Object { $_.Value } |
        Where-Object { $_ -notin @('skill','when','with','from','this','that','into','using','create','update','codex') } |
        Sort-Object -Unique

    foreach ($word in $words) {
        if (-not $conceptWords.ContainsKey($word)) {
            $conceptWords[$word] = [System.Collections.Generic.List[string]]::new()
        }
        [void]$conceptWords[$word].Add($skill.path)
    }
}

$duplicateConcepts = foreach ($key in $conceptWords.Keys | Sort-Object) {
    $paths = @($conceptWords[$key] | Sort-Object -Unique)
    if ($paths.Count -gt 2) {
        [pscustomobject]@{
            concept = $key
            count = $paths.Count
            paths = $paths
        }
    }
}

$noteFiles = [System.Collections.Generic.List[System.IO.FileInfo]]::new()
foreach ($dir in @('memory/diary', 'memory/sessions', 'runtime/research')) {
    $fullDir = Join-Path $repoRoot $dir
    if (Test-Path -LiteralPath $fullDir) {
        Get-ChildItem -LiteralPath $fullDir -Recurse -File -Filter '*.md' -ErrorAction SilentlyContinue |
            Where-Object { $_.FullName -notmatch '\\runtime\\research\\[^\\]+-src\\' } |
            ForEach-Object { [void]$noteFiles.Add($_) }
    }
}

$noteCorpus = ''
foreach ($file in $noteFiles) {
    $noteCorpus += "`n" + (Get-Content -LiteralPath $file.FullName -Raw -Encoding UTF8)
}

$frequentlyMentionedSkills = foreach ($skill in $skills) {
    if ([string]::IsNullOrWhiteSpace($skill.name)) {
        continue
    }

    $pattern = [regex]::Escape($skill.name)
    $count = [regex]::Matches($noteCorpus, $pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase).Count
    if ($count -gt 0) {
        [pscustomobject]@{
            name = $skill.name
            mentions = $count
            path = $skill.path
        }
    }
}

$frequentlyMentionedSkills = $frequentlyMentionedSkills |
    Sort-Object @{ Expression = 'mentions'; Descending = $true }, @{ Expression = 'name'; Descending = $false }

$docs = [System.Collections.Generic.List[System.IO.FileInfo]]::new()
$git = Get-Command git -ErrorAction SilentlyContinue
if ($git) {
    $tracked = & $git.Source -C $repoRoot ls-files
    if ($LASTEXITCODE -eq 0) {
        foreach ($relative in $tracked) {
            if ($relative -match '\.(md|ya?ml)$') {
                $fullPath = Join-Path $repoRoot $relative
                if (Test-Path -LiteralPath $fullPath) {
                    [void]$docs.Add((Get-Item -LiteralPath $fullPath))
                }
            }
        }
    }
}

if ($docs.Count -eq 0) {
    Get-ChildItem -LiteralPath $repoRoot -Recurse -File -Include '*.md','*.yaml','*.yml' -ErrorAction SilentlyContinue |
        ForEach-Object { [void]$docs.Add($_) }
}

$docs = $docs | Sort-Object FullName -Unique
$brokenRefs = [System.Collections.Generic.List[object]]::new()
$localOnlyRefs = [System.Collections.Generic.List[object]]::new()

foreach ($file in $docs) {
    $content = Get-Content -LiteralPath $file.FullName -Raw -Encoding UTF8
    $relativeFile = Get-RelativePath -Path $file.FullName

    foreach ($match in [regex]::Matches($content, '(?<![A-Za-z])([A-Za-z]:[\\/][^\s`)]+)')) {
        $value = $match.Groups[1].Value.TrimEnd('.', ',', ':', ';')
        [void]$localOnlyRefs.Add([pscustomobject]@{
            file = $relativeFile
            reference = $value
        })
    }

    $references = [System.Collections.Generic.HashSet[string]]::new()
    foreach ($match in [regex]::Matches($content, '`([^`]+)`')) {
        [void]$references.Add($match.Groups[1].Value)
    }
    foreach ($match in [regex]::Matches($content, '\[[^\]]+\]\(([^)]+)\)')) {
        [void]$references.Add($match.Groups[1].Value)
    }

    foreach ($reference in $references) {
        if (-not (Should-CheckReference -Value $reference)) {
            continue
        }

        if (-not (Test-LocalReference -Reference $reference -SourceDir $file.DirectoryName)) {
            [void]$brokenRefs.Add([pscustomobject]@{
                file = $relativeFile
                reference = $reference
            })
        }
    }
}

$report = [pscustomobject]@{
    generated_at = $now.ToString('yyyy-MM-dd HH:mm:ss')
    stale_days_threshold = $StaleDays
    counts = [pscustomobject]@{
        skills = ($skills | Measure-Object).Count
        stale_skills = ($staleSkills | Measure-Object).Count
        duplicate_skill_names = ($duplicateSkillNames | Measure-Object).Count
        duplicate_concepts = ($duplicateConcepts | Measure-Object).Count
        mentioned_skills = ($frequentlyMentionedSkills | Measure-Object).Count
        broken_refs = $brokenRefs.Count
        local_only_refs = $localOnlyRefs.Count
    }
    stale_skills = $staleSkills
    duplicate_skill_names = $duplicateSkillNames
    duplicate_concepts = $duplicateConcepts
    frequently_mentioned_skills = $frequentlyMentionedSkills
    broken_refs = $brokenRefs
    local_only_refs = $localOnlyRefs
}

if ($Json) {
    $report | ConvertTo-Json -Depth 8
    exit 0
}

Write-Host 'Context pack health scan' -ForegroundColor Cyan
$report.counts | Format-List

if ($staleSkills) {
    Write-Host ''
    Write-Host "Stale skills (modified >= $StaleDays days ago):" -ForegroundColor Yellow
    $staleSkills | Select-Object -First 20 | Format-Table -AutoSize
}

if ($duplicateSkillNames) {
    Write-Host ''
    Write-Host 'Duplicate skill names:' -ForegroundColor Yellow
    $duplicateSkillNames | Format-List
}

if ($duplicateConcepts) {
    Write-Host ''
    Write-Host 'Possible duplicate concepts across skills:' -ForegroundColor Yellow
    $duplicateConcepts | Sort-Object count -Descending | Select-Object -First 20 | Format-Table -AutoSize
}

if ($frequentlyMentionedSkills) {
    Write-Host ''
    Write-Host 'Frequently mentioned skills in diary/session/research notes:' -ForegroundColor Green
    $frequentlyMentionedSkills | Select-Object -First 20 | Format-Table -AutoSize
}

if ($brokenRefs.Count -gt 0) {
    Write-Host ''
    Write-Host 'Broken local references:' -ForegroundColor Red
    $brokenRefs | Select-Object -First 50 | Format-Table -AutoSize
}

if ($localOnlyRefs.Count -gt 0) {
    Write-Host ''
    Write-Host 'Local-only absolute references:' -ForegroundColor Yellow
    $localOnlyRefs | Select-Object -First 50 | Format-Table -AutoSize
}

Write-Host ''
Write-Host 'Read-only report. No files were changed.'
