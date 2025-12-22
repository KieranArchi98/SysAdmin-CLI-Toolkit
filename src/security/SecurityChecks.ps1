function Get-FirewallStatus {
    [CmdletBinding()]
    param ()

    try {
        # Get status for all profiles
        $profiles = @("Domain", "Private", "Public")
        $status = foreach ($p in $profiles) {
            $state = (Get-NetFirewallProfile -Profile $p).Enabled
            [PSCustomObject]@{
                Profile = $p
                Enabled = $state
            }
        }
        return $status
    }
    catch {
        Write-Warning "Error checking firewall status: $_"
    }
}



function Get-AVStatus {
    [CmdletBinding()]
    param ()

    try {
        $avProducts = Get-CimInstance -Namespace "root\SecurityCenter2" -ClassName "AntiVirusProduct" -ErrorAction SilentlyContinue
        if ($avProducts) {
            $avProducts | Select-Object displayName, productState, pathToSignedProductExe
        }
        else {
            Write-Warning "No antivirus product detected."
        }
    }
    catch {
        Write-Warning "Error checking antivirus status: $_"
    }
}



