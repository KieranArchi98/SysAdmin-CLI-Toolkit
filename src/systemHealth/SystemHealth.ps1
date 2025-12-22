function Get-SystemUptime {
    [CmdletBinding()]
    param ()

    try {
        $os = Get-CimInstance -ClassName Win32_OperatingSystem
        $uptime = (Get-Date) - $os.LastBootUpTime
        Write-Log -Level INFO -Message "System uptime: $($uptime.Days) days, $($uptime.Hours) hours, $($uptime.Minutes) minutes"
        return $uptime
    }
    catch {
        Write-Log -Level ERROR -Message "Failed to retrieve system uptime: $_"
    }
}

function Get-TopCPUProcesses {
    [CmdletBinding()]
    param (
        [int]$Top = 5
    )

    try {
        $processes = Get-Process | Sort-Object CPU -Descending | Select-Object -First $Top Name, Id, CPU, WS
        Write-Log -Level INFO -Message "Retrieved top $Top CPU-consuming processes"
        return $processes
    }
    catch {
        Write-Log -Level ERROR -Message "Failed to retrieve CPU processes: $_"
    }
}

function Get-TopMemoryProcesses {
    [CmdletBinding()]
    param (
        [int]$Top = 5
    )

    try {
        $processes = Get-Process | Sort-Object WS -Descending | Select-Object -First $Top Name, Id, CPU, WS
        Write-Log -Level INFO -Message "Retrieved top $Top memory-consuming processes"
        return $processes
    }
    catch {
        Write-Log -Level ERROR -Message "Failed to retrieve memory processes: $_"
    }
}

function Get-DiskUsage {
    [CmdletBinding()]
    param ()

    try {
        $disks = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" | 
                 Select-Object DeviceID, VolumeName, @{Name="Size(GB)";Expression={"{0:N2}" -f ($_.Size/1GB)}}, @{Name="Free(GB)";Expression={"{0:N2}" -f ($_.FreeSpace/1GB)}}, @{Name="Free%";Expression={"{0:N2}" -f (($_.FreeSpace/$_.Size)*100)}}

        foreach ($disk in $disks) {
            if ([double]$disk.'Free%' -lt 20) {
                Write-Log -Level WARN -Message "Disk $($disk.DeviceID) below 20% free"
            }
        }

        Write-Log -Level INFO -Message "Retrieved disk usage information"
        return $disks
    }
    catch {
        Write-Log -Level ERROR -Message "Failed to retrieve disk usage: $_"
    }
}

function Get-WindowsUpdateStatus {
    [CmdletBinding()]
    param ()

    try {
        $updates = Get-WmiObject -Namespace "root\cimv2" -Class "Win32_QuickFixEngineering" | Select-Object HotFixID, Description, InstalledOn
        Write-Log -Level INFO -Message "Retrieved $($updates.Count) installed updates"
        return $updates
    }
    catch {
        Write-Log -Level ERROR -Message "Failed to retrieve Windows Update status: $_"
    }
}

function Get-HardwareInventory {
    [CmdletBinding()]
    param ()

    try {
        $cpu = Get-CimInstance Win32_Processor | Select-Object Name, NumberOfCores, NumberOfLogicalProcessors, MaxClockSpeed
        $ram = Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum
        $bios = Get-CimInstance Win32_BIOS | Select-Object Manufacturer, SMBIOSBIOSVersion, ReleaseDate
        $motherboard = Get-CimInstance Win32_BaseBoard | Select-Object Manufacturer, Product, SerialNumber

        $inventory = [PSCustomObject]@{
            CPU = $cpu
            RAM_GB = [math]::Round($ram.Sum/1GB,2)
            BIOS = $bios
            Motherboard = $motherboard
        }

        Write-Log -Level INFO -Message "Retrieved hardware inventory"
        return $inventory
    }
    catch {
        Write-Log -Level ERROR -Message "Failed to retrieve hardware inventory: $_"
    }
}

