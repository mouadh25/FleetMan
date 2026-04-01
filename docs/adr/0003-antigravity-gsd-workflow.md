# ADR-0003: Agentic "Get Shit Done" (GSD) Workflow with AntiGravity

**Date:** 2026-04-01  
**Status:** Accepted  

## Context
The previous iterations of the GSD workflow relied entirely on meticulous, manual human involvement. The human developer spawned fresh, isolated conversations with the AI, manually executed the required codebase adjustments, and invoked custom legacy scripts (`.planning/add_checkboxes.py`) to systematically tick off boxes on the core `gsd_phase_roadmap.md`. 
This is fundamentally unscalable, prone to omission errors, and underutilizes modern autonomous agentic capabilities like Model Context Protocol (MCP).

## Decision
We officially transition to a **Native AntiGravity Agentic Workflow** where the AI autonomously orchestrates the repetitive elements of the GSD lifecycle. 
This behaves seamlessly in the background. The user simply signals the transition to a new phase (e.g., "AntiGravity, execute Phase 3").

1. **AntiGravity drives `gsd_phase_roadmap.md`:** The AI implicitly retrieves the `.md` file, decomposes the instructions, creates an execution blueprint inside `task.md`, executes it using its native development tools, and formally marks the phase item with a `[x]` using direct text replacement.
2. **Automated Verifications:** Instead of relying on manual build deployments by the developer, the AI executes `gh run` monitoring natively. Wait cycles are self-sustained by the agent.
3. **Deprecation of Manual Scripts:** `add_checkboxes.py` has been explicitly deleted. The AI interacts with the roadmap purely as a dynamic text document.

## Consequences
- **Positive:** Massive reduction in developer overhead. True continuous "vibe coding" without rigid CLI interventions for task tracking. Error-prone manual updates to the monolithic roadmap are eliminated.
- **Negative:** Increased reliance on the AI's understanding of the Markdown format. If AntiGravity incorrectly parses the roadmap text table, it might skew progress. (Mitigated by strict table-structure enforcement during edits).
