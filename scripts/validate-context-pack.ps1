Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot

$requiredPaths = @(
    'AGENTS.md',
    'CLAUDE.md',
    'README.md',
    'CODEX-USAGE.md',
    'RESTORE-CHECKLIST.md',
    'PORTABILITY.md',
    'DAILY.md',
    'LICENSE',
    'CONTRIBUTING.md',
    'code_review.md',
    'resume.ps1',
    'new-project.ps1',
    'new-memory-repo.ps1',
    'doctor.ps1',
    '.editorconfig',
    '.agents/AGENTS.md',
    '.agents/skills/README.md',
    '.github/AGENTS.md',
    '.github/codex/prompts/review.md',
    '.github/workflows/validate-context-pack.yml',
    '.github/workflows/codex-review.yml',
    '.github/ISSUE_TEMPLATE/config.yml',
    '.github/ISSUE_TEMPLATE/project-intake.yml',
    '.github/ISSUE_TEMPLATE/skill-request.yml',
    '.github/pull_request_template.md',
    '.codex/config.toml',
    '.codex/agents/AGENTS.md',
    '.codex/agents/repo-recon.toml',
    '.codex/agents/security-reviewer.toml',
    '.codex/agents/docs-researcher.toml',
    '.codex/agents/exa-researcher.toml',
    '.codex/agents/notebooklm-summarizer.toml',
    '.codex/agents/browser-debugger.toml',
    '.codex/agents/targeted-fixer.toml',
    'rules/AGENTS.md',
    'rules/README.md',
    'rules/agent-behavior.md',
    'rules/work-style.md',
    'rules/code-style.md',
    'rules/subagents.md',
    'skills/AGENTS.md',
    'skills/README.md',
    'skills/core/README.md',
    'skills/optional/README.md',
    'knowledge/AGENTS.md',
    'knowledge/README.md',
    'memory/AGENTS.md',
    'memory/README.md',
    'memory/PROJECT_CONTEXT.md',
    'memory/DEV_CONTEXT.md',
    'memory/diary/README.md',
    'memory/reflections/README.md',
    'memory/reflections/processed.log',
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
    'runtime/research/RECON-TEMPLATE.md',
    'runtime/scratch/README.md',
    'aboutme.md',
    'scripts/bootstrap-portable.ps1',
    'scripts/resume.ps1',
    'scripts/new-project.ps1',
    'scripts/new-memory-repo.ps1',
    'scripts/doctor.ps1',
    'scripts/smoke-codex-subagents.ps1',
    'scripts/sync-profile-from-obsidian.ps1',
    'scripts/sync-agent-skills.ps1',
    'scripts/sync-project-subagents.ps1',
    'scripts/scan-context-pack-health.ps1',
    'scripts/search-session-notes.ps1',
    'scripts/validate-project-context.ps1',
    'templates/README.md',
    'templates/project-starter/AGENTS.md',
    'templates/project-starter/README.md',
    'templates/project-starter/.gitignore',
    'templates/project-starter/.codex/config.toml',
    'templates/project-starter/.codex/agents/AGENTS.md',
    'templates/project-starter/.codex/agents/repo-recon.toml',
    'templates/project-starter/.codex/agents/security-reviewer.toml',
    'templates/project-starter/.codex/agents/docs-researcher.toml',
    'templates/project-starter/.codex/agents/exa-researcher.toml',
    'templates/project-starter/.codex/agents/notebooklm-summarizer.toml',
    'templates/project-starter/.codex/agents/browser-debugger.toml',
    'templates/project-starter/.codex/agents/targeted-fixer.toml',
    'templates/project-starter/resume.ps1',
    'templates/project-starter/memory/PROJECT_CONTEXT.md',
    'templates/project-starter/memory/DEV_CONTEXT.md',
    'templates/project-starter/memory/diary/README.md',
    'templates/project-starter/memory/reflections/README.md',
    'templates/project-starter/memory/reflections/processed.log',
    'templates/project-starter/inbox/now.md',
    'templates/project-starter/inbox/backlog.md',
    'templates/project-starter/runtime/research/README.md',
    'templates/project-starter/runtime/outputs/README.md',
    'templates/project-starter/runtime/scratch/README.md',
    'templates/project-starter/scripts/README.md',
    'templates/project-starter/scripts/smoke-codex-subagents.ps1',
    'templates/project-starter/scripts/validate-project-context.ps1',
    'templates/memory-repo-starter/AGENTS.md',
    'templates/memory-repo-starter/README.md',
    'templates/memory-repo-starter/.gitignore',
    'templates/memory-repo-starter/resume.ps1',
    'templates/memory-repo-starter/persona/voice.md',
    'templates/memory-repo-starter/persona/operator-rules.md',
    'templates/memory-repo-starter/memory/user-profile.md',
    'templates/memory-repo-starter/memory/stable-facts.md',
    'templates/memory-repo-starter/memory/projects.md',
    'templates/memory-repo-starter/memory/relationships.md',
    'templates/memory-repo-starter/memory/CHANGELOG.md',
    'templates/memory-repo-starter/handoff/now.md',
    'templates/memory-repo-starter/handoff/recent-decisions.md',
    'templates/memory-repo-starter/runtime/imports/README.md',
    'templates/memory-repo-starter/scripts/validate-memory-repo.ps1',
    'templates/memory-repo-starter/knowledge/imported/cipher-knowledge/README.md',
    'MEMORY-REPO-RUNBOOK.md',
    'runbooks/README.md',
    'runbooks/openclaw/README.md',
    'runbooks/openclaw/OPENCLAW-SECOND-LAPTOP.md',
    'runbooks/openclaw/OPENCLAW-UPGRADE-RUNBOOK.md',
    'runbooks/openclaw/WSL-MIGRATION.md',
    'runbooks/openclaw/FRESH-CODEX-OPENCLAW-PROMPT.md',
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
    'memory/reflections',
    'inbox',
    'runtime',
    'runbooks',
    'runbooks/openclaw',
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

$runtimeOutputsPath = Join-Path $repoRoot 'runtime\outputs'
if (Test-Path -LiteralPath $runtimeOutputsPath) {
    $topLevelOutputDirs = Get-ChildItem -LiteralPath $runtimeOutputsPath -Directory -Force -ErrorAction SilentlyContinue
    foreach ($dir in $topLevelOutputDirs) {
        $embeddedOutputsPath = Join-Path $dir.FullName 'runtime\outputs'
        if (Test-Path -LiteralPath $embeddedOutputsPath) {
            $relativeDir = $dir.FullName.Substring($repoRoot.Length + 1).Replace('\', '/')
            $errors.Add("Top-level runtime output must not embed a repo-shaped runtime/outputs tree: $relativeDir")
        }
    }
}

function Test-ExternalReference {
    param(
        [string]$Value
    )

    return $Value -match '^(https?://|mailto:|~|[A-Za-z]:[\\/]|/|#)'
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

}

function Test-CodexAgentToml {
    param(
        [string]$RelativePath
    )

    $fullPath = Join-Path $repoRoot $RelativePath
    if (-not (Test-Path -LiteralPath $fullPath)) {
        return $null
    }

    $content = Get-Content -LiteralPath $fullPath -Raw -Encoding utf8

    if ($content -notmatch '(?m)^name\s*=\s*".+?"\s*$') {
        $errors.Add("Missing custom agent name: $RelativePath")
    }

    if ($content -notmatch '(?m)^description\s*=\s*".+?"\s*$') {
        $errors.Add("Missing custom agent description: $RelativePath")
    }

    if ($content -notmatch '(?s)developer_instructions\s*=\s*""".+?"""') {
        $errors.Add("Missing custom agent developer_instructions: $RelativePath")
    }

    if ($content -notmatch '(?m)^sandbox_mode\s*=\s*"(read-only|workspace-write|danger-full-access)"\s*$') {
        $errors.Add("Missing or invalid sandbox_mode for custom agent: $RelativePath")
    }

    $nameMatch = [regex]::Match($content, '(?m)^name\s*=\s*"([^"]+)"\s*$')
    if ($nameMatch.Success) {
        return $nameMatch.Groups[1].Value
    }

    return $null
}

Test-ContentHasPatterns -RelativePath 'memory/README.md' -Patterns @('DEV_CONTEXT\.md', 'PROJECT_CONTEXT\.md') -ErrorPrefix 'Memory boundary is too vague'
Test-ContentHasPatterns -RelativePath 'PORTABILITY.md' -Patterns @('bootstrap-portable\.ps1', 'validate-context-pack\.ps1') -ErrorPrefix 'Portability flow is incomplete'
Test-ContentHasPatterns -RelativePath 'scripts/sync-profile-from-obsidian.ps1' -Patterns @('aboutme\.md', 'deep-values\.md', 'deep-philosophy\.md', 'writing-style\.md', 'SourcePath') -ErrorPrefix 'Profile sync script is incomplete'
Test-AliasFile -RelativePath 'CLAUDE.md'
Test-ContentHasPatterns -RelativePath '.codex/config.toml' -Patterns @('(?s)\[features\].*?multi_agent\s*=\s*true', '(?s)\[agents\].*?max_threads\s*=\s*\d+', '(?s)\[agents\].*?max_depth\s*=\s*\d+') -ErrorPrefix 'Codex subagent config is incomplete'
Test-ContentHasPatterns -RelativePath '.codex/agents/docs-researcher.toml' -Patterns @('(?s)\[mcp_servers\.openaiDeveloperDocs\].*?https://developers\.openai\.com/mcp') -ErrorPrefix 'docs_researcher MCP wiring is incomplete'
Test-ContentHasPatterns -RelativePath '.github/workflows/codex-review.yml' -Patterns @('openai/codex-action@v1', '\.github/codex/prompts/review\.md', 'workspace-write') -ErrorPrefix 'Codex review workflow is incomplete'
Test-ContentHasPatterns -RelativePath 'templates/project-starter/.codex/config.toml' -Patterns @('(?s)\[features\].*?multi_agent\s*=\s*true', '(?s)\[agents\].*?max_threads\s*=\s*\d+', '(?s)\[agents\].*?max_depth\s*=\s*\d+') -ErrorPrefix 'Project starter Codex subagent config is incomplete'
Test-ContentHasPatterns -RelativePath 'templates/project-starter/.codex/agents/docs-researcher.toml' -Patterns @('(?s)\[mcp_servers\.openaiDeveloperDocs\].*?https://developers\.openai\.com/mcp') -ErrorPrefix 'Project starter docs_researcher MCP wiring is incomplete'

function Test-CodexAgentSet {
    param(
        [string[]]$RelativePaths,
        [string]$Label
    )

    $agentNames = [System.Collections.Generic.HashSet[string]]::new()
    foreach ($agentFile in $RelativePaths) {
        $agentName = Test-CodexAgentToml -RelativePath $agentFile
        if ([string]::IsNullOrWhiteSpace($agentName)) {
            continue
        }

        if (-not $agentNames.Add($agentName)) {
            $errors.Add("$Label has duplicate custom agent name: $agentName")
        }
    }
}

Test-CodexAgentSet -Label 'Root custom agents' -RelativePaths @(
    '.codex/agents/repo-recon.toml',
    '.codex/agents/security-reviewer.toml',
    '.codex/agents/docs-researcher.toml',
    '.codex/agents/exa-researcher.toml',
    '.codex/agents/notebooklm-summarizer.toml',
    '.codex/agents/browser-debugger.toml',
    '.codex/agents/targeted-fixer.toml'
)

Test-CodexAgentSet -Label 'Project starter custom agents' -RelativePaths @(
    'templates/project-starter/.codex/agents/repo-recon.toml',
    'templates/project-starter/.codex/agents/security-reviewer.toml',
    'templates/project-starter/.codex/agents/docs-researcher.toml',
    'templates/project-starter/.codex/agents/exa-researcher.toml',
    'templates/project-starter/.codex/agents/notebooklm-summarizer.toml',
    'templates/project-starter/.codex/agents/browser-debugger.toml',
    'templates/project-starter/.codex/agents/targeted-fixer.toml'
)

$skillDirs = Get-ChildItem -Path (Join-Path $repoRoot 'skills') -Recurse -File -Filter 'SKILL.md' -ErrorAction SilentlyContinue |
    ForEach-Object { $_.Directory } |
    Sort-Object FullName -Unique

foreach ($skillDir in $skillDirs) {
    $skillPath = $skillDir.FullName.Substring($repoRoot.Length + 1).Replace('\', '/')
    $skillFile = Join-Path $skillDir.FullName 'SKILL.md'
    $skillUi = Join-Path $skillDir.FullName 'agents/openai.yaml'

    if (-not (Test-Path -LiteralPath $skillFile)) {
        $errors.Add("Missing skill file: $skillPath/SKILL.md")
    }

    if (-not (Test-Path -LiteralPath $skillUi)) {
        $errors.Add("Missing skill UI metadata: $skillPath/agents/openai.yaml")
    }

    if (Test-Path -LiteralPath $skillFile) {
        $skillContent = Get-Content -LiteralPath $skillFile -Raw -Encoding utf8
        $frontMatterMatch = [regex]::Match($skillContent, '(?s)^---\r?\n(.*?)\r?\n---')

        if (-not $frontMatterMatch.Success) {
            $errors.Add("Invalid skill front matter: $skillPath/SKILL.md")
        }
        else {
            $frontMatter = $frontMatterMatch.Groups[1].Value
            if ($frontMatter -notmatch '(?m)^name:\s*\S+') {
                $errors.Add("Missing skill name in front matter: $skillPath/SKILL.md")
            }

            if ($frontMatter -notmatch '(?m)^description:\s*(\S+|[>|])') {
                $errors.Add("Missing skill description in front matter: $skillPath/SKILL.md")
            }
        }

        if ($skillDir.Name -eq 'repo-recon' -and $skillContent -notmatch 'references/safety-map-checklist\.md') {
            $errors.Add('repo-recon must reference safety-map-checklist.md')
        }
    }

    if (Test-Path -LiteralPath $skillUi) {
        $uiContent = Get-Content -LiteralPath $skillUi -Raw -Encoding utf8

        if ($uiContent -notmatch '(?m)^\s*interface:\s*$') {
            $errors.Add("Missing interface block in skill UI metadata: $skillPath/agents/openai.yaml")
        }

        if ($uiContent -notmatch '(?m)^\s*display_name:\s*.+$') {
            $errors.Add("Missing display_name in skill UI metadata: $skillPath/agents/openai.yaml")
        }

        if ($uiContent -notmatch '(?m)^\s*short_description:\s*.+$') {
            $errors.Add("Missing short_description in skill UI metadata: $skillPath/agents/openai.yaml")
        }

        if ($uiContent -notmatch '(?m)^\s*default_prompt:\s*.+$') {
            $errors.Add("Missing default_prompt in skill UI metadata: $skillPath/agents/openai.yaml")
        }
    }
}

$syncAgentSkillsScript = Join-Path $repoRoot 'scripts/sync-agent-skills.ps1'
if (Test-Path -LiteralPath $syncAgentSkillsScript) {
    try {
        & $syncAgentSkillsScript -Check | Out-Null
        if ($LASTEXITCODE -ne 0) {
            $errors.Add('Repo-native skill wrappers are missing or out of sync. Run scripts/sync-agent-skills.ps1')
        }
    }
    catch {
        $errors.Add("Repo-native skill sync check failed: $($_.Exception.Message)")
    }
}

$healthScanSummary = $null
$healthScanScript = Join-Path $repoRoot 'scripts/scan-context-pack-health.ps1'
if (Test-Path -LiteralPath $healthScanScript) {
    try {
        $healthJson = & $healthScanScript -Json | Out-String
        if ($LASTEXITCODE -ne 0) {
            $errors.Add('Context pack health scan failed. Run scripts/scan-context-pack-health.ps1')
        }
        else {
            $healthScanSummary = $healthJson | ConvertFrom-Json
        }
    }
    catch {
        $errors.Add("Context pack health scan failed: $($_.Exception.Message)")
    }
}

$docs = [System.Collections.Generic.List[System.IO.FileInfo]]::new()
$git = Get-Command git -ErrorAction SilentlyContinue

if ($git) {
    $trackedDocPaths = & $git.Source -C $repoRoot ls-files
    if ($LASTEXITCODE -eq 0) {
        foreach ($relativePath in $trackedDocPaths) {
            if ($relativePath -notmatch '\.(md|ya?ml)$') {
                continue
            }

            $fullPath = Join-Path $repoRoot $relativePath
            if (Test-Path -LiteralPath $fullPath) {
                [void]$docs.Add((Get-Item -LiteralPath $fullPath))
            }
        }
    }
}

if ($docs.Count -eq 0) {
    $docs += Get-ChildItem -Path $repoRoot -Recurse -File -Filter *.md
    $docs += Get-ChildItem -Path $repoRoot -Recurse -File -Include *.yaml,*.yml
}

foreach ($path in $requiredPaths) {
    if ($path -notmatch '\.(md|ya?ml)$') {
        continue
    }

    $fullPath = Join-Path $repoRoot $path
    if (Test-Path -LiteralPath $fullPath) {
        [void]$docs.Add((Get-Item -LiteralPath $fullPath))
    }
}

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

if ($healthScanSummary -and $healthScanSummary.counts) {
    $counts = $healthScanSummary.counts
    Write-Host ("Health scan: {0} skill(s), {1} stale, {2} duplicate concept(s), {3} broken ref(s), {4} local-only ref(s)." -f `
        $counts.skills, `
        $counts.stale_skills, `
        $counts.duplicate_concepts, `
        $counts.broken_refs, `
        $counts.local_only_refs) -ForegroundColor Cyan
}

Write-Host 'Validation passed.' -ForegroundColor Green
