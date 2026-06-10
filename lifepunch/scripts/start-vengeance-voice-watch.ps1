# Start the VENGEANCE-side watcher for Cornerman "Talk to Vengeance" relay.
# Leave this window open while brainstorming. Cornerman desktop shortcut captures voice;
# this script auto-copies new transcripts to clipboard (Cornerman TTS is the audio cue).

$watch = Join-Path $PSScriptRoot 'watch-cornerman-voice.ps1'
Write-Host 'Voice brainstorm mode ON' -ForegroundColor Green
Write-Host '  Cornerman: Talk to Vengeance - say "send message", then your idea' -ForegroundColor DarkGray
Write-Host '  VENGEANCE: when Cornerman says paste, Ctrl+V into Cursor' -ForegroundColor DarkGray
Write-Host '  Also run start-session-sync.ps1 in a second window to archive logs on lifepunchnet' -ForegroundColor DarkGray
Write-Host ''
& $watch
