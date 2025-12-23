# 🚁 Neon Spectre: Dual Ops (MVP)

> **Concept:** Tactical stealth puzzle. Switch between a high-flying scout and a rugged ground saboteur to infiltrate complex facilities.

## 1. Core Loop (The "Switch & Solve")
1.  **Deploy:** Both drones start at the insertion point.
2.  **Infiltrate:** Swap between drones to overcome specific obstacles.
3.  **Interact:** Open paths, disable security, and hack terminals.
4.  **Objective:** Coordinate both drones to the "Server Room".
5.  **Exfiltrate:** Both units must survive.

## 2. The Units

### 🚁 The Spectre (Air Unit)
*   **Role:** Scout, High-Angle Hack, Distraction.
*   **Movement:** High inertia (drifty), fast.
*   **Passives:**
    *   *Flyover:* Ignores "Low Obstacles" (desks, small crates, tripwires).
    *   *Fragile:* Detected easily, dies instantly to defenses.
*   **Limits:** Short battery life. Cannot use physical switches.

### 🚜 The Badger (Ground Unit)
*   **Role:** Saboteur, Physical Interaction, Covert.
*   **Movement:** High drag (stops quick), precise, slower.
*   **Passives:**
    *   *Low Profile:* Can hide *under* "Low Obstacles" (tables) to avoid vision.
    *   *Vent Access:* Can travel through small ducts.
*   **Capabilities:** Can push objects, interface with physical ports, survive 1 hit.

## 3. Detailed Environment & Interactables

### 🏗️ Verticality & Cover
*   **High Walls:** Block movement and vision for **BOTH**.
*   **Low Obstacles (Desks/Crates):**
    *   *Air:* Flies over.
    *   *Ground:* Blocks movement, but provides **Hiding** (invisible to guards while under).
*   **Vents:** Block *Air*. Allow *Ground*.
*   **Glass:** Blocks movement for **BOTH**. Allows vision.

### 🔌 Interactables
*   **Terminals (Hacking):**
    *   *Air:* Wireless hack (proximity). Fast but creates a "Signal Ring" (noise).
    *   *Ground:* Physical hack (contact). Slow but silent.
*   **Switches/Levers:** *Ground Only*. Opens doors, disables lasers.
*   **Distractibles:** Vending machines, forklifts. Can be hacked to make noise.

## 4. Visual & Audio Style
*   **Aesthetic:** "Diegetic UI".
    *   *Air View:* Blue tint, waveform overlays, wider FOV.
    *   *Ground View:* Amber tint, grid overlays, flashlight cone.
*   **Audio:** distinct engine hums. Air = High pitch whine. Ground = Low rumble/treads.

## 5. MVP Scope (Level 1: The Warehouse)
*   **Puzzle:** A locked door requires the Ground drone to find a vent, flank a guard, and hit a switch, letting the Air drone fly in to hack the server.
*   **Entities:** 1 Spectre, 1 Badger, Guards, Camera.
