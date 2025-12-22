function Initialize-Log {
    param (
        [string]$LogFolder = "$PSScriptRoot\..\logs",
        [switch]$Overwrite = $false
    )

    # Ensure log folder exists
    if (-not (Test-Path $LogFolder)) {
        New-Item -ItemType Directory -Path $LogFolder | Out-Null
    }

    # Session ID for this execution
    $global:ToolkitSessionID = [guid]::NewGuid().ToString()

    # Log file path
    $global:ToolkitLogFile = Join-Path $LogFolder ("ToolkitLog_{0}.log" -f (Get-Date -Format "yyyyMMdd_HHmmss"))

    if (Test-Path $global:ToolkitLogFile -and $Overwrite) {
        Remove-Item $global:ToolkitLogFile
    }

    Write-Host "Logging initialized. Session ID: $global:ToolkitSessionID"
    Write-Host "Log file: $global:ToolkitLogFile"
}

function Write-Log {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateSet("INFO","WARN","ERROR")]
        [string]$Level,

        [Parameter(Mandatory=$true)]
        [string]$Message,

        [switch]$NoConsole
    )

    # Timestamp
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    # Format: [TIMESTAMP] [SESSION_ID] [LEVEL] Message
    $logEntry = "[{0}] [{1}] [{2}] {3}" -f $timestamp, $global:ToolkitSessionID, $Level, $Message

    # Write to file
    Add-Content -Path $global:ToolkitLogFile -Value $logEntry

    # Optional console output
    if (-not $NoConsole) {
        switch ($Level) {
            "INFO"  { Write-Host $logEntry -ForegroundColor Cyan }
            "WARN"  { Write-Warning $logEntry }
            "ERROR" { Write-Error $logEntry }
        }
    }
}

function Get-RecentEvents {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)]
        [int]$HoursBack = 24,

        [Parameter(Mandatory=$false)]
        [string[]]$LogNames = @("System","Application")
    )

    try {
        Write-Log -Level INFO -Message "Querying events from $($LogNames -join ', ') for last $HoursBack hours"

        $startTime = (Get-Date).AddHours(-$HoursBack)

        $allEvents = foreach ($log in $LogNames) {
            Get-WinEvent -LogName $log -FilterHashtable @{StartTime=$startTime; Level=1,2,3} -ErrorAction SilentlyContinue
        }

        if (-not $allEvents) {
            Write-Log -Level INFO -Message "No recent critical/error/warning events found."
            return @()
        }

        # Return selected fields
        $allEvents | Select-Object TimeCreated, ProviderName, Id, LevelDisplayName, Message
    }
    catch {
        Write-Log -Level ERROR -Message "Failed to query event logs: $_"
    }
}

function Export-Events {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [array]$Events,

        [Parameter(Mandatory=$true)]
        [string]$Path,

        [ValidateSet("CSV","JSON")]
        [string]$Format = "CSV"
    )

    try {
        if ($Format -eq "CSV") {
            $Events | Export-Csv -Path $Path -NoTypeInformation
        } else {
            $Events | ConvertTo-Json | Set-Content -Path $Path
        }
        Write-Log -Level INFO -Message "Exported $($Events.Count) events to $Path in $Format format"
    }
    catch {
        Write-Log -Level ERROR -Message "Failed to export events: $_"
    }
}

function Get-IncidentSummary {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)]
        [int]$HoursBack = 24
    )

    try {
        $events = Get-RecentEvents -HoursBack $HoursBack
        if (-not $events) { return }

        $summary = $events | Group-Object LevelDisplayName | Select-Object Name, Count
        Write-Log -Level INFO -Message "Incident summary for last $HoursBack hours:"
        foreach ($item in $summary) {
            Write-Log -Level INFO -Message "$($item.Name): $($item.Count)"
        }
        return $summary
    }
    catch {
        Write-Log -Level ERROR -Message "Failed to generate incident summary: $_"
    }
}

