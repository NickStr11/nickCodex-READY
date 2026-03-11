param(
    [string]$TargetPath = (Get-Location).Path,
    [switch]$Deep,
    [switch]$CopyToClipboard
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Add-FileIfExists {
    param(
        [System.Collections.Generic.List[string]]$Bucket,
        [string]$PathValue
    )

    if (Test-Path -LiteralPath $PathValue) {
        [void]$Bucket.Add($PathValue)
    }
}

$resolvedRoot = (Resolve-Path -LiteralPath $TargetPath).Path
$filesToRead = [System.Collections.Generic.List[string]]::new()

Add-FileIfExists -Bucket $filesToRead -PathValue (Join-Path $resolvedRoot 'AGENTS.md')
Add-FileIfExists -Bucket $filesToRead -PathValue (Join-Path $resolvedRoot 'memory\PROJECT_CONTEXT.md')
Add-FileIfExists -Bucket $filesToRead -PathValue (Join-Path $resolvedRoot 'inbox\now.md')
Add-FileIfExists -Bucket $filesToRead -PathValue (Join-Path $resolvedRoot 'ARCHITECTURE.md')

if ($Deep) {
    Add-FileIfExists -Bucket $filesToRead -PathValue (Join-Path $resolvedRoot 'memory\DEV_CONTEXT.md')
}

$promptLines = [System.Collections.Generic.List[string]]::new()
[void]$promptLines.Add("Load the project context from ``$resolvedRoot``.")
[void]$promptLines.Add('')

if ($filesToRead.Count -gt 0) {
    [void]$promptLines.Add('Read first:')
    foreach ($file in $filesToRead) {
        [void]$promptLines.Add("- ``$file``")
    }
    [void]$promptLines.Add('')
}

if ((Test-Path -LiteralPath (Join-Path $resolvedRoot 'memory\DEV_CONTEXT.md')) -and -not $Deep) {
    [void]$promptLines.Add('If you need the latest handoff or blockers, then read:')
    [void]$promptLines.Add("- ``$(Join-Path $resolvedRoot 'memory\DEV_CONTEXT.md')``")
    [void]$promptLines.Add('')
}

[void]$promptLines.Add('After loading the context:')
[void]$promptLines.Add('1. briefly say what the current focus is')
[void]$promptLines.Add('2. name the next step')
[void]$promptLines.Add('3. if you make changes, save them into project-local memory and inbox')

$prompt = ($promptLines -join [Environment]::NewLine).Trim()

Write-Host ''
Write-Host '=== Resume Prompt ===' -ForegroundColor Cyan
Write-Host $prompt
Write-Host ''

if ($CopyToClipboard -and (Get-Command Set-Clipboard -ErrorAction SilentlyContinue)) {
    Set-Clipboard -Value $prompt
    Write-Host 'Prompt copied to clipboard.' -ForegroundColor Green
}
