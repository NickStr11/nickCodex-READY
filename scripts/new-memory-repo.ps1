param(
    [Parameter(Mandatory = $true)]
    [string]$RepoName,
    [string]$DestinationRoot = (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)),
    [string]$OwnerName = 'Nikita',
    [string]$AgentName = 'Kleshnya / Cipher V2',
    [string]$LegacySourceName = 'cipher-knowledge',
    [switch]$NoGit
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$templateRoot = Join-Path $repoRoot 'templates\memory-repo-starter'
$memoryRepoRoot = Join-Path $DestinationRoot $RepoName

if (-not (Test-Path -LiteralPath $templateRoot)) {
    throw "Template root not found: $templateRoot"
}

if (Test-Path -LiteralPath $memoryRepoRoot) {
    throw "Memory repo already exists: $memoryRepoRoot"
}

Copy-Item -Path $templateRoot -Destination $memoryRepoRoot -Recurse

$defaultLegacySourceName = 'cipher-knowledge'
$defaultLegacySourceRoot = Join-Path $memoryRepoRoot "knowledge\imported\$defaultLegacySourceName"
if ($LegacySourceName -ne $defaultLegacySourceName) {
    if (-not (Test-Path -LiteralPath $defaultLegacySourceRoot)) {
        throw "Default legacy source folder not found: $defaultLegacySourceRoot"
    }

    $targetLegacySourceRoot = Join-Path $memoryRepoRoot "knowledge\imported\$LegacySourceName"
    Move-Item -LiteralPath $defaultLegacySourceRoot -Destination $targetLegacySourceRoot
}

$textFiles = Get-ChildItem -Path $memoryRepoRoot -Recurse -File -Force
foreach ($file in $textFiles) {
    $content = Get-Content -LiteralPath $file.FullName -Raw -Encoding utf8
    $content = $content.Replace('{{MEMORY_REPO_NAME}}', $RepoName)
    $content = $content.Replace('{{OWNER_NAME}}', $OwnerName)
    $content = $content.Replace('{{AGENT_NAME}}', $AgentName)
    $content = $content.Replace('{{LEGACY_SOURCE_NAME}}', $LegacySourceName)
    Set-Content -LiteralPath $file.FullName -Value $content -Encoding utf8
}

if (-not $NoGit) {
    $git = Get-Command git -ErrorAction SilentlyContinue
    if ($git) {
        & $git.Source init --initial-branch main $memoryRepoRoot | Out-Null
    }
}

Write-Host ''
Write-Host 'Memory repo created:' -ForegroundColor Green
Write-Host $memoryRepoRoot
Write-Host ''
Write-Host 'Next:' -ForegroundColor Cyan
Write-Host "1. cd $memoryRepoRoot"
Write-Host "2. Fill persona/ and memory/ files with curated long-term context from $LegacySourceName"
Write-Host '3. Run .\scripts\validate-memory-repo.ps1'
Write-Host '4. Commit locally and push to a private GitHub repo'
