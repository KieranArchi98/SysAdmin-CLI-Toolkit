function Get-SystemHealth {
    [CmdletBinding()]
    param (
        [int]$DiskThreshold = 15  # Alert if free disk space < threshold %
    )

    begin {
        # Check for admin privileges
        if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
            Write-Warning "You are not running as Administrator. Some checks may fail."
        }
    }

    process {
        try {
            # CPU Usage
            $cpu = Get-CimInstance Win32_Processor | Select-Object -ExpandProperty LoadPercentage

            # Memory Usage
            $memory = Get-CimInstance Win32_OperatingSystem | Select-Object @{Name="TotalGB";Expression={[math]::Round($_.TotalVisibleMemorySize/1MB,2)}}, @{Name="FreeGB";Expression={[math]::Round($_.FreePhysicalMemory/1MB,2)}}

            # Disk Usage
            $disks = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" | Select-Object DeviceID, @{Name="FreeGB";Expression={[math]::Round($_.FreeSpace/1GB,2)}}, @{Name="SizeGB";Expression={[math]::Round($_.Size/1GB,2)}}

            # Service Status (example critical services)
            $servicesToCheck = @("wuauserv","WinRM","Spooler")
            $serviceStatus = $servicesToCheck | ForEach-Object {
                $svc = Get-Service -Name $_
                [PSCustomObject]@{
                    Service = $svc.Name
                    Status  = $svc.Status
                }
            }

            # Output
            [PSCustomObject]@{
                CPU_Load        = "$cpu %"
                Memory_Status   = $memory
                Disk_Status     = $disks | ForEach-Object {
                    if ($_.FreeGB / $_.SizeGB * 100 -lt $DiskThreshold) {
                        $_ | Add-Member -MemberType NoteProperty -Name "Alert" -Value "Low Disk Space!" -PassThru
                    }
                    else { $_ }
                }
                Service_Status  = $serviceStatus
            }
        }
        catch {
            Write-Error "Error retrieving system health: $_"
        }
    }
}
