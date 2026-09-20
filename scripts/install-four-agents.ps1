[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
param(
    [ValidateSet('All', 'ClaudeCode', 'Codex', 'OpenCode', 'AntiGravity')]
    [string[]]$Agent = @('All'),

    [switch]$Force,

    [string]$StagingRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$sourceRoot = (Resolve-Path -LiteralPath (Join-Path (Split-Path -Parent $PSScriptRoot) 'rdq')).Path
$validator = Join-Path $PSScriptRoot 'validate-skill.ps1'

& $validator -SkillRoot $sourceRoot
if ($LASTEXITCODE -ne 0) {
    throw 'Source validation failed. Installation stopped.'
}

if ([string]::IsNullOrWhiteSpace($StagingRoot)) {
    $profilePath = [Environment]::GetFolderPath('UserProfile')
    $targetRoots = [ordered]@{
        ClaudeCode = Join-Path $profilePath '.claude/skills'
        Codex       = Join-Path $profilePath '.agents/skills'
        OpenCode    = Join-Path $profilePath '.config/opencode/skills'
        AntiGravity = Join-Path $profilePath '.gemini/config/skills'
    }
}
else {
    $stagingPath = [System.IO.Path]::GetFullPath($StagingRoot)
    $targetRoots = [ordered]@{
        ClaudeCode = Join-Path $stagingPath 'ClaudeCode'
        Codex       = Join-Path $stagingPath 'Codex'
        OpenCode    = Join-Path $stagingPath 'OpenCode'
        AntiGravity = Join-Path $stagingPath 'AntiGravity'
    }
}

$selectedAgents = if ($Agent -contains 'All') {
    @($targetRoots.Keys)
}
else {
    @($Agent | Select-Object -Unique)
}

$runtimeFiles = @(
    'SKILL.md',
    'references/question-bank.md',
    'references/spec-template.md'
)

foreach ($agentName in $selectedAgents) {
    $destinationRoot = $targetRoots[$agentName]
    $destination = Join-Path $destinationRoot 'rdq'
    $destinationExists = Test-Path -LiteralPath $destination

    if ($destinationExists -and -not $Force) {
        if ($WhatIfPreference) {
            Write-Warning "$agentName already has $destination; a real install requires -Force."
        }
        else {
            throw "$agentName already has RDQ at $destination. Add -Force after confirming overwrite."
        }
    }

    if (-not $PSCmdlet.ShouldProcess($destination, "Install RDQ Skill for $agentName")) {
        continue
    }

    $destinationReferences = Join-Path $destination 'references'
    New-Item -ItemType Directory -Path $destinationReferences -Force | Out-Null

    Copy-Item -LiteralPath (Join-Path $sourceRoot 'SKILL.md') `
        -Destination (Join-Path $destination 'SKILL.md') -Force
    Copy-Item -LiteralPath (Join-Path $sourceRoot 'references/question-bank.md') `
        -Destination (Join-Path $destinationReferences 'question-bank.md') -Force
    Copy-Item -LiteralPath (Join-Path $sourceRoot 'references/spec-template.md') `
        -Destination (Join-Path $destinationReferences 'spec-template.md') -Force

    foreach ($runtimeFile in $runtimeFiles) {
        $sourceFile = Join-Path $sourceRoot $runtimeFile
        $destinationFile = Join-Path $destination $runtimeFile
        $sourceHash = (Get-FileHash -LiteralPath $sourceFile -Algorithm SHA256).Hash
        $destinationHash = (Get-FileHash -LiteralPath $destinationFile -Algorithm SHA256).Hash
        if ($sourceHash -ne $destinationHash) {
            throw "$agentName hash mismatch after install: $runtimeFile"
        }
    }

    Write-Host "Installed and verified: $agentName -> $destination" -ForegroundColor Green
}
