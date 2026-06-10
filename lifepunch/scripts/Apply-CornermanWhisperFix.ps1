# Patch Cornerman voice relay to use lifepunchnet Whisper by default (run on Cornerman).
# Fixes: unused LIFEPUNCHNET_WHISPER_DEFAULT, wrong model (Whisper-Small), dead Lemonade fallback.

param(
    [string] $CornermanRag = 'C:\Projects\cornerman-rag'
)

$ErrorActionPreference = 'Stop'
$relayPy = Join-Path $CornermanRag 'relay.py'
$relayPs1 = Join-Path $CornermanRag 'relay.ps1'
if (-not (Test-Path -LiteralPath $relayPy)) { throw "Missing $relayPy" }

$py = Get-Content -LiteralPath $relayPy -Raw -Encoding UTF8

if ($py -notmatch 'LIFEPUNCHNET_WHISPER_DEFAULT') {
    throw 'relay.py missing LIFEPUNCHNET_WHISPER_DEFAULT — unexpected version'
}

$py = $py.Replace(
    'remote = (remote_url or REMOTE_WHISPER_URL).strip()',
    'remote = (remote_url or REMOTE_WHISPER_URL or LIFEPUNCHNET_WHISPER_DEFAULT).strip()'
)

if ($py -notmatch 'REMOTE_WHISPER_MODEL') {
    $py = $py.Replace(
        'LEMONADE_MODEL = os.environ.get("CORNERMAN_LEMONADE_MODEL", "Whisper-Small")',
        @'
LEMONADE_MODEL = os.environ.get("CORNERMAN_LEMONADE_MODEL", "Whisper-Small")
REMOTE_WHISPER_MODEL = os.environ.get("CORNERMAN_REMOTE_WHISPER_MODEL", "small.en")
'@
    )
}

$py = $py.Replace(
@'
    data = {"model": LEMONADE_MODEL}
    r = requests.post(url, files=files, data=data, timeout=30)
'@,
@'
    data = {"model": REMOTE_WHISPER_MODEL}
    r = requests.post(url, files=files, data=data, timeout=120)
'@
)

$py = $py.Replace(
@'
            ui.warn(f"  lifepunchnet unreachable ({exc}); using Lemonade")
            log_stt_path("lemonade-fallback", LEMONADE_URL)
            return transcribe_lemonade(audio)
'@,
@'
            ui.warn(f"  lifepunchnet unreachable ({exc}); using local Whisper")
            log_stt_path("local-fallback", "stt.py")
            return transcribe_local(audio)
'@
)

if ($py -match 'remote = \(args\.remote_whisper or ""\)\.strip\(\)') {
    $py = $py.Replace(
        'remote = (args.remote_whisper or "").strip()',
        'remote = (args.remote_whisper or REMOTE_WHISPER_URL or LIFEPUNCHNET_WHISPER_DEFAULT).strip()'
    )
}

Set-Content -LiteralPath $relayPy -Value $py -Encoding UTF8 -NoNewline

$envBlock = @'
$env:CORNERMAN_REMOTE_WHISPER_URL = 'http://205.209.104.22:9000/v1/audio/transcriptions'
$env:CORNERMAN_REMOTE_WHISPER_MODEL = 'small.en'

'@

if (Test-Path -LiteralPath $relayPs1) {
    $ps1 = Get-Content -LiteralPath $relayPs1 -Raw -Encoding UTF8
    if ($ps1 -notmatch 'CORNERMAN_REMOTE_WHISPER_MODEL') {
        $ps1 = $ps1.Replace(
            "`$ErrorActionPreference = 'Stop'",
            "`$ErrorActionPreference = 'Stop'`r`n$envBlock"
        )
    }
    $ps1 = $ps1.Replace(
@'
} elseif (-not $SelfTest) {
    $pyArgs += '--lemonade'
}
'@,
@'
}
'@
    )
    Set-Content -LiteralPath $relayPs1 -Value $ps1 -Encoding UTF8 -NoNewline
}

[Environment]::SetEnvironmentVariable(
    'CORNERMAN_REMOTE_WHISPER_URL',
    'http://205.209.104.22:9000/v1/audio/transcriptions',
    'User'
)
[Environment]::SetEnvironmentVariable('CORNERMAN_REMOTE_WHISPER_MODEL', 'small.en', 'User')

Write-Host 'Cornerman relay patched for lifepunchnet Whisper (small.en).' -ForegroundColor Green
Write-Host 'Restart Talk to Vengeance on Cornerman.' -ForegroundColor Cyan
