# Patterns & Solutions Guide: Drone Recon Ops
## 🧩 Common Challenges & Game Development Patterns

**Version**: 1.0  
**Date**: December 2024  
**Status**: Implementation Ready  

---

## 📋 Overview

This guide covers common patterns, challenges, and solutions you'll encounter while developing Drone Recon Ops. Each section includes practical examples, best practices, and code solutions that junior developers can understand and apply.

### What's Covered:
- **Game Programming Patterns** - Common design patterns for games
- **Phaser.js Specific Solutions** - Framework-specific challenges
- **Performance Optimization** - Making your game run smoothly
- **State Management** - Handling complex game states
- **Event-Driven Architecture** - Loose coupling between systems
- **Common Bugs** - How to avoid and fix typical issues

---

## 🎮 Game Programming Patterns

### 1. Component Pattern

**Problem**: Game objects need different behaviors (movement, health, AI, etc.), but inheritance becomes messy.

**Solution**: Use composition over inheritance with components.

```typescript
// Base component interface
interface IComponent {
  name: string;
  update(deltaTime: number): void;
  shutdown(): void;
}

// Individual components
class MovementComponent implements IComponent {
  name = 'MovementComponent';
  
  constructor(private entity: GameEntity, private speed: number) {}
  
  update(deltaTime: number): void {
    // Handle movement logic
  }
  
  shutdown(): void {
    // Cleanup
  }
}

class HealthComponent implements IComponent {
  name = 'HealthComponent';
  private health = 100;
  
  constructor(private entity: GameEntity) {}
  
  takeDamage(amount: number): void {
    this.health -= amount;
    if (this.health <= 0) {
      this.entity.destroy();
    }
  }
  
  update(deltaTime: number): void {
    // Health regeneration logic
  }
  
  shutdown(): void {}
}

// Entity with components
class GameEntity {
  private components: Map<string, IComponent> = new Map();
  
  addComponent(component: IComponent): void {
    this.components.set(component.name, component);
  }
  
  getComponent<T extends IComponent>(name: string): T | null {
    return (this.components.get(name) as T) || null;
  }
  
  update(deltaTime: number): void {
    for (const component of this.components.values()) {
      component.update(deltaTime);
    }
  }
  
  destroy(): void {
    for (const component of this.components.values()) {
      component.shutdown();
    }
    this.components.clear();
  }
}

// Usage
const drone = new GameEntity();
drone.addComponent(new MovementComponent(drone, 150));
drone.addComponent(new HealthComponent(drone));

// Access components
const movement = drone.getComponent<MovementComponent>('MovementComponent');
const health = drone.getComponent<HealthComponent>('HealthComponent');
```

**When to use**: When you have entities that need different combinations of behaviors.

---

### 2. State Machine Pattern

**Problem**: Complex behavior with many states (idle, patrol, chase, etc.) becomes hard to manage.

**Solution**: Use a finite state machine to organize behavior.

```typescript
// State interface
interface IState {
  name: string;
  enter(entity: any): void;
  update(entity: any, deltaTime: number): void;
  exit(entity: any): void;
}

// Concrete states
class IdleState implements IState {
  name = 'idle';
  
  enter(guard: AIGuard): void {
    guard.setVelocity(0, 0);
    console.log('Guard entered idle state');
  }
  
  update(guard: AIGuard, deltaTime: number): void {
    // Look around occasionally
    if (Math.random() < 0.001) {
      guard.setDirection(Math.random() * 360);
    }
  }
  
  exit(guard: AIGuard): void {
    console.log('Guard exited idle state');
  }
}

class PatrolState implements IState {
  name = 'patrol';
  
  enter(guard: AIGuard): void {
    console.log('Guard started patrolling');
  }
  
  update(guard: AIGuard, deltaTime: number): void {
    // Move along patrol route
    guard.moveToNextWaypoint();
  }
  
  exit(guard: AIGuard): void {
    console.log('Guard stopped patrolling');
  }
}

// State machine
class StateMachine {
  private currentState: IState | null = null;
  private states: Map<string, IState> = new Map();
  
  addState(state: IState): void {
    this.states.set(state.name, state);
  }
  
  changeState(stateName: string, entity: any): void {
    const newState = this.states.get(stateName);
    if (!newState) {
      console.error(`State ${stateName} not found`);
      return;
    }
    
    if (this.currentState) {
      this.currentState.exit(entity);
    }
    
    this.currentState = newState;
    this.currentState.enter(entity);
  }
  
  update(entity: any, deltaTime: number): void {
    if (this.currentState) {
      this.currentState.update(entity, deltaTime);
    }
  }
  
  getCurrentStateName(): string {
    return this.currentState?.name || 'none';
  }
}

// Usage in AI Guard
class AIGuard {
  private stateMachine = new StateMachine();
  
  constructor() {
    this.stateMachine.addState(new IdleState());
    this.stateMachine.addState(new PatrolState());
    this.stateMachine.changeState('idle', this);
  }
  
  update(deltaTime: number): void {
    this.stateMachine.update(this, deltaTime);
  }
  
  onDetectionEvent(level: DetectionLevel): void {
    switch (level) {
      case DetectionLevel.SAFE:
        this.stateMachine.changeState('patrol', this);
        break;
      case DetectionLevel.ALERT:
        this.stateMachine.changeState('chase', this);
        break;
    }
  }
}
```

**When to use**: When an entity has multiple distinct behaviors that shouldn't overlap.

---

### 3. Observer Pattern (Event System)

**Problem**: Systems need to communicate without tight coupling.

**Solution**: Use events to decouple systems.

```typescript
// Event types
type EventCallback<T = any> = (data: T) => void;

// Event emitter
class EventEmitter {
  private listeners: Map<string, EventCallback[]> = new Map();
  
  on<T>(event: string, callback: EventCallback<T>): void {
    if (!this.listeners.has(event)) {
      this.listeners.set(event, []);
    }
    this.listeners.get(event)!.push(callback);
  }
  
  off<T>(event: string, callback: EventCallback<T>): void {
    const callbacks = this.listeners.get(event);
    if (callbacks) {
      const index = callbacks.indexOf(callback);
      if (index > -1) {
        callbacks.splice(index, 1);
      }
    }
  }
  
  emit<T>(event: string, data?: T): void {
    const callbacks = this.listeners.get(event);
    if (callbacks) {
      callbacks.forEach(callback => callback(data));
    }
  }
}

// Global event bus
export const GameEvents = new EventEmitter();

// Usage across systems
class DroneSystem {
  constructor() {
    // Listen for detection events
    GameEvents.on('detection:levelChanged', this.onDetectionChanged.bind(this));
  }
  
  private onDetectionChanged(data: { level: DetectionLevel }): void {
    console.log('Drone received detection update:', data.level);
    // React to detection level
  }
  
  // Emit events for other systems
  private onBatteryLow(): void {
    GameEvents.emit('drone:batteryLow', { level: this.batteryLevel });
  }
}

class UISystem {
  constructor() {
    // Listen for drone events
    GameEvents.on('drone:batteryLow', this.showBatteryWarning.bind(this));
    GameEvents.on('detection:levelChanged', this.updateDetectionIndicator.bind(this));
  }
  
  private showBatteryWarning(data: { level: number }): void {
    // Show UI warning
  }
  
  private updateDetectionIndicator(data: { level: DetectionLevel }): void {
    // Update UI detection indicator
  }
}
```

**When to use**: When systems need to communicate but shouldn't be directly coupled.

---

### 4. Object Pool Pattern

**Problem**: Creating/destroying many objects causes performance issues and garbage collection spikes.

**Solution**: Reuse objects from a pool.

```typescript
// Generic object pool
class ObjectPool<T> {
  private pool: T[] = [];
  private createFn: () => T;
  private resetFn: (obj: T) => void;
  private maxSize: number;
  
  constructor(
    createFn: () => T,
    resetFn: (obj: T) => void,
    initialSize = 10,
    maxSize = 100
  ) {
    this.createFn = createFn;
    this.resetFn = resetFn;
    this.maxSize = maxSize;
    
    // Pre-populate pool
    for (let i = 0; i < initialSize; i++) {
      this.pool.push(this.createFn());
    }
  }
  
  acquire(): T {
    if (this.pool.length > 0) {
      return this.pool.pop()!;
    }
    return this.createFn();
  }
  
  release(obj: T): void {
    if (this.pool.length < this.maxSize) {
      this.resetFn(obj);
      this.pool.push(obj);
    }
  }
  
  getPoolSize(): number {
    return this.pool.length;
  }
}

// Specific pools for game objects
class ParticlePoolManager {
  private explosionPool: ObjectPool<Phaser.GameObjects.Sprite>;
  private sparkPool: ObjectPool<Phaser.GameObjects.Sprite>;
  
  constructor(scene: Phaser.Scene) {
    this.explosionPool = new ObjectPool(
      () => scene.add.sprite(0, 0, 'explosion').setVisible(false),
      (sprite) => {
        sprite.setVisible(false);
        sprite.setPosition(0, 0);
        sprite.setScale(1);
        sprite.setAlpha(1);
      },
      5,
      20
    );
    
    this.sparkPool = new ObjectPool(
      () => scene.add.sprite(0, 0, 'spark').setVisible(false),
      (sprite) => {
        sprite.setVisible(false);
        sprite.setPosition(0, 0);
        sprite.setVelocity(0, 0);
      },
      20,
      100
    );
  }
  
  createExplosion(x: number, y: number): void {
    const explosion = this.explosionPool.acquire();
    explosion.setPosition(x, y);
    explosion.setVisible(true);
    
    // Play explosion animation
    explosion.play('explode');
    
    // Return to pool when animation completes
    explosion.once('animationcomplete', () => {
      this.explosionPool.release(explosion);
    });
  }
  
  createSpark(x: number, y: number, velocityX: number, velocityY: number): void {
    const spark = this.sparkPool.acquire();
    spark.setPosition(x, y);
    spark.setVisible(true);
    
    // Add physics and movement
    const body = spark.body as Phaser.Physics.Arcade.Body;
    body.setVelocity(velocityX, velocityY);
    
    // Auto-return to pool after 1 second
    scene.time.delayedCall(1000, () => {
      this.sparkPool.release(spark);
    });
  }
}
```

**When to use**: For frequently created/destroyed objects like particles, bullets, or UI elements.

---

## 🎯 Phaser.js Specific Solutions

### 1. Scene Management

**Problem**: Switching between game scenes, menus, and managing data transfer.

**Solution**: Use Phaser's scene system with proper data passing.

```typescript
// Scene registry for type safety
enum SceneKeys {
  BOOT = 'BootScene',
  MENU = 'MenuScene',
  GAME = 'GameScene',
  PAUSE = 'PauseScene',
  GAME_OVER = 'GameOverScene'
}

// Base scene with common functionality
abstract class BaseScene extends Phaser.Scene {
  protected sceneData: any = {};
  
  constructor(key: string) {
    super({ key });
  }
  
  // Helper methods for scene transitions
  protected goToScene(sceneKey: SceneKeys, data?: any): void {
    this.scene.start(sceneKey, data);
  }
  
  protected pauseAndShowScene(sceneKey: SceneKeys, data?: any): void {
    this.scene.pause();
    this.scene.launch(sceneKey, data);
  }
  
  protected resumeFromPause(): void {
    this.scene.resume();
  }
  
  // Data handling
  init(data: any): void {
    this.sceneData = data || {};
  }
}

// Game scene implementation
class GameScene extends BaseScene {
  private drone: Drone;
  private missionData: MissionData;
  
  constructor() {
    super(SceneKeys.GAME);
  }
  
  init(data: any): void {
    super.init(data);
    this.missionData = data.mission || this.getDefaultMission();
  }
  
  create(): void {
    // Initialize game objects
    this.createDrone();
    this.setupUI();
    
    // Listen for pause key
    this.input.keyboard.on('keydown-ESC', () => {
      this.pauseAndShowScene(SceneKeys.PAUSE, {
        currentMission: this.missionData,
        droneState: this.drone.getState()
      });
    });
  }
  
  private onMissionComplete(): void {
    const results = {
      score: this.calculateScore(),
      timeElapsed: this.getElapsedTime(),
      stealthRating: this.getStealthRating()
    };
    
    this.goToScene(SceneKeys.GAME_OVER, results);
  }
}

// Pause overlay scene
class PauseScene extends BaseScene {
  constructor() {
    super(SceneKeys.PAUSE);
  }
  
  create(): void {
    // Create pause menu UI
    const graphics = this.add.graphics();
    graphics.fillStyle(0x000000, 0.7);
    graphics.fillRect(0, 0, this.scale.width, this.scale.height);
    
    const resumeButton = this.add.text(400, 300, 'Resume', {
      fontSize: '32px',
      color: '#ffffff'
    }).setInteractive();
    
    resumeButton.on('pointerdown', () => {
      this.scene.stop(); // Stop pause scene
      this.scene.resume(SceneKeys.GAME); // Resume game scene
    });
  }
}
```

### 2. Asset Loading with Progress

**Problem**: Loading many assets with user feedback.

**Solution**: Centralized asset loading with progress tracking.

```typescript
class AssetLoader {
  private scene: Phaser.Scene;
  private progressCallback?: (progress: number) => void;
  
  constructor(scene: Phaser.Scene) {
    this.scene = scene;
  }
  
  loadGameAssets(onProgress?: (progress: number) => void): Promise<void> {
    this.progressCallback = onProgress;
    
    return new Promise((resolve) => {
      // Set up progress tracking
      this.scene.load.on('progress', (progress: number) => {
        if (this.progressCallback) {
          this.progressCallback(Math.round(progress * 100));
        }
      });
      
      this.scene.load.on('complete', () => {
        resolve();
      });
      
      // Load all assets
      this.loadImages();
      this.loadAudio();
      this.loadData();
      
      // Start loading
      this.scene.load.start();
    });
  }
  
  private loadImages(): void {
    // Sprites
    this.scene.load.image('drone', 'assets/images/drone.png');
    this.scene.load.image('guard', 'assets/images/guard.png');
    this.scene.load.image('wall', 'assets/images/wall.png');
    
    // Spritesheets
    this.scene.load.spritesheet('explosion', 'assets/images/explosion.png', {
      frameWidth: 64,
      frameHeight: 64
    });
    
    // UI elements
    this.scene.load.image('battery-full', 'assets/ui/battery-full.png');
    this.scene.load.image('battery-low', 'assets/ui/battery-low.png');
  }
  
  private loadAudio(): void {
    this.scene.load.audio('drone-hum', 'assets/audio/drone-hum.mp3');
    this.scene.load.audio('alert-sound', 'assets/audio/alert.mp3');
    this.scene.load.audio('footsteps', 'assets/audio/footsteps.mp3');
  }
  
  private loadData(): void {
    this.scene.load.json('mission-1', 'assets/data/mission-1.json');
    this.scene.load.json('guard-routes', 'assets/data/guard-routes.json');
  }
}

// Usage in boot scene
class BootScene extends Phaser.Scene {
  private loadingText: Phaser.GameObjects.Text;
  private progressBar: Phaser.GameObjects.Graphics;
  
  constructor() {
    super({ key: 'BootScene' });
  }
  
  preload(): void {
    this.createLoadingUI();
    
    const assetLoader = new AssetLoader(this);
    assetLoader.loadGameAssets((progress) => {
      this.updateProgress(progress);
    }).then(() => {
      // Loading complete, go to menu
      this.scene.start('MenuScene');
    });
  }
  
  private createLoadingUI(): void {
    this.loadingText = this.add.text(400, 300, 'Loading... 0%', {
      fontSize: '24px',
      color: '#ffffff'
    }).setOrigin(0.5);
    
    this.progressBar = this.add.graphics();
  }
  
  private updateProgress(progress: number): void {
    this.loadingText.setText(`Loading... ${progress}%`);
    
    // Draw progress bar
    this.progressBar.clear();
    this.progressBar.fillStyle(0x00ff00);
    this.progressBar.fillRect(300, 350, (progress / 100) * 200, 20);
  }
}
```

### 3. Input Management

**Problem**: Handling multiple input types (keyboard, mouse, gamepad) consistently.

**Solution**: Centralized input manager with action mapping.

```typescript
// Input action types
enum InputAction {
  MOVE_UP = 'move_up',
  MOVE_DOWN = 'move_down',
  MOVE_LEFT = 'move_left',
  MOVE_RIGHT = 'move_right',
  PRECISION_MODE = 'precision_mode',
  EMERGENCY_STOP = 'emergency_stop',
  INTERACT = 'interact',
  PAUSE = 'pause'
}

// Input binding configuration
interface InputBinding {
  action: InputAction;
  keyboard?: string[];
  gamepad?: number[];
  mouse?: number[];
}

class InputManager {
  private scene: Phaser.Scene;
  private bindings: Map<InputAction, InputBinding> = new Map();
  private actionStates: Map<InputAction, boolean> = new Map();
  private gamepad: Phaser.Input.Gamepad.Gamepad | null = null;
  
  constructor(scene: Phaser.Scene) {
    this.scene = scene;
    this.setupDefaultBindings();
    this.initializeInputs();
  }
  
  private setupDefaultBindings(): void {
    const defaultBindings: InputBinding[] = [
      {
        action: InputAction.MOVE_UP,
        keyboard: ['W', 'UP'],
        gamepad: [12] // D-pad up
      },
      {
        action: InputAction.MOVE_DOWN,
        keyboard: ['S', 'DOWN'],
        gamepad: [13] // D-pad down
      },
      {
        action: InputAction.MOVE_LEFT,
        keyboard: ['A', 'LEFT'],
        gamepad: [14] // D-pad left
      },
      {
        action: InputAction.MOVE_RIGHT,
        keyboard: ['D', 'RIGHT'],
        gamepad: [15] // D-pad right
      },
      {
        action: InputAction.PRECISION_MODE,
        keyboard: ['SHIFT'],
        gamepad: [4] // Left shoulder button
      },
      {
        action: InputAction.EMERGENCY_STOP,
        keyboard: ['SPACE'],
        gamepad: [0] // A button
      },
      {
        action: InputAction.INTERACT,
        keyboard: ['E'],
        gamepad: [1] // B button
      },
      {
        action: InputAction.PAUSE,
        keyboard: ['ESC'],
        gamepad: [6] // Menu button
      }
    ];
    
    defaultBindings.forEach(binding => {
      this.bindings.set(binding.action, binding);
      this.actionStates.set(binding.action, false);
    });
  }
  
  private initializeInputs(): void {
    // Initialize keyboard
    this.scene.input.keyboard.on('keydown', this.onKeyDown.bind(this));
    this.scene.input.keyboard.on('keyup', this.onKeyUp.bind(this));
    
    // Initialize gamepad
    this.scene.input.gamepad.once('connected', (pad: Phaser.Input.Gamepad.Gamepad) => {
      this.gamepad = pad;
      console.log('Gamepad connected:', pad.id);
    });
  }
  
  private onKeyDown(event: KeyboardEvent): void {
    const key = event.code;
    this.updateActionStates(key, true);
  }
  
  private onKeyUp(event: KeyboardEvent): void {
    const key = event.code;
    this.updateActionStates(key, false);
  }
  
  private updateActionStates(input: string, isPressed: boolean): void {
    for (const [action, binding] of this.bindings) {
      if (binding.keyboard?.includes(input)) {
        this.actionStates.set(action, isPressed);
      }
    }
  }
  
  // Public API
  isActionPressed(action: InputAction): boolean {
    return this.actionStates.get(action) || false;
  }
  
  isActionJustPressed(action: InputAction): boolean {
    // Implementation would track frame-by-frame state changes
    // This is a simplified version
    return this.isActionPressed(action);
  }
  
  getMovementVector(): { x: number; y: number } {
    let x = 0;
    let y = 0;
    
    if (this.isActionPressed(InputAction.MOVE_LEFT)) x -= 1;
    if (this.isActionPressed(InputAction.MOVE_RIGHT)) x += 1;
    if (this.isActionPressed(InputAction.MOVE_UP)) y -= 1;
    if (this.isActionPressed(InputAction.MOVE_DOWN)) y += 1;
    
    // Normalize diagonal movement
    if (x !== 0 && y !== 0) {
      const length = Math.sqrt(x * x + y * y);
      x /= length;
      y /= length;
    }
    
    return { x, y };
  }
  
  update(): void {
    // Update gamepad state
    if (this.gamepad) {
      this.updateGamepadStates();
    }
  }
  
  private updateGamepadStates(): void {
    if (!this.gamepad) return;
    
    for (const [action, binding] of this.bindings) {
      if (binding.gamepad) {
        let isPressed = false;
        
        for (const buttonIndex of binding.gamepad) {
          if (this.gamepad.buttons[buttonIndex]?.pressed) {
            isPressed = true;
            break;
          }
        }
        
        this.actionStates.set(action, isPressed);
      }
    }
  }
}

// Usage in game scene
class GameScene extends Phaser.Scene {
  private inputManager: InputManager;
  private drone: Drone;
  
  create(): void {
    this.inputManager = new InputManager(this);
    // ... other initialization
  }
  
  update(): void {
    this.inputManager.update();
    
    // Use input manager for drone control
    const movement = this.inputManager.getMovementVector();
    this.drone.setMovementInput(movement);
    
    if (this.inputManager.isActionJustPressed(InputAction.PRECISION_MODE)) {
      this.drone.togglePrecisionMode();
    }
    
    if (this.inputManager.isActionJustPressed(InputAction.EMERGENCY_STOP)) {
      this.drone.emergencyStop();
    }
  }
}
```

---

## 🔧 Common Bug Fixes

### 1. Memory Leaks

**Problem**: Game slows down over time due to memory leaks.

**Common causes and solutions:**

```typescript
// ❌ BAD: Not cleaning up event listeners
class BadSystem {
  constructor(scene: Phaser.Scene) {
    scene.events.on('update', this.update.bind(this));
    // Never removes the listener!
  }
}

// ✅ GOOD: Proper cleanup
class GoodSystem {
  private scene: Phaser.Scene;
  private updateHandler: () => void;
  
  constructor(scene: Phaser.Scene) {
    this.scene = scene;
    this.updateHandler = this.update.bind(this);
    scene.events.on('update', this.updateHandler);
  }
  
  shutdown(): void {
    this.scene.events.off('update', this.updateHandler);
  }
  
  private update(): void {
    // Update logic
  }
}

// ❌ BAD: Creating objects in update loop
class BadDrone {
  update(): void {
    const position = { x: this.x, y: this.y }; // New object every frame!
    this.checkCollision(position);
  }
}

// ✅ GOOD: Reuse objects
class GoodDrone {
  private tempPosition = { x: 0, y: 0 }; // Reusable object
  
  update(): void {
    this.tempPosition.x = this.x;
    this.tempPosition.y = this.y;
    this.checkCollision(this.tempPosition);
  }
}

// ❌ BAD: Keeping references to destroyed objects
class BadManager {
  private entities: GameEntity[] = [];
  
  removeEntity(entity: GameEntity): void {
    entity.destroy();
    // Still in the array! Memory leak!
  }
}

// ✅ GOOD: Proper reference management
class GoodManager {
  private entities: GameEntity[] = [];
  
  removeEntity(entity: GameEntity): void {
    const index = this.entities.indexOf(entity);
    if (index > -1) {
      this.entities.splice(index, 1);
    }
    entity.destroy();
  }
}
```

### 2. Physics Issues

**Problem**: Objects passing through walls or incorrect collision detection.

**Solutions:**

```typescript
// ❌ BAD: Setting position directly
class BadDrone {
  moveToTarget(targetX: number, targetY: number): void {
    this.x = targetX; // Teleports through walls!
    this.y = targetY;
  }
}

// ✅ GOOD: Use physics for movement
class GoodDrone {
  moveToTarget(targetX: number, targetY: number): void {
    const angle = Phaser.Math.Angle.Between(this.x, this.y, targetX, targetY);
    const speed = 100;
    
    this.body.setVelocity(
      Math.cos(angle) * speed,
      Math.sin(angle) * speed
    );
  }
}

// Fix for high-speed objects passing through walls
class FastProjectile extends Phaser.Physics.Arcade.Sprite {
  constructor(scene: Phaser.Scene, x: number, y: number) {
    super(scene, x, y, 'bullet');
    
    // Enable continuous collision detection
    this.body.setSize(4, 4); // Smaller hitbox
    
    // Set max velocity to prevent tunneling
    this.body.setMaxVelocity(500);
  }
  
  fireAt(targetX: number, targetY: number): void {
    const angle = Phaser.Math.Angle.Between(this.x, this.y, targetX, targetY);
    const speed = 400;
    
    this.body.setVelocity(
      Math.cos(angle) * speed,
      Math.sin(angle) * speed
    );
    
    // Use stepped movement for very fast objects
    this.scene.physics.world.on('worldstep', this.checkCollisions, this);
  }
  
  private checkCollisions(): void {
    // Manual collision checking between physics steps
    // for ultra-fast projectiles
  }
}
```

### 3. Performance Problems

**Problem**: Frame rate drops and stuttering.

**Diagnostic and solutions:**

```typescript
// Performance monitoring utility
class PerformanceProfiler {
  private frameCount = 0;
  private lastTime = performance.now();
  private fps = 60;
  private updateTimes: number[] = [];
  private renderTimes: number[] = [];
  
  startFrame(): void {
    this.frameStart = performance.now();
  }
  
  endUpdate(): void {
    this.updateEnd = performance.now();
    this.updateTimes.push(this.updateEnd - this.frameStart);
    
    // Keep only last 60 frames
    if (this.updateTimes.length > 60) {
      this.updateTimes.shift();
    }
  }
  
  endFrame(): void {
    const frameEnd = performance.now();
    this.renderTimes.push(frameEnd - this.updateEnd);
    
    if (this.renderTimes.length > 60) {
      this.renderTimes.shift();
    }
    
    this.frameCount++;
    
    // Calculate FPS every second
    if (frameEnd - this.lastTime >= 1000) {
      this.fps = Math.round((this.frameCount * 1000) / (frameEnd - this.lastTime));
      this.frameCount = 0;
      this.lastTime = frameEnd;
      
      // Log performance warnings
      if (this.fps < 50) {
        this.logPerformanceIssues();
      }
    }
  }
  
  private logPerformanceIssues(): void {
    const avgUpdate = this.updateTimes.reduce((a, b) => a + b, 0) / this.updateTimes.length;
    const avgRender = this.renderTimes.reduce((a, b) => a + b, 0) / this.renderTimes.length;
    
    console.warn(`Performance issues detected:
      FPS: ${this.fps}
      Avg Update Time: ${avgUpdate.toFixed(2)}ms
      Avg Render Time: ${avgRender.toFixed(2)}ms
    `);
  }
}

// Common performance optimizations
class OptimizedGameScene extends Phaser.Scene {
  private profiler = new PerformanceProfiler();
  private visibleEntities: GameEntity[] = [];
  private lastCullingUpdate = 0;
  
  update(time: number, delta: number): void {
    this.profiler.startFrame();
    
    // Only update frustum culling every 100ms
    if (time - this.lastCullingUpdate > 100) {
      this.updateVisibilityClling();
      this.lastCullingUpdate = time;
    }
    
    // Only update visible entities
    for (const entity of this.visibleEntities) {
      entity.update(delta);
    }
    
    this.profiler.endUpdate();
  }
  
  private updateVisibilityClling(): void {
    const camera = this.cameras.main;
    const worldView = camera.worldView;
    
    this.visibleEntities = this.allEntities.filter(entity => {
      return Phaser.Geom.Rectangle.Contains(worldView, entity.x, entity.y);
    });
  }
  
  // Batch operations for better performance
  private updateEntitiesInBatches(): void {
    const batchSize = 10;
    let processed = 0;
    
    const processBatch = () => {
      for (let i = 0; i < batchSize && processed < this.allEntities.length; i++, processed++) {
        this.allEntities[processed].expensiveOperation();
      }
      
      if (processed < this.allEntities.length) {
        // Continue next frame
        this.time.delayedCall(0, processBatch);
      }
    };
    
    processBatch();
  }
}

// Efficient collision detection
class SpatialHashGrid {
  private cellSize: number;
  private grid: Map<string, GameEntity[]> = new Map();
  
  constructor(cellSize = 64) {
    this.cellSize = cellSize;
  }
  
  clear(): void {
    this.grid.clear();
  }
  
  insert(entity: GameEntity): void {
    const cellKey = this.getCellKey(entity.x, entity.y);
    
    if (!this.grid.has(cellKey)) {
      this.grid.set(cellKey, []);
    }
    
    this.grid.get(cellKey)!.push(entity);
  }
  
  getNearby(x: number, y: number, radius: number): GameEntity[] {
    const entities: GameEntity[] = [];
    const cells = this.getCellsInRadius(x, y, radius);
    
    for (const cellKey of cells) {
      const cellEntities = this.grid.get(cellKey);
      if (cellEntities) {
        entities.push(...cellEntities);
      }
    }
    
    return entities;
  }
  
  private getCellKey(x: number, y: number): string {
    const cellX = Math.floor(x / this.cellSize);
    const cellY = Math.floor(y / this.cellSize);
    return `${cellX},${cellY}`;
  }
  
  private getCellsInRadius(x: number, y: number, radius: number): string[] {
    const cells: string[] = [];
    const minCellX = Math.floor((x - radius) / this.cellSize);
    const maxCellX = Math.floor((x + radius) / this.cellSize);
    const minCellY = Math.floor((y - radius) / this.cellSize);
    const maxCellY = Math.floor((y + radius) / this.cellSize);
    
    for (let cellX = minCellX; cellX <= maxCellX; cellX++) {
      for (let cellY = minCellY; cellY <= maxCellY; cellY++) {
        cells.push(`${cellX},${cellY}`);
      }
    }
    
    return cells;
  }
}
```

---

## 🎨 State Management Patterns

### 1. Game State Manager

**Problem**: Managing complex game states (menu, playing, paused, game over).

**Solution**: Centralized state management.

```typescript
enum GameState {
  LOADING = 'loading',
  MENU = 'menu',
  PLAYING = 'playing',
  PAUSED = 'paused',
  GAME_OVER = 'game_over'
}

interface GameStateData {
  currentMission?: MissionData;
  score?: number;
  droneState?: any;
  timeElapsed?: number;
}

class GameStateManager {
  private currentState: GameState = GameState.LOADING;
  private stateData: GameStateData = {};
  private stateHistory: GameState[] = [];
  
  // Event emitter for state changes
  private onStateChanged = new Phaser.Events.EventEmitter();
  
  setState(newState: GameState, data?: Partial<GameStateData>): void {
    const previousState = this.currentState;
    
    // Store previous state in history
    this.stateHistory.push(previousState);
    
    // Keep history to reasonable size
    if (this.stateHistory.length > 10) {
      this.stateHistory.shift();
    }
    
    // Update state
    this.currentState = newState;
    if (data) {
      this.stateData = { ...this.stateData, ...data };
    }
    
    // Emit state change event
    this.onStateChanged.emit('stateChanged', {
      previous: previousState,
      current: newState,
      data: this.stateData
    });
    
    console.log(`Game state: ${previousState} → ${newState}`);
  }
  
  getState(): GameState {
    return this.currentState;
  }
  
  getStateData(): GameStateData {
    return { ...this.stateData };
  }
  
  canTransitionTo(targetState: GameState): boolean {
    // Define valid state transitions
    const validTransitions: Record<GameState, GameState[]> = {
      [GameState.LOADING]: [GameState.MENU],
      [GameState.MENU]: [GameState.PLAYING],
      [GameState.PLAYING]: [GameState.PAUSED, GameState.GAME_OVER],
      [GameState.PAUSED]: [GameState.PLAYING, GameState.MENU],
      [GameState.GAME_OVER]: [GameState.MENU, GameState.PLAYING]
    };
    
    return validTransitions[this.currentState].includes(targetState);
  }
  
  getPreviousState(): GameState | null {
    return this.stateHistory[this.stateHistory.length - 1] || null;
  }
  
  // Event subscription
  on(event: string, callback: Function): void {
    this.onStateChanged.on(event, callback);
  }
  
  off(event: string, callback: Function): void {
    this.onStateChanged.off(event, callback);
  }
}

// Global game state instance
export const gameState = new GameStateManager();

// Usage in scenes
class MenuScene extends Phaser.Scene {
  create(): void {
    gameState.setState(GameState.MENU);
    
    const playButton = this.add.text(400, 300, 'Play', { fontSize: '32px' })
      .setInteractive()
      .on('pointerdown', () => {
        if (gameState.canTransitionTo(GameState.PLAYING)) {
          this.scene.start('GameScene');
          gameState.setState(GameState.PLAYING, {
            currentMission: this.getSelectedMission()
          });
        }
      });
  }
}

class GameScene extends Phaser.Scene {
  init(): void {
    // Listen for state changes
    gameState.on('stateChanged', this.onGameStateChanged.bind(this));
  }
  
  private onGameStateChanged(data: any): void {
    switch (data.current) {
      case GameState.PAUSED:
        this.physics.pause();
        this.scene.launch('PauseScene');
        break;
        
      case GameState.PLAYING:
        if (data.previous === GameState.PAUSED) {
          this.physics.resume();
          this.scene.stop('PauseScene');
        }
        break;
        
      case GameState.GAME_OVER:
        this.handleGameOver(data.data);
        break;
    }
  }
}
```

### 2. Save/Load System

**Problem**: Persisting game progress and settings.

**Solution**: Robust save system with versioning.

```typescript
interface SaveData {
  version: number;
  timestamp: number;
  playerProgress: {
    unlockedMissions: string[];
    completedMissions: string[];
    bestScores: Record<string, number>;
    totalPlayTime: number;
  };
  settings: {
    volume: number;
    controls: Record<string, string>;
    graphics: {
      quality: 'low' | 'medium' | 'high';
      fullscreen: boolean;
    };
  };
  gameState?: {
    currentMission?: string;
    droneUpgrades: string[];
    currency: number;
  };
}

class SaveManager {
  private static readonly SAVE_KEY = 'drone-recon-ops-save';
  private static readonly CURRENT_VERSION = 1;
  
  static save(data: Partial<SaveData>): boolean {
    try {
      const existingData = this.load();
      const saveData: SaveData = {
        version: this.CURRENT_VERSION,
        timestamp: Date.now(),
        playerProgress: {
          unlockedMissions: [],
          completedMissions: [],
          bestScores: {},
          totalPlayTime: 0,
          ...existingData?.playerProgress,
          ...data.playerProgress
        },
        settings: {
          volume: 1.0,
          controls: {},
          graphics: {
            quality: 'medium',
            fullscreen: false
          },
          ...existingData?.settings,
          ...data.settings
        },
        gameState: {
          ...existingData?.gameState,
          ...data.gameState
        }
      };
      
      const serialized = JSON.stringify(saveData);
      localStorage.setItem(this.SAVE_KEY, serialized);
      
      console.log('Game saved successfully');
      return true;
    } catch (error) {
      console.error('Failed to save game:', error);
      return false;
    }
  }
  
  static load(): SaveData | null {
    try {
      const serialized = localStorage.getItem(this.SAVE_KEY);
      if (!serialized) {
        return null;
      }
      
      const data = JSON.parse(serialized) as SaveData;
      
      // Handle version migration
      return this.migrateVersion(data);
    } catch (error) {
      console.error('Failed to load game:', error);
      return null;
    }
  }
  
  static hasSaveData(): boolean {
    return localStorage.getItem(this.SAVE_KEY) !== null;
  }
  
  static deleteSave(): void {
    localStorage.removeItem(this.SAVE_KEY);
    console.log('Save data deleted');
  }
  
  private static migrateVersion(data: SaveData): SaveData {
    // Handle save data version migrations
    if (data.version < this.CURRENT_VERSION) {
      console.log(`Migrating save data from version ${data.version} to ${this.CURRENT_VERSION}`);
      
      // Perform migrations based on version differences
      if (data.version < 1) {
        // Migration logic for version 0 -> 1
        data.playerProgress.totalPlayTime = 0;
      }
      
      data.version = this.CURRENT_VERSION;
    }
    
    return data;
  }
  
  // Auto-save functionality
  static enableAutoSave(interval = 30000): void {
    setInterval(() => {
      const currentData = {
        gameState: {
          currency: gameState.getStateData().score || 0,
          // ... other current game state
        }
      };
      
      this.save(currentData);
    }, interval);
  }
}

// Usage
class GameManager {
  private saveData: SaveData | null = null;
  
  initialize(): void {
    this.saveData = SaveManager.load();
    
    if (!this.saveData) {
      // First time player
      this.createNewSave();
    }
    
    // Enable auto-save every 30 seconds
    SaveManager.enableAutoSave();
  }
  
  private createNewSave(): void {
    SaveManager.save({
      playerProgress: {
        unlockedMissions: ['tutorial'],
        completedMissions: [],
        bestScores: {},
        totalPlayTime: 0
      }
    });
    
    this.saveData = SaveManager.load();
  }
  
  completeMission(missionId: string, score: number): void {
    if (!this.saveData) return;
    
    const bestScore = this.saveData.playerProgress.bestScores[missionId] || 0;
    
    SaveManager.save({
      playerProgress: {
        completedMissions: [...new Set([...this.saveData.playerProgress.completedMissions, missionId])],
        bestScores: {
          ...this.saveData.playerProgress.bestScores,
          [missionId]: Math.max(score, bestScore)
        }
      }
    });
  }
}
```

---

## 🎉 Summary

This guide covered the most important patterns and solutions for developing Drone Recon Ops:

### Key Takeaways:

1. **Use established patterns** - Component, State Machine, Observer, and Object Pool patterns solve common game development challenges

2. **Handle Phaser.js specifics** - Proper scene management, asset loading, and input handling are crucial

3. **Fix bugs early** - Memory leaks, physics issues, and performance problems are easier to fix when caught early

4. **Manage complexity** - Good state management and save systems make your game more robust

5. **Profile performance** - Monitor and optimize performance from the beginning

### Remember:
- **Start simple** and add complexity gradually
- **Test frequently** to catch issues early
- **Document patterns** you use for future reference
- **Learn from examples** but adapt them to your specific needs

**Next Steps:**
1. Apply these patterns to your Drone Recon Ops implementation
2. Create your own patterns for unique challenges
3. Share solutions with the team
4. Contribute to this guide as you discover new patterns

**Questions?** This guide is living documentation - update it as you learn new patterns and solutions!

Happy coding! 🚁✨ 