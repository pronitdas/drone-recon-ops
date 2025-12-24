import { Scene } from 'phaser';
import { Spectre } from '../entities/drones/Spectre';
import { Badger } from '../entities/drones/Badger';
import { DroneManager } from '../systems/DroneManager';
import { InteractionManager } from '../systems/InteractionManager';
import { Terminal } from '../entities/interactables/Terminal';

export class GameScene extends Scene {
  private droneManager!: DroneManager;
  private interactionManager!: InteractionManager;
  private desks!: Phaser.Physics.Arcade.StaticGroup;
  private spectre!: Spectre;
  private badger!: Badger;

  // Map
  private map!: Phaser.Tilemaps.Tilemap;
  private groundLayer!: Phaser.Tilemaps.TilemapLayer;
  private lowLayer!: Phaser.Tilemaps.TilemapLayer;
  private highLayer!: Phaser.Tilemaps.TilemapLayer;

  constructor() {
    super('GameScene');
  }

  create() {
    // 1. Setup World
    this.createLevel();

    // 2. Setup Drones
    this.spectre = new Spectre(this, 100, 100);
    this.badger = new Badger(this, 100, 200);

    // Set Depths (Z-Ordering)
    this.badger.setDepth(10);
    this.desks.setDepth(25); 
    this.spectre.setDepth(30);
    
    // 3. Setup Managers
    this.droneManager = new DroneManager(this, this.spectre, this.badger);
    this.interactionManager = new InteractionManager(this);

    // Test Terminal
    const terminal = new Terminal(this, 300, 300);
    terminal.setDepth(25); // Same as desks
    this.interactionManager.register(terminal);

    // 4. Input
    this.input.keyboard?.on('keydown-TAB', () => {
      this.droneManager.switchDrone();
    });

    // 5. Collisions
    // Spectre vs High (Walls/Vents) - Blocked by all
    this.physics.add.collider(this.spectre, this.highLayer);
    
    // Badger vs High (Walls/Vents) - Blocked by Walls, Ignores Vents
    this.physics.add.collider(this.badger, this.highLayer, undefined, (_b, tile) => {
        const t = tile as Phaser.Tilemaps.Tile;
        return t.properties.height !== 'vent';
    });

    // Badger vs Low (Low Walls) - Blocked
    this.physics.add.collider(this.badger, this.lowLayer);
    
    // Hiding Logic
    this.physics.add.overlap(this.badger, this.desks, (_b, _d) => {
        this.badger.setAlpha(0.5);
    });

    // CameraBounds
    this.cameras.main.setBounds(0, 0, this.map.widthInPixels, this.map.heightInPixels);
    this.cameras.main.startFollow(this.droneManager.getActiveDrone(), true, 0.1, 0.1);
  }

  update(time: number, delta: number) {
    // Reset Badger Alpha each frame (unless inactive)
    if (this.badger.isActive) {
        this.badger.setAlpha(1);
    } else {
        this.badger.setAlpha(0.6);
    }

    this.droneManager.update(time, delta);
    this.interactionManager.update(this.droneManager.getActiveDrone());
  }

  private createLevel() {
    this.map = this.make.tilemap({ key: 'level01' });
    const tileset = this.map.addTilesetImage('tileset', 'tileset');
    
    if (!tileset) {
        console.error("Tileset not found");
        return;
    }

    this.groundLayer = this.map.createLayer('Ground', tileset)!;
    this.lowLayer = this.map.createLayer('Low', tileset)!;
    this.highLayer = this.map.createLayer('High', tileset)!;

    this.groundLayer.setDepth(0);
    this.lowLayer.setDepth(20);
    this.highLayer.setDepth(40);

    // Enable collisions
    this.lowLayer.setCollisionByProperty({ collides: true });
    this.highLayer.setCollisionByProperty({ collides: true });

    // Desks (Still procedural for now)
    this.desks = this.physics.add.staticGroup();
    // Add some "Desks"
    for (let x = 20; x < 25; x++) {
        this.desks.create(x * 32, 200, 'desk');
    }
  }
}
