# 🔧 TypeScript Patterns for Game Development
## Advanced Type Safety in Drone Recon Ops

**For developers ready to leverage TypeScript's full power in game development**

---

## 📋 Overview

This guide covers advanced TypeScript patterns specifically tailored for game development. Each pattern includes practical examples from Drone Recon Ops, explaining not just the "how" but the "why" behind using these patterns in games.

### What You'll Learn:
- **Advanced Interfaces** - Type-safe game systems
- **Generic Patterns** - Reusable game components  
- **Union Types** - Game state management
- **Conditional Types** - Dynamic behavior systems
- **Utility Types** - Clean API design
- **Decorators** - System annotations

**Prerequisites**: Basic TypeScript knowledge, completed [Beginner Guide](BEGINNER_GUIDE.md)

---

## 🎮 Game-Specific Type Patterns

### 1. Entity Component System (ECS) Types

**The Problem**: Game entities need flexible component composition while maintaining type safety.

**The Solution**: Generic interfaces with constrained types.

```typescript
// Base component interface
interface IComponent {
  readonly name: string;
  readonly entity: GameEntity;
  update(deltaTime: number): void;
  destroy(): void;
}

// Generic component base class
abstract class Component<T extends Record<string, any> = {}> implements IComponent {
  abstract readonly name: string;
  
  constructor(
    public readonly entity: GameEntity,
    protected config: T
  ) {}
  
  abstract update(deltaTime: number): void;
  
  destroy(): void {
    // Default cleanup logic
  }
}

// Specific components with typed configurations
interface MovementConfig {
  speed: number;
  acceleration: number;
  drag: number;
}

class MovementComponent extends Component<MovementConfig> {
  readonly name = 'movement';
  
  update(deltaTime: number): void {
    // Type-safe access to this.config.speed, etc.
    const velocity = this.config.speed * deltaTime;
    // Movement logic here
  }
}

// Entity with type-safe component management
class GameEntity {
  private components = new Map<string, IComponent>();
  
  // Generic method with type inference
  addComponent<T extends IComponent>(component: T): T {
    this.components.set(component.name, component);
    return component;
  }
  
  // Type-safe component retrieval
  getComponent<T extends IComponent>(name: string): T | null {
    return (this.components.get(name) as T) || null;
  }
  
  // Type guard for checking component existence
  hasComponent(name: string): boolean {
    return this.components.has(name);
  }
}

// Usage with full type safety
const drone = new GameEntity();
const movement = drone.addComponent(new MovementComponent(drone, {
  speed: 150,
  acceleration: 300,
  drag: 0.8
}));

// TypeScript knows movement is MovementComponent
movement.config.speed; // ✅ Type-safe access
```

### 2. State Machine Pattern with Union Types

**The Problem**: AI states need to be type-safe but flexible for different behaviors.

**The Solution**: Discriminated unions with state-specific data.

```typescript
// Define all possible states with their data
type GuardState = 
  | { type: 'idle'; waitTime: number }
  | { type: 'patrol'; currentWaypoint: number; waypointPath: Vector2[] }
  | { type: 'investigate'; targetPosition: Vector2; alertLevel: number }
  | { type: 'chase'; targetEntity: GameEntity; lastKnownPosition: Vector2 }
  | { type: 'search'; searchCenter: Vector2; searchRadius: number; searchTime: number };

// State machine with type-safe transitions
class GuardStateMachine {
  private currentState: GuardState;
  
  constructor(initialState: GuardState) {
    this.currentState = initialState;
  }
  
  // Type-safe state transitions
  setState(newState: GuardState): void {
    this.exitState(this.currentState);
    this.currentState = newState;
    this.enterState(newState);
  }
  
  // Pattern matching with type narrowing
  update(deltaTime: number): void {
    switch (this.currentState.type) {
      case 'idle':
        this.updateIdle(this.currentState, deltaTime);
        break;
      case 'patrol':
        this.updatePatrol(this.currentState, deltaTime);
        break;
      case 'investigate':
        this.updateInvestigate(this.currentState, deltaTime);
        break;
      case 'chase':
        this.updateChase(this.currentState, deltaTime);
        break;
      case 'search':
        this.updateSearch(this.currentState, deltaTime);
        break;
      default:
        // TypeScript ensures this is never reached
        const _exhaustive: never = this.currentState;
        break;
    }
  }
  
  // Type-narrowed state handlers
  private updateIdle(state: Extract<GuardState, { type: 'idle' }>, deltaTime: number): void {
    // TypeScript knows state.waitTime exists
    state.waitTime -= deltaTime;
    if (state.waitTime <= 0) {
      // Transition to patrol
      this.setState({
        type: 'patrol',
        currentWaypoint: 0,
        waypointPath: this.getPatrolPath()
      });
    }
  }
  
  private updatePatrol(state: Extract<GuardState, { type: 'patrol' }>, deltaTime: number): void {
    // TypeScript knows about currentWaypoint and waypointPath
    const target = state.waypointPath[state.currentWaypoint];
    // Patrol logic here
  }
  
  // Helper methods
  private enterState(state: GuardState): void {
    console.log(`Entering state: ${state.type}`);
  }
  
  private exitState(state: GuardState): void {
    console.log(`Exiting state: ${state.type}`);
  }
  
  private getPatrolPath(): Vector2[] {
    // Return patrol waypoints
    return [];
  }
}
```

### 3. Event System with Typed Payloads

**The Problem**: Game events need type-safe payloads while remaining flexible.

**The Solution**: Mapped types with event payload interfaces.

```typescript
// Define all game events and their payloads
interface GameEventMap {
  'drone.battery.critical': { batteryLevel: number; droneId: string };
  'guard.spotted.drone': { guardId: string; dronePosition: Vector2; confidenceLevel: number };
  'mission.objective.completed': { objectiveId: string; completionTime: number; score: number };
  'audio.detection': { sourcePosition: Vector2; intensity: number; detectorId: string };
  'system.performance.warning': { system: string; frameTime: number; threshold: number };
}

// Event emitter with type safety
class TypedEventEmitter {
  private listeners = new Map<string, Function[]>();
  
  // Type-safe event subscription
  on<K extends keyof GameEventMap>(
    eventType: K,
    listener: (payload: GameEventMap[K]) => void
  ): void {
    if (!this.listeners.has(eventType)) {
      this.listeners.set(eventType, []);
    }
    this.listeners.get(eventType)!.push(listener);
  }
  
  // Type-safe event emission
  emit<K extends keyof GameEventMap>(
    eventType: K,
    payload: GameEventMap[K]
  ): void {
    const handlers = this.listeners.get(eventType) || [];
    handlers.forEach(handler => handler(payload));
  }
  
  // Remove listeners
  off<K extends keyof GameEventMap>(
    eventType: K,
    listener: (payload: GameEventMap[K]) => void
  ): void {
    const handlers = this.listeners.get(eventType) || [];
    const index = handlers.indexOf(listener);
    if (index !== -1) {
      handlers.splice(index, 1);
    }
  }
}

// Usage with full type safety
const eventBus = new TypedEventEmitter();

// TypeScript enforces correct payload structure
eventBus.on('drone.battery.critical', (payload) => {
  // payload is automatically typed as { batteryLevel: number; droneId: string }
  console.log(`Drone ${payload.droneId} battery at ${payload.batteryLevel}%`);
});

// Compile-time error if payload is wrong
eventBus.emit('drone.battery.critical', {
  batteryLevel: 15,
  droneId: 'drone-001'
}); // ✅ Correct

// eventBus.emit('drone.battery.critical', { wrong: 'payload' }); // ❌ Compile error
```

### 4. Configuration System with Conditional Types

**The Problem**: Game systems need flexible configuration while maintaining type safety.

**The Solution**: Conditional types that adapt based on system type.

```typescript
// Base configuration interface
interface BaseSystemConfig {
  enabled: boolean;
  debugMode: boolean;
}

// System-specific configurations
interface PhysicsConfig extends BaseSystemConfig {
  gravity: Vector2;
  worldBounds: Rectangle;
  timeStep: number;
}

interface DetectionConfig extends BaseSystemConfig {
  maxViewDistance: number;
  fieldOfView: number;
  audioFalloffRate: number;
}

interface AudioConfig extends BaseSystemConfig {
  masterVolume: number;
  spatialAudioEnabled: boolean;
  maxSimultaneousSounds: number;
}

// Map system names to their configurations
interface SystemConfigMap {
  physics: PhysicsConfig;
  detection: DetectionConfig;
  audio: AudioConfig;
}

// Conditional type for system configuration
type SystemConfig<T extends keyof SystemConfigMap> = SystemConfigMap[T];

// Generic system base class
abstract class GameSystem<T extends keyof SystemConfigMap> {
  protected config: SystemConfig<T>;
  
  constructor(config: SystemConfig<T>) {
    this.config = config;
  }
  
  abstract initialize(): Promise<void>;
  abstract update(deltaTime: number): void;
  abstract shutdown(): void;
  
  // Type-safe configuration updates
  updateConfig(updates: Partial<SystemConfig<T>>): void {
    this.config = { ...this.config, ...updates };
  }
  
  isEnabled(): boolean {
    return this.config.enabled;
  }
}

// Specific system implementations
class PhysicsSystem extends GameSystem<'physics'> {
  async initialize(): Promise<void> {
    // this.config is automatically typed as PhysicsConfig
    console.log(`Physics initialized with gravity: ${this.config.gravity.y}`);
  }
  
  update(deltaTime: number): void {
    if (!this.isEnabled()) return;
    
    // Type-safe access to physics-specific config
    const timeStep = this.config.timeStep * deltaTime;
    // Physics update logic
  }
  
  shutdown(): void {
    // Cleanup logic
  }
}

class DetectionSystem extends GameSystem<'detection'> {
  async initialize(): Promise<void> {
    // this.config is automatically typed as DetectionConfig
    console.log(`Detection initialized with FOV: ${this.config.fieldOfView}°`);
  }
  
  update(deltaTime: number): void {
    if (!this.isEnabled()) return;
    
    // Type-safe access to detection-specific config
    const maxDistance = this.config.maxViewDistance;
    // Detection logic
  }
  
  shutdown(): void {
    // Cleanup logic
  }
}

// System factory with type safety
class SystemFactory {
  static createSystem<T extends keyof SystemConfigMap>(
    systemType: T,
    config: SystemConfig<T>
  ): GameSystem<T> {
    switch (systemType) {
      case 'physics':
        return new PhysicsSystem(config as PhysicsConfig) as GameSystem<T>;
      case 'detection':
        return new DetectionSystem(config as DetectionConfig) as GameSystem<T>;
      case 'audio':
        // Would implement AudioSystem
        throw new Error('AudioSystem not implemented');
      default:
        const _exhaustive: never = systemType;
        throw new Error(`Unknown system type: ${systemType}`);
    }
  }
}

// Usage with complete type safety
const physicsSystem = SystemFactory.createSystem('physics', {
  enabled: true,
  debugMode: false,
  gravity: { x: 0, y: 0 },
  worldBounds: { x: 0, y: 0, width: 800, height: 600 },
  timeStep: 1/60
});

// TypeScript prevents wrong configuration
// SystemFactory.createSystem('physics', { wrong: 'config' }); // ❌ Compile error
```

### 5. Asset Loading with Branded Types

**The Problem**: Asset references should be type-safe to prevent loading wrong assets.

**The Solution**: Branded types for asset identification.

```typescript
// Branded types for different asset categories
declare const __brand: unique symbol;
type Brand<T, TBrand> = T & { [__brand]: TBrand };

type ImageAssetId = Brand<string, 'ImageAsset'>;
type AudioAssetId = Brand<string, 'AudioAsset'>;
type DataAssetId = Brand<string, 'DataAsset'>;

// Asset registry with type safety
interface AssetRegistry {
  images: Record<ImageAssetId, HTMLImageElement>;
  audio: Record<AudioAssetId, HTMLAudioElement>;
  data: Record<DataAssetId, any>;
}

// Asset manager with branded types
class AssetManager {
  private assets: AssetRegistry = {
    images: {} as Record<ImageAssetId, HTMLImageElement>,
    audio: {} as Record<AudioAssetId, HTMLAudioElement>,
    data: {} as Record<DataAssetId, any>
  };
  
  // Type-safe asset loading
  async loadImage(id: ImageAssetId, url: string): Promise<HTMLImageElement> {
    return new Promise((resolve, reject) => {
      const img = new Image();
      img.onload = () => {
        this.assets.images[id] = img;
        resolve(img);
      };
      img.onerror = reject;
      img.src = url;
    });
  }
  
  async loadAudio(id: AudioAssetId, url: string): Promise<HTMLAudioElement> {
    const audio = new Audio(url);
    this.assets.audio[id] = audio;
    return audio;
  }
  
  async loadData(id: DataAssetId, url: string): Promise<any> {
    const response = await fetch(url);
    const data = await response.json();
    this.assets.data[id] = data;
    return data;
  }
  
  // Type-safe asset retrieval
  getImage(id: ImageAssetId): HTMLImageElement | null {
    return this.assets.images[id] || null;
  }
  
  getAudio(id: AudioAssetId): HTMLAudioElement | null {
    return this.assets.audio[id] || null;
  }
  
  getData(id: DataAssetId): any | null {
    return this.assets.data[id] || null;
  }
}

// Asset ID factory functions
const createImageId = (id: string): ImageAssetId => id as ImageAssetId;
const createAudioId = (id: string): AudioAssetId => id as AudioAssetId;
const createDataId = (id: string): DataAssetId => id as DataAssetId;

// Usage with type safety
const assetManager = new AssetManager();

// Define asset IDs with type safety
const DRONE_SPRITE = createImageId('drone-sprite');
const ENGINE_SOUND = createAudioId('engine-sound');
const LEVEL_DATA = createDataId('level-01');

// Load assets
await assetManager.loadImage(DRONE_SPRITE, '/assets/drone.png');
await assetManager.loadAudio(ENGINE_SOUND, '/assets/engine.mp3');
await assetManager.loadData(LEVEL_DATA, '/assets/level01.json');

// Retrieve assets with type safety
const droneImage = assetManager.getImage(DRONE_SPRITE); // HTMLImageElement | null
const engineSound = assetManager.getAudio(ENGINE_SOUND); // HTMLAudioElement | null

// TypeScript prevents mixing asset types
// assetManager.getImage(ENGINE_SOUND); // ❌ Compile error
```

---

## 🧩 Utility Type Patterns

### 1. Recursive Type for Nested Game Objects

```typescript
// Type for deeply nested game object hierarchies
type DeepGameObject<T> = {
  [K in keyof T]: T[K] extends object
    ? T[K] extends any[]
      ? T[K]
      : DeepGameObject<T[K]> & {
          parent?: DeepGameObject<any>;
          children?: DeepGameObject<any>[];
        }
    : T[K];
};

// Transform configuration type
type GameObjectConfig = DeepGameObject<{
  transform: {
    position: Vector2;
    rotation: number;
    scale: Vector2;
  };
  renderer: {
    sprite: string;
    tint: number;
    alpha: number;
  };
  physics?: {
    body: 'static' | 'dynamic';
    mass: number;
  };
}>;
```

### 2. Function Composition Types

```typescript
// Type for composable game system functions
type SystemFunction<TInput, TOutput> = (input: TInput) => TOutput;

type Compose<T extends readonly SystemFunction<any, any>[]> = 
  T extends readonly [SystemFunction<infer A, infer B>]
    ? SystemFunction<A, B>
    : T extends readonly [SystemFunction<infer A, infer B>, ...infer Rest]
    ? Rest extends readonly SystemFunction<B, any>[]
      ? Compose<[SystemFunction<A, B>, ...Rest]>
      : never
    : never;

// Usage for creating system pipelines
const processInput: SystemFunction<RawInput, NormalizedInput> = (input) => ({ normalized: input });
const applyPhysics: SystemFunction<NormalizedInput, PhysicsResult> = (input) => ({ physics: true });
const render: SystemFunction<PhysicsResult, void> = (result) => { /* render */ };

// Composed system pipeline with type safety
type GamePipeline = Compose<[typeof processInput, typeof applyPhysics, typeof render]>;
```

---

## 🎯 Performance Patterns

### 1. Object Pool with Generics

```typescript
interface Poolable {
  reset(): void;
  isActive(): boolean;
  setActive(active: boolean): void;
}

class ObjectPool<T extends Poolable> {
  private available: T[] = [];
  private active: Set<T> = new Set();
  
  constructor(
    private factory: () => T,
    private initialSize: number = 10
  ) {
    this.initialize();
  }
  
  private initialize(): void {
    for (let i = 0; i < this.initialSize; i++) {
      this.available.push(this.factory());
    }
  }
  
  acquire(): T {
    let object = this.available.pop();
    
    if (!object) {
      object = this.factory();
    }
    
    object.setActive(true);
    this.active.add(object);
    return object;
  }
  
  release(object: T): void {
    if (this.active.has(object)) {
      object.reset();
      object.setActive(false);
      this.active.delete(object);
      this.available.push(object);
    }
  }
  
  releaseAll(): void {
    this.active.forEach(object => this.release(object));
  }
  
  getActiveCount(): number {
    return this.active.size;
  }
  
  getAvailableCount(): number {
    return this.available.length;
  }
}

// Usage with game objects
class Bullet implements Poolable {
  private active = false;
  
  reset(): void {
    // Reset bullet properties
  }
  
  isActive(): boolean {
    return this.active;
  }
  
  setActive(active: boolean): void {
    this.active = active;
  }
}

const bulletPool = new ObjectPool(() => new Bullet(), 50);
```

---

## 🚀 Advanced Patterns

### 1. Dependency Injection with Type Safety

```typescript
// Service container with type-safe dependency injection
class ServiceContainer {
  private services = new Map<string, any>();
  private factories = new Map<string, () => any>();
  
  // Register a service factory
  register<T>(token: new (...args: any[]) => T, factory: () => T): void {
    this.factories.set(token.name, factory);
  }
  
  // Resolve a service with type safety
  resolve<T>(token: new (...args: any[]) => T): T {
    const name = token.name;
    
    if (this.services.has(name)) {
      return this.services.get(name) as T;
    }
    
    const factory = this.factories.get(name);
    if (!factory) {
      throw new Error(`Service ${name} not registered`);
    }
    
    const instance = factory();
    this.services.set(name, instance);
    return instance;
  }
}

// Usage with game systems
const container = new ServiceContainer();

container.register(PhysicsSystem, () => new PhysicsSystem({
  enabled: true,
  debugMode: false,
  gravity: { x: 0, y: 0 },
  worldBounds: { x: 0, y: 0, width: 800, height: 600 },
  timeStep: 1/60
}));

const physics = container.resolve(PhysicsSystem); // Fully typed
```

---

## 📝 Best Practices Summary

### 1. **Use Branded Types for Domain Safety**
- Asset IDs, Entity IDs, System IDs should be branded types
- Prevents accidental mixing of different ID types

### 2. **Leverage Union Types for State Management**
- Game states, AI states, animation states
- TypeScript ensures all cases are handled

### 3. **Generic Components for Reusability**
- ECS components with typed configurations
- System interfaces with flexible implementations

### 4. **Event Systems with Mapped Types**
- Type-safe event emission and subscription
- Compile-time validation of event payloads

### 5. **Conditional Types for System Configuration**
- Different config types for different systems
- Type-safe factory functions

---

## 🐛 Common TypeScript Pitfalls in Games

### 1. **Circular Dependencies**
```typescript
// ❌ Bad: Circular dependency
// EntityManager imports Entity, Entity imports EntityManager

// ✅ Good: Use interfaces to break cycles
interface IEntityManager {
  addEntity(entity: IEntity): void;
  removeEntity(id: string): void;
}

interface IEntity {
  id: string;
  manager?: IEntityManager;
}
```

### 2. **Any Type Overuse**
```typescript
// ❌ Bad: Loses type safety
function updateComponent(component: any, data: any): void {
  component.update(data);
}

// ✅ Good: Generic constraints
function updateComponent<T extends IComponent>(
  component: T, 
  data: ComponentUpdateData<T>
): void {
  component.update(data);
}
```

### 3. **Missing Null Checks**
```typescript
// ❌ Bad: Runtime errors
const sprite = this.getSprite(id);
sprite.setPosition(x, y); // sprite might be null

// ✅ Good: Type-safe null handling
const sprite = this.getSprite(id);
if (sprite) {
  sprite.setPosition(x, y);
}

// Or use optional chaining
sprite?.setPosition(x, y);
```

---

*🎯 Master these TypeScript patterns to build maintainable, type-safe game systems that scale with your project's complexity!* 