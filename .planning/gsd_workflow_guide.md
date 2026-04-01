# GSD Execution Framework: The FleetMan Guide

> **Welcome to the "Get Shit Done" Workflow.**
> This guide outlines exactly how we will build the FleetMan MVP securely, without hallucinations, context loss, or messy code bases. It explains how to select the right AI models and how to manage the "Burn-and-Replace" loop.

## The Core Concept: Context is King
Never ask an AI to "remember" the whole application. Over time, AI memory gets polluted. Instead, you use short-lived, highly-focused AI agents that are handed exact Context Files (like the PRD or Phase Roadmap) right when they spawn.

---

## 1. Selecting the Proper AI Model

When opening a new session, you must choose the right model for the job:

### A. The "Planner" (Complex Reasoning)
*   **Models to use:** Google Gemini Pro, Claude 3.5 Sonnet, or GPT-4o.
*   **When to use:** For architecture designs, database schema planning, bug hunting across multiple files, or writing PRDs.
*   **Strengths:** Excellent at reading complex documentation, understanding edge cases, and making high-level decisions.
*   **Role in GSD:** You use this model to look at the `gsd_phase_roadmap.md` and say: *"Write the exact SQL migrations for Phase 0."*

### B. The "Coder / Subagent" (High Speed, Focused Execution)
*   **Models to use:** Claude 3.5 Haiku, Gemini Flash, or specialized coding subagents.
*   **When to use:** To write a specific UI screen (e.g., `login_screen.dart`), scaffold a Next.js component, or generate simple unit tests.
*   **Strengths:** Fast generation speed and high compliance with atomic tasks.
*   **Role in GSD:** You use this model to execute *one specific step* from the Planner's roadmap.

---

## 2. The Daily Execution Loop (Burn-and-Replace)

Here is your exact workflow for building a feature (e.g., The Login Screen) without context rot.

> [!IMPORTANT]
> **Step 1: Spark the Phase**
> Inform AntiGravity to begin execution (e.g., "AntiGravity, begin Phase 3 from the roadmap"). AntiGravity will naturally pull `gsd_phase_roadmap.md` and read the requirements.

> [!NOTE]
> **Step 2: Autonomous Tracking & Execution**
> AntiGravity orchestrates the execution entirely inside its current persistent context. It uses native tools to scaffold Dart/TypeScript, spins up internal verifications (via testing tools/MCP), and commits directly to `main`. 

> [!TIP]
> **Step 3: Auto-Checkboxes**
> Previously, we used `.planning/add_checkboxes.py`. This is deprecated. AntiGravity uses code-modification tools to dynamically update `[ ]` to `[x]` within the roadmap itself after verifying the CI pipeline statuses natively.

> [!CAUTION]  
> **Step 4: The Phase Cap**
> While AntiGravity manages the complex loop seamlessly, do not bleed phases! Let AntiGravity completely declare a phase finished and formally print the Walkthrough before initiating the prompt for the next broad phase.

---

## 3. Subagents & Tool Orchestration

If you are using an IDE integration (like Cursor, Copilot, or Claude Code), you can delegate work to temporary subagents.

*   **When a task is large** (e.g., "Build the whole Web Dashboard"), use your Planner Agent to break it into atomic pieces.
*   The Planner Agent can spawn a **Browser Subagent** (to look at Material UI docs or check live localhost deployment) or a **Coding Subagent** to edit the files.
*   **Rule of Thumb:** A subagent should never work on more than 2-3 files at once. 

## 4. Applying this to Phase 0 (Supabase) right now
To execute our immediate next step (Phase 0), the GSD prompt will be:

*"You are the Supabase Database Architect. Read `docs/implementation_plan.md` Phase 0. Proceed to write the 7 exact `.sql` files for the tables, including the RLS policies. Do not use UI code. Focus ONLY on SQL."*
