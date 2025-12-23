# Design Decisions — SysAdmin Toolkit

This file documents the rationale and trade-offs behind the toolkit's main design choices.

## Why modular structure
Rationale:
- Improves clarity by grouping related functionality (e.g., networking vs. system health).
- Eases incremental development and review.

Trade-offs:
- Slight overhead in management (many small files) and initial load code, but mitigated by dot-sourcing only required modules.

## Why object-based output
Rationale:
- Structured data simplifies reporting and automating pipelines.
- Encourages programmatic consumption (Export-CSV, Export-HTML, remote aggregation).

Trade-offs:
- Requires consumers to understand object schema; documentation (see `docs/COMMANDS.md`) mitigates this.

## Why logging abstraction
Rationale:
- Centralizing logs via `Write-Log` ensures consistent formatting and easier future redirection (files, remote). The session ID concept enables grouping of related entries.

Trade-offs:
- A thin logging layer adds indirection, but the benefits for observability and audit compliance outweigh the cost.

## Why config-driven design
Rationale:
- Makes the toolkit adaptable to different environments without code edits.
- Facilitates automation, templating, and secure storage of parameters (e.g., Service Account names in orchestrated runs).

Trade-offs:
- Requires a config loader and validation; the toolkit keeps this lightweight to avoid complexity.

***

File location: docs/Design_Decisions.md
