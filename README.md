# SysAdmin Toolkit

What is this?
- A lightweight PowerShell toolkit of modular diagnostics and audit functions to collect system health, security, network, and event-log data, with report generation and optional remote execution.

Who is it for?
- System administrators, SREs, and engineers who need a reproducible, scriptable toolkit for quickly collecting host-level diagnostics and producing reports.

What problems does it solve?
- Provides a consistent set of checks (CPU, memory, disk, services), security audits (antivirus, BitLocker, RDP), network diagnostics, and event-log collection.
- Generates CSV/HTML/Markdown reports and supports running checks remotely and on schedules.

Why was it built this way?
- Modular structure keeps concerns separate (logging, monitoring, network, security) so features can be extended or reused.
- Object-based outputs make it easy to export, transform, and aggregate results programmatically.
- A simple logging abstraction (`Write-Log`) centralizes formatting and enables future redirection of log sinks.

What skills does it demonstrate?
- PowerShell scripting with advanced functions and `CmdletBinding`, remote execution (`Invoke-Command` / WinRM), structured outputs (`PSCustomObject`), logging best-practices, and automation via scheduled tasks or CI.

Where to start
- Load the toolkit into your session: dot-source `src/Toolkit.ps1`.
- Run the full workflow with `.\RunToolkit.ps1` from the repository root.
- See `docs/USAGE.md` for load/run/automation examples and `docs/COMMANDS.md` for a catalog of available commands.

Documentation
- Commands reference: docs/COMMANDS.md
- Usage and automation: docs/USAGE.md
- Architecture rationale: docs/ARCHITECTURE.md
- Design decisions: docs/Design_Decisions.md

License & notes
- This repository is intended as a demonstration toolkit. Use and modify as needed for your environment; ensure scripts are run with appropriate privileges and review remote execution settings before use.
