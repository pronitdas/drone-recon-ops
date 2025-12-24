# 🤖 Agent Development Guide & Protocols

This guide outlines the operational context, constraints, and workflows for AI agents working on the **Neon Spectre** project.

## 1. Environment & Tooling
**CRITICAL:** This project uses **Bun** as the package manager and runtime.
*   ❌ Do NOT use `npm` or `pnpm`.
*   ✅ Use `bun` for all script executions.

### Common Commands
| Action | Command |
| :--- | :--- |
| **Install Deps** | `bun install` |
| **Dev Server** | `bun run dev` |
| **Build** | `bun run build` |
| **Lint** | `bun run lint` |
| **Test** | `bun run test` |

## 2. Project Structure
*   **Engine:** Phaser 3 (Arcade Physics).
*   **Language:** TypeScript (Strict mode).
*   **Build Tool:** Vite.
*   **Entry Point:** `src/main.ts`.
*   **Scenes:** `src/scenes/` (Boot, Game, UI).
*   **Entities:** `src/entities/` (Prefabs extending `Phaser.Physics.Arcade.Sprite`).

## 3. Operational Protocols
1.  **Verification First:** Always read relevant files (`GameScene.ts`, `BaseDrone.ts`, etc.) before proposing changes.
2.  **Atomic Changes:** Break down complex features into "Chunks" as defined in `IMPLEMENTATION_GUIDE.md`.
3.  **Type Safety:** Avoid `any`. Use Phaser types (`Phaser.Scene`, `Phaser.Physics.Arcade.Sprite`) explicitly.
4.  **Asset Handling:**
    *   Current Phase: Use programmatic graphics (`this.make.graphics`) in `BootScene.ts`.
    *   Future Phase: Load external assets in `preload()`.

## 4. Current Status (Context)
*   **Active Phase:** Phase 2 (The Detailed World).
*   **Recent Changes:** 
    *   Added `vents` StaticGroup.
    *   Implemented collision logic: `Spectre` hits Walls/Vents, `Badger` hits Walls/LowWalls.
    *   Added placeholder textures for 'vent'.

## 5. Next Steps
*   Refine `chunk 2.1` implementation.
*   Implement Z-Ordering (Chunk 2.2).
*   Prepare for Tilemap integration (Chunk 2.3).
