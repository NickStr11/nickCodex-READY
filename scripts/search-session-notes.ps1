param(
    [string]$Query = '',
    [int]$ContextLines = 1,
    [int]$Limit = 30,
    [switch]$Json
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot

$searchDirs = @(
    'memory/diary',
    'memory/sessions',
    'runtime/research'
)

$files = [System.Collections.Generic.List[System.IO.FileInfo]]::new()
foreach ($dir in $searchDirs) {
    $fullDir = Join-Path $repoRoot $dir
    if (Test-Path -LiteralPath $fullDir) {
        Get-ChildItem -LiteralPath $fullDir -Recurse -File -Filter '*.md' -ErrorAction SilentlyContinue |
            Where-Object { $_.FullName -notmatch '\\runtime\\research\\[^\\]+-src\\' } |
            ForEach-Object { [void]$files.Add($_) }
    }
}

$files = $files | Sort-Object LastWriteTime -Descending

if ([string]::IsNullOrWhiteSpace($Query)) {
    $recent = $files |
        Select-Object -First $Limit |
        ForEach-Object {
            [pscustomobject]@{
                path = $_.FullName.Substring($repoRoot.Length + 1).Replace('\', '/')
                modified = $_.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss')
                bytes = $_.Length
            }
        }

    if ($Json) {
        $recent | ConvertTo-Json -Depth 4
    }
    else {
        Write-Host 'Recent session/research notes:' -ForegroundColor Cyan
        $recent | Format-Table -AutoSize
        Write-Host ''
        Write-Host 'Pass -Query "text" to search inside these notes.'
    }

    exit 0
}

$matches = [System.Collections.Generic.List[object]]::new()

foreach ($file in $files) {
    $content = @(Get-Content -LiteralPath $file.FullName -Encoding UTF8)
    $lineMatches = [System.Collections.Generic.List[int]]::new()
    for ($i = 0; $i -lt $content.Count; $i++) {
        if ($content[$i].IndexOf($Query, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
            [void]$lineMatches.Add($i + 1)
        }
    }

    if ($lineMatches.Count -eq 0) {
        continue
    }

    $snippets = [System.Collections.Generic.List[string]]::new()
    foreach ($lineNumber in $lineMatches | Select-Object -First 5) {
        $start = [Math]::Max(1, $lineNumber - $ContextLines)
        $end = [Math]::Min($content.Count, $lineNumber + $ContextLines)
        $block = for ($i = $start; $i -le $end; $i++) {
            '{0}: {1}' -f $i, $content[$i - 1]
        }
        [void]$snippets.Add(($block -join "`n"))
    }

    [void]$matches.Add([pscustomobject]@{
        path = $file.FullName.Substring($repoRoot.Length + 1).Replace('\', '/')
        modified = $file.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss')
        match_count = $lineMatches.Count
        snippets = $snippets
    })
}

$ranked = $matches |
    Sort-Object @{ Expression = 'match_count'; Descending = $true }, @{ Expression = 'modified'; Descending = $true } |
    Select-Object -First $Limit

if ($Json) {
    $ranked | ConvertTo-Json -Depth 6
}
else {
    if (-not $ranked) {
        Write-Host "No matches for: $Query" -ForegroundColor Yellow
        exit 0
    }

    foreach ($item in $ranked) {
        Write-Host ''
        Write-Host ("{0}  ({1} matches, {2})" -f $item.path, $item.match_count, $item.modified) -ForegroundColor Cyan
        foreach ($snippet in $item.snippets) {
            Write-Host $snippet
            Write-Host '---'
        }
    }
}
