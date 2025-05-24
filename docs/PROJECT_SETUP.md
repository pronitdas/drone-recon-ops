# Project Setup Guide: Drone Recon Ops
## 📚 For Junior Developers

**Version**: 1.0  
**Date**: December 2024  
**Status**: Implementation Ready  

---

## 🎯 What We're Building

A tactical stealth game where players control surveillance drones to complete reconnaissance missions. Think of it like the drone sequences from Rainbow Six Siege, but as a full game.

### Key Features:
- **Drone flight mechanics** with realistic physics
- **Stealth detection systems** (visual and audio)
- **AI patrol behaviors** for enemies
- **Mission objectives** (surveillance, data extraction)
- **Web-based** for easy distribution

---

## 🛠️ Prerequisites

Before we start, make sure you have these tools installed:

### Required Software:
1. **Node.js** (v18 or higher) - [Download here](https://nodejs.org/)
2. **Git** - [Download here](https://git-scm.com/)
3. **VS Code** (recommended) - [Download here](https://code.visualstudio.com/)

### VS Code Extensions (Recommended):
- TypeScript and JavaScript Language Features (built-in)
- ESLint
- Prettier - Code formatter
- Live Server
- Bracket Pair Colorizer

### Verify Installation:
```bash
# Check Node.js version
node --version  # Should show v18+ 

# Check npm version  
npm --version   # Should show 8+

# Check Git version
git --version   # Should show 2.0+
```

---

## 🚀 Step 1: Project Initialization

### 1.1 Create Project Directory
```bash
# Create and navigate to project folder
mkdir drone-recon-ops
cd drone-recon-ops

# Initialize Git repository
git init

# Create initial folder structure
mkdir -p src/{core,systems,entities,scenes,types,utils}
mkdir -p assets/{images,audio,data}
mkdir -p docs
mkdir -p tests
```

### 1.2 Initialize Node.js Project
```bash
# Create package.json
npm init -y
```

### 1.3 Install Dependencies
```bash
# Core dependencies
npm install phaser@3.88.2

# Development dependencies
npm install --save-dev \
  typescript@5.3.0 \
  vite@5.0.0 \
  @types/node@20.0.0 \
  eslint@8.55.0 \
  @typescript-eslint/eslint-plugin@6.15.0 \
  @typescript-eslint/parser@6.15.0 \
  prettier@3.1.0 \
  jest@29.7.0 \
  @types/jest@29.5.0 \
  ts-jest@29.1.0
```

**Why these dependencies?**
- `phaser`: Our game framework
- `typescript`: Type safety and better development experience
- `vite`: Fast build tool and dev server
- `eslint`: Code linting for consistency
- `prettier`: Code formatting
- `jest`: Testing framework

---

## 📝 Step 2: Configuration Files

### 2.1 TypeScript Configuration (`tsconfig.json`)
```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "ESNext",
    "moduleResolution": "node",
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "declaration": true,
    "outDir": "./dist",
    "rootDir": "./src",
    "baseUrl": "./src",
    "paths": {
      "@/*": ["*"],
      "@core/*": ["core/*"],
      "@systems/*": ["systems/*"],
      "@entities/*": ["entities/*"],
      "@scenes/*": ["scenes/*"],
      "@types/*": ["types/*"],
      "@utils/*": ["utils/*"]
    }
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "tests"]
}
```

**What this does:**
- Sets up modern TypeScript compilation
- Enables strict type checking
- Creates path aliases for cleaner imports (e.g., `@core/GameEngine` instead of `../../core/GameEngine`)

### 2.2 Vite Configuration (`vite.config.ts`)
```typescript
import { defineConfig } from 'vite';
import { resolve } from 'path';

export default defineConfig({
  root: '.',
  base: './',
  resolve: {
    alias: {
      '@': resolve(__dirname, 'src'),
      '@core': resolve(__dirname, 'src/core'),
      '@systems': resolve(__dirname, 'src/systems'),
      '@entities': resolve(__dirname, 'src/entities'),
      '@scenes': resolve(__dirname, 'src/scenes'),
      '@types': resolve(__dirname, 'src/types'),
      '@utils': resolve(__dirname, 'src/utils')
    }
  },
  server: {
    port: 3000,
    open: true
  },
  build: {
    outDir: 'dist',
    assetsDir: 'assets',
    sourcemap: true,
    target: 'es2020'
  }
});
```

### 2.3 ESLint Configuration (`.eslintrc.js`)
```javascript
module.exports = {
  env: {
    browser: true,
    es2021: true,
    node: true,
    jest: true
  },
  extends: [
    'eslint:recommended',
    '@typescript-eslint/recommended'
  ],
  parser: '@typescript-eslint/parser',
  parserOptions: {
    ecmaVersion: 'latest',
    sourceType: 'module'
  },
  plugins: ['@typescript-eslint'],
  rules: {
    'no-console': 'warn',
    '@typescript-eslint/no-unused-vars': 'error',
    '@typescript-eslint/explicit-function-return-type': 'warn',
    '@typescript-eslint/no-explicit-any': 'warn'
  }
};
```

### 2.4 Prettier Configuration (`.prettierrc`)
```json
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 80,
  "tabWidth": 2,
  "useTabs": false
}
```

### 2.5 Jest Configuration (`jest.config.js`)
```javascript
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'jsdom',
  roots: ['<rootDir>/src', '<rootDir>/tests'],
  moduleNameMapping: {
    '^@/(.*)$': '<rootDir>/src/$1',
    '^@core/(.*)$': '<rootDir>/src/core/$1',
    '^@systems/(.*)$': '<rootDir>/src/systems/$1',
    '^@entities/(.*)$': '<rootDir>/src/entities/$1',
    '^@scenes/(.*)$': '<rootDir>/src/scenes/$1',
    '^@types/(.*)$': '<rootDir>/src/types/$1',
    '^@utils/(.*)$': '<rootDir>/src/utils/$1'
  },
  testMatch: [
    '**/__tests__/**/*.(ts|js)',
    '**/?(*.)(spec|test).(ts|js)'
  ],
  collectCoverageFrom: [
    'src/**/*.(ts|js)',
    '!src/**/*.d.ts'
  ]
};
```

---

## 📦 Step 3: Package.json Scripts

Update your `package.json` with these scripts:

```json
{
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "preview": "vite preview",
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage",
    "lint": "eslint src/**/*.ts",
    "lint:fix": "eslint src/**/*.ts --fix",
    "format": "prettier --write src/**/*.ts",
    "type-check": "tsc --noEmit"
  }
}
```

**What each script does:**
- `dev`: Starts development server with hot reload
- `build`: Compiles TypeScript and builds for production
- `test`: Runs all tests
- `lint`: Checks code for style issues
- `format`: Auto-formats code

---

## 🌐 Step 4: HTML Entry Point

Create `index.html` in the root directory:

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Drone Recon Ops</title>
    <style>
        body {
            margin: 0;
            padding: 0;
            background-color: #1a1a1a;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            font-family: Arial, sans-serif;
        }
        
        #game-container {
            border: 2px solid #333;
            border-radius: 8px;
            overflow: hidden;
        }
        
        #loading {
            color: #00ff00;
            text-align: center;
            padding: 20px;
        }
    </style>
</head>
<body>
    <div id="game-container">
        <div id="loading">Loading Drone Recon Ops...</div>
    </div>
    <script type="module" src="/src/main.ts"></script>
</body>
</html>
```

---

## 🎮 Step 5: Basic Game Setup

### 5.1 Type Definitions (`src/types/index.ts`)
```typescript
// Core interfaces
export interface IGameSystem {
  name: string;
  initialize(): Promise<void>;
  update(deltaTime: number): void;
  shutdown(): void;
}

export interface IEvent {
  type: string;
  payload: any;
  timestamp: number;
}

// Game state
export interface GameConfig {
  width: number;
  height: number;
  backgroundColor: string;
  physics: {
    gravity: { x: number; y: number };
    debug: boolean;
  };
}

// Vector utilities
export interface Vector2 {
  x: number;
  y: number;
}

// Detection system
export enum DetectionLevel {
  SAFE = 'safe',
  CAUTION = 'caution', 
  ALERT = 'alert',
  DISCOVERED = 'discovered'
}
```

### 5.2 Event System (`src/core/EventBus.ts`)
```typescript
import { IEvent } from '@types/index';

export class EventBus {
  private listeners: Map<string, Array<(event: IEvent) => void>> = new Map();

  subscribe(eventType: string, callback: (event: IEvent) => void): void {
    if (!this.listeners.has(eventType)) {
      this.listeners.set(eventType, []);
    }
    this.listeners.get(eventType)!.push(callback);
  }

  unsubscribe(eventType: string, callback: (event: IEvent) => void): void {
    const callbacks = this.listeners.get(eventType);
    if (callbacks) {
      const index = callbacks.indexOf(callback);
      if (index > -1) {
        callbacks.splice(index, 1);
      }
    }
  }

  emit(eventType: string, payload: any): void {
    const event: IEvent = {
      type: eventType,
      payload,
      timestamp: Date.now()
    };

    const callbacks = this.listeners.get(eventType);
    if (callbacks) {
      callbacks.forEach(callback => callback(event));
    }
  }
}
```

### 5.3 Game Engine Core (`src/core/GameEngine.ts`)
```typescript
import { Scene, Game } from 'phaser';
import { IGameSystem, GameConfig } from '@types/index';
import { EventBus } from './EventBus';

export class GameEngine {
  private systems: Map<string, IGameSystem> = new Map();
  private eventBus: EventBus = new EventBus();
  private game: Game | null = null;

  constructor(private config: GameConfig) {}

  addSystem(system: IGameSystem): void {
    this.systems.set(system.name, system);
  }

  getSystem<T extends IGameSystem>(name: string): T | null {
    return (this.systems.get(name) as T) || null;
  }

  getEventBus(): EventBus {
    return this.eventBus;
  }

  async initialize(): Promise<void> {
    // Initialize Phaser game
    const phaserConfig = {
      type: Phaser.AUTO,
      width: this.config.width,
      height: this.config.height,
      backgroundColor: this.config.backgroundColor,
      parent: 'game-container',
      physics: {
        default: 'arcade',
        arcade: {
          gravity: this.config.physics.gravity,
          debug: this.config.physics.debug
        }
      }
    };

    this.game = new Game(phaserConfig);

    // Initialize all systems
    for (const system of this.systems.values()) {
      await system.initialize();
    }

    console.log('Game engine initialized successfully');
  }

  update(deltaTime: number): void {
    // Update all systems
    for (const system of this.systems.values()) {
      system.update(deltaTime);
    }
  }

  shutdown(): void {
    // Shutdown all systems
    for (const system of this.systems.values()) {
      system.shutdown();
    }

    if (this.game) {
      this.game.destroy(true);
    }
  }
}
```

### 5.4 Main Entry Point (`src/main.ts`)
```typescript
import { GameEngine } from '@core/GameEngine';
import { GameConfig } from '@types/index';

// Game configuration
const gameConfig: GameConfig = {
  width: 1024,
  height: 768,
  backgroundColor: '#2c3e50',
  physics: {
    gravity: { x: 0, y: 0 }, // No gravity for top-down drone game
    debug: true // Enable physics debugging for development
  }
};

// Initialize and start the game
async function startGame(): Promise<void> {
  try {
    const gameEngine = new GameEngine(gameConfig);
    
    // TODO: Add game systems here
    // gameEngine.addSystem(new DroneSystem());
    // gameEngine.addSystem(new DetectionSystem());
    // gameEngine.addSystem(new MissionSystem());
    
    await gameEngine.initialize();
    
    // Hide loading message
    const loadingElement = document.getElementById('loading');
    if (loadingElement) {
      loadingElement.style.display = 'none';
    }
    
    console.log('🚁 Drone Recon Ops started successfully!');
  } catch (error) {
    console.error('Failed to start game:', error);
  }
}

// Start the game when the page loads
window.addEventListener('load', startGame);
```

---

## ✅ Step 6: Verification

### 6.1 Test the Setup
```bash
# Install all dependencies
npm install

# Run type checking
npm run type-check

# Run linting
npm run lint

# Start development server
npm run dev
```

### 6.2 What You Should See
1. **Terminal**: No TypeScript errors, server running on `http://localhost:3000`
2. **Browser**: Black game canvas with "Drone Recon Ops started successfully!" in console
3. **No errors** in browser console

### 6.3 Project Structure Check
Your folder structure should look like this:
```
drone-recon-ops/
├── src/
│   ├── core/
│   │   ├── EventBus.ts
│   │   └── GameEngine.ts
│   ├── systems/
│   ├── entities/
│   ├── scenes/
│   ├── types/
│   │   └── index.ts
│   ├── utils/
│   └── main.ts
├── assets/
├── docs/
├── tests/
├── index.html
├── package.json
├── tsconfig.json
├── vite.config.ts
├── .eslintrc.js
├── .prettierrc
└── jest.config.js
```

---

## 🐛 Common Issues & Solutions

### Issue: "Cannot resolve module" errors
**Solution**: Make sure your `tsconfig.json` path mapping matches your `vite.config.ts` aliases.

### Issue: Phaser not loading
**Solution**: Check that you have the correct Phaser version installed and imported properly.

### Issue: ESLint errors
**Solution**: Run `npm run lint:fix` to auto-fix many issues, or adjust rules in `.eslintrc.js`.

### Issue: TypeScript compilation errors
**Solution**: Run `npm run type-check` to see detailed errors, check your types in `src/types/index.ts`.

---

## 🎉 Next Steps

Congratulations! You now have a solid foundation for the Drone Recon Ops game. 

**What we've accomplished:**
- ✅ Modern TypeScript development environment
- ✅ Phaser.js game engine integration
- ✅ Modular architecture foundation
- ✅ Development tools (linting, formatting, testing)
- ✅ Build and deployment pipeline

**Next up:**
1. Read `IMPLEMENTATION_GUIDE.md` to start building game systems
2. Check out `DEVELOPMENT_WORKFLOW.md` for best practices
3. Review `PATTERNS_AND_SOLUTIONS.md` for common challenges

**Questions?** Check the troubleshooting section or refer to the [Phaser.js documentation](https://phaser.io/phaser3/documentation).

---

## 📚 Additional Resources

- [Phaser.js Getting Started](https://phaser.io/learn)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
- [Vite Guide](https://vitejs.dev/guide/)
- [Jest Testing Framework](https://jestjs.io/docs/getting-started)

Happy coding! 🚁✨ 