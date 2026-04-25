#Requires -Version 5.1
# Optional: Reliability history summary (may be slow).
Get-WinEvent -LogName Microsoft-Windows-Diagnostics-Performance/Operational -MaxEvents 5 -ErrorAction SilentlyContinue |
  Format-List TimeCreated, Id, Message
