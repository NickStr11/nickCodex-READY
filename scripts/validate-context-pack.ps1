Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot

$requiredPaths = @(
    'AGENTS.md',
    'AGENTS-HARD.md',
    'CLAUDE.md',
    'README.md',
    'PORTABLE-README.md',
    'PORTABILITY.md',
    'DAILY.md',
    'LICENSE',
    'CONTRIBUTING.md',
    '.editorconfig',
    '.github/AGENTS.md',
    '.github/workflows/validate-context-pack.yml',
    '.github/ISSUE_TEMPLATE/config.yml',
    '.github/ISSUE_TEMPLATE/project-intake.yml',
    '.github/ISSUE_TEMPLATE/skill-request.yml',
    '.github/pull_request_template.md',
    '.codex/config.toml',
    'rules/AGENTS.md',
    'rules/README.md',
    'rules/agent-behavior.md',
    'rules/work-style.md',
    'rules/code-style.md',
    'skills/AGENTS.md',
    'skills/README.md',
    'knowledge/AGENTS.md',
    'knowledge/README.md',
    'memory/AGENTS.md',
    'memory/README.md',
    'memory/PROJECT_CONTEXT.md',
    'memory/DEV_CONTEXT.md',
    'memory/sessions/README.md',
    'inbox/AGENTS.md',
    'inbox/README.md',
    'inbox/now.md',
    'inbox/backlog.md',
    'runtime/AGENTS.md',
    'runtime/README.md',
    'runtime/imports/README.md',
    'runtime/imports/youtube-raw/README.md',
    'runtime/outputs/README.md',
    'runtime/research/README.md',
    'runtime/scratch/README.md',
    'aboutme.md',
    'scripts/validate-context-pack.ps1'
)

$errors = [System.Collections.Generic.List[string]]::new()

foreach ($path in $requiredPaths) {
    $fullPath = Join-Path $repoRoot $path
    if (-not (Test-Path -LiteralPath $fullPath)) {
        $errors.Add("Missing required path: $path")
    }
}

$layerDirsRequiringAgents = @(
    'rules',
    'skills',
    'knowledge',
    'memory',
    'inbox',
    'runtime',
    '.github'
)

foreach ($dir in $layerDirsRequiringAgents) {
    $agentsPath = Join-Path $repoRoot (Join-Path $dir 'AGENTS.md')
    if (-not (Test-Path -LiteralPath $agentsPath)) {
        $errors.Add("Missing local AGENTS.md for layer: $dir/AGENTS.md")
    }
}

$publicDirsRequiringReadme = @(
    'rules',
    'skills',
    'knowledge',
    'memory',
    'inbox',
    'runtime',
    'runtime/imports',
    'runtime/imports/youtube-raw',
    'runtime/outputs',
    'runtime/research',
    'runtime/scratch'
)

foreach ($dir in $publicDirsRequiringReadme) {
    $readmePath = Join-Path $repoRoot (Join-Path $dir 'README.md')
    if (-not (Test-Path -LiteralPath $readmePath)) {
        $errors.Add("Missing README for public layer: $dir/README.md")
    }
}

function Test-ExternalReference {
    param(
        [string]$Value
    )

    return $Value -match '^(https?://|mailto:|~|[A-Za-z]:\\|/|#)'
}

function Should-CheckReference {
    param(
        [string]$Value
    )

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return $false
    }

    if ($Value -match '\s') {
        return $false
    }

    if (Test-ExternalReference -Value $Value) {
        return $false
    }

    if ($Value.StartsWith('$')) {
        return $false
    }

    if ($Value -match '^\d+(?:/\d+)+$') {
        return $false
    }

    if ($Value -match '^[A-Za-z0-9.-]+\.[A-Za-z]{2,}/') {
        return $false
    }

    if ($Value -match '^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$') {
        return $false
    }

    return $Value -match '(\*|\.md$|\.toml$|\.ps1$|\.json$|\.ya?ml$|\.py$|\.sh$|\.env\.example$)'
}

function Test-LocalReference {
    param(
        [string]$Reference,
        [string]$SourceDir,
        [string]$RepoRoot
    )

    $clean = $Reference.Trim()
    $clean = $clean.TrimEnd('.', ',', ':', ';')
    $clean = $clean.Split('#')[0]
    $clean = $clean.Split('?')[0]

    if ([string]::IsNullOrWhiteSpace($clean)) {
        return $true
    }

    $bases = @($SourceDir, $RepoRoot) | Select-Object -Unique

    if ($clean.Contains('*')) {
        foreach ($base in $bases) {
            try {
                $pattern = Join-Path $base $clean
                if (Get-ChildItem -Path $pattern -ErrorAction SilentlyContinue) {
                    return $true
                }
            }
            catch {
                continue
            }
        }

        return $false
    }

    foreach ($base in $bases) {
        try {
            $candidate = Join-Path $base $clean
            if (Test-Path -LiteralPath $candidate) {
                return $true
            }
        }
        catch {
            continue
        }
    }

    return $false
}

function Test-ContentHasPatterns {
    param(
        [string]$RelativePath,
        [string[]]$Patterns,
        [string]$ErrorPrefix
    )

    $fullPath = Join-Path $repoRoot $RelativePath
    if (-not (Test-Path -LiteralPath $fullPath)) {
        return
    }

    $content = Get-Content -LiteralPath $fullPath -Raw -Encoding utf8
    foreach ($pattern in $Patterns) {
        if ($content -notmatch $pattern) {
            $errors.Add("${ErrorPrefix}: $RelativePath")
            break
        }
    }
}

function Test-AliasFile {
    param(
        [string]$RelativePath
    )

    $fullPath = Join-Path $repoRoot $RelativePath
    if (-not (Test-Path -LiteralPath $fullPath)) {
        return
    }

    $lines = Get-Content -LiteralPath $fullPath -Encoding utf8
    $content = $lines -join "`n"

    if ($lines.Count -gt 12) {
        $errors.Add("Alias wrapper grew too large: $RelativePath")
    }

    if ($content -notmatch 'AGENTS\.md') {
        $errors.Add("Alias wrapper must point to AGENTS.md: $RelativePath")
    }

    if ($content -notmatch 'второй источник истины') {
        $errors.Add("Alias wrapper must forbid second source of truth: $RelativePath")
    }
}

Test-ContentHasPatterns -RelativePath 'memory/README.md' -Patterns @('актив', 'времен') -ErrorPrefix 'Memory boundary is too vague'
Test-ContentHasPatterns -RelativePath 'knowledge/README.md' -Patterns @('долговеч', 'переиспольз') -ErrorPrefix 'Knowledge boundary is too vague'
Test-AliasFile -RelativePath 'CLAUDE.md'
Test-AliasFile -RelativePath 'AGENTS-HARD.md'

$skillDirs = Get-ChildItem -Path (Join-Path $repoRoot 'skills') -Directory -ErrorAction SilentlyContinue
foreach ($skillDir in $skillDirs) {
    $skillFile = Join-Path $skillDir.FullName 'SKILL.md'
    $skillUi = Join-Path $skillDir.FullName 'agents/openai.yaml'

    if (-not (Test-Path -LiteralPath $skillFile)) {
        $errors.Add("Missing skill file: skills/$($skillDir.Name)/SKILL.md")
    }

    if (-not (Test-Path -LiteralPath $skillUi)) {
        $errors.Add("Missing skill UI metadata: skills/$($skillDir.Name)/agents/openai.yaml")
    }

    if (Test-Path -LiteralPath $skillFile) {
        $skillContent = Get-Content -LiteralPath $skillFile -Raw -Encoding utf8
        $frontMatterMatch = [regex]::Match($skillContent, '(?s)^---\r?\n(.*?)\r?\n---')

        if (-not $frontMatterMatch.Success) {
            $errors.Add("Invalid skill front matter: skills/$($skillDir.Name)/SKILL.md")
        }
        else {
            $frontMatter = $frontMatterMatch.Groups[1].Value
            if ($frontMatter -notmatch '(?m)^name:\s*\S+') {
                $errors.Add("Missing skill name in front matter: skills/$($skillDir.Name)/SKILL.md")
            }

            if ($frontMatter -notmatch '(?m)^description:\s*(\S+|[>|])') {
                $errors.Add("Missing skill description in front matter: skills/$($skillDir.Name)/SKILL.md")
            }
        }
    }

    if (Test-Path -LiteralPath $skillUi) {
        $uiContent = Get-Content -LiteralPath $skillUi -Raw -Encoding utf8

        if ($uiContent -notmatch '(?m)^\s*interface:\s*$') {
            $errors.Add("Missing interface block in skill UI metadata: skills/$($skillDir.Name)/agents/openai.yaml")
        }

        if ($uiContent -notmatch '(?m)^\s*display_name:\s*.+$') {
            $errors.Add("Missing display_name in skill UI metadata: skills/$($skillDir.Name)/agents/openai.yaml")
        }

        if ($uiContent -notmatch '(?m)^\s*short_description:\s*.+$') {
            $errors.Add("Missing short_description in skill UI metadata: skills/$($skillDir.Name)/agents/openai.yaml")
        }

        if ($uiContent -notmatch '(?m)^\s*default_prompt:\s*.+$') {
            $errors.Add("Missing default_prompt in skill UI metadata: skills/$($skillDir.Name)/agents/openai.yaml")
        }
    }
}

$docs = @()
$docs += Get-ChildItem -Path $repoRoot -Recurse -File -Filter *.md
$docs += Get-ChildItem -Path $repoRoot -Recurse -File -Include *.yaml,*.yml
$docs = $docs | Sort-Object FullName -Unique

foreach ($file in $docs) {
    $content = Get-Content -LiteralPath $file.FullName -Raw -Encoding utf8
    $references = [System.Collections.Generic.HashSet[string]]::new()

    foreach ($match in [regex]::Matches($content, '`([^`]+)`')) {
        [void]$references.Add($match.Groups[1].Value)
    }

    foreach ($match in [regex]::Matches($content, '\[[^\]]+\]\(([^)]+)\)')) {
        [void]$references.Add($match.Groups[1].Value)
    }

    foreach ($match in [regex]::Matches($content, '"([^"\r\n]+\.[A-Za-z0-9]+)"')) {
        [void]$references.Add($match.Groups[1].Value)
    }

    foreach ($reference in $references) {
        if (-not (Should-CheckReference -Value $reference)) {
            continue
        }

        $isValid = Test-LocalReference -Reference $reference -SourceDir $file.DirectoryName -RepoRoot $repoRoot
        if (-not $isValid) {
            $relativeFile = Resolve-Path -LiteralPath $file.FullName -Relative
            $errors.Add("Broken reference in $relativeFile -> $reference")
        }
    }
}

if ($errors.Count -gt 0) {
    Write-Host 'Validation failed:' -ForegroundColor Red
    $errors | Sort-Object -Unique | ForEach-Object {
        Write-Host " - $_"
    }
    exit 1
}

Write-Host 'Validation passed.' -ForegroundColor Green

