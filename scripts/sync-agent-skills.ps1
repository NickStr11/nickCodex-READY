param(
    [switch]$Check
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceRoot = Join-Path $repoRoot 'skills'
$targetRoot = Join-Path $repoRoot '.agents/skills'
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)

function Get-NormalizedContent {
    param(
        [string]$Path
    )

    $content = Get-Content -LiteralPath $Path -Raw -Encoding utf8
    $content = $content -replace "`r?`n", "`n"
    if (-not $content.EndsWith("`n")) {
        $content += "`n"
    }

    return $content
}

function New-WrapperSkillContent {
    param(
        [string]$SourceRelativeDir,
        [string]$SourceContent
    )

    $frontMatterMatch = [regex]::Match($SourceContent, '(?s)^---\n(.*?)\n---')
    if (-not $frontMatterMatch.Success) {
        throw "Invalid skill front matter in $SourceRelativeDir/SKILL.md"
    }

    $frontMatter = $frontMatterMatch.Value.TrimEnd()
    $sourceSkillPath = "$SourceRelativeDir/SKILL.md"

    $lines = @(
        $frontMatter,
        '',
        '# Repo Skill Wrapper',
        '',
        ('Canonical skill: `{0}`' -f $sourceSkillPath),
        '',
        'This wrapper exists so Codex can discover the skill from `.agents/skills`.',
        'Read and follow the canonical skill above before doing the task.',
        ('Resolve any relative `scripts/`, `references/`, `assets/`, and `agents/` paths from `{0}/`.' -f $SourceRelativeDir),
        'Do not edit this wrapper manually. Regenerate it with `powershell -ExecutionPolicy Bypass -File scripts/sync-agent-skills.ps1`.'
    )

    return (($lines -join "`n").TrimEnd() + "`n")
}

function Get-SourceSkills {
    $skillFiles = Get-ChildItem -Path $sourceRoot -Recurse -File -Filter 'SKILL.md' -ErrorAction Stop |
        Sort-Object FullName

    $skills = foreach ($skillFile in $skillFiles) {
        $skillDir = $skillFile.Directory
        $relativeDir = $skillDir.FullName.Substring($repoRoot.Length + 1).Replace('\', '/')
        $skillName = $skillDir.Name
        $uiPath = Join-Path $skillDir.FullName 'agents/openai.yaml'

        if (-not (Test-Path -LiteralPath $uiPath)) {
            throw "Missing agents/openai.yaml for $relativeDir"
        }

        $skillContent = Get-NormalizedContent -Path $skillFile.FullName
        $uiContent = Get-NormalizedContent -Path $uiPath
        $frontMatterMatch = [regex]::Match($skillContent, '(?s)^---\n(.*?)\n---')
        $nameMatch = [regex]::Match($frontMatterMatch.Groups[1].Value, '(?m)^name:\s*(.+?)\s*$')

        if (-not $nameMatch.Success) {
            throw "Missing skill name in front matter for $relativeDir"
        }

        [pscustomobject]@{
            Name = $skillName
            ExportedSkillName = $nameMatch.Groups[1].Value.Trim()
            RelativeDir = $relativeDir
            WrapperDir = Join-Path $targetRoot $skillName
            WrapperSkillPath = Join-Path (Join-Path $targetRoot $skillName) 'SKILL.md'
            WrapperUiPath = Join-Path (Join-Path (Join-Path $targetRoot $skillName) 'agents') 'openai.yaml'
            ExpectedSkillContent = New-WrapperSkillContent -SourceRelativeDir $relativeDir -SourceContent $skillContent
            ExpectedUiContent = $uiContent
        }
    }

    $duplicateNames = $skills |
        Group-Object -Property Name |
        Where-Object { $_.Count -gt 1 } |
        Select-Object -ExpandProperty Name

    if ($duplicateNames) {
        throw ('Duplicate skill leaf directories are not exportable to `.agents/skills`: {0}' -f (($duplicateNames | Sort-Object) -join ', '))
    }

    $duplicateExportedNames = $skills |
        Group-Object -Property ExportedSkillName |
        Where-Object { $_.Count -gt 1 } |
        Select-Object -ExpandProperty Name

    if ($duplicateExportedNames) {
        throw ('Duplicate skill front matter names are not exportable to `.agents/skills`: {0}' -f (($duplicateExportedNames | Sort-Object) -join ', '))
    }

    return $skills
}

function Set-Utf8NoBomFile {
    param(
        [string]$Path,
        [string]$Content
    )

    $parentDir = Split-Path -Parent $Path
    if (-not (Test-Path -LiteralPath $parentDir)) {
        New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
    }

    [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

$skills = Get-SourceSkills

if (-not (Test-Path -LiteralPath $targetRoot)) {
    if ($Check) {
        Write-Host 'Missing .agents/skills directory.' -ForegroundColor Yellow
        exit 1
    }

    New-Item -ItemType Directory -Path $targetRoot -Force | Out-Null
}

$expectedNames = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
foreach ($skill in $skills) {
    [void]$expectedNames.Add($skill.Name)
}

$existingWrapperDirs = Get-ChildItem -LiteralPath $targetRoot -Directory -ErrorAction SilentlyContinue
$drift = [System.Collections.Generic.List[string]]::new()

foreach ($wrapperDir in $existingWrapperDirs) {
    if (-not $expectedNames.Contains($wrapperDir.Name)) {
        if ($Check) {
            $drift.Add("Stale wrapper directory: .agents/skills/$($wrapperDir.Name)")
        }
        else {
            Remove-Item -LiteralPath $wrapperDir.FullName -Recurse -Force
        }
    }
}

foreach ($skill in $skills) {
    if ($Check) {
        if (-not (Test-Path -LiteralPath $skill.WrapperSkillPath)) {
            $drift.Add("Missing wrapper skill: .agents/skills/$($skill.Name)/SKILL.md")
        }
        elseif ((Get-NormalizedContent -Path $skill.WrapperSkillPath) -ne $skill.ExpectedSkillContent) {
            $drift.Add("Out-of-sync wrapper skill: .agents/skills/$($skill.Name)/SKILL.md")
        }

        if (-not (Test-Path -LiteralPath $skill.WrapperUiPath)) {
            $drift.Add("Missing wrapper UI metadata: .agents/skills/$($skill.Name)/agents/openai.yaml")
        }
        elseif ((Get-NormalizedContent -Path $skill.WrapperUiPath) -ne $skill.ExpectedUiContent) {
            $drift.Add("Out-of-sync wrapper UI metadata: .agents/skills/$($skill.Name)/agents/openai.yaml")
        }

        continue
    }

    if (Test-Path -LiteralPath $skill.WrapperDir) {
        Remove-Item -LiteralPath $skill.WrapperDir -Recurse -Force
    }

    New-Item -ItemType Directory -Path $skill.WrapperDir -Force | Out-Null
    Set-Utf8NoBomFile -Path $skill.WrapperSkillPath -Content $skill.ExpectedSkillContent
    Set-Utf8NoBomFile -Path $skill.WrapperUiPath -Content $skill.ExpectedUiContent
}

if ($Check) {
    if ($drift.Count -gt 0) {
        $drift | Sort-Object -Unique | ForEach-Object {
            Write-Host $_ -ForegroundColor Yellow
        }
        exit 1
    }

    Write-Host ('Repo-native skill wrappers are in sync: {0}' -f $skills.Count) -ForegroundColor Green
    exit 0
}

Write-Host ('Synced repo-native skill wrappers: {0}' -f $skills.Count) -ForegroundColor Green
