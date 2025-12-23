# Architecture — SysAdmin Toolkit

This document explains key architecture choices made in the toolkit and why they are beneficial.

## Why modular structure
- Separation of concerns: each module (logging, systemHealth, networkTools, security, etc.) focuses on a single responsibility, making the code easier to read, test, and maintain.
- Reuse: functions are grouped into logical folders so they can be loaded independently or shared across scripts.
- Scalability: new checks or features can be added as separate modules without impacting existing ones.

## Why object-based output
- Machine-friendly: functions return structured objects (PSCustomObject, collections) rather than free-form text, enabling downstream filtering, aggregation, and export.
- Predictability: consumers (reports, remote collectors, CI) can rely on stable properties and types.
- Testability: structured outputs are easier to assert in automated tests.

## Why logging abstraction
- Centralized control: `Write-Log` centralizes formatting and persistent storage (session ID, logfile), ensuring consistent entries across modules.
- Flexible sinks: decoupling code from direct file writes allows future changes (send logs to remote store, syslog, or telemetry) without modifying business logic.
- Auditability: consistent timestamps and session IDs make it straightforward to trace activity across modules and remote runs.

## Why config-driven design
- Environment adaptability: configuration (paths, thresholds, lists of services) enables the same code to run in multiple environments with minimal changes.
- Non-code changes: shifting operational parameters (e.g., disk alert threshold) can be done via config rather than code changes, lowering risk.
- Automation-friendly: configs can be generated or templated for different deployment profiles (dev, staging, prod).

***

File location: docs/ARCHITECTURE.md
