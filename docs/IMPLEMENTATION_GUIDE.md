# 🛠️ Implementation Guide: Neon Spectre (Dual Ops)

> **Status:** Phase 1 Complete. Phase 2 Ready to Start.

## Phase 1: Dual Physics & Control (✅ Done)
*   **Physics Layers:** Air and Ground drones with distinct movement feel (Drift vs. Grip).
*   **Control Manager:** `DroneManager` handles swapping (`TAB`) and input routing.
*   **Foundation:** Basic `GameScene` with static wall collisions.

## Phase 2: The Detailed World (✅ Done)
**Goal:** Create a rich environment where verticality matters.
1.  **Chunk 2.1: Advanced Collisions (✅ Done)**
    *   Implement "Low Wall" logic:
        *   `Spectre` (Air) flies *over* Low Walls (no collision).
        *   `Badger` (Ground) is blocked by Low Walls.
    *   Implement "Vents":
        *   `Spectre` is blocked.
        *   `Badger` passes through.
2.  **Chunk 2.2: Visual Depth & Layers (✅ Done)**
    *   **Z-Ordering:** Ensure Ground Drone renders *below* Low Walls, Air Drone *above*.
    *   **Hiding Spots:** Create "Under Desk" zones where the Ground drone becomes invisible to AI.
3.  **Chunk 2.3: Tilemap Integration (✅ Done)**
    *   Replace procedural blocks with a real Tiled (JSON) map.
    *   Parse custom properties (`collides: true`, `height: low`) from the map.

## Phase 3: Interaction System (Next)
**Goal:** Make the world tactile and solvable.
1.  **Chunk 3.1: The Interaction Engine**
    *   Create `IInteractable` interface.
    *   Implement `InteractionManager`: Listens for `E`, finds nearest valid object.
2.  **Chunk 3.2: Object Types**
    *   **Terminals:** "Hack" logic (Hold E for X seconds).
    *   **Switches:** Instant toggle (Doors Open/Close).
    *   **Heavy Objects:** Pushable crates (Physics-based).
3.  **Chunk 3.3: Drone Specifics**
    *   Air: Can only Hack (Wireless).
    *   Ground: Can Hack (Wired), Push, and Toggle Switches.

## Phase 4: Stealth & AI
**Goal:** Tension and threat.
1.  **Chunk 4.1: The Senses**
    *   **Vision:** Raycasting cones. Blocked by High Walls.
        *   *Special:* Air Drone seen over Low Walls. Ground Drone hidden by Low Walls (if ducking/under).
    *   **Audio:** "Noise Rings". Air = Loud when fast. Ground = Quiet but constant rumble.
2.  **Chunk 4.2: Guard Behavior**
    *   Patrol Paths (Waypoints).
    *   States: Idle -> Suspicious (Investigate Noise) -> Alert (Chase).
3.  **Chunk 4.3: Cameras & Turrets**
    *   Static rotating cones.
    *   Hacking a terminal disables them.

## Phase 5: Mission Loop & UI
**Goal:** A complete playable level.
1.  **Chunk 5.1: The HUD**
    *   "Diegetic" overlays.
    *   Air: Blue tint, waveform data.
    *   Ground: Amber tint, grid overlay.
2.  **Chunk 5.2: Objectives**
    *   "Find Keycard" (Badger) -> "Unlock Door" (Badger) -> "Fly to Server" (Spectre) -> "Hack" (Spectre).
3.  **Chunk 5.3: Win/Loss**
    *   Exfiltration zone.
    *   Battery timers.