# ⚡ Quick Reference Guide
## Drone Recon Ops Developer Cheat Sheet

**For when you need answers fast**

---

## 🚀 Common Commands

### Development Server
```bash
# Start development
npm run dev

# Build for production
npm run build

# Run tests
npm test

# Lint code
npm run lint

# Format code
npm run format
```

### Git Workflow
```bash
# Feature branch workflow
git checkout -b feature/new-system
git add .
git commit -m "feat: add new detection system"
git push origin feature/new-system

# Update from main
git checkout main
git pull origin main
git checkout feature/new-system
git rebase main
```

---

## 🎮 Game Systems Quick Access

### Drone Physics
```typescript
// Create drone with custom config
const drone = new Drone({
  scene: this,
  x: 100, y: 100,
  maxSpeed: 200,
  batteryCapacity: 100
});

// Movement input (normalized -1 to 1)
drone.setMovementInput({ x: 1, y: 0 }); // Right
drone.setMovementInput({ x: 0, y: -1 }); // Up

// Toggle precision mode
drone.togglePrecisionMode();

// Get status
const battery = drone.getBatteryLevel(); // 0-100
const noise = drone.getNoiseLevel(); // 0-5
const critical = drone.isBatteryCritical(); // boolean
```

### Detection System
```typescript
// Check line of sight
const visible = detectionSystem.checkVisibility(
  dronePosition,
  guardPosition
);

// Get detection level
const level = detectionSystem.getDetectionLevel();
// Returns: 'safe' | 'caution' | 'alert' | 'discovered'

// Add detector
detectionSystem.addDetector({
  position: { x: 200, y: 200 },
  range: 150,
  fieldOfView: 90
});
```

### Mission System
```typescript
// Load mission
missionSystem.loadMission({
  id: 'mission-01',
  objectives: [
    { type: 'reach', target: { x: 500, y: 300 } },
    { type: 'photograph', target: 'evidence-01' }
  ]
});

// Check progress
const current = missionSystem.getCurrentObjective();
const complete = missionSystem.isComplete();
const score = missionSystem.getScore();
```

### Event System
```typescript
// Subscribe to events
eventBus.on('drone.battery.critical', (payload) => {
  console.log(`Drone ${payload.droneId} battery: ${payload.batteryLevel}%`);
});

// Emit events
eventBus.emit('mission.objective.completed', {
  objectiveId: 'obj-01',
  completionTime: 1500,
  score: 850
});
```

---

## 🔧 Phaser.js Quick Reference

### Scene Lifecycle
```typescript
class GameScene extends Phaser.Scene {
  preload(): void {
    // Load assets before scene starts
    this.load.image('drone', 'assets/drone.png');
  }
  
  create(): void {
    // Initialize scene objects
    this.drone = this.add.sprite(100, 100, 'drone');
  }
  
  update(time: number, delta: number): void {
    // Called every frame
    this.drone.update(delta);
  }
}
```

### Common Phaser Patterns
```typescript
// Create sprite with physics
const sprite = this.physics.add.sprite(x, y, 'texture');
sprite.setCollideWorldBounds(true);

// Input handling
const cursors = this.input.keyboard.createCursorKeys();
if (cursors.left.isDown) { /* handle input */ }

// Collision detection
this.physics.add.overlap(player, enemy, this.onCollision, null, this);

// Tweens (animations)
this.tweens.add({
  targets: sprite,
  x: 400,
  duration: 1000,
  ease: 'Power2'
});

// Groups for multiple objects
const enemies = this.physics.add.group();
enemies.create(100, 100, 'enemy');
```

---

## 📝 TypeScript Patterns

### Component System
```typescript
// Generic component with config
abstract class Component<T = {}> {
  constructor(
    public entity: GameEntity,
    protected config: T
  ) {}
  
  abstract update(deltaTime: number): void;
}

// Usage
interface MovementConfig {
  speed: number;
  acceleration: number;
}

class MovementComponent extends Component<MovementConfig> {
  update(deltaTime: number): void {
    // this.config.speed is type-safe
  }
}
```

### State Machine
```typescript
// Union type for states
type AIState = 
  | { type: 'idle'; duration: number }
  | { type: 'patrol'; waypoints: Vector2[] }
  | { type: 'chase'; target: GameEntity };

// Type-safe state handling
switch (state.type) {
  case 'idle':
    // state.duration is available
    break;
  case 'patrol':
    // state.waypoints is available
    break;
}
```

### Event Types
```typescript
// Define event map
interface GameEvents {
  'player.moved': { position: Vector2 };
  'enemy.spawned': { id: string; position: Vector2 };
}

// Type-safe event emitter
eventBus.on('player.moved', (data) => {
  // data is automatically typed
  console.log(data.position.x, data.position.y);
});
```

---

## 🏗️ Architecture Patterns

### Dependency Injection
```typescript
// Service container
const container = new ServiceContainer();

// Register services
container.register(PhysicsSystem, () => new PhysicsSystem(config));
container.register(AudioSystem, () => new AudioSystem(config));

// Resolve with type safety
const physics = container.resolve(PhysicsSystem);
```

### Observer Pattern
```typescript
interface Observer<T> {
  update(data: T): void;
}

class Subject<T> {
  private observers: Observer<T>[] = [];
  
  subscribe(observer: Observer<T>): void {
    this.observers.push(observer);
  }
  
  notify(data: T): void {
    this.observers.forEach(obs => obs.update(data));
  }
}
```

---

## 🎯 Performance Tips

### Object Pooling
```typescript
// Create pool for frequently created/destroyed objects
const bulletPool = new ObjectPool(() => new Bullet(), 50);

// Use pooled objects
const bullet = bulletPool.acquire();
bullet.fire(direction);

// Return to pool when done
bulletPool.release(bullet);
```

### Efficient Updates
```typescript
// Good: Only update when necessary
if (entity.isActive() && entity.needsUpdate()) {
  entity.update(deltaTime);
}

// Good: Batch operations
entities.forEach(entity => entity.update(deltaTime));

// Bad: Individual operations in loop
for (let i = 0; i < entities.length; i++) {
  if (entities[i].active) {
    entities[i].x += 1;
    entities[i].y += 1;
    entities[i].render();
  }
}
```

### Memory Management
```typescript
// Clean up listeners
eventBus.off('event.name', this.handler);

// Destroy objects
sprite.destroy();

// Clear references
this.enemies = null;
```

---

## 🐛 Common Issues & Solutions

### Physics Not Working
```typescript
// ✅ Make sure physics is enabled
scene.physics.add.existing(sprite);

// ✅ Check world bounds
sprite.setCollideWorldBounds(true);

// ✅ Verify body exists
if (sprite.body) {
  sprite.body.setVelocity(100, 0);
}
```

### Sprites Not Visible
```typescript
// ✅ Check sprite is added to scene
scene.add.existing(sprite);

// ✅ Verify position is in camera bounds
sprite.setPosition(400, 300); // Center of 800x600 game

// ✅ Check depth/layer
sprite.setDepth(10);

// ✅ Ensure texture is loaded
scene.load.image('key', 'path/to/image.png');
```

### Input Not Responding
```typescript
// ✅ Create input in create() method
this.cursors = this.input.keyboard.createCursorKeys();

// ✅ Check input in update() method
if (this.cursors.left.isDown) { /* handle */ }

// ✅ Verify scene is active
this.scene.isActive(); // should return true
```

### Performance Issues
```typescript
// ✅ Disable debug mode
physics: {
  default: 'arcade',
  arcade: { debug: false }
}

// ✅ Limit particle count
const particles = this.add.particles(x, y, 'texture', {
  maxParticles: 50
});

// ✅ Use object pools
const pool = new ObjectPool(() => new Enemy(), 20);
```

---

## 📊 Debug Commands

### Console Debugging
```typescript
// Scene debugging
console.log('Active scenes:', this.scene.manager.keys);
console.log('Scene status:', this.scene.isActive());

// Entity debugging
console.log('Sprite position:', sprite.x, sprite.y);
console.log('Physics body:', sprite.body);

// Performance monitoring
console.time('updateLoop');
// ... update code ...
console.timeEnd('updateLoop');
```

### Phaser Debug Features
```typescript
// Enable physics debug
physics: {
  default: 'arcade',
  arcade: { debug: true }
}

// Debug info overlay
this.add.text(10, 10, () => `FPS: ${this.game.loop.actualFps.toFixed(1)}`, {
  fontSize: '16px'
});
```

---

## 📋 Useful Constants

### Game Configuration
```typescript
export const GAME_CONFIG = {
  WIDTH: 800,
  HEIGHT: 600,
  BACKGROUND_COLOR: '#2c3e50',
  PHYSICS_FPS: 60,
  DEBUG_MODE: false
} as const;
```

### Physics Values
```typescript
export const PHYSICS = {
  DRONE_SPEED: 200,
  DRONE_ACCELERATION: 300,
  DRONE_DRAG: 0.8,
  WORLD_GRAVITY: { x: 0, y: 0 }
} as const;
```

### Asset Paths
```typescript
export const ASSETS = {
  IMAGES: {
    DRONE: 'assets/images/drone.png',
    GUARD: 'assets/images/guard.png',
    BACKGROUND: 'assets/images/background.jpg'
  },
  AUDIO: {
    ENGINE: 'assets/audio/engine.mp3',
    ALERT: 'assets/audio/alert.wav'
  }
} as const;
```

---

## 🔗 Links

### Documentation
- [Main README](README.md) - Overview and navigation
- [Beginner Guide](BEGINNER_GUIDE.md) - Get started
- [Architecture](ARCHITECTURE.md) - System design
- [Patterns](PATTERNS_AND_SOLUTIONS.md) - Code patterns
- [TypeScript Patterns](TYPESCRIPT_PATTERNS.md) - Advanced typing

### External Resources
- [Phaser 3 Documentation](https://photonstorm.github.io/phaser3-docs/)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
- [MDN Web Docs](https://developer.mozilla.org/)

### Tools
- [VS Code](https://code.visualstudio.com/) - Editor
- [Vite](https://vitejs.dev/) - Build tool
- [Jest](https://jestjs.io/) - Testing
- [ESLint](https://eslint.org/) - Linting

---

*📌 Bookmark this page for quick access to common patterns and solutions!* 