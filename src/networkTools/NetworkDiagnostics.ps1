function Get-IPConfig {
    [CmdletBinding()]
    param ()

    try {
        $interfaces = Get-NetIPConfiguration | Select-Object InterfaceAlias, IPv4Address, IPv6Address, IPv4DefaultGateway, DNSServer
        Write-Log -Level INFO -Message "Retrieved IP configuration for $($interfaces.Count) network interfaces"
        return $interfaces
    }
    catch {
        Write-Log -Level ERROR -Message "Failed to retrieve IP configuration: $_"
    }
}

function Test-HostConnectivity {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Target
    )

    try {
        $ping = Test-Connection -ComputerName $Target -Count 2 -Quiet
        if ($ping) {
            Write-Log -Level INFO -Message "Ping to $Target successful"
        } else {
            Write-Log -Level WARN -Message "Ping to $Target failed"
        }
        return $ping
    }
    catch {
        Write-Log -Level ERROR -Message "Ping test failed: $_"
    }
}

function Test-TCPPort {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Host,
        [Parameter(Mandatory=$true)]
        [int]$Port
    )

    try {
        $connection = Test-NetConnection -ComputerName $Host -Port $Port
        if ($connection.TcpTestSucceeded) {
            Write-Log -Level INFO -Message "TCP port $Port on $Host is open"
        } else {
            Write-Log -Level WARN -Message "TCP port $Port on $Host is closed or unreachable"
        }
        return $connection.TcpTestSucceeded
    }
    catch {
        Write-Log -Level ERROR -Message "TCP port test failed: $_"
    }
}

function Test-DNSResolution {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Host
    )

    try {
        $ip = [System.Net.Dns]::GetHostAddresses($Host)
        Write-Log -Level INFO -Message "DNS resolution for $Host: $($ip -join ', ')"
        return $ip
    }
    catch {
        Write-Log -Level ERROR -Message "DNS resolution failed for $Host: $_"
    }
}

function Get-RoutingTable {
    [CmdletBinding()]
    param ()

    try {
        $routes = Get-NetRoute | Select-Object ifIndex, DestinationPrefix, NextHop, RouteMetric, InterfaceAlias
        Write-Log -Level INFO -Message "Retrieved routing table"
        return $routes
    }
    catch {
        Write-Log -Level ERROR -Message "Failed to retrieve routing table: $_"
    }
}

function Get-ARPCache {
    [CmdletBinding()]
    param ()

    try {
        $arp = Get-NetNeighbor | Select-Object ifIndex, IPAddress, LinkLayerAddress, State
        Write-Log -Level INFO -Message "Retrieved ARP cache"
        return $arp
    }
    catch {
        Write-Log -Level ERROR -Message "Failed to retrieve ARP cache: $_"
    }
}

function Get-FirewallRules {
    [CmdletBinding()]
    param ()

    try {
        $rules = Get-NetFirewallRule | Select-Object DisplayName, Direction, Enabled, Action, Profile
        Write-Log -Level INFO -Message "Retrieved $($rules.Count) firewall rules"
        return $rules
    }
    catch {
        Write-Log -Level ERROR -Message "Failed to retrieve firewall rules: $_"
    }
}

function Test-Traceroute {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Host
    )

    try {
        $trace = Test-NetConnection -ComputerName $Host -TraceRoute
        Write-Log -Level INFO -Message "Traceroute to $Host completed"
        return $trace.TraceRoute
    }
    catch {
        Write-Log -Level ERROR -Message "Traceroute failed: $_"
    }
}
