<#
.SYNOPSIS
    Scheduled read-only repo scans for Green on CORNERMAN (localhost LM Studio).

.DESCRIPTION
    Canon: lifepunch/docs/cvl/GREEN_AUTONOMOUS_SCAN_2026-07-14.md
    Ruling: comms\copilot\0013

    Pulls Green clone to develop, runs four scan types against
    qwen/qwen3.6-27b on 127.0.0.1:1234, writes ADVICE-class results to
    C:\lifepunch\cornerman\OUTBOX\scans\ only.

    Read-only on the clone. No commit/push/merge/tag. Findings are NOT
    work orders. Fast-fail on error or timeout >120s.

.PARAMETER Interval
    Minutes between loop iterations. Default 15. Minimum 5.

.PARAMETER Once
    Run one full scan pass and exit (no sleep loop).

.PARAMETER ClonePath
    Green read-only clone root. Default C:\lifepunch\greenclone

.PARAMETER OutboxScans
    Scan result directory. Default C:\lifepunch\cornerman\OUTBOX\scans

.PARAMETER BaseUrl
    LM Studio base (no /v1). Default http://127.0.0.1:1234

.PARAMETER Model
    Model id. Default qwen/qwen3.6-27b

.PARAMETER TimeoutSec
    Per-request timeout. Default 120 (ruling fast-fail).

.EXAMPLE
    powershell -File lifepunch\scripts\cornerman-scan.ps1 -Once

.EXAMPLE
    powershell -File lifepunch\scripts\cornerman-scan.ps1 -Interval 15
#>
[CmdletBinding()]
param(
    [ValidateRange(5, 1440)]
    [int] $Interval = 15,

    [switch] $Once,

    [string] $ClonePath = 'C:\lifepunch\greenclone',

    [string] $OutboxScans = 'C:\lifepunch\cornerman\OUTBOX\scans',

    [string] $BaseUrl = 'http://127.0.0.1:1234',

    [string] $Model = 'qwen/qwen3.6-27b',

    [ValidateRange(10, 120)]
    [int] $TimeoutSec = 120
)

$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
function Write-ScanOutbox {
    param(
        [Parameter(Mandatory)] [string] $Type,
        [Parameter(Mandatory)] [string] $Body,
        [switch] $IsError
    )
    if (-not (Test-Path -LiteralPath $OutboxScans)) {
        New-Item -ItemType Directory -Force -Path $OutboxScans | Out-Null
    }
    $utc = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHHmmssZ')
    $safe = ($Type -replace '[^A-Za-z0-9_-]', '_').ToUpperInvariant()
    $name = if ($IsError) { "SCAN_${safe}_ERROR_$utc.md" } else { "SCAN_${safe}_$utc.md" }
    $path = Join-Path $OutboxScans $name
    $header = @(
        'ADVICE, NOT A WORK ORDER'
        ''
        "# SCAN $safe"
        ''
        "- UTC: $utc"
        "- Model: $Model"
        "- Clone: $ClonePath"
        "- Class: Green advisory (GREEN_AUTONOMOUS_SCAN_2026-07-14)"
        ''
        '---'
        ''
    ) -join "`n"
    $text = $header + $Body.TrimEnd() + "`n"
    [System.IO.File]::WriteAllText($path, $text, [System.Text.UTF8Encoding]::new($false))
    Write-Host "[outbox] $path" -ForegroundColor DarkGray
    return $path
}

function Invoke-CornermanChat {
    param([Parameter(Mandatory)] [string] $Prompt)

    # Residency preflight (same sensor law as ask-cornerman.ps1)
    $catalog = Invoke-RestMethod -Uri "$BaseUrl/api/v0/models" -TimeoutSec 20
    $target = $catalog.data | Where-Object { $_.id -eq $Model }
    if (-not $target) {
        $known = ($catalog.data | ForEach-Object { $_.id }) -join ', '
        throw "Model '$Model' not installed. Installed: $known"
    }
    if ($target.state -ne 'loaded') {
        throw "CONSULT REFUSED - model '$Model' state=$($target.state) (need loaded)"
    }

    $payload = @{
        model       = $Model
        messages    = @(@{ role = 'user'; content = $Prompt })
        temperature = 0.2
        max_tokens  = 2048
    } | ConvertTo-Json -Depth 6

    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    try {
        $reply = Invoke-RestMethod -Uri "$BaseUrl/v1/chat/completions" `
            -Method Post `
            -ContentType 'application/json; charset=utf-8' `
            -Body ([System.Text.Encoding]::UTF8.GetBytes($payload)) `
            -TimeoutSec $TimeoutSec
    }
    catch {
        throw "Chat failed after $([math]::Round($sw.Elapsed.TotalSeconds,1))s - $($_.Exception.Message)"
    }
    $sw.Stop()
    if ($sw.Elapsed.TotalSeconds -gt $TimeoutSec) {
        throw "Chat exceeded ${TimeoutSec}s fast-fail"
    }

    $content = $reply.choices[0].message.content
    if ([string]::IsNullOrWhiteSpace($content)) {
        throw 'Empty model response'
    }
    return $content
}

function Get-ContextSnippet {
    param([Parameter(Mandatory)] [scriptblock] $Block)
    try {
        $out = & $Block 2>&1 | Out-String
        if ($out.Length -gt 24000) {
            return $out.Substring(0, 24000) + "`n...[truncated]..."
        }
        return $out
    }
    catch {
        return "[context gather failed: $($_.Exception.Message)]"
    }
}

function Update-GreenClone {
    if (-not (Test-Path -LiteralPath (Join-Path $ClonePath '.git'))) {
        throw "ClonePath is not a git repo: $ClonePath"
    }
    Push-Location $ClonePath
    try {
        $branch = (git branch --show-current).Trim()
        Write-Host "[git] branch=$branch pull --rebase origin develop" -ForegroundColor DarkGray
        git fetch origin develop
        git pull --rebase origin develop
        if ($LASTEXITCODE -ne 0) {
            throw "git pull --rebase failed (exit $LASTEXITCODE)"
        }
    }
    finally {
        Pop-Location
    }
}

function Invoke-ScanPass {
    Update-GreenClone

    $scans = @(
        @{
            Type    = 'stale-docs'
            Context = {
                Push-Location $ClonePath
                try {
                    "=== recent docs ==="
                    git log --since='90 days ago' --name-only --pretty=format: -- '**/docs/**/*.md' 'CLAUDE.md' 'AGENTS.md' |
                        Where-Object { $_ } | Sort-Object -Unique | Select-Object -First 80
                    "=== grep superseded markers (sample) ==="
                    rg -n -i "START_HERE_AGENTS|superseded|DEPRECATED|TODO\(remove\)|obsolete" `
                        --glob '*.md' -g '!handoff/**' -g '!**/node_modules/**' `
                        -m 40 . 2>$null
                }
                finally { Pop-Location }
            }
            Prompt  = @'
You are Green (advisory-only) scanning a LIFEPUNCH monorepo clone for STALE DOCS.
Read the CONTEXT below. List concrete risks: superseded paths, wrong seat names,
pointers to deleted files, or canon drift. Prefer file paths that appear in CONTEXT.
Do not invent sensors. Do not propose patches. Output short bullets.
'@
        }
        @{
            Type    = 'pattern-lint'
            Context = {
                Push-Location $ClonePath
                try {
                    "=== AI attribution / trailer markers (tracked text) ==="
                    rg -n -i "Co-authored-by:\s*Cursor|cursoragent|Generated with|Made with Cursor|Assisted-by:" `
                        --glob '!**/node_modules/**' --glob '!**/.git/**' -m 40 . 2>$null
                    "=== credential-shaped tokens (paths only; do not echo secrets) ==="
                    rg -n -i "sk-[a-zA-Z0-9]{10,}|ghp_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|BEGIN (RSA |OPENSSH )?PRIVATE KEY" `
                        --glob '!**/.env' --glob '!**/*credential*' --glob '!**/node_modules/**' -m 20 . 2>$null |
                        ForEach-Object { ($_ -split ':')[0..1] -join ':' }
                }
                finally { Pop-Location }
            }
            Prompt  = @'
You are Green (advisory-only) running PATTERN LINT on LIFEPUNCH.
From CONTEXT, flag AI attribution trailers, credential-shaped hits, or banned
agent self-praise. Cite path:line only when present in CONTEXT. Never invent
secrets. Never request .env. Short bullets only.
'@
        }
        @{
            Type    = 'skill-parity'
            Context = {
                Push-Location $ClonePath
                try {
                    $claude = @()
                    $agents = @()
                    if (Test-Path .claude\skills) {
                        $claude = Get-ChildItem .claude\skills -Directory | ForEach-Object { $_.Name } | Sort-Object
                    }
                    if (Test-Path .agents\skills) {
                        $agents = Get-ChildItem .agents\skills -Directory | ForEach-Object { $_.Name } | Sort-Object
                    }
                    "=== .claude/skills ($($claude.Count)) ==="
                    $claude -join "`n"
                    "=== .agents/skills ($($agents.Count)) ==="
                    $agents -join "`n"
                    "=== only in .claude ==="
                    (Compare-Object $claude $agents | Where-Object SideIndicator -eq '<=' | ForEach-Object InputObject) -join "`n"
                    "=== only in .agents ==="
                    (Compare-Object $claude $agents | Where-Object SideIndicator -eq '=>' | ForEach-Object InputObject) -join "`n"
                }
                finally { Pop-Location }
            }
            Prompt  = @'
You are Green (advisory-only) checking SKILL PARITY between .claude/skills and
.agents/skills (paired surfaces law). From CONTEXT, list missing mirrors and
whether that is expected for harness-specific skills. Short bullets. No edits.
'@
        }
        @{
            Type    = 'branch-hygiene'
            Context = {
                Push-Location $ClonePath
                try {
                    git fetch origin --prune 2>&1 | Out-String
                    "=== HEAD ==="
                    git log -1 --oneline --decorate
                    "=== remote branches (merged into origin/develop) ==="
                    git branch -r --merged origin/develop | Select-Object -First 40
                    "=== remote branches (NOT merged into origin/develop) ==="
                    git branch -r --no-merged origin/develop | Select-Object -First 40
                    "=== develop tip ==="
                    git rev-parse --short origin/develop
                }
                finally { Pop-Location }
            }
            Prompt  = @'
You are Green (advisory-only) reviewing BRANCH HYGIENE for LIFEPUNCH.
From CONTEXT, note stale remote branches, odd naming, or risk that develop
looks conflicted. Do not suggest force-push. Short bullets. Advice only.
'@
        }
    )

    foreach ($scan in $scans) {
        $type = $scan.Type
        Write-Host "[scan] $type" -ForegroundColor Cyan
        try {
            $ctx = Get-ContextSnippet -Block $scan.Context
            $fullPrompt = @"
$($scan.Prompt)

Begin every answer with the exact line:
ADVICE, NOT A WORK ORDER

CONTEXT:
$ctx
"@
            $answer = Invoke-CornermanChat -Prompt $fullPrompt
            if ($answer -notmatch '(?m)^ADVICE, NOT A WORK ORDER') {
                $answer = "ADVICE, NOT A WORK ORDER`n`n" + $answer
            }
            Write-ScanOutbox -Type $type -Body $answer | Out-Null
        }
        catch {
            $err = $_.Exception.Message
            Write-Host "[scan-fail] $type : $err" -ForegroundColor Red
            Write-ScanOutbox -Type $type -IsError -Body "ERROR: $err`nAborting remaining scans this pass (fast-fail)." | Out-Null
            throw
        }
    }
}

# ---------------------------------------------------------------------------
# Overlap guard (no concurrent passes)
# ---------------------------------------------------------------------------
$lockPath = Join-Path $env:TEMP 'lifepunch-cornerman-scan.lock'
if (Test-Path -LiteralPath $lockPath) {
    $age = (Get-Date) - (Get-Item -LiteralPath $lockPath).LastWriteTime
    if ($age.TotalMinutes -lt ($Interval + 5)) {
        throw "Another cornerman-scan appears active (lock $lockPath age $([math]::Round($age.TotalMinutes,1))m). No overlap."
    }
    Remove-Item -LiteralPath $lockPath -Force -ErrorAction SilentlyContinue
}
New-Item -ItemType File -Path $lockPath -Force | Out-Null

try {
    do {
        $passStarted = Get-Date
        Write-Host "[pass] start $($passStarted.ToUniversalTime().ToString('o'))" -ForegroundColor Green
        try {
            Invoke-ScanPass
            Write-Host '[pass] complete' -ForegroundColor Green
        }
        catch {
            # Error note already written per scan; continue loop unless -Once
            Write-Host "[pass] aborted: $($_.Exception.Message)" -ForegroundColor Yellow
            if ($Once) { throw }
        }

        if ($Once) { break }

        $elapsedMin = ((Get-Date) - $passStarted).TotalMinutes
        $sleepMin = [math]::Max(0, $Interval - $elapsedMin)
        Write-Host "[sleep] ${sleepMin}m until next pass (Interval=$Interval)" -ForegroundColor DarkGray
        Start-Sleep -Seconds ([int][math]::Ceiling($sleepMin * 60))
    } while (-not $Once)
}
finally {
    Remove-Item -LiteralPath $lockPath -Force -ErrorAction SilentlyContinue
}
