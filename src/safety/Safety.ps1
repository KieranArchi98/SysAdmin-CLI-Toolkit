function Assert-Admin {
    [CmdletBinding()]
    param ()

    try {
        $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
        if (-not $isAdmin) {
            Write-Log -Level ERROR -Message "Administrator privileges required to run this action."
            throw "Administrator privileges required."
        } else {
            Write-Log -Level INFO -Message "Admin privileges confirmed."
        }
        return $isAdmin
    }
    catch {
        Write-Log -Level ERROR -Message "Admin check failed: $_"
    }
}

function Assert-Module {
    param (
        [Parameter(Mandatory=$true)]
        [string]$ModuleName
    )

    try {
        if (-not (Get-Module -ListAvailable -Name $ModuleName)) {
            Write-Log -Level ERROR -Message "Required module '$ModuleName' not installed."
            throw "Module '$ModuleName' not available."
        } else {
            Write-Log -Level INFO -Message "Required module '$ModuleName' is available."
        }
    }
    catch {
        Write-Log -Level ERROR -Message "Module check failed: $_"
    }
}

function Remove-LocalUserSafe {
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact="Medium")]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Username
    )

    process {
        try {
            $user = Get-LocalUser -Name $Username -ErrorAction SilentlyContinue
            if (-not $user) {
                Write-Log -Level WARN -Message "User '$Username' does not exist."
                return
            }

            if ($PSCmdlet.ShouldProcess("LocalUser/$Username", "Remove")) {
                Remove-LocalUser -Name $Username
                Write-Log -Level INFO -Message "User '$Username' removed successfully."
            }
        }
        catch {
            Write-Log -Level ERROR -Message "Error removing user '$Username': $_"
        }
    }
}

