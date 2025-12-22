function Test-HostConnectivity {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Target
    )

    try {
        $pingResult = Test-Connection -ComputerName $Target -Count 4 -ErrorAction Stop
        $pingResult | Select-Object Address, ResponseTime, StatusCode
    }
    catch {
        Write-Warning "Unable to reach host '$Target'. $_"
    }
}




function Test-TCPPort {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Target,

        [Parameter(Mandatory=$true)]
        [int]$Port
    )

    try {
        $result = Test-NetConnection -ComputerName $Target -Port $Port -WarningAction SilentlyContinue
        [PSCustomObject]@{
            Host            = $Target
            Port            = $Port
            TcpTestSucceeded = $result.TcpTestSucceeded
        }
    }
    catch {
        Write-Warning "Unable to test port $Port on $Target. $_"
    }
}



function Resolve-HostName {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Target
    )

    try {
        Resolve-DnsName -Name $Target | Select-Object Name, IPAddress, QueryType
    }
    catch {
        Write-Warning "Unable to resolve hostname '$Target'. $_"
    }
}



