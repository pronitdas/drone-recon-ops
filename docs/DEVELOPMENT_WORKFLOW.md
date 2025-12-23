# ⚡ Dev Workflow & Setup

> **Goal:** Zero friction. Clone, install, fly.

## 1. Setup
```bash
# Install dependencies (pnpm recommended for speed, or npm)
npm install

# Start local dev server (Hot Module Reloading enabled)
npm run dev

# Build for production
npm run build
```

## 2. Development Loop
1.  **Code:** Edit files in `src/`. Vite updates the browser instantly.
2.  **Debug:** 
    *   Press `F1` (or custom key) to toggle **Hitbox/Vision Debug Mode**.
    *   Use browser console to access `window.Game` for quick state hacks.
3.  **Test:** Write small unit tests for complex logic (e.g., "Does raycast hit wall?").
    *   `npm test` (Uses Vitest/Jest).

## 3. Git Conventions
*   **Main Branch:** `main` (Always deployable).
*   **Feature Branches:** `feat/movement`, `fix/collision`.
*   **Commits:** Conventional Commits (`feat: add turbo boost`, `fix: camera jitter`).

## 4. Asset Pipeline
*   **Images:** Place in `public/assets`. Use web-optimized formats (WebP/PNG).
*   **Audio:** MP3/OGG.
*   **Maps:** JSON (Tiled) or programmatic generation for MVP.