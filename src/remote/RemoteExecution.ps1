function Test-RemoteHost {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Target
    )

    try {
        if (-not (Test-Connection -ComputerName $Target -Count 2 -Quiet)) {
            Write-Log -Level WARN -Message "Host $Target is unreachable."
            return $false
        }

        # Optional: test WinRM availability
        $winRM = Test-WSMan -ComputerName $Target -ErrorAction SilentlyContinue
        if (-not $winRM) {
            Write-Log -Level WARN -Message "WinRM not available on $Target."
            return $false
        }

        Write-Log -Level INFO -Message "Remote host $Target is reachable and WinRM is available."
        return $true
    }
    catch {
        Write-Log -Level ERROR -Message "Failed to test remote host $Target: $_"
        return $false
    }
}

function Invoke-RemoteSystemHealth {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string[]]$Targets
    )

    foreach ($target in $Targets) {
        if (-not (Test-RemoteHost -Target $target)) { continue }

        try {
            Write-Log -Level INFO -Message "Collecting system health from $target"

            $results = Invoke-Command -ComputerName $target -ScriptBlock {
                # Load the toolkit on the remote host
                $toolkitPath = "C:\Users\coco1\Desktop\SystemDiagnosticsToolkit\src\Toolkit.ps1"
                if (Test-Path $toolkitPath) { . $toolkitPath }

                # Collect data
                $sysHealth = Get-SystemUptime
                $disk = Get-DiskUsage
                $cpu = Get-TopCPUProcesses
                $mem = Get-TopMemoryProcesses

                [PSCustomObject]@{
                    Host = $env:COMPUTERNAME
                    Uptime = $sysHealth
                    Disk = $disk
                    CPU = $cpu
                    Memory = $mem
                }
            } -ErrorAction Stop

            # Export results
            $results | Export-Csv -Path "$PSScriptRoot\..\logs\$target-SystemHealth.csv" -NoTypeInformation -Force
            Write-Log -Level INFO -Message "System health collected from $target"
        }
        catch {
            Write-Log -Level ERROR -Message "Failed to collect system health from $target: $_"
        }
    }
}

function Invoke-RemoteSecurityAudit {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string[]]$Targets
    )

    foreach ($target in $Targets) {
        if (-not (Test-RemoteHost -Target $target)) { continue }

        try {
            Write-Log -Level INFO -Message "Starting security audit on $target"

            $results = Invoke-Command -ComputerName $target -ScriptBlock {
                $toolkitPath = "C:\Users\coco1\Desktop\SystemDiagnosticsToolkit\src\Toolkit.ps1"
                if (Test-Path $toolkitPath) { . $toolkitPath }

                $av = Get-AntivirusStatus
                $defender = Get-DefenderRealtimeStatus
                $bitlocker = Get-BitLockerStatus
                $secureboot = Get-SecureBootStatus
                $rdp = Get-RDPStatus
                $admins = Get-LocalAdminAccounts

                [PSCustomObject]@{
                    Host = $env:COMPUTERNAME
                    Antivirus = $av.DisplayName -join ", "
                    DefenderRealtime = $defender
                    BitLocker = ($bitlocker | ForEach-Object { $_.ProtectionStatus }) -join ", "
                    SecureBoot = $secureboot
                    RDP = $rdp
                    Admins = $admins.Name -join ", "
                }
            } -ErrorAction Stop

            $results | Export-Csv -Path "$PSScriptRoot\..\logs\$target-SecurityAudit.csv" -NoTypeInformation -Force
            Write-Log -Level INFO -Message "Security audit completed on $target"
        }
        catch {
            Write-Log -Level ERROR -Message "Security audit failed on $target: $_"
        }
    }
}

function Invoke-RemoteNetworkDiagnostics {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string[]]$Targets
    )

    foreach ($target in $Targets) {
        if (-not (Test-RemoteHost -Target $target)) { continue }

        try {
            Write-Log -Level INFO -Message "Running network diagnostics on $target"

            $results = Invoke-Command -ComputerName $target -ScriptBlock {
                $toolkitPath = "C:\Users\coco1\Desktop\SystemDiagnosticsToolkit\src\Toolkit.ps1"
                if (Test-Path $toolkitPath) { . $toolkitPath }

                $ip = Get-IPConfig
                $ping = Test-HostConnectivity -Target "8.8.8.8"
                $tcp = Test-TCPPort -Host "google.com" -Port 443
                $route = Get-RoutingTable
                $arp = Get-ARPCache

                [PSCustomObject]@{
                    Host = $env:COMPUTERNAME
                    IPConfig = $ip
                    Ping = $ping
                    TCP443 = $tcp
                    Routes = $route
                    ARP = $arp
                }
            } -ErrorAction Stop

            $results | Export-Csv -Path "$PSScriptRoot\..\logs\$target-NetworkDiagnostics.csv" -NoTypeInformation -Force
            Write-Log -Level INFO -Message "Network diagnostics completed on $target"
        }
        catch {
            Write-Log -Level ERROR -Message "Network diagnostics failed on $target: $_"
        }
    }
}

