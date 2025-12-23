# SysAdmin Toolkit — Commands Reference

This file documents the public functions found in the toolkit: purpose, parameters, example usage, and typical output.

---

## User Management

### New-LocalUserSecure
- Purpose: Create a new local user with a SecureString password and add to `Users` group.
- Parameters: `-Username` (string, required), `-Password` (SecureString, required), `-FullName` (string), `-Description` (string)
- Example: `New-LocalUserSecure -Username Alice -Password (ConvertTo-SecureString 'P@ssw0rd' -AsPlainText -Force) -FullName 'Alice Smith'`
- Output: Writes host/warning/error messages; returns nothing. Creates a local user account.

### Remove-LocalUserSafe
- Purpose: Safely remove a local user (SupportsShouldProcess).
- Parameters: `-Username` (string, required)
- Example: `Remove-LocalUserSafe -Username Alice`
- Output: Writes host/warning/error messages; removes the named user when confirmed.

### Get-LocalUsers
- Purpose: List local users with basic fields.
- Parameters: none
- Example: `Get-LocalUsers`
- Output: Collection of local users with `Name, FullName, Enabled, Description`.

### Import-LocalUsersFromCSV
- Purpose: Bulk-create users from CSV (expects columns like Username, Password, FullName).
- Parameters: `-CSVPath` (string, required)
- Example: `Import-LocalUsersFromCSV -CSVPath .\users.csv`
- Output: Creates users, writes errors/warnings on failure.

---

## System Monitoring & Health

### Get-SystemHealth
- Purpose: Aggregate quick system health info (CPU, memory, disks, services).
- Parameters: `-DiskThreshold` (int, default 15)
- Example: `Get-SystemHealth -DiskThreshold 10`
- Output: PSCustomObject with `CPU_Load`, `Memory_Status`, `Disk_Status` (with optional Alert property), and `Service_Status`.

### Get-SystemUptime
- Purpose: Return system uptime.
- Parameters: none
- Example: `Get-SystemUptime`
- Output: TimeSpan object representing uptime; also logs an INFO line.

### Get-TopCPUProcesses / Get-TopMemoryProcesses
- Purpose: Return top N processes by CPU or memory.
- Parameters: `-Top` (int, default 5)
- Example: `Get-TopCPUProcesses -Top 10`
- Output: Collection of processes with `Name, Id, CPU, WS`.

### Get-DiskUsage
- Purpose: Return disk usage per physical drive and warn for low free space.
- Parameters: none
- Example: `Get-DiskUsage`
- Output: Collection of drives with `DeviceID, VolumeName, Size(GB), Free(GB), Free%` (and written WARN logs if low).

### Get-WindowsUpdateStatus
- Purpose: List installed quick-fix updates.
- Parameters: none
- Example: `Get-WindowsUpdateStatus`
- Output: Collection of updates with `HotFixID, Description, InstalledOn`.

### Get-HardwareInventory
- Purpose: Collect hardware info (CPU, RAM, BIOS, motherboard).
- Parameters: none
- Example: `Get-HardwareInventory`
- Output: PSCustomObject with CPU, RAM_GB, BIOS, Motherboard details.

---

## Network Tools & Diagnostics

### Get-IPConfig
- Purpose: Return IP configuration for network interfaces.
- Parameters: none
- Example: `Get-IPConfig`
- Output: Collection with `InterfaceAlias, IPv4Address, IPv6Address, IPv4DefaultGateway, DNSServer`.

### Test-HostConnectivity
- Purpose: Ping a host to test basic connectivity.
- Parameters: `-Target` (string, required)
- Example: `Test-HostConnectivity -Target 8.8.8.8`
- Output: Boolean (success/fail) or ping result objects; logs INFO/WARN.

### Test-TCPPort
- Purpose: Test TCP connectivity to a host:port.
- Parameters: `-Host`/`-Target` (string, required), `-Port` (int, required)
- Example: `Test-TCPPort -Host google.com -Port 443`
- Output: Boolean success and/or PSCustomObject including `TcpTestSucceeded`.

### Test-DNSResolution / Resolve-HostName
- Purpose: Resolve DNS name to IP addresses.
- Parameters: `-Host`/`-Target` (string, required)
- Example: `Test-DNSResolution -Host example.com`
- Output: IP addresses array or `Resolve-DnsName` records.

### Get-RoutingTable
- Purpose: Return routing table entries.
- Parameters: none
- Example: `Get-RoutingTable`
- Output: Collection with `ifIndex, DestinationPrefix, NextHop, RouteMetric, InterfaceAlias`.

### Get-ARPCache
- Purpose: Return ARP cache entries.
- Parameters: none
- Example: `Get-ARPCache`
- Output: Collection with `IPAddress, LinkLayerAddress, State`.

### Get-FirewallRules
- Purpose: List firewall rules.
- Parameters: none
- Example: `Get-FirewallRules`
- Output: Collection with `DisplayName, Direction, Enabled, Action, Profile`.

### Test-Traceroute
- Purpose: Perform traceroute to a host.
- Parameters: `-Host` (string, required)
- Example: `Test-Traceroute -Host example.com`
- Output: TraceRoute hops collection.

---

## Remote Execution

### Test-RemoteHost
- Purpose: Verify remote host reachability and WinRM availability.
- Parameters: `-Target` (string, required)
- Example: `Test-RemoteHost -Target Host1`
- Output: Boolean; logs INFO/WARN/ERROR.

### Invoke-RemoteSystemHealth / Invoke-RemoteSecurityAudit / Invoke-RemoteNetworkDiagnostics
- Purpose: Run respective checks on one or more remote targets (uses `Invoke-Command`).
- Parameters: `-Targets` (string[], required)
- Example: `Invoke-RemoteSystemHealth -Targets @('Host1','Host2')`
- Output: Exports CSV logs to `./logs/<target>-*.csv` and returns the collected PSCustomObject(s); writes log entries.

---

## Reporting

### Export-ReportCSV
- Purpose: Export provided data object to a CSV file in the `logs` folder.
- Parameters: `-Data` (PSObject, required), `-ReportName` (string, required)
- Example: `Export-ReportCSV -Data $report -ReportName 'Summary'`
- Output: File path to the created CSV; writes INFO log.

### Export-ReportHTML
- Purpose: Generate an HTML report from data.
- Parameters: `-Data` (PSObject, required), `-ReportName` (string, required)
- Example: `Export-ReportHTML -Data $report -ReportName 'Summary'`
- Output: File path to the HTML file; writes INFO log.

### Export-ReportMarkdown
- Purpose: Generate a simple Markdown report from data.
- Parameters: `-Data` (PSObject, required), `-ReportName` (string, required)
- Example: `Export-ReportMarkdown -Data $report -ReportName 'Summary'`
- Output: File path to the .md file; writes INFO log.

---

## Safety & Validation

### Assert-Admin
- Purpose: Ensure the caller has administrator privileges; throws/logs otherwise.
- Parameters: none
- Example: `Assert-Admin`
- Output: Boolean true if admin; logs and throws if not.

### Assert-Module
- Purpose: Check that a required module is available.
- Parameters: `-ModuleName` (string, required)
- Example: `Assert-Module -ModuleName PSReadLine`
- Output: Logs INFO if available; throws/logs ERROR if missing.

---

## Security Checks

### Get-AntivirusStatus
- Purpose: Query Windows SecurityCenter2 for antivirus products.
- Parameters: none
- Example: `Get-AntivirusStatus`
- Output: Collection of antivirus product objects or WARN if none detected.

### Get-DefenderRealtimeStatus
- Purpose: Return Windows Defender real-time protection status.
- Parameters: none
- Example: `Get-DefenderRealtimeStatus`
- Output: String `Enabled`/`Disabled`.

### Get-BitLockerStatus, Get-SecureBootStatus, Get-RDPStatus
- Purpose: Return BitLocker volumes, Secure Boot, and RDP enablement respectively.
- Parameters: none
- Example: `Get-BitLockerStatus`
- Output: BitLocker volume objects / `Enabled` or `Disabled` strings / RDP status string.

### Get-LocalAdminAccounts / Get-PasswordPolicy
- Purpose: Enumerate local admin accounts; basic password policy metadata.
- Parameters: none
- Example: `Get-LocalAdminAccounts`
- Output: Collections reporting account names and password info.

---

## Logging & Event Utilities

### Initialize-Log
- Purpose: Create logs folder, initialize session ID and log file path.
- Parameters: `-LogFolder` (string, default `./logs`), `-Overwrite` (switch)
- Example: `Initialize-Log -LogFolder .\logs -Overwrite`
- Output: Writes the session ID and log filepath to console and creates log file on first write.

### Write-Log
- Purpose: Append a timestamped entry to the toolkit log and optionally print to console.
- Parameters: `-Level` (INFO|WARN|ERROR, required), `-Message` (string, required), `-NoConsole` (switch)
- Example: `Write-Log -Level INFO -Message 'Task completed'`
- Output: Adds formatted line to log file (global `$ToolkitLogFile`).

### Get-RecentEvents / Export-Events / Get-IncidentSummary
- Purpose: Query recent critical/warning/error events, export them, and produce a summary.
- Parameters: `-HoursBack` (int, default 24), `-LogNames` (string[]), `-Events`/`-Path`/`-Format` for export
- Example: `Get-RecentEvents -HoursBack 12` / `Export-Events -Events $e -Path .\events.csv -Format CSV`
- Output: Collections of events, exported CSV/JSON file, and grouped incident summary.

---

## Notes
- Most functions write structured logs via `Write-Log` and rely on `Initialize-Log` to set `$global:ToolkitLogFile`.
- Several network functions have name variants (e.g., `Test-HostConnectivity` appears in both network modules) — they provide similar interfaces.
- Remote invocations rely on WinRM (`Invoke-Command`) and assume remote hosts have the toolkit path present or the called functions available.

---

File location: docs/COMMANDS.md
