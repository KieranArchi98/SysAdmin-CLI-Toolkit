function Get-AntivirusStatus {
    [CmdletBinding()]
    param ()

    try {
        $avProducts = Get-CimInstance -Namespace "root/SecurityCenter2" -ClassName "AntiVirusProduct" -ErrorAction SilentlyContinue
        if ($avProducts) {
            foreach ($av in $avProducts) {
                Write-Log -Level INFO -Message "Antivirus detected: $($av.displayName) | State: $($av.productState)"
            }
            return $avProducts
        } else {
            Write-Log -Level WARN -Message "No antivirus product detected!"
        }
    }
    catch {
        Write-Log -Level ERROR -Message "Failed to query antivirus status: $_"
    }
}

function Get-DefenderRealtimeStatus {
    [CmdletBinding()]
    param ()

    try {
        $realtime = Get-MpPreference
        $status = if ($realtime.DisableRealtimeMonitoring) { "Disabled" } else { "Enabled" }
        Write-Log -Level INFO -Message "Windows Defender Real-Time Protection: $status"
        return $status
    }
    catch {
        Write-Log -Level ERROR -Message "Failed to retrieve Defender real-time status: $_"
    }
}

function Get-BitLockerStatus {
    [CmdletBinding()]
    param ()

    try {
        $volumes = Get-BitLockerVolume
        foreach ($vol in $volumes) {
            Write-Log -Level INFO -Message "Drive $($vol.MountPoint) | Protection Status: $($vol.ProtectionStatus) | Lock Status: $($vol.LockStatus)"
        }
        return $volumes
    }
    catch {
        Write-Log -Level ERROR -Message "Failed to retrieve BitLocker status: $_"
    }
}

function Get-SecureBootStatus {
    [CmdletBinding()]
    param ()

    try {
        $sb = Confirm-SecureBootUEFI
        $status = if ($sb) { "Enabled" } else { "Disabled" }
        Write-Log -Level INFO -Message "Secure Boot: $status"
        return $status
    }
    catch {
        Write-Log -Level ERROR -Message "Failed to check Secure Boot status: $_"
    }
}

function Get-RDPStatus {
    [CmdletBinding()]
    param ()

    try {
        $rdpStatus = Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections"
        $status = if ($rdpStatus.fDenyTSConnections -eq 0) { "Enabled" } else { "Disabled" }
        Write-Log -Level INFO -Message "RDP Status: $status"
        return $status
    }
    catch {
        Write-Log -Level ERROR -Message "Failed to retrieve RDP status: $_"
    }
}

function Get-LocalAdminAccounts {
    [CmdletBinding()]
    param ()

    try {
        $admins = Get-LocalGroupMember -Group "Administrators" | Select-Object Name, ObjectClass
        Write-Log -Level INFO -Message "Local Administrators: $($admins.Name -join ', ')"
        return $admins
    }
    catch {
        Write-Log -Level ERROR -Message "Failed to retrieve local admin accounts: $_"
    }
}

function Get-PasswordPolicy {
    [CmdletBinding()]
    param ()

    try {
        $pol = Get-LocalUser | Select-Object Name, PasswordExpired, PasswordLastSet
        Write-Log -Level INFO -Message "Retrieved password policy info for local users"
        return $pol
    }
    catch {
        Write-Log -Level ERROR -Message "Failed to retrieve password policy info: $_"
    }
}

