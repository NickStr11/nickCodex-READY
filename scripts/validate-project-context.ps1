param(
    [string]$TargetPath = (Get-Location).Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$projectRoot = (Resolve-Path -LiteralPath $TargetPath).Path
$requiredPaths = @(
    'AGENTS.md',
    'README.md',
    'resume.ps1',
    'memory\PROJECT_CONTEXT.md',
    'memory\DEV_CONTEXT.md',
    'inbox\now.md',
    'inbox\backlog.md',
    'runtime\research\README.md',
    'runtime\outputs\README.md',
    'runtime\scratch\README.md'
)

$errors = [System.Collections.Generic.List[string]]::new()

foreach ($relativePath in $requiredPaths) {
    $fullPath = Join-Path $projectRoot $relativePath
    if (-not (Test-Path -LiteralPath $fullPath)) {
        $errors.Add("Missing required path: $relativePath")
    }
}

function Test-ExternalReference {
    param([string]$Value)
    return $Value -match '^(https?://|mailto:|~|[A-Za-z]:\\|/|#)'
}

function Should-CheckReference {
    param([string]$Value)

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return $false
    }

    if ($Value -match '\s') {
        return $false
    }

    if (Test-ExternalReference -Value $Value) {
        return $false
    }

    return $Value -match '(\.md$|\.ps1$|\.json$|\.ya?ml$|\.py$|\.env$|\.env\.example$)'
}

function Test-LocalReference {
    param(
        [string]$Reference,
        [string]$SourceDir,
        [string]$ProjectRoot
    )

    $clean = $Reference.Trim().TrimEnd('.', ',', ':', ';')
    $clean = $clean.Split('#')[0]
    $clean = $clean.Split('?')[0]

    if ([string]::IsNullOrWhiteSpace($clean)) {
        return $true
    }

    foreach ($base in @($SourceDir, $ProjectRoot) | Select-Object -Unique) {
        $candidate = Join-Path $base $clean
        if (Test-Path -LiteralPath $candidate) {
            return $true
        }
    }

    return $false
}

$docs = Get-ChildItem -Path $projectRoot -Recurse -File -Include *.md,*.yml,*.yaml
foreach ($file in $docs) {
    $content = Get-Content -LiteralPath $file.FullName -Raw -Encoding utf8
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

        if (-not (Test-LocalReference -Reference $reference -SourceDir $file.DirectoryName -ProjectRoot $projectRoot)) {
            $relativeFile = Resolve-Path -LiteralPath $file.FullName -Relative
            $errors.Add("Broken reference in $relativeFile -> $reference")
        }
    }
}

if ($errors.Count -gt 0) {
    Write-Host 'Project validation failed:' -ForegroundColor Red
    $errors | Sort-Object -Unique | ForEach-Object {
        Write-Host " - $_"
    }
    exit 1
}

Write-Host 'Project validation passed.' -ForegroundColor Green
