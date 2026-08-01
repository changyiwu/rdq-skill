[CmdletBinding()]
param(
    [string]$SkillRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($SkillRoot)) {
    $SkillRoot = Join-Path (Split-Path -Parent $PSScriptRoot) 'rdq'
}

$resolvedRoot = (Resolve-Path -LiteralPath $SkillRoot).Path
$failures = [System.Collections.Generic.List[string]]::new()

function Add-Failure {
    param([string]$Message)
    $failures.Add($Message)
}

$requiredFiles = @(
    'SKILL.md',
    'references\question-bank.md',
    'references\spec-template.md'
)

foreach ($relativePath in $requiredFiles) {
    $fullPath = Join-Path $resolvedRoot $relativePath
    if (-not (Test-Path -LiteralPath $fullPath -PathType Leaf)) {
        Add-Failure "Missing required file: $relativePath"
    }
}

$skillPath = Join-Path $resolvedRoot 'SKILL.md'
if (Test-Path -LiteralPath $skillPath -PathType Leaf) {
    $skillBytes = [System.IO.File]::ReadAllBytes($skillPath)
    $hasBom = $skillBytes.Length -ge 3 -and
        $skillBytes[0] -eq 0xEF -and
        $skillBytes[1] -eq 0xBB -and
        $skillBytes[2] -eq 0xBF

    if ($hasBom) {
        Add-Failure 'SKILL.md has a UTF-8 BOM before the YAML frontmatter.'
    }

    try {
        $strictUtf8 = [System.Text.UTF8Encoding]::new($false, $true)
        $skillText = $strictUtf8.GetString($skillBytes)
    }
    catch {
        Add-Failure "SKILL.md is not valid UTF-8: $($_.Exception.Message)"
        $skillText = ''
    }

    if ($skillText) {
        $skillLines = $skillText -split "\r?\n"
        if ($skillLines[0] -ne '---') {
            Add-Failure 'SKILL.md must start with the YAML delimiter ---.'
        }

        $frontmatterEnd = -1
        for ($index = 1; $index -lt $skillLines.Count; $index++) {
            if ($skillLines[$index] -eq '---') {
                $frontmatterEnd = $index
                break
            }
        }

        if ($frontmatterEnd -lt 0) {
            Add-Failure 'Missing the closing YAML frontmatter delimiter.'
        }
        else {
            $frontmatterKeys = @()
            for ($index = 1; $index -lt $frontmatterEnd; $index++) {
                if ($skillLines[$index] -match '^([A-Za-z0-9_-]+):') {
                    $frontmatterKeys += $Matches[1]
                }
            }

            foreach ($requiredKey in @('name', 'description')) {
                if ($frontmatterKeys -notcontains $requiredKey) {
                    Add-Failure "Missing frontmatter key: $requiredKey"
                }
            }

            $unexpectedKeys = $frontmatterKeys |
                Where-Object { $_ -notin @('name', 'description') }
            if ($unexpectedKeys) {
                Add-Failure "Unsupported frontmatter keys: $($unexpectedKeys -join ', ')"
            }

            $nameLine = $skillLines |
                Select-String -Pattern '^name:\s*(.+)$' |
                Select-Object -First 1
            if (-not $nameLine -or $nameLine.Matches[0].Groups[1].Value.Trim() -ne 'rdq') {
                Add-Failure 'The Skill name must be rdq.'
            }
        }

        if ($skillLines.Count -gt 500) {
            Add-Failure "SKILL.md has $($skillLines.Count) lines; the limit is 500."
        }

        $referenceMatches = [regex]::Matches(
            $skillText,
            'references/[A-Za-z0-9._/-]+\.md'
        )
        $referencePaths = $referenceMatches |
            ForEach-Object { $_.Value } |
            Sort-Object -Unique
        foreach ($referencePath in $referencePaths) {
            $windowsPath = $referencePath.Replace('/', '\')
            if (-not (Test-Path -LiteralPath (Join-Path $resolvedRoot $windowsPath))) {
                Add-Failure "Missing referenced file: $referencePath"
            }
        }
    }
}

$runtimePaths = @(
    (Join-Path $resolvedRoot 'SKILL.md'),
    (Join-Path $resolvedRoot 'references\question-bank.md'),
    (Join-Path $resolvedRoot 'references\spec-template.md')
)
$platformBoundPatterns = @(
    'AskUserQuestion',
    'WebSearch',
    'html-slide-builder',
    'soil-html-deck',
    'soil-image-deck',
    'soil-teaching-deck',
    'lesson-prep',
    'teaching-cockpit',
    'teaching-minigames',
    'yt-pack',
    'seedance'
)

foreach ($runtimePath in $runtimePaths) {
    if (-not (Test-Path -LiteralPath $runtimePath -PathType Leaf)) {
        continue
    }

    foreach ($pattern in $platformBoundPatterns) {
        $matches = Select-String -LiteralPath $runtimePath -Pattern $pattern -Encoding UTF8
        foreach ($match in $matches) {
            Add-Failure "Platform-bound runtime token: $($match.Path):$($match.LineNumber) [$pattern]"
        }
    }
}

$questionBankPath = Join-Path $resolvedRoot 'references\question-bank.md'
if (Test-Path -LiteralPath $questionBankPath -PathType Leaf) {
    $questionBankText = [System.IO.File]::ReadAllText(
        $questionBankPath,
        [System.Text.Encoding]::UTF8
    )
    $tocLinkCount = [regex]::Matches(
        $questionBankText,
        '(?m)^- \[[^\]]+\]\(#[^)]+\)$'
    ).Count
    if ($tocLinkCount -lt 6) {
        Add-Failure 'question-bank.md must contain a table of contents.'
    }
}

if ($failures.Count -gt 0) {
    Write-Host "RDQ Skill validation failed ($($failures.Count) issue(s)):" -ForegroundColor Red
    foreach ($failure in $failures) {
        Write-Host "  - $failure" -ForegroundColor Red
    }
    exit 1
}

Write-Host 'RDQ Skill validation passed.' -ForegroundColor Green
Write-Host "  Source: $resolvedRoot"
Write-Host "  Runtime: $($requiredFiles -join ', ')"
exit 0
