<#
.SYNOPSIS
    Run full SysAdmin Toolkit workflow (local + remote)
.DESCRIPTION
    Executes all toolkit modules safely, with logging, remote execution, and report generation.
.EXAMPLE
    .\RunToolkit.ps1
.NOTES
    Designed for GitHub portfolio demonstration
#>

# Load toolkit
$ToolkitPath = "C:\Users\coco1\Desktop\SystemDiagnosticsToolkit\src\Toolkit.ps1"
. $ToolkitPath

# Define remote hosts (optional)
$RemoteHosts = @("Host1", "Host2")  # Replace with real hostnames

# Step 1: Pre-flight check
Assert-Admin
$RemoteHosts | ForEach-Object { Test-RemoteHost -Target $_ }

# Step 2: Local System Health
Write-Host "Running local system health..."
$localHealth = [PSCustomObject]@{
    Uptime = Get-SystemUptime
    Disk = Get-DiskUsage
    TopCPU = Get-TopCPUProcesses
    TopMemory = Get-TopMemoryProcesses
}

# Step 3: Local Security Audit
$localSecurity = [PSCustomObject]@{
    Antivirus = Get-AntivirusStatus
    DefenderRealtime = Get-DefenderRealtimeStatus
    BitLocker = Get-BitLockerStatus
    SecureBoot = Get-SecureBootStatus
    RDP = Get-RDPStatus
    LocalAdmins = Get-LocalAdminAccounts | ForEach-Object { $_.Name } -join ", "
}

# Step 4: Local Network Diagnostics
$localNetwork = [PSCustomObject]@{
    IPConfig = Get-IPConfig
    PingTest = Test-HostConnectivity -Target "8.8.8.8"
    TCP443 = Test-TCPPort -Host "google.com" -Port 443
    Routes = Get-RoutingTable
    ARP = Get-ARPCache
}

# Step 5: Remote Execution (if any remote hosts)
if ($RemoteHosts.Count -gt 0) {
    Write-Host "Running remote system health and audits..."
    Invoke-RemoteSystemHealth -Targets $RemoteHosts
    Invoke-RemoteSecurityAudit -Targets $RemoteHosts
    Invoke-RemoteNetworkDiagnostics -Targets $RemoteHosts
}

# Step 6: Reporting
Write-Host "Generating reports..."
$combinedReport = [PSCustomObject]@{
    LocalHealth = $localHealth
    LocalSecurity = $localSecurity
    LocalNetwork = $localNetwork
}

Export-ReportCSV -Data $combinedReport -ReportName "FullLocalReport"
Export-ReportHTML -Data $combinedReport -ReportName "FullLocalReport"
Export-ReportMarkdown -Data $combinedReport -ReportName "FullLocalReport"

Write-Host "Full Toolkit run completed. Reports saved in ./logs/"
