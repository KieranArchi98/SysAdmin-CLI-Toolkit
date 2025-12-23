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


