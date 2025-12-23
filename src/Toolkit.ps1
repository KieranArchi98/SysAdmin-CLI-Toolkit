# Load modules
$functionFolders = @(
    "logging",
    "safety",
    "systemMonitoring",
    "systemHealth",
    "userManagement",
    "networkTools",
    "security",
    "eventLogs",
    "remote",
    "reporting"
)
foreach ($folder in $functionFolders) {
    Get-ChildItem "$PSScriptRoot\$folder\*.ps1" | ForEach-Object { . $_.FullName }
}

Write-Log -Level INFO -Message "SysAdmin Toolkit loaded successfully"

# Example: generate reports after session
$systemHealth = Get-SystemUptime
$diskUsage = Get-DiskUsage
$topCPU = Get-TopCPUProcesses

# Combine results
$reportData = [PSCustomObject]@{
    Uptime = $systemHealth
    Disk = $diskUsage
    TopCPU = $topCPU
}

# Export reports
Export-ReportCSV -Data $reportData -ReportName "SystemHealthSummary"
Export-ReportHTML -Data $reportData -ReportName "SystemHealthSummary"
Export-ReportMarkdown -Data $reportData -ReportName "SystemHealthSummary"
