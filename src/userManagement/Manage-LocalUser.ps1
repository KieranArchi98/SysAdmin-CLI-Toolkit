function New-LocalUserSecure {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Username,

        [Parameter(Mandatory=$true)]
        [SecureString]$Password,

        [string]$FullName = "",
        [string]$Description = "Created by SysAdmin Toolkit"
    )

    # BEGIN block
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
        Write-Warning "Administrator privileges required to create a user."
        return
    }

    # PROCESS block (main logic)
    try {
        if (Get-LocalUser -Name $Username -ErrorAction SilentlyContinue) {
            Write-Warning "User '$Username' already exists."
            return
        }

        if ($PSCmdlet.ShouldProcess("LocalUser/$Username", "Create")) {
            New-LocalUser -Name $Username -Password $Password -FullName $FullName -Description $Description
            Add-LocalGroupMember -Group "Users" -Member $Username
            Write-Host "User '$Username' created successfully."
        }
    }
    catch {
        Write-Error "Error creating user '$Username': $_"
    }
}



function Remove-LocalUserSafe {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Username
    )

    try {
        $user = Get-LocalUser -Name $Username -ErrorAction SilentlyContinue
        if (-not $user) {
            Write-Warning "User '$Username' does not exist."
            return
        }

        if ($PSCmdlet.ShouldProcess("LocalUser/$Username","Remove")) {
            Remove-LocalUser -Name $Username
            Write-Host "User '$Username' removed successfully."
        }
    }
    catch {
        Write-Error "Error removing user '$Username': $_"
    }
}




function Get-LocalUsers {
    [CmdletBinding()]
    param()  # param block is required if CmdletBinding is used

    try {
        Get-LocalUser | Select-Object Name, FullName, Enabled, Description
    }
    catch {
        Write-Error "Error retrieving local users: $_"
    }
}




function Import-LocalUsersFromCSV {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [Parameter(Mandatory=$true)]
        [string]$CSVPath
    )

    try {
        $users = Import-Csv $CSVPath
        foreach ($u in $users) {
            $securePwd = ConvertTo-SecureString $u.Password -AsPlainText -Force
            New-LocalUserSecure -Username $u.Username -Password $securePwd -FullName $u.FullName
        }
    }
    catch {
        Write-Error "Error importing users from CSV: $_"
    }
}
