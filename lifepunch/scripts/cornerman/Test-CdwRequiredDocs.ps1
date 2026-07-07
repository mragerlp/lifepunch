# =====================================================================
# RISK: READ-ONLY TEST (temp fixtures only)  |  drift-scanner Slice 1 (Part A)
# NODE: Red (VENGEANCE) -- runs anywhere the repo is checked out
# WHAT: Mock test harness for inputs.requiredDocs (canon loader). Fixture-
#       based, no live model -- mirrors the Slice 1-3 dry-run style. Exercises
#       Get-CdwPackedInputs / Test-CdwInputPaths / Invoke-CdwInputContentScan /
#       Build-CdwModelRequest / New-CornermanTaskPacket. Prints PASS/FAIL and
#       exits non-zero on any failure. Case 10 (live model) is deferred to Part B.
# USAGE:
#   powershell -NoProfile -ExecutionPolicy Bypass -File Test-CdwRequiredDocs.ps1
# =====================================================================
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$here = $PSScriptRoot
. (Join-Path $here 'CornermanDropWorker.Lib.ps1')

$script:pass = 0; $script:fail = 0
function Assert($cond, $name) {
  if ($cond) { $script:pass++; Write-Output "  PASS  $name" }
  else { $script:fail++; Write-Output "  FAIL  $name" }
}
function New-TestPacket($inputsHash, $profileName = 'lifepunch-private') {
  $p = @{
    inputs = $inputsHash; instruction = 'compare specs against canon and report drift'
    deliverable = @{ outboxName = 'OUT'; format = 'markdown' }
    forbiddenScope = @(); repoProfile = $profileName
  }
  return ($p | ConvertTo-Json -Depth 8 | ConvertFrom-Json)
}

# ---- fixtures ----
$tmp = Join-Path $env:TEMP ('cdw-reqdocs-' + [guid]::NewGuid().ToString('N').Substring(0,8))
New-Item -ItemType Directory -Force -Path $tmp | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $tmp 'docs') | Out-Null
Set-Content -LiteralPath (Join-Path $tmp 'canon.md')        -Value "# Canon`nRed RAM = 64GB unified`n" -NoNewline -Encoding utf8
Set-Content -LiteralPath (Join-Path $tmp 'target_clean.md') -Value "# Target`nRed RAM = 64GB unified`n" -NoNewline -Encoding utf8
Set-Content -LiteralPath (Join-Path $tmp 'big.md')          -Value ('x' * 5000) -NoNewline -Encoding utf8
Set-Content -LiteralPath (Join-Path $tmp 'docs\canon_blocked.md') -Value "# Ref`nSee LIFEPUNCH private doctrine`n" -NoNewline -Encoding utf8

$priv = [pscustomobject]@{ cloneWindows = $tmp; focus = 'LifePunch' }
$dxrp = [pscustomobject]@{ cloneWindows = $tmp; focus = 'DXRP'; forbidInputPrefixes = @('lifepunch/','lifepunchaddons/','lifepunchdxrp/') }
$config = @{ request = @{ temperature = 0.2; maxTokens = 4096; maxPromptChars = 120000 } } | ConvertTo-Json | ConvertFrom-Json
$NL = [Environment]::NewLine

Write-Output "== Case 1: pack separation (canon vs drift, distinct delimiters + prompt order) =="
$pk = New-TestPacket @{ requiredDocs = @('canon.md'); readFiles = @('target_clean.md'); maxBytes = 400000 }
$r = Get-CdwPackedInputs -Packet $pk -Profile $priv -GlobFiles @() -MaxPromptChars 120000
Assert ($r.Ok) 'C1 pack ok'
Assert ($r.ReferenceText -match '=== CANON/REFERENCE: canon\.md') 'C1 canon delimiter present'
Assert ($r.PackedText -match '=== FILE: target_clean\.md') 'C1 drift delimiter present'
Assert ($r.ReferenceText -notmatch 'target_clean') 'C1 canon block excludes drift file'
$req = Build-CdwModelRequest -Packet $pk -ProfileName 'lifepunch-private' -ModelId 'm' -PackedInputs $r.PackedText -ReferenceInputs $r.ReferenceText -Config $config
$ic = $req.UserPrompt.IndexOf('CANON / REFERENCE (authoritative'); $id = $req.UserPrompt.IndexOf('INPUT FILES (drift targets')
Assert ($ic -ge 0 -and $id -gt $ic) 'C1 canon precedes drift in prompt'
Assert ($req.SystemPrompt -match 'Treat canon as the source of truth') 'C1 system canon line present'

Write-Output "== Case 2: requiredDocs bytes count toward maxBytes =="
$pk = New-TestPacket @{ requiredDocs = @('big.md'); readFiles = @('target_clean.md'); maxBytes = 3000 }
$r = Get-CdwPackedInputs -Packet $pk -Profile $priv -GlobFiles @() -MaxPromptChars 120000
Assert (-not $r.Ok) 'C2 fails closed on maxBytes'
Assert (($r.Errors -join '|') -match 'exceed inputs\.maxBytes' -and ($r.Errors -join '|') -match 'requiredDocs') 'C2 error names maxBytes + requiredDocs'

Write-Output "== Case 3 (SAFETY): over-cap fail-closed on maxPromptChars, no truncation =="
$pk = New-TestPacket @{ requiredDocs = @('canon.md'); readFiles = @('target_clean.md'); maxBytes = 400000 }
$r = Get-CdwPackedInputs -Packet $pk -Profile $priv -GlobFiles @() -MaxPromptChars 30
Assert (-not $r.Ok) 'C3 fails closed over prompt ceiling'
Assert (($r.Errors -join '|') -match 'exceeds prompt context ceiling' -and ($r.Errors -join '|') -match 'canon \+ drift-targets') 'C3 error names ceiling + canon'
Assert (($r.ReferenceText.Length + $r.PackedText.Length) -gt 30) 'C3 content NOT truncated (full length retained)'

Write-Output "== Case 4 (SAFETY): path safety on requiredDocs (absolute / .. / forbid-prefix) =="
$r = Test-CdwInputPaths -Packet (New-TestPacket @{ requiredDocs = @('C:\evil.md'); readFiles = @('target_clean.md'); maxBytes = 400000 }) -Profile $priv
Assert (($r.Errors -join '|') -match 'absolute rejected') 'C4a absolute canon path rejected'
$r = Test-CdwInputPaths -Packet (New-TestPacket @{ requiredDocs = @('../evil.md'); readFiles = @('target_clean.md'); maxBytes = 400000 }) -Profile $priv
Assert (($r.Errors -join '|') -match "traversal") 'C4b traversal canon path rejected'
$r = Test-CdwInputPaths -Packet (New-TestPacket @{ requiredDocs = @('lifepunch/secret.md'); readFiles = @('target_clean.md'); maxBytes = 400000 } 'dxrp-official') -Profile $dxrp
Assert (($r.Errors -join '|') -match 'forbidden prefix') 'C4c dxrp-official private-canon prefix rejected (SMUGGLE HOLE CLOSED)'

Write-Output "== Case 5: missing canon file fails closed =="
$pk = New-TestPacket @{ requiredDocs = @('nope.md'); readFiles = @('target_clean.md'); maxBytes = 400000 }
$r = Get-CdwPackedInputs -Packet $pk -Profile $priv -GlobFiles @() -MaxPromptChars 120000
Assert (-not $r.Ok) 'C5 missing canon fails closed'
Assert (($r.Errors -join '|') -match 'required canon doc not found in clone') 'C5 error message'

Write-Output "== Case 7 (SAFETY): backward-compat -- no requiredDocs => byte-identical prompt =="
$pk = New-TestPacket @{ readFiles = @('target_clean.md'); maxBytes = 400000 }
$r = Get-CdwPackedInputs -Packet $pk -Profile $priv -GlobFiles @() -MaxPromptChars 120000
Assert ($r.ReferenceText -eq '') 'C7 no canon -> empty ReferenceText'
$req = Build-CdwModelRequest -Packet $pk -ProfileName 'lifepunch-private' -ModelId 'm' -PackedInputs $r.PackedText -ReferenceInputs $r.ReferenceText -Config $config
Assert ($req.UserPrompt.EndsWith('INPUT FILES:' + $NL + $r.PackedText)) 'C7 prompt tail byte-identical (plain INPUT FILES: + packed)'
Assert ($req.UserPrompt -notmatch 'CANON / REFERENCE') 'C7 no canon header emitted'
Assert ($req.UserPrompt -notmatch 'drift targets') 'C7 no drift-targets label emitted'
Assert ($req.SystemPrompt -notmatch 'Treat canon as the source of truth') 'C7 no canon system line emitted'

Write-Output "== Case 8 (SAFETY): dxrp-official canon contents scanned (defense-in-depth) =="
$pk = New-TestPacket @{ requiredDocs = @('docs/canon_blocked.md'); readFiles = @('target_clean.md'); maxBytes = 400000 } 'dxrp-official'
$r = Invoke-CdwInputContentScan -Packet $pk -Profile $dxrp -GlobFiles @() -GlobsExpanded $true
Assert (-not $r.Ok) 'C8 dxrp canon content scan blocks'
Assert (($r.Failures -join '|') -match 'canon_blocked\.md' -and ($r.Failures -join '|') -match 'LIFEPUNCH') 'C8 blocked token in canon flagged'
Assert (@($r.ScannedFiles) -contains 'docs/canon_blocked.md') 'C8 canon file was actually scanned'

Write-Output "== Case 6 & 9: builder subprocess (exit codes) =="
$script = (Join-Path $here 'New-CornermanTaskPacket.ps1')
$outDir = Join-Path $tmp 'packets'
$o6 = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $script -RepoProfile lifepunch-private -RouteTag 'GREEN DEEP REQUIRED' -Instruction 'compare specs against canon' -RequiredDocs docs/canon.md -OutputDir $outDir 2>&1
Assert ($LASTEXITCODE -ne 0 -and (($o6 -join '|') -match 'at least one of -ReadFiles')) 'C6 requiredDocs alone rejected (anyOf preserved)'
$o9 = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $script -RepoProfile lifepunch-private -RouteTag 'GREEN DEEP REQUIRED' -Type audit -Instruction 'compare specs against canon and report drift' -RequiredDocs docs/canon.md -ReadFiles target_clean.md -OutputDir $outDir 2>&1
Assert ($LASTEXITCODE -eq 0 -and (($o9 -join '|') -match 'OK: packet written')) 'C9 builder writes schema-valid packet'
$pkFile = Get-ChildItem $outDir -Filter '*.json' | Select-Object -First 1
$json = Get-Content $pkFile.FullName -Raw | ConvertFrom-Json
Assert (@($json.inputs.requiredDocs) -contains 'docs/canon.md') 'C9 packet carries inputs.requiredDocs'
Assert ($json.mode -eq 'report' -and $json.constraints.noPatch -eq $true) 'C9 packet is report-mode / noPatch (flags only)'

Write-Output "== Case 11: GREEN DAILY route (tag validates + resolves) =="
$o11 = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $script -RepoProfile lifepunch-private -RouteTag 'GREEN DAILY REQUIRED' -Type audit -Slug 'daily-route-case' -Instruction 'compare specs against canon and report drift' -ReadFiles target_clean.md -OutputDir $outDir 2>&1
Assert ($LASTEXITCODE -eq 0 -and (($o11 -join '|') -match 'OK: packet written')) 'C11 builder accepts GREEN DAILY REQUIRED (ValidateSet + schema)'
$dailyCfg = '{"routes":{"GREEN DEEP REQUIRED":"qwen/qwen3.6-27b","GREEN DAILY REQUIRED":"qwen/qwen3.6-35b-a3b","GREEN CODE REQUIRED":"qwen2.5-coder-32b-instruct"}}' | ConvertFrom-Json
$dailyPk = '{"routeTag":"GREEN DAILY REQUIRED","modelCall":{"enabled":true,"requiredModel":null,"allowFallback":false}}' | ConvertFrom-Json
$r11 = Resolve-CdwModelRoute -Packet $dailyPk -Config $dailyCfg
Assert ($r11.Ok -and $r11.ModelId -eq 'qwen/qwen3.6-35b-a3b') 'C11 Daily tag resolves to qwen/qwen3.6-35b-a3b'

Write-Output "== Case 10: live 27b audit run =="
Write-Output "  SKIP  C10 real model run -- deferred to Part B (separate GO)"

Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue
Write-Output ""
Write-Output ("RESULT: {0} PASS / {1} FAIL  (C10 deferred to Part B)" -f $script:pass, $script:fail)
if ($script:fail -gt 0) { exit 1 } else { exit 0 }
