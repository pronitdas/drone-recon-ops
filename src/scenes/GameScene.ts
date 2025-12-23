import { Scene } from 'phaser';
import { Spectre } from '../entities/drones/Spectre';
import { Badger } from '../entities/drones/Badger';
import { DroneManager } from '../systems/DroneManager';

export class GameScene extends Scene {
  private droneManager!: DroneManager;
  private walls!: Phaser.Physics.Arcade.StaticGroup;
  private lowWalls!: Phaser.Physics.Arcade.StaticGroup;

  constructor() {
    super('GameScene');
  }

  create() {
    // 1. Setup World (Simple placeholder map)
    this.createLevel();

    // 2. Setup Drones
    const spectre = new Spectre(this, 100, 100);
    const badger = new Badger(this, 100, 200);

    // 3. Setup Manager
    this.droneManager = new DroneManager(this, spectre, badger);

    // 4. Input
    this.input.keyboard?.on('keydown-TAB', () => {
      this.droneManager.switchDrone();
    });

    // 5. Collisions
    // Note: Collision logic will be refined in the update loop or here based on active state
    // For now, static collisions:
    this.physics.add.collider(spectre, this.walls);
    this.physics.add.collider(badger, this.walls);
    this.physics.add.collider(badger, this.lowWalls); 
    // Spectre ignores lowWalls (no collider added)

    // Camera
    this.cameras.main.startFollow(this.droneManager.getActiveDrone(), true, 0.1, 0.1);
  }

  update(time: number, delta: number) {
    this.droneManager.update(time, delta);
  }

  private createLevel() {
    this.walls = this.physics.add.staticGroup();
    this.lowWalls = this.physics.add.staticGroup();

    // Create a simple box room
    // Top/Bottom
    for (let x = 0; x < 40; x++) {
      this.walls.create(x * 32, 0, 'wall');
      this.walls.create(x * 32, 600, 'wall');
    }
    // Left/Right
    for (let y = 0; y < 20; y++) {
      this.walls.create(0, y * 32, 'wall');
      this.walls.create(1248, y * 32, 'wall');
    }

    // Add some "Low Walls" (Crates) in the middle
    for (let x = 10; x < 15; x++) {
      this.lowWalls.create(x * 32, 300, 'wall_low');
    }
  }
}
