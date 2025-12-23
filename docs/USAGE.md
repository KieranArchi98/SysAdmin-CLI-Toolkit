# Usage — SysAdmin Toolkit

This document explains how to load the toolkit into a PowerShell session, run the full workflow, invoke individual commands, and automate runs.

1) Load the toolkit into your current session

Dot-source the Toolkit to import functions into the current PowerShell session:

```powershell
. "C:\Users\coco1\Desktop\SystemDiagnosticsToolkit\src\Toolkit.ps1"
```

After this, functions like `Get-SystemUptime`, `Get-DiskUsage`, and `Write-Log` are available.

2) Run the full workflow

Use the provided runner to execute the full workflow (local checks, optional remote execution, and reporting):

```powershell
# From the repository root
powershell -ExecutionPolicy Bypass -File .\RunToolkit.ps1
```

3) Run individual commands

After loading `Toolkit.ps1`, call any function directly:

```powershell
Get-SystemHealth -DiskThreshold 10
Get-TopCPUProcesses -Top 10
Test-TCPPort -Host example.com -Port 443
```

4) Automate runs (Task Scheduler)

Create a scheduled task that runs `RunToolkit.ps1` under a service account with appropriate privileges.

Example: create a scheduled task that runs daily at 2:00 AM:

```powershell
$action = New-ScheduledTaskAction -Execute 'PowerShell.exe' -Argument '-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "C:\Users\coco1\Desktop\SystemDiagnosticsToolkit\RunToolkit.ps1"'
$trigger = New-ScheduledTaskTrigger -Daily -At 2am
Register-ScheduledTask -TaskName 'SysAdminToolkit-Daily' -Action $action -Trigger $trigger -User 'DOMAIN\svc-toolkit' -RunLevel Highest
```

5) Automate runs (CI / GitHub Actions)

You can run the toolkit on a Windows runner. Minimal workflow step:

```yaml
# .github/workflows/run-toolkit.yml
name: Run SysAdmin Toolkit
on:
  workflow_dispatch: {}
jobs:
  run-toolkit:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run Toolkit
        shell: powershell
        run: pwsh -NoProfile -ExecutionPolicy Bypass -File .\RunToolkit.ps1
```

6) Permissions & environment notes
- Many checks require Administrator privileges — run Task Scheduler or CI with an account that has the rights.
- Remote execution uses WinRM/`Invoke-Command` and assumes target hosts allow WinRM and have required modules available.
- Logs are written to the `logs` folder; ensure the account running the toolkit can write there.

7) Troubleshooting
- If functions are unavailable after dot-sourcing, verify the path and that PowerShell's execution policy allows script loading.
- Use `Initialize-Log` to create the log session and inspect `$global:ToolkitLogFile` for details.

***

File location: docs/USAGE.md
