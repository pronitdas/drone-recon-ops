# 🏗️ Modern Architecture & Stack

## 1. Tech Stack
*   **Engine:** Phaser 3.
*   **Physics:** Arcade Physics (Customized collision filtering).
*   **Build:** Vite.

## 2. Project Structure
```text
src/
├── components/
│   ├── PhysicsComponent.ts   # Handles Drag/Velocity/Bounce
│   ├── InteractionComponent.ts # For switches/terminals
│   └── VisionComponent.ts    # Raycasting logic
├── entities/
│   ├── drones/
│   │   ├── BaseDrone.ts
│   │   ├── Spectre.ts (Air)
│   │   └── Badger.ts (Ground)
│   └── environment/
│       ├── Wall.ts
│       ├── Vent.ts
│       └── Terminal.ts
├── systems/
│   ├── DroneManager.ts       # Handles swapping active unit
│   └── InteractionManager.ts # Global input for 'E' key
```

## 3. Key Patterns

### 🔄 The "Active Unit" Pattern
The `DroneManager` holds a reference to `currentDrone`. Input events are routed only to this instance.
*   **Camera:** Follows `DroneManager.currentDrone`.
*   **UI:** Updates HUD based on `currentDrone.type` (Blue vs Amber theme).

### 🧩 Interaction System
Decoupled interactions using an interface/event approach.
*   *Input:* Player presses 'E'.
*   *Event:* `Drone` fires `INTERACT_REQUEST`.
*   *System:* Checks overlapping `Interactables`.
*   *Logic:* `Interactable` validates drone type -> Triggers callback (`OpenDoor`).
