# Start the VENGEANCE-side watcher for Cornerman "Talk to Vengeance" relay.
# Leave this window open while brainstorming. Cornerman desktop shortcut captures voice;
# this script auto-copies new transcripts to clipboard (Cornerman TTS is the audio cue).

. (Join-Path $PSScriptRoot 'Voice-Console.ps1')
$script:VoiceConsoleAccent = 'Cyan'
$watch = Join-Path $PSScriptRoot 'watch-cornerman-voice.ps1'
Write-Host 'Voice brainstorm mode ON' -ForegroundColor Cyan
Write-VoiceMuted 'Cornerman: Talk to Vengeance window open - F7 arm, Ready, hold F8, release'
Write-VoiceMuted 'VENGEANCE (this window): copies new transcripts to clipboard - Ctrl+V in Cursor'
Write-VoiceMuted 'Tip: LifePunch Voice Comms shortcut starts sync + watch together'
Write-Host ''
& $watch
