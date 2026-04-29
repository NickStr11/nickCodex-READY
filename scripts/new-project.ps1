param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectName,
    [string]$DestinationRoot = (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)),
    [switch]$NoGit
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$templateRoot = Join-Path $repoRoot 'templates\project-starter'
$projectRoot = Join-Path $DestinationRoot $ProjectName

if (-not (Test-Path -LiteralPath $templateRoot)) {
    throw "Template root not found: $templateRoot"
}

if (Test-Path -LiteralPath $projectRoot) {
    throw "Project already exists: $projectRoot"
}

Copy-Item -Path $templateRoot -Destination $projectRoot -Recurse

$textFiles = Get-ChildItem -Path $projectRoot -Recurse -File -Force
foreach ($file in $textFiles) {
    $content = Get-Content -LiteralPath $file.FullName -Raw -Encoding utf8
    $content = $content.Replace('{{PROJECT_NAME}}', $ProjectName)
    Set-Content -LiteralPath $file.FullName -Value $content -Encoding utf8
}

if (-not $NoGit) {
    $git = Get-Command git -ErrorAction SilentlyContinue
    if ($git) {
        & $git.Source init --initial-branch main $projectRoot | Out-Null
    }
}

Write-Host ''
Write-Host 'Project created:' -ForegroundColor Green
Write-Host $projectRoot
Write-Host ''
Write-Host 'Next:' -ForegroundColor Cyan
Write-Host "1. cd $projectRoot"
Write-Host '2. Fill memory/PROJECT_CONTEXT.md and inbox/now.md before real work'
Write-Host '3. Run .\resume.ps1'
