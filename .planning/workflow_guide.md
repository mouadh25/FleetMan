# The GSD Workflow: FleetMan Training Guide

Welcome to the **Get Shit Done (GSD)** methodology. If you are reading this, you have abandoned the chaos of long, confusing AI chats. You are now a Context Engineer.

## 1. Installation (In your IDE)
To officially bind the GSD CLI to your terminal (if you are using Claude Code, OpenCode, or an AI terminal runner), run this locally in your workspace:

```bash
npx get-shit-done-cc@latest
```
*(Select "Local Project Install" when it asks).*

## 2. How to Work: The "Burn-and-Replace" Loop
Here is your exact daily workflow for building FleetMan without the AI ever hallucinating or losing context.

### Step 1: The Master Plan
Always ensure `.planning/fleetman_project_context.md` is up to date. You never ask an AI to remember the whole app; you just hand it this file.

### Step 2: The Task Prompt (Fresh Agent)
When you want to build a feature (e.g., The Login Screen), you **open a brand new, empty AI chat session.**
You type your prompt exactly like this:
> "Read `.planning/fleetman_project_context.md`. I am in Execute Phase. I want you to scaffold the Flutter Login UI. Use `auth_service.dart`. Do not change any architectural rules."

### Step 3: Verify & Commit
The agent writes the code. You test it in your emulator.
*   If it breaks, you reply to the agent: *"Error on line 42, fix it."*
*   If it works, you **commit the code to Git** immediately.

### Step 4: The Kill Switch (CRITICAL)
Once the code is committed, **you instantly close that AI chat session and delete the thread.** 
Do not say "Thank you, now build the Dashboard." If you do, the AI starts carrying the weight of the Login UI into the Dashboard task, and "context rot" begins.
To build the Dashboard, you return to Step 2: Open a fresh, empty AI chat.

## 3. The Official GSD Slash Commands (If using the CLI)
If you install the GSD CLI wrapper, you can use these shortcuts to automate the loop above:
*   `/gsd:plan-phase 1` -> Forces the AI to write out microscopic, atomic steps for a feature.
*   `/gsd:execute-phase 1` -> Spawns isolated execution windows for each step.
*   `/gsd:verify-work 1` -> Triggers a quality assurance sweep before letting you commit.
