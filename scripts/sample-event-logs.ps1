#Requires -Version 5.1
# Optional: sample Application / System log errors (last 24h). Review for PII before sharing.
param([int]$Hours = 24)
$start = (Get-Date).AddHours(-$Hours)
Get-WinEvent -FilterHashtable @{ LogName = 'Application'; Level = 2,3; StartTime = $start } -MaxEvents 40 -ErrorAction SilentlyContinue |
  Format-Table TimeCreated, Id, ProviderName, Message -Wrap
