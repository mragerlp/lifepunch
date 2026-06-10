# Start the VENGEANCE-side watcher for Cornerman "Talk to Vengeance" relay.
# Leave this window open while brainstorming. Cornerman desktop shortcut captures voice;
# this script auto-copies new transcripts to clipboard (Cornerman TTS is the audio cue).

$watch = Join-Path $PSScriptRoot 'watch-cornerman-voice.ps1'
Write-Host 'Voice brainstorm mode ON' -ForegroundColor Green
Write-Host '  Cornerman: tap F7 to arm, wait for Ready, hold F8, release' -ForegroundColor DarkGray
Write-Host '  VENGEANCE: when clipboard updates, Ctrl+V into Cursor' -ForegroundColor DarkGray
Write-Host '  Tip: use LifePunch Voice Comms shortcut to start sync + watch together' -ForegroundColor DarkGray
Write-Host ''
& $watch
