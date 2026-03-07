Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot

$requiredPaths = @(
    'AGENTS.md',
    'AGENTS-HARD.md',
    'CLAUDE.md',
    'README.md',
    'PORTABLE-README.md',
    '.codex/config.toml',
    'rules/AGENTS.md',
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

