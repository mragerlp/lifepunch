# Start the VENGEANCE-side watcher for Cornerman "Talk to Vengeance" relay.
# Leave this window open while brainstorming. Cornerman desktop shortcut captures voice;
# this script auto-copies new transcripts to clipboard (Cornerman TTS is the audio cue).

$watch = Join-Path $PSScriptRoot 'watch-cornerman-voice.ps1'
Write-Host 'Voice brainstorm mode ON' -ForegroundColor Cyan
Write-Host '  Cornerman: Talk to Vengeance window open — F7 arm, Ready, hold F8, release' -ForegroundColor Gray
Write-Host '  VENGEANCE (this window): copies new transcripts to clipboard — Ctrl+V in Cursor' -ForegroundColor Gray
Write-Host '  Tip: LifePunch Voice Comms shortcut starts sync + watch together' -ForegroundColor DarkGray
Write-Host ''
& $watch
