$functionFolders = @(
    "logging",
    "systemMonitoring",
    "systemHealth",
    "userManagement",
    "networkTools",
    "security",
    "eventLogs"
)
foreach ($folder in $functionFolders) {
    Get-ChildItem "$PSScriptRoot\$folder\*.ps1" | ForEach-Object {
        . $_.FullName
    }
}

Write-Log -Level INFO -Message "SysAdmin Toolkit loaded successfully"
