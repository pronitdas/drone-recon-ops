# Implementation Guide: Drone Recon Ops Systems
## 🔧 Building Game Systems Step-by-Step

**Version**: 1.0  
**Date**: December 2024  
**Status**: Implementation Ready  

---

## 📋 Overview

This guide walks you through implementing each core system of Drone Recon Ops. Each system is built incrementally with detailed explanations suitable for junior developers.

### Systems We'll Build:
1. **Drone Physics System** - Movement and flight mechanics
2. **Detection System** - Line-of-sight and audio detection
3. **AI Patrol System** - Enemy behavior and pathfinding
4. **Mission System** - Objectives and scoring
5. **Audio System** - Spatial sound and feedback
6. **UI System** - HUD and interface elements

**Prerequisites**: Complete `PROJECT_SETUP.md` first.

---

## 🚁 System 1: Drone Physics System

### What This System Does:
- Handles drone movement with realistic physics
- Manages battery consumption
- Controls different flight modes (normal/precision)
- Applies environmental effects (wind, obstacles)

### 1.1 Drone Entity (`src/entities/Drone.ts`)

```typescript
import { Physics } from 'phaser';
import { Vector2 } from '@types/index';

export interface DroneConfig {
  maxSpeed: number;
  acceleration: number;
  drag: number;
  batteryCapacity: number;
  position: Vector2;
}

export class Drone extends Physics.Arcade.Sprite {
  // Movement properties
  private maxSpeed: number;
  private acceleration: number;
  private dragCoefficient: number;
  
  // Battery system
  private batteryLevel: number;
  private batteryCapacity: number;
  private batteryDrainRate: number;
  
  // Flight modes
  private isPrecisionMode: boolean = false;
  private isHovering: boolean = true;
  
  // Input tracking
  private inputVector: Vector2 = { x: 0, y: 0 };

  constructor(scene: Phaser.Scene, config: DroneConfig) {
    super(scene, config.position.x, config.position.y, 'drone');
    
    // Initialize properties
    this.maxSpeed = config.maxSpeed;
    this.acceleration = config.acceleration;
    this.dragCoefficient = config.drag;
    this.batteryCapacity = config.batteryCapacity;
    this.batteryLevel = config.batteryCapacity;
    this.batteryDrainRate = 1; // 1% per 10 seconds baseline
    
    // Add to scene
    scene.add.existing(this);
    scene.physics.add.existing(this);
    
    // Configure physics body
    this.body.setCollideWorldBounds(true);
    this.body.setDrag(this.dragCoefficient);
    
    console.log('🚁 Drone initialized');
  }

  /**
   * Update drone physics and systems each frame
   * Called from the main game loop
   */
  update(deltaTime: number): void {
    this.updateMovement(deltaTime);
    this.updateBattery(deltaTime);
    this.updateAudioEffects();
  }

  /**
   * Apply movement input to the drone
   * @param input - Normalized input vector (-1 to 1 for each axis)
   */
  setMovementInput(input: Vector2): void {
    this.inputVector = { ...input };
    this.isHovering = (input.x === 0 && input.y === 0);
  }

  /**
   * Toggle precision mode (slower, quieter movement)
   */
  togglePrecisionMode(): void {
    this.isPrecisionMode = !this.isPrecisionMode;
    console.log(`Precision mode: ${this.isPrecisionMode ? 'ON' : 'OFF'}`);
  }

  /**
   * Emergency stop - immediate velocity reduction with battery cost
   */
  emergencyStop(): void {
    if (this.batteryLevel >= 5) {
      this.body.setVelocity(0, 0);
      this.batteryLevel -= 5; // Emergency stop costs 5% battery
      console.log('🛑 Emergency stop activated');
    }
  }

  /**
   * Get current noise level for detection system
   */
  getNoiseLevel(): number {
    if (this.isHovering) return 0;
    
    const speed = Math.abs(this.body.velocity.x) + Math.abs(this.body.velocity.y);
    const baseNoise = speed / this.maxSpeed * 5; // 0-5 noise units
    
    return this.isPrecisionMode ? baseNoise * 0.5 : baseNoise;
  }

  /**
   * Get battery level as percentage (0-100)
   */
  getBatteryLevel(): number {
    return (this.batteryLevel / this.batteryCapacity) * 100;
  }

  /**
   * Check if drone is in critical battery state
   */
  isBatteryCritical(): boolean {
    return this.getBatteryLevel() <= 25;
  }

  private updateMovement(deltaTime: number): void {
    if (this.batteryLevel <= 0) {
      // No movement when battery is dead
      this.body.setVelocity(0, 0);
      return;
    }

    // Calculate movement speeds based on mode and battery
    const speedMultiplier = this.isPrecisionMode ? 0.5 : 1.0;
    const batteryEfficiency = this.getBatteryLevel() < 50 ? 0.8 : 1.0;
    
    const effectiveSpeed = this.maxSpeed * speedMultiplier * batteryEfficiency;
    const effectiveAcceleration = this.acceleration * speedMultiplier;

    // Apply forces based on input
    const forceX = this.inputVector.x * effectiveAcceleration;
    const forceY = this.inputVector.y * effectiveAcceleration;

    // Set velocity with limits
    const newVelX = Phaser.Math.Clamp(
      this.body.velocity.x + forceX * deltaTime,
      -effectiveSpeed,
      effectiveSpeed
    );
    const newVelY = Phaser.Math.Clamp(
      this.body.velocity.y + forceY * deltaTime,
      -effectiveSpeed,
      effectiveSpeed
    );

    this.body.setVelocity(newVelX, newVelY);
  }

  private updateBattery(deltaTime: number): void {
    let drainRate = this.batteryDrainRate; // Baseline hovering drain

    // Additional drain from movement
    if (!this.isHovering) {
      drainRate += this.isPrecisionMode ? 0.5 : 1.0; // Movement drain
    }

    // Apply battery drain
    this.batteryLevel -= (drainRate * deltaTime) / 1000; // Convert to per-second
    this.batteryLevel = Math.max(0, this.batteryLevel);

    // Force precision mode when battery is critical
    if (this.isBatteryCritical() && !this.isPrecisionMode) {
      this.isPrecisionMode = true;
      console.log('⚡ Battery critical - forcing precision mode');
    }
  }

  private updateAudioEffects(): void {
    // Audio cues will be handled by the Audio System
    // This just provides data for other systems
    const noiseLevel = this.getNoiseLevel();
    const batteryLevel = this.getBatteryLevel();

    // Emit events for audio system
    this.scene.events.emit('drone:noise', { level: noiseLevel });
    this.scene.events.emit('drone:battery', { level: batteryLevel });
  }
}
```

### 1.2 Drone Input System (`src/systems/DroneInputSystem.ts`)

```typescript
import { IGameSystem, Vector2 } from '@types/index';
import { Drone } from '@entities/Drone';

export class DroneInputSystem implements IGameSystem {
  name = 'DroneInputSystem';
  
  private scene: Phaser.Scene;
  private drone: Drone | null = null;
  private cursors: Phaser.Types.Input.Keyboard.CursorKeys;
  private wasdKeys: any;
  private shiftKey: Phaser.Input.Keyboard.Key;
  private spaceKey: Phaser.Input.Keyboard.Key;

  constructor(scene: Phaser.Scene) {
    this.scene = scene;
  }

  async initialize(): Promise<void> {
    // Set up keyboard inputs
    this.cursors = this.scene.input.keyboard.createCursorKeys();
    
    this.wasdKeys = this.scene.input.keyboard.addKeys('W,S,A,D');
    this.shiftKey = this.scene.input.keyboard.addKey('SHIFT');
    this.spaceKey = this.scene.input.keyboard.addKey('SPACE');

    // Set up key event listeners
    this.shiftKey.on('down', () => {
      if (this.drone) {
        this.drone.togglePrecisionMode();
      }
    });

    this.spaceKey.on('down', () => {
      if (this.drone) {
        this.drone.emergencyStop();
      }
    });

    console.log('🎮 Drone input system initialized');
  }

  update(deltaTime: number): void {
    if (!this.drone) return;

    // Calculate movement input
    const input: Vector2 = { x: 0, y: 0 };

    // WASD or Arrow keys
    if (this.cursors.left.isDown || this.wasdKeys.A.isDown) {
      input.x -= 1;
    }
    if (this.cursors.right.isDown || this.wasdKeys.D.isDown) {
      input.x += 1;
    }
    if (this.cursors.up.isDown || this.wasdKeys.W.isDown) {
      input.y -= 1;
    }
    if (this.cursors.down.isDown || this.wasdKeys.S.isDown) {
      input.y += 1;
    }

    // Normalize diagonal movement
    if (input.x !== 0 && input.y !== 0) {
      const length = Math.sqrt(input.x * input.x + input.y * input.y);
      input.x /= length;
      input.y /= length;
    }

    // Send input to drone
    this.drone.setMovementInput(input);
  }

  shutdown(): void {
    // Clean up input listeners
    this.shiftKey.removeAllListeners();
    this.spaceKey.removeAllListeners();
  }

  /**
   * Set the drone this system should control
   */
  setDrone(drone: Drone): void {
    this.drone = drone;
  }
}
```

### 1.3 Usage Example

```typescript
// In your main scene file
import { Drone, DroneConfig } from '@entities/Drone';
import { DroneInputSystem } from '@systems/DroneInputSystem';

export class GameScene extends Phaser.Scene {
  private drone: Drone;
  private inputSystem: DroneInputSystem;

  create(): void {
    // Create drone
    const droneConfig: DroneConfig = {
      maxSpeed: 150,
      acceleration: 300,
      drag: 500,
      batteryCapacity: 100,
      position: { x: 400, y: 300 }
    };

    this.drone = new Drone(this, droneConfig);
    
    // Set up input system
    this.inputSystem = new DroneInputSystem(this);
    this.inputSystem.initialize();
    this.inputSystem.setDrone(this.drone);
  }

  update(time: number, delta: number): void {
    this.drone.update(delta);
    this.inputSystem.update(delta);
  }
}
```

---

## 👁️ System 2: Detection System

### What This System Does:
- Calculates line-of-sight detection by enemies
- Handles audio detection zones
- Manages detection states (Safe, Caution, Alert, Discovered)
- Provides feedback to other systems

### 2.1 Detection Types (`src/types/detection.ts`)

```typescript
export interface IDetector {
  id: string;
  position: Vector2;
  range: number;
  fieldOfView: number; // For visual detectors
  direction: number; // Angle in degrees
  isActive: boolean;
  detectorType: DetectorType;
}

export enum DetectorType {
  VISUAL = 'visual',
  AUDIO = 'audio',
  MOTION = 'motion'
}

export interface DetectionResult {
  detected: boolean;
  detectionLevel: number; // 0-1, how strongly detected
  detector: IDetector;
  distance: number;
}

export interface AudioZone {
  center: Vector2;
  radius: number;
  sensitivity: number; // Minimum noise level to trigger
}
```

### 2.2 Line of Sight Calculator (`src/utils/LineOfSight.ts`)

```typescript
import { Vector2 } from '@types/index';

export class LineOfSightCalculator {
  private obstacles: Phaser.GameObjects.Rectangle[] = [];

  /**
   * Add an obstacle that blocks line of sight
   */
  addObstacle(obstacle: Phaser.GameObjects.Rectangle): void {
    this.obstacles.push(obstacle);
  }

  /**
   * Check if there's a clear line of sight between two points
   * @param from - Starting position
   * @param to - Target position
   * @returns true if line of sight is clear
   */
  hasLineOfSight(from: Vector2, to: Vector2): boolean {
    // Create a line from source to target
    const line = new Phaser.Geom.Line(from.x, from.y, to.x, to.y);

    // Check intersection with each obstacle
    for (const obstacle of this.obstacles) {
      const bounds = obstacle.getBounds();
      const rect = new Phaser.Geom.Rectangle(
        bounds.x, bounds.y, bounds.width, bounds.height
      );

      if (Phaser.Geom.Intersects.LineToRectangle(line, rect)) {
        return false; // Line of sight blocked
      }
    }

    return true; // Clear line of sight
  }

  /**
   * Calculate visibility percentage based on angle and distance
   * @param detector - The detecting entity
   * @param target - The target position
   * @returns visibility percentage (0-1)
   */
  calculateVisibility(detector: IDetector, target: Vector2): number {
    const distance = Phaser.Math.Distance.Between(
      detector.position.x, detector.position.y,
      target.x, target.y
    );

    // Check if target is within range
    if (distance > detector.range) {
      return 0;
    }

    // Check if target is within field of view
    if (detector.fieldOfView < 360) {
      const angleToTarget = Phaser.Math.Angle.Between(
        detector.position.x, detector.position.y,
        target.x, target.y
      );
      
      const angleDiff = Math.abs(
        Phaser.Math.Angle.ShortestBetween(detector.direction, angleToTarget)
      );
      
      if (angleDiff > detector.fieldOfView / 2) {
        return 0; // Outside field of view
      }
    }

    // Check line of sight
    if (!this.hasLineOfSight(detector.position, target)) {
      return 0;
    }

    // Calculate visibility based on distance (closer = more visible)
    const distanceFactor = 1 - (distance / detector.range);
    
    return distanceFactor;
  }
}
```

### 2.3 Detection System (`src/systems/DetectionSystem.ts`)

```typescript
import { IGameSystem, DetectionLevel, Vector2 } from '@types/index';
import { IDetector, DetectionResult, AudioZone } from '@types/detection';
import { LineOfSightCalculator } from '@utils/LineOfSight';
import { Drone } from '@entities/Drone';

export class DetectionSystem implements IGameSystem {
  name = 'DetectionSystem';
  
  private scene: Phaser.Scene;
  private lineOfSight: LineOfSightCalculator;
  private detectors: Map<string, IDetector> = new Map();
  private audioZones: AudioZone[] = [];
  private currentDetectionLevel: DetectionLevel = DetectionLevel.SAFE;
  private alertTimer: number = 0;
  private readonly ALERT_TIMEOUT = 30000; // 30 seconds

  constructor(scene: Phaser.Scene) {
    this.scene = scene;
    this.lineOfSight = new LineOfSightCalculator();
  }

  async initialize(): Promise<void> {
    console.log('👁️ Detection system initialized');
  }

  update(deltaTime: number): void {
    this.updateAlertTimer(deltaTime);
    // Main detection update will be called when needed
  }

  shutdown(): void {
    this.detectors.clear();
    this.audioZones = [];
  }

  /**
   * Add a visual detector (guard, camera, etc.)
   */
  addDetector(detector: IDetector): void {
    this.detectors.set(detector.id, detector);
  }

  /**
   * Remove a detector
   */
  removeDetector(id: string): void {
    this.detectors.delete(id);
  }

  /**
   * Add an audio detection zone
   */
  addAudioZone(zone: AudioZone): void {
    this.audioZones.push(zone);
  }

  /**
   * Add an obstacle that blocks line of sight
   */
  addObstacle(obstacle: Phaser.GameObjects.Rectangle): void {
    this.lineOfSight.addObstacle(obstacle);
  }

  /**
   * Check detection for a target (usually the drone)
   * @param target - Target position
   * @param noiseLevel - Current noise level of target
   * @returns Detection results from all detectors
   */
  checkDetection(target: Vector2, noiseLevel: number = 0): DetectionResult[] {
    const results: DetectionResult[] = [];
    let maxDetectionLevel = 0;

    // Check visual detection
    for (const detector of this.detectors.values()) {
      if (!detector.isActive) continue;

      const distance = Phaser.Math.Distance.Between(
        detector.position.x, detector.position.y,
        target.x, target.y
      );

      let detectionLevel = 0;

      if (detector.detectorType === 'visual') {
        detectionLevel = this.lineOfSight.calculateVisibility(detector, target);
      }

      results.push({
        detected: detectionLevel > 0,
        detectionLevel,
        detector,
        distance
      });

      maxDetectionLevel = Math.max(maxDetectionLevel, detectionLevel);
    }

    // Check audio detection
    const audioDetection = this.checkAudioDetection(target, noiseLevel);
    results.push(...audioDetection);

    // Update overall detection state
    this.updateDetectionState(maxDetectionLevel);

    return results;
  }

  /**
   * Get current detection level
   */
  getDetectionLevel(): DetectionLevel {
    return this.currentDetectionLevel;
  }

  private checkAudioDetection(target: Vector2, noiseLevel: number): DetectionResult[] {
    const results: DetectionResult[] = [];

    for (const zone of this.audioZones) {
      const distance = Phaser.Math.Distance.Between(
        zone.center.x, zone.center.y,
        target.x, target.y
      );

      if (distance <= zone.radius && noiseLevel >= zone.sensitivity) {
        // Create a virtual audio detector for the result
        const audioDetector: IDetector = {
          id: `audio_${zone.center.x}_${zone.center.y}`,
          position: zone.center,
          range: zone.radius,
          fieldOfView: 360,
          direction: 0,
          isActive: true,
          detectorType: 'audio'
        };

        const detectionLevel = Math.min(1, noiseLevel / 10); // Normalize noise level

        results.push({
          detected: true,
          detectionLevel,
          detector: audioDetector,
          distance
        });
      }
    }

    return results;
  }

  private updateDetectionState(detectionLevel: number): void {
    const previousLevel = this.currentDetectionLevel;

    if (detectionLevel > 0.8) {
      this.currentDetectionLevel = DetectionLevel.DISCOVERED;
      this.alertTimer = this.ALERT_TIMEOUT;
    } else if (detectionLevel > 0.5) {
      this.currentDetectionLevel = DetectionLevel.ALERT;
      this.alertTimer = this.ALERT_TIMEOUT;
    } else if (detectionLevel > 0.2) {
      this.currentDetectionLevel = DetectionLevel.CAUTION;
    } else if (this.alertTimer <= 0) {
      this.currentDetectionLevel = DetectionLevel.SAFE;
    }

    // Emit event if detection level changed
    if (previousLevel !== this.currentDetectionLevel) {
      this.scene.events.emit('detection:stateChanged', {
        previous: previousLevel,
        current: this.currentDetectionLevel
      });

      console.log(`Detection level: ${this.currentDetectionLevel}`);
    }
  }

  private updateAlertTimer(deltaTime: number): void {
    if (this.alertTimer > 0) {
      this.alertTimer -= deltaTime;
      
      if (this.alertTimer <= 0 && this.currentDetectionLevel !== DetectionLevel.DISCOVERED) {
        // Return to safe if not actively discovered
        this.currentDetectionLevel = DetectionLevel.SAFE;
        this.scene.events.emit('detection:stateChanged', {
          previous: DetectionLevel.ALERT,
          current: DetectionLevel.SAFE
        });
      }
    }
  }
}
```

### 2.4 Usage Example

```typescript
// In your game scene
export class GameScene extends Phaser.Scene {
  private detectionSystem: DetectionSystem;
  private drone: Drone;

  create(): void {
    this.detectionSystem = new DetectionSystem(this);
    this.detectionSystem.initialize();

    // Add a guard (visual detector)
    this.detectionSystem.addDetector({
      id: 'guard1',
      position: { x: 300, y: 300 },
      range: 80,
      fieldOfView: 90,
      direction: 0, // Facing right
      isActive: true,
      detectorType: 'visual'
    });

    // Add an obstacle (wall)
    const wall = this.add.rectangle(400, 200, 100, 20, 0x666666);
    this.detectionSystem.addObstacle(wall);

    // Add audio zone
    this.detectionSystem.addAudioZone({
      center: { x: 500, y: 400 },
      radius: 40,
      sensitivity: 3 // Triggered by noise level 3+
    });

    // Listen for detection events
    this.events.on('detection:stateChanged', (data) => {
      console.log(`Detection changed: ${data.previous} → ${data.current}`);
    });
  }

  update(): void {
    // Check detection every frame
    const dronePosition = { x: this.drone.x, y: this.drone.y };
    const noiseLevel = this.drone.getNoiseLevel();
    
    this.detectionSystem.checkDetection(dronePosition, noiseLevel);
  }
}
```

---

## 🤖 System 3: AI Patrol System

### What This System Does:
- Creates patrol routes for enemies
- Implements different AI behaviors (static, patrol, search)
- Handles state transitions based on detection
- Provides realistic enemy movement patterns

### 3.1 AI Types and States (`src/types/ai.ts`)

```typescript
import { Vector2 } from '@types/index';

export enum AIState {
  IDLE = 'idle',
  PATROL = 'patrol',
  INVESTIGATE = 'investigate',
  SEARCH = 'search',
  CHASE = 'chase'
}

export enum AIType {
  STATIC_GUARD = 'static_guard',
  PATROL_GUARD = 'patrol_guard',
  ROAMING_GUARD = 'roaming_guard'
}

export interface Waypoint {
  position: Vector2;
  waitTime?: number; // Time to wait at this waypoint (milliseconds)
  lookDirection?: number; // Direction to face while waiting (degrees)
}

export interface PatrolRoute {
  waypoints: Waypoint[];
  isLoop: boolean;
  patrolSpeed: number;
}

export interface AIConfig {
  type: AIType;
  position: Vector2;
  detectionRange: number;
  fieldOfView: number;
  moveSpeed: number;
  patrolRoute?: PatrolRoute;
  alertDuration: number; // How long to stay alert after losing target
}
```

### 3.2 AI Entity (`src/entities/AIGuard.ts`)

```typescript
import { AIState, AIType, AIConfig, Waypoint } from '@types/ai';
import { Vector2, DetectionLevel } from '@types/index';
import { IDetector } from '@types/detection';

export class AIGuard extends Phaser.GameObjects.Sprite implements IDetector {
  // IDetector implementation
  id: string;
  position: Vector2;
  range: number;
  fieldOfView: number;
  direction: number;
  isActive: boolean = true;
  detectorType = 'visual' as const;

  // AI properties
  private aiType: AIType;
  private currentState: AIState = AIState.IDLE;
  private moveSpeed: number;
  private alertDuration: number;
  
  // Patrol system
  private waypoints: Waypoint[] = [];
  private currentWaypointIndex: number = 0;
  private isReturningToRoute: boolean = false;
  private waitTimer: number = 0;
  
  // State timers
  private alertTimer: number = 0;
  private investigateTimer: number = 0;
  
  // Target tracking
  private lastKnownTargetPosition: Vector2 | null = null;
  private suspicionLevel: number = 0;

  constructor(scene: Phaser.Scene, config: AIConfig) {
    super(scene, config.position.x, config.position.y, 'guard');
    
    this.id = `guard_${Math.random().toString(36).substr(2, 9)}`;
    this.position = { x: config.position.x, y: config.position.y };
    this.range = config.detectionRange;
    this.fieldOfView = config.fieldOfView;
    this.direction = 0;
    
    this.aiType = config.type;
    this.moveSpeed = config.moveSpeed;
    this.alertDuration = config.alertDuration;
    
    if (config.patrolRoute) {
      this.waypoints = config.patrolRoute.waypoints;
    }
    
    // Add to scene
    scene.add.existing(this);
    
    // Set initial state based on type
    this.setState(config.type === AIType.STATIC_GUARD ? AIState.IDLE : AIState.PATROL);
    
    console.log(`🤖 AI Guard ${this.id} created (${config.type})`);
  }

  update(deltaTime: number): void {
    this.updateTimers(deltaTime);
    this.updateBehavior(deltaTime);
    this.updateSuspicion(deltaTime);
    
    // Update detector position and direction
    this.position = { x: this.x, y: this.y };
  }

  /**
   * React to detection events
   * @param detectionLevel - Current detection level from detection system
   * @param targetPosition - Last known position of target
   */
  onDetectionEvent(detectionLevel: DetectionLevel, targetPosition?: Vector2): void {
    switch (detectionLevel) {
      case DetectionLevel.SAFE:
        if (this.currentState === AIState.CHASE) {
          this.setState(AIState.SEARCH);
          this.investigateTimer = 5000; // Search for 5 seconds
        }
        break;
        
      case DetectionLevel.CAUTION:
        this.suspicionLevel = Math.min(100, this.suspicionLevel + 10);
        if (this.currentState === AIState.PATROL) {
          this.setState(AIState.INVESTIGATE);
        }
        break;
        
      case DetectionLevel.ALERT:
        this.suspicionLevel = Math.min(100, this.suspicionLevel + 25);
        this.setState(AIState.INVESTIGATE);
        if (targetPosition) {
          this.lastKnownTargetPosition = { ...targetPosition };
        }
        break;
        
      case DetectionLevel.DISCOVERED:
        this.suspicionLevel = 100;
        this.setState(AIState.CHASE);
        if (targetPosition) {
          this.lastKnownTargetPosition = { ...targetPosition };
        }
        break;
    }
  }

  private setState(newState: AIState): void {
    if (this.currentState === newState) return;
    
    const oldState = this.currentState;
    this.currentState = newState;
    
    // State entry actions
    switch (newState) {
      case AIState.IDLE:
        this.setVelocity(0, 0);
        break;
        
      case AIState.PATROL:
        this.isReturningToRoute = false;
        break;
        
      case AIState.INVESTIGATE:
        this.investigateTimer = 3000; // Investigate for 3 seconds
        break;
        
      case AIState.SEARCH:
        this.alertTimer = this.alertDuration;
        break;
        
      case AIState.CHASE:
        this.alertTimer = this.alertDuration;
        break;
    }
    
    console.log(`🤖 Guard ${this.id}: ${oldState} → ${newState}`);
  }

  private updateBehavior(deltaTime: number): void {
    switch (this.currentState) {
      case AIState.IDLE:
        this.behaviorIdle();
        break;
        
      case AIState.PATROL:
        this.behaviorPatrol(deltaTime);
        break;
        
      case AIState.INVESTIGATE:
        this.behaviorInvestigate(deltaTime);
        break;
        
      case AIState.SEARCH:
        this.behaviorSearch(deltaTime);
        break;
        
      case AIState.CHASE:
        this.behaviorChase(deltaTime);
        break;
    }
  }

  private behaviorIdle(): void {
    // Static guards just look around occasionally
    if (Math.random() < 0.001) { // Very rare random look
      this.direction = Math.random() * 360;
    }
  }

  private behaviorPatrol(deltaTime: number): void {
    if (this.waypoints.length === 0) return;
    
    const targetWaypoint = this.waypoints[this.currentWaypointIndex];
    
    if (this.waitTimer > 0) {
      // Waiting at waypoint
      this.setVelocity(0, 0);
      if (targetWaypoint.lookDirection !== undefined) {
        this.direction = targetWaypoint.lookDirection;
      }
      return;
    }
    
    // Move towards current waypoint
    const distance = Phaser.Math.Distance.Between(
      this.x, this.y,
      targetWaypoint.position.x, targetWaypoint.position.y
    );
    
    if (distance < 5) {
      // Reached waypoint
      this.setVelocity(0, 0);
      this.waitTimer = targetWaypoint.waitTime || 0;
      
      // Move to next waypoint
      this.currentWaypointIndex = (this.currentWaypointIndex + 1) % this.waypoints.length;
    } else {
      // Move towards waypoint
      this.moveTowardsPoint(targetWaypoint.position, this.moveSpeed * 0.8);
    }
  }

  private behaviorInvestigate(deltaTime: number): void {
    if (this.investigateTimer <= 0) {
      // Investigation complete, return to normal behavior
      this.setState(this.aiType === AIType.STATIC_GUARD ? AIState.IDLE : AIState.PATROL);
      return;
    }
    
    if (this.lastKnownTargetPosition) {
      // Move towards last known position
      const distance = Phaser.Math.Distance.Between(
        this.x, this.y,
        this.lastKnownTargetPosition.x, this.lastKnownTargetPosition.y
      );
      
      if (distance > 10) {
        this.moveTowardsPoint(this.lastKnownTargetPosition, this.moveSpeed * 0.6);
      } else {
        // Reached investigation point, look around
        this.setVelocity(0, 0);
        this.direction += 60 * (deltaTime / 1000); // Slow rotation
      }
    }
  }

  private behaviorSearch(deltaTime: number): void {
    if (this.alertTimer <= 0) {
      // Search complete, return to patrol
      this.setState(this.aiType === AIType.STATIC_GUARD ? AIState.IDLE : AIState.PATROL);
      this.lastKnownTargetPosition = null;
      return;
    }
    
    // Random search pattern around last known position
    if (this.lastKnownTargetPosition) {
      // Move randomly within search area
      const searchRadius = 100;
      const angle = Math.random() * Math.PI * 2;
      const distance = Math.random() * searchRadius;
      
      const searchPoint = {
        x: this.lastKnownTargetPosition.x + Math.cos(angle) * distance,
        y: this.lastKnownTargetPosition.y + Math.sin(angle) * distance
      };
      
      this.moveTowardsPoint(searchPoint, this.moveSpeed * 0.9);
    }
  }

  private behaviorChase(deltaTime: number): void {
    if (this.lastKnownTargetPosition) {
      // Chase directly towards target
      this.moveTowardsPoint(this.lastKnownTargetPosition, this.moveSpeed);
    }
  }

  private moveTowardsPoint(target: Vector2, speed: number): void {
    const angle = Phaser.Math.Angle.Between(this.x, this.y, target.x, target.y);
    
    const velocityX = Math.cos(angle) * speed;
    const velocityY = Math.sin(angle) * speed;
    
    this.setVelocity(velocityX, velocityY);
    
    // Update facing direction
    this.direction = Phaser.Math.RadToDeg(angle);
  }

  private updateTimers(deltaTime: number): void {
    if (this.waitTimer > 0) {
      this.waitTimer -= deltaTime;
    }
    
    if (this.alertTimer > 0) {
      this.alertTimer -= deltaTime;
    }
    
    if (this.investigateTimer > 0) {
      this.investigateTimer -= deltaTime;
    }
  }

  private updateSuspicion(deltaTime: number): void {
    // Gradually reduce suspicion over time
    if (this.suspicionLevel > 0 && this.currentState === AIState.PATROL) {
      this.suspicionLevel = Math.max(0, this.suspicionLevel - (deltaTime / 100));
    }
  }

  /**
   * Get current patrol waypoint for debugging
   */
  getCurrentWaypoint(): Waypoint | null {
    if (this.waypoints.length === 0) return null;
    return this.waypoints[this.currentWaypointIndex];
  }

  /**
   * Get current AI state
   */
  getState(): AIState {
    return this.currentState;
  }

  /**
   * Get suspicion level (0-100)
   */
  getSuspicionLevel(): number {
    return this.suspicionLevel;
  }
}
```

### 3.3 AI System Manager (`src/systems/AISystem.ts`)

```typescript
import { IGameSystem, DetectionLevel } from '@types/index';
import { AIGuard } from '@entities/AIGuard';
import { AIConfig } from '@types/ai';
import { DetectionSystem } from './DetectionSystem';

export class AISystem implements IGameSystem {
  name = 'AISystem';
  
  private scene: Phaser.Scene;
  private guards: AIGuard[] = [];
  private detectionSystem: DetectionSystem | null = null;

  constructor(scene: Phaser.Scene) {
    this.scene = scene;
  }

  async initialize(): Promise<void> {
    console.log('🤖 AI system initialized');
  }

  update(deltaTime: number): void {
    // Update all guards
    for (const guard of this.guards) {
      guard.update(deltaTime);
    }
  }

  shutdown(): void {
    this.guards.forEach(guard => guard.destroy());
    this.guards = [];
  }

  /**
   * Create a new AI guard
   */
  createGuard(config: AIConfig): AIGuard {
    const guard = new AIGuard(this.scene, config);
    this.guards.push(guard);
    
    // Register with detection system if available
    if (this.detectionSystem) {
      this.detectionSystem.addDetector(guard);
    }
    
    return guard;
  }

  /**
   * Remove a guard
   */
  removeGuard(guard: AIGuard): void {
    const index = this.guards.indexOf(guard);
    if (index > -1) {
      this.guards.splice(index, 1);
      guard.destroy();
      
      if (this.detectionSystem) {
        this.detectionSystem.removeDetector(guard.id);
      }
    }
  }

  /**
   * Set the detection system for AI coordination
   */
  setDetectionSystem(detectionSystem: DetectionSystem): void {
    this.detectionSystem = detectionSystem;
    
    // Register all existing guards
    for (const guard of this.guards) {
      detectionSystem.addDetector(guard);
    }
  }

  /**
   * Notify all guards of a detection event
   */
  notifyDetectionEvent(detectionLevel: DetectionLevel, targetPosition?: { x: number; y: number }): void {
    for (const guard of this.guards) {
      guard.onDetectionEvent(detectionLevel, targetPosition);
    }
  }

  /**
   * Get all guards
   */
  getGuards(): AIGuard[] {
    return [...this.guards];
  }

  /**
   * Get guards in a specific state
   */
  getGuardsByState(state: AIState): AIGuard[] {
    return this.guards.filter(guard => guard.getState() === state);
  }
}
```

---

This implementation guide continues with the remaining systems (Mission System, Audio System, UI System) in the same detailed format. Each system is broken down into:

1. **What it does** - Clear explanation of purpose
2. **Type definitions** - TypeScript interfaces and enums
3. **Core implementation** - Main classes with detailed comments
4. **Usage examples** - How to integrate with other systems

The key principles followed throughout:

- **Modular design** - Each system is independent and communicates through events
- **Clear interfaces** - Well-defined contracts between systems
- **Comprehensive comments** - Every method and complex logic explained
- **Real examples** - Practical usage patterns shown
- **Error handling** - Defensive programming practices
- **Performance considerations** - Efficient algorithms and memory management

Would you like me to continue with the remaining systems (Mission, Audio, UI) or would you prefer me to create the other documentation files (Development Workflow, Patterns & Solutions) first? 