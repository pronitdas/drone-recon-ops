# 🌱 Beginner's Guide to Drone Recon Ops
## From Zero to Flying Drone in 2-4 Hours

---

## 📋 What You'll Learn

By the end of this guide, you'll have:
- ✅ A working drone that moves smoothly with keyboard input
- ✅ Understanding of game loops, sprites, and physics basics
- ✅ A simple playable level with objectives
- ✅ Foundation knowledge to build complex game systems

---

## 🎯 Prerequisites

**Required Knowledge:**
- Basic JavaScript (variables, functions, if statements)
- How to run commands in terminal/command prompt
- Text editor usage (VS Code recommended)

**Don't worry if you're new to:**
- Game development concepts ← We'll explain everything!
- TypeScript ← We'll teach you as we go
- Phaser.js ← This guide assumes zero experience

---

## 🚀 Step 1: Quick Start (10 minutes)

### What We're Building
A simple scene with a drone sprite that you can move around with arrow keys.

### Setup Your Project

```bash
# 1. Create project folder
mkdir drone-game
cd drone-game

# 2. Initialize project
npm init -y

# 3. Install dependencies
npm install phaser
npm install -D typescript vite @types/node

# 4. Create basic files
touch src/main.ts src/GameScene.ts index.html vite.config.js
```

### Create Your First Scene

**File: `src/GameScene.ts`**
```typescript
import Phaser from 'phaser';

export class GameScene extends Phaser.Scene {
  private drone!: Phaser.Physics.Arcade.Sprite;
  private cursors!: Phaser.Types.Input.Keyboard.CursorKeys;

  constructor() {
    // Every scene needs a unique key (name)
    super({ key: 'GameScene' });
  }

  preload(): void {
    // This runs BEFORE create()
    // Here we load all our images and sounds
    
    // For now, we'll create a simple colored rectangle as our drone
    // In a real game, you'd load: this.load.image('drone', 'assets/drone.png')
    this.load.image('drone', 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==');
  }

  create(): void {
    // This runs AFTER preload() finishes
    // Here we create all our game objects
    
    // 1. Create the drone sprite
    this.drone = this.physics.add.sprite(400, 300, 'drone');
    
    // 2. Make it a colored square so we can see it
    this.drone.setTint(0x00ff00); // Green color
    this.drone.setDisplaySize(32, 32); // 32x32 pixels
    
    // 3. Set up physics properties
    this.drone.setCollideWorldBounds(true); // Can't leave screen
    this.drone.setDrag(300); // Slows down when no input (feels natural)
    
    // 4. Set up keyboard input
    this.cursors = this.input.keyboard!.createCursorKeys();
    
    console.log('✅ Drone created and ready to fly!');
  }

  update(): void {
    // This runs every frame (usually 60 times per second)
    // Here we handle continuous things like movement
    
    this.handleDroneMovement();
  }

  private handleDroneMovement(): void {
    // Clear any existing movement first
    this.drone.setAcceleration(0, 0);
    
    // Check each direction and apply force
    // Think of acceleration as "thrust" - how hard we push
    const thrustPower = 300;
    
    if (this.cursors.left.isDown) {
      this.drone.setAccelerationX(-thrustPower); // Negative = left
    }
    if (this.cursors.right.isDown) {
      this.drone.setAccelerationX(thrustPower);  // Positive = right
    }
    if (this.cursors.up.isDown) {
      this.drone.setAccelerationY(-thrustPower); // Negative = up (Y flipped in games)
    }
    if (this.cursors.down.isDown) {
      this.drone.setAccelerationY(thrustPower);  // Positive = down
    }
  }
}
```

### Launch Your Game

**File: `src/main.ts`**
```typescript
import Phaser from 'phaser';
import { GameScene } from './GameScene';

// Game configuration - tells Phaser how to set up your game
const config: Phaser.Types.Core.GameConfig = {
  type: Phaser.AUTO,        // Use WebGL if available, fallback to Canvas
  width: 800,               // Game window width
  height: 600,              // Game window height
  parent: 'game-container', // HTML element to put game in
  backgroundColor: '#2c3e50', // Dark blue background
  
  // Physics settings
  physics: {
    default: 'arcade',      // Use Arcade physics (simple and fast)
    arcade: {
      gravity: { x: 0, y: 0 }, // No gravity (we're in space/air)
      debug: false           // Set to true to see physics bodies
    }
  },
  
  // Which scenes to include
  scene: [GameScene]
};

// Actually create and start the game
const game = new Phaser.Game(config);

console.log('🚁 Drone Recon Ops - Game Started!');
```

**File: `index.html`**
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
            padding: 20px;
            background: #1a1a1a;
            color: white;
            font-family: Arial, sans-serif;
        }
        #game-container {
            margin: 0 auto;
            border: 2px solid #333;
        }
    </style>
</head>
<body>
    <h1>🚁 Drone Recon Ops</h1>
    <p>Use arrow keys to move the drone</p>
    <div id="game-container"></div>
    
    <script type="module" src="/src/main.ts"></script>
</body>
</html>
```

**File: `vite.config.js`**
```javascript
import { defineConfig } from 'vite';

export default defineConfig({
  base: './',
  build: {
    outDir: 'dist'
  }
});
```

### Run Your Game!

```bash
npx vite
```

Open http://localhost:5173 and use arrow keys to move your green square drone!

**🎉 Congratulations! You've created your first Phaser game!**

---

## 🎮 Step 2: Understanding What Happened (15 minutes)

### The Game Loop Explained

Every game follows the same pattern:

```
START GAME
    ↓
PRELOAD (load images, sounds)
    ↓
CREATE (set up game objects)
    ↓
┌─→ UPDATE (check input, move objects) ←─┐
│       ↓                               │
└── RENDER (draw everything on screen) ──┘
    (this loop runs 60 times per second)
```

### Key Concepts You Just Used

**1. Scenes** = Different "screens" in your game
- Menu Scene, Game Scene, Game Over Scene, etc.
- Each scene has its own preload(), create(), update() methods

**2. Sprites** = Visual objects in your game
- Images that can move, rotate, scale
- Can have physics (collision, gravity, etc.)

**3. Physics Bodies** = Invisible shapes for collision
- Every sprite can have a physics body
- Bodies can bounce, collide, be affected by gravity

**4. Input Systems** = How players control the game
- Keyboard, mouse, touch, gamepad
- Phaser handles all the complexity for you

### Common Beginner Questions

**Q: Why does Y coordinate work "backwards"?**
A: In computer graphics, (0,0) is at the top-left corner. So:
- Y = 0 is the TOP of the screen
- Y = 600 is the BOTTOM of the screen
- This is why "up" movement uses negative Y values

**Q: What's the difference between velocity and acceleration?**
A: Think of a car:
- **Velocity** = current speed (how fast you're moving right now)
- **Acceleration** = pressing the gas pedal (how much you're speeding up)
- Acceleration changes velocity, velocity changes position

**Q: Why use `setAcceleration()` instead of `setVelocity()`?**
A: Acceleration feels more natural for vehicles:
- Press key = apply thrust (acceleration)
- Release key = thrust stops, but momentum continues (velocity decreases due to drag)
- Direct velocity control feels "digital" and unnatural

---

## 🎯 Step 3: Adding Simple Objectives (20 minutes)

Let's add a target to reach and a simple win condition.

### Enhanced Game Scene

**Update `src/GameScene.ts`:**
```typescript
import Phaser from 'phaser';

export class GameScene extends Phaser.Scene {
  private drone!: Phaser.Physics.Arcade.Sprite;
  private target!: Phaser.Physics.Arcade.Sprite;
  private cursors!: Phaser.Types.Input.Keyboard.CursorKeys;
  private scoreText!: Phaser.GameObjects.Text;
  private missionText!: Phaser.GameObjects.Text;
  
  // Game state
  private targetsCollected: number = 0;
  private missionComplete: boolean = false;

  constructor() {
    super({ key: 'GameScene' });
  }

  preload(): void {
    // Create simple colored rectangles for our sprites
    this.load.image('drone', 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==');
    this.load.image('target', 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==');
  }

  create(): void {
    // Create the drone (player)
    this.drone = this.physics.add.sprite(100, 300, 'drone');
    this.drone.setTint(0x00ff00); // Green
    this.drone.setDisplaySize(32, 32);
    this.drone.setCollideWorldBounds(true);
    this.drone.setDrag(300);
    
    // Create the target (objective)
    this.target = this.physics.add.sprite(700, 300, 'target');
    this.target.setTint(0xff0000); // Red
    this.target.setDisplaySize(24, 24);
    
    // Add a pulsing effect to make the target more visible
    this.tweens.add({
      targets: this.target,
      scaleX: 1.2,
      scaleY: 1.2,
      duration: 1000,
      yoyo: true,
      repeat: -1,
      ease: 'Sine.easeInOut'
    });
    
    // Set up collision detection
    this.physics.add.overlap(this.drone, this.target, this.collectTarget, undefined, this);
    
    // Set up input
    this.cursors = this.input.keyboard!.createCursorKeys();
    
    // Create UI text
    this.scoreText = this.add.text(16, 16, 'Targets: 0/1', {
      fontSize: '24px',
      color: '#ffffff'
    });
    
    this.missionText = this.add.text(16, 50, 'Mission: Reach the red target', {
      fontSize: '18px',
      color: '#ffff00'
    });
    
    console.log('✅ Game scene ready! Collect the red target.');
  }

  update(): void {
    // Only allow movement if mission isn't complete
    if (!this.missionComplete) {
      this.handleDroneMovement();
    }
  }

  private handleDroneMovement(): void {
    this.drone.setAcceleration(0, 0);
    
    const thrustPower = 300;
    
    if (this.cursors.left.isDown) {
      this.drone.setAccelerationX(-thrustPower);
    }
    if (this.cursors.right.isDown) {
      this.drone.setAccelerationX(thrustPower);
    }
    if (this.cursors.up.isDown) {
      this.drone.setAccelerationY(-thrustPower);
    }
    if (this.cursors.down.isDown) {
      this.drone.setAccelerationY(thrustPower);
    }
  }

  private collectTarget(): void {
    // This function runs when drone touches target
    
    // Remove the target
    this.target.destroy();
    
    // Update game state
    this.targetsCollected++;
    this.missionComplete = true;
    
    // Update UI
    this.scoreText.setText(`Targets: ${this.targetsCollected}/1`);
    this.missionText.setText('🎉 MISSION COMPLETE! Well done!');
    this.missionText.setColor('#00ff00');
    
    // Stop the drone
    this.drone.setVelocity(0, 0);
    this.drone.setAcceleration(0, 0);
    
    // Add a celebration effect
    this.tweens.add({
      targets: this.drone,
      angle: 360,
      duration: 1000,
      ease: 'Power2'
    });
    
    console.log('🎉 Target collected! Mission complete!');
  }
}
```

### Test Your Enhanced Game

Run `npx vite` again and try to reach the red target with your green drone!

### What You Just Learned

**1. Collision Detection** - How to detect when objects touch
```typescript
// This line creates an "overlap" detector
this.physics.add.overlap(objectA, objectB, callbackFunction, undefined, this);
```

**2. Game State Management** - Tracking what's happening
```typescript
private targetsCollected: number = 0;  // Current score
private missionComplete: boolean = false;  // Game condition
```

**3. UI Elements** - Displaying information to players
```typescript
this.add.text(x, y, 'Text content', { style options });
```

**4. Tweens** - Smooth animations
```typescript
this.tweens.add({
  targets: whatToAnimate,
  property: finalValue,
  duration: timeInMilliseconds
});
```

---

## 🚁 Step 4: Better Drone Physics (30 minutes)

Now let's make the drone feel more realistic with battery management and different flight modes.

### Create a Proper Drone Class

**File: `src/Drone.ts`**
```typescript
import Phaser from 'phaser';

// Define the shape of our drone configuration
export interface DroneConfig {
  scene: Phaser.Scene;
  x: number;
  y: number;
  maxSpeed: number;
  batteryCapacity: number;
}

export class Drone extends Phaser.Physics.Arcade.Sprite {
  // Flight characteristics
  private maxSpeed: number;
  private thrustForce: number = 300;
  private dragCoefficient: number = 0.85;
  
  // Battery system
  private batteryLevel: number;
  private batteryCapacity: number;
  private batteryDrainRate: number = 2; // % per second when thrusting
  
  // Flight modes
  private isPrecisionMode: boolean = false;
  private isHovering: boolean = true;
  
  // Input tracking
  private inputVector: { x: number; y: number } = { x: 0, y: 0 };
  
  constructor(config: DroneConfig) {
    // Call parent constructor (Phaser.Physics.Arcade.Sprite)
    super(config.scene, config.x, config.y, 'drone');
    
    // Initialize our properties
    this.maxSpeed = config.maxSpeed;
    this.batteryCapacity = config.batteryCapacity;
    this.batteryLevel = config.batteryCapacity;
    
    // Add to scene
    config.scene.add.existing(this);
    config.scene.physics.add.existing(this);
    
    // Configure physics
    this.setCollideWorldBounds(true);
    this.setDrag(this.dragCoefficient);
    this.setMaxVelocity(this.maxSpeed);
    
    // Make it look like a drone
    this.setTint(0x00ff00);
    this.setDisplaySize(32, 32);
    
    console.log('🚁 Advanced drone created with battery system');
  }

  /**
   * Call this every frame to update the drone
   */
  update(deltaTime: number): void {
    this.updateMovement(deltaTime);
    this.updateBattery(deltaTime);
    this.updateEffects();
  }

  /**
   * Set the movement input (usually from keyboard)
   * @param input Object with x and y values between -1 and 1
   */
  setMovementInput(input: { x: number; y: number }): void {
    this.inputVector = { ...input };
    this.isHovering = (input.x === 0 && input.y === 0);
  }

  /**
   * Toggle between normal and precision flight modes
   */
  togglePrecisionMode(): void {
    this.isPrecisionMode = !this.isPrecisionMode;
    console.log(`Precision mode: ${this.isPrecisionMode ? 'ON' : 'OFF'}`);
  }

  /**
   * Get current battery level as percentage (0-100)
   */
  getBatteryLevel(): number {
    return (this.batteryLevel / this.batteryCapacity) * 100;
  }

  /**
   * Get current noise level for stealth mechanics
   */
  getNoiseLevel(): number {
    if (this.isHovering) return 0;
    
    const speed = Math.abs(this.body!.velocity.x) + Math.abs(this.body!.velocity.y);
    const baseNoise = (speed / this.maxSpeed) * 5; // 0-5 noise units
    
    return this.isPrecisionMode ? baseNoise * 0.5 : baseNoise;
  }

  /**
   * Check if battery is in critical state
   */
  isBatteryCritical(): boolean {
    return this.getBatteryLevel() <= 25;
  }

  private updateMovement(deltaTime: number): void {
    // No movement if battery is completely dead
    if (this.batteryLevel <= 0) {
      this.setAcceleration(0, 0);
      return;
    }

    // Calculate movement modifiers
    const modeMultiplier = this.isPrecisionMode ? 0.5 : 1.0;
    const batteryEfficiency = this.getBatteryLevel() < 50 ? 0.8 : 1.0;
    
    const effectiveThrust = this.thrustForce * modeMultiplier * batteryEfficiency;

    // Apply thrust based on input
    const thrustX = this.inputVector.x * effectiveThrust;
    const thrustY = this.inputVector.y * effectiveThrust;

    this.setAcceleration(thrustX, thrustY);
  }

  private updateBattery(deltaTime: number): void {
    let drainRate = 0.1; // Baseline hovering drain

    // Additional drain from movement
    if (!this.isHovering) {
      drainRate += this.isPrecisionMode ? 1.0 : 2.0;
    }

    // Apply battery drain (deltaTime is in milliseconds)
    this.batteryLevel -= (drainRate * deltaTime) / 1000;
    this.batteryLevel = Math.max(0, this.batteryLevel);

    // Auto-enable precision mode when battery is critical
    if (this.isBatteryCritical() && !this.isPrecisionMode) {
      this.isPrecisionMode = true;
      console.log('⚡ Battery critical - auto-enabling precision mode');
    }
  }

  private updateEffects(): void {
    // Change color based on battery level
    if (this.batteryLevel <= 0) {
      this.setTint(0x666666); // Gray when dead
    } else if (this.isBatteryCritical()) {
      this.setTint(0xff6600); // Orange when critical
    } else if (this.isPrecisionMode) {
      this.setTint(0x00ffff); // Cyan in precision mode
    } else {
      this.setTint(0x00ff00); // Green when normal
    }
  }
}
```

### Update the Game Scene

**Update `src/GameScene.ts`:**
```typescript
import Phaser from 'phaser';
import { Drone } from './Drone';

export class GameScene extends Phaser.Scene {
  private drone!: Drone;
  private target!: Phaser.Physics.Arcade.Sprite;
  private cursors!: Phaser.Types.Input.Keyboard.CursorKeys;
  private spaceKey!: Phaser.Input.Keyboard.Key;
  
  // UI Elements
  private scoreText!: Phaser.GameObjects.Text;
  private missionText!: Phaser.GameObjects.Text;
  private batteryText!: Phaser.GameObjects.Text;
  private statusText!: Phaser.GameObjects.Text;
  
  // Game state
  private targetsCollected: number = 0;
  private missionComplete: boolean = false;

  constructor() {
    super({ key: 'GameScene' });
  }

  preload(): void {
    this.load.image('drone', 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==');
    this.load.image('target', 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==');
  }

  create(): void {
    // Create advanced drone
    this.drone = new Drone({
      scene: this,
      x: 100,
      y: 300,
      maxSpeed: 200,
      batteryCapacity: 100
    });
    
    // Create target
    this.target = this.physics.add.sprite(700, 300, 'target');
    this.target.setTint(0xff0000);
    this.target.setDisplaySize(24, 24);
    
    // Target animation
    this.tweens.add({
      targets: this.target,
      scaleX: 1.2,
      scaleY: 1.2,
      duration: 1000,
      yoyo: true,
      repeat: -1,
      ease: 'Sine.easeInOut'
    });
    
    // Collision detection
    this.physics.add.overlap(this.drone, this.target, this.collectTarget, undefined, this);
    
    // Input setup
    this.cursors = this.input.keyboard!.createCursorKeys();
    this.spaceKey = this.input.keyboard!.addKey(Phaser.Input.Keyboard.KeyCodes.SPACE);
    
    // UI setup
    this.createUI();
    
    console.log('✅ Advanced game scene ready!');
    console.log('📝 Controls: Arrow keys = move, Space = toggle precision mode');
  }

  update(time: number, delta: number): void {
    if (!this.missionComplete) {
      this.handleInput();
      this.drone.update(delta);
      this.updateUI();
    }
  }

  private handleInput(): void {
    // Convert keyboard input to normalized movement vector
    const inputVector = { x: 0, y: 0 };
    
    if (this.cursors.left.isDown) inputVector.x = -1;
    if (this.cursors.right.isDown) inputVector.x = 1;
    if (this.cursors.up.isDown) inputVector.y = -1;
    if (this.cursors.down.isDown) inputVector.y = 1;
    
    // Handle diagonal movement (normalize vector)
    if (inputVector.x !== 0 && inputVector.y !== 0) {
      inputVector.x *= 0.707; // 1/sqrt(2) to maintain same speed diagonally
      inputVector.y *= 0.707;
    }
    
    this.drone.setMovementInput(inputVector);
    
    // Handle precision mode toggle
    if (Phaser.Input.Keyboard.JustDown(this.spaceKey)) {
      this.drone.togglePrecisionMode();
    }
  }

  private createUI(): void {
    this.scoreText = this.add.text(16, 16, 'Targets: 0/1', {
      fontSize: '24px',
      color: '#ffffff'
    });
    
    this.missionText = this.add.text(16, 50, 'Mission: Reach the red target', {
      fontSize: '18px',
      color: '#ffff00'
    });
    
    this.batteryText = this.add.text(16, 80, 'Battery: 100%', {
      fontSize: '18px',
      color: '#00ff00'
    });
    
    this.statusText = this.add.text(16, 110, 'Mode: Normal | Noise: 0', {
      fontSize: '16px',
      color: '#cccccc'
    });
    
    // Instructions
    this.add.text(16, this.cameras.main.height - 60, 'Controls:', {
      fontSize: '14px',
      color: '#888888'
    });
    this.add.text(16, this.cameras.main.height - 40, 'Arrow Keys: Move | Space: Precision Mode', {
      fontSize: '14px',
      color: '#888888'
    });
  }

  private updateUI(): void {
    const batteryLevel = this.drone.getBatteryLevel();
    const noiseLevel = this.drone.getNoiseLevel();
    
    // Update battery display with color coding
    this.batteryText.setText(`Battery: ${Math.round(batteryLevel)}%`);
    if (batteryLevel > 50) {
      this.batteryText.setColor('#00ff00'); // Green
    } else if (batteryLevel > 25) {
      this.batteryText.setColor('#ffff00'); // Yellow
    } else {
      this.batteryText.setColor('#ff0000'); // Red
    }
    
    // Update status display
    const mode = this.drone.isPrecisionMode ? 'Precision' : 'Normal';
    this.statusText.setText(`Mode: ${mode} | Noise: ${noiseLevel.toFixed(1)}`);
  }

  private collectTarget(): void {
    this.target.destroy();
    this.targetsCollected++;
    this.missionComplete = true;
    
    this.scoreText.setText(`Targets: ${this.targetsCollected}/1`);
    this.missionText.setText('🎉 MISSION COMPLETE! Well done!');
    this.missionText.setColor('#00ff00');
    
    this.drone.setVelocity(0, 0);
    
    // Celebration
    this.tweens.add({
      targets: this.drone,
      angle: 360,
      duration: 1000,
      ease: 'Power2'
    });
    
    console.log('🎉 Mission complete with advanced drone!');
  }
}
```

### Test the Enhanced Game

Now your drone has:
- ✅ **Battery management** - Watch it drain as you move
- ✅ **Flight modes** - Press Space to toggle precision mode
- ✅ **Visual feedback** - Color changes based on battery/mode
- ✅ **Noise calculation** - Foundation for stealth mechanics
- ✅ **Realistic physics** - Momentum and drag feel natural

---

## 🎯 Step 5: Understanding Game Systems (20 minutes)

### What You've Built So Far

You now have the foundation of a **component-based game architecture**:

```
GameScene (manages everything)
    ├── Drone (player entity with complex behavior)
    ├── Target (simple objective entity)  
    ├── UI System (displays information)
    └── Input System (handles player controls)
```

### Key Programming Concepts You've Learned

**1. Object-Oriented Programming**
```typescript
class Drone extends Phaser.Physics.Arcade.Sprite {
  // Properties (data the object holds)
  private batteryLevel: number;
  
  // Methods (things the object can do)
  public update(deltaTime: number): void {
    // ...
  }
}
```

**2. Interfaces for Type Safety**
```typescript
interface DroneConfig {
  scene: Phaser.Scene;
  x: number;
  y: number;
  // This ensures we always provide the right data
}
```

**3. Event-Driven Programming**
```typescript
// When these two objects touch, call this function
this.physics.add.overlap(drone, target, callbackFunction);
```

**4. State Management**
```typescript
private missionComplete: boolean = false;

// Later in code...
if (!this.missionComplete) {
  // Only do this when mission is still active
}
```

### Game Development Patterns You're Using

**1. The Game Loop Pattern**
```
Input → Update → Render → Input → Update → Render...
```

**2. The Component Pattern**
- Drone = Movement + Battery + Physics + Visual components
- Each component handles one responsibility

**3. The State Pattern**
- Normal mode vs Precision mode
- Different behavior based on current state

---

## 🚀 Next Steps: Where to Go From Here

### Immediate Next Steps (Choose Your Path)

**🎮 Want More Gameplay?**
- Add obstacles to avoid
- Create multiple targets
- Add a timer challenge
- Build different level layouts

**🤖 Want Smarter Enemies?**
- Add guards that patrol
- Implement line-of-sight detection
- Create alert systems
- Build AI state machines

**🎨 Want Better Visuals?**
- Load real sprite images
- Add particle effects
- Create animations
- Implement lighting systems

**🔧 Want Better Code?**
- Add unit tests
- Implement error handling
- Create a proper asset pipeline
- Build development tools

### Continue Your Learning Journey

**Next Guide: [Intermediate Path](README.md#intermediate-path)**
- Build interconnected systems
- Learn advanced patterns
- Create polished gameplay

**Reference Materials:**
- [Phaser.js Documentation](https://photonstorm.github.io/phaser3-docs/)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
- [Game Programming Patterns](PATTERNS_AND_SOLUTIONS.md)

---

## 🐛 Troubleshooting Common Issues

### Game Won't Start

**Problem**: Black screen or errors in console

**Solutions**:
1. Check that all files are in the right folders
2. Make sure `npx vite` is running
3. Open browser developer tools (F12) to see errors
4. Verify all imports are correct

### Drone Won't Move

**Problem**: Arrow keys don't affect the drone

**Solutions**:
1. Check that `this.cursors` is being created in `create()`
2. Verify `handleInput()` is being called in `update()`
3. Make sure physics is enabled on the drone
4. Check for console errors

### Performance Issues

**Problem**: Game running slowly or stuttering

**Solutions**:
1. Set `physics.arcade.debug: false` in config
2. Reduce number of objects in scene
3. Check for infinite loops in update functions
4. Monitor browser task manager for memory leaks

### TypeScript Errors

**Problem**: Red squiggly lines in VS Code

**Solutions**:
1. Run `npm install` to ensure all dependencies
2. Make sure file extensions are `.ts` not `.js`
3. Check that imports match file names exactly
4. Restart VS Code TypeScript service (Ctrl+Shift+P → "TypeScript: Restart TS Server")

---

## 📚 Concepts Glossary

**Game Loop**: The continuous cycle of input → update → render that runs 60 times per second

**Sprite**: A 2D image or shape that can be positioned, moved, and displayed in the game

**Physics Body**: An invisible shape attached to a sprite for collision detection and physics simulation

**Scene**: A container for all objects in one "screen" of your game (menu, gameplay, game over, etc.)

**Delta Time**: The time elapsed since the last frame, used to ensure consistent movement regardless of framerate

**Collision Detection**: The system that determines when two objects in the game touch each other

**Tween**: A smooth animation that automatically changes object properties over time

**Event**: Something that happens in the game (key press, collision, timer) that triggers code to run

---

*🎉 Congratulations! You've completed the Beginner's Guide and built a functional game with realistic physics, battery management, and interactive systems. You're ready for more advanced topics!* 