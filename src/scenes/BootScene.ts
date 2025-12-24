import { Scene } from 'phaser';

export class BootScene extends Scene {
  constructor() {
    super('BootScene');
  }

  preload() {
    this.load.tilemapTiledJSON('level01', 'assets/maps/level01.json');

    // Generate simple placeholder textures programmatically
    // Drone - Air (Triangle)
    const gfx = this.make.graphics({ x: 0, y: 0 });
    gfx.fillStyle(0x00ffff); // Cyan
    gfx.fillTriangle(0, 20, 10, 0, 20, 20);
    gfx.generateTexture('drone_air', 20, 20);

    // Drone - Ground (Square)
    gfx.clear();
    gfx.fillStyle(0xffaa00); // Amber
    gfx.fillRect(0, 0, 20, 20);
    gfx.generateTexture('drone_ground', 20, 20);

    // Desk (Hiding Spot for Ground)
    gfx.clear();
    gfx.fillStyle(0x8B4513); // SaddleBrown
    gfx.fillRect(4, 4, 24, 24); // Slightly smaller than tile
    gfx.lineStyle(2, 0xDAA520); // Golden trim
    gfx.strokeRect(4, 4, 24, 24);
    gfx.generateTexture('desk', 32, 32);

    // Tileset (Composite for Map)
    // 2x2 Grid of 32x32 tiles = 64x64
    gfx.clear();
    
    // 1. Wall (Top-Right, Index 1 if 0-based layout?)
    // Let's draw:
    // Top-Left (Index 0): Floor (Black)
    gfx.fillStyle(0x000000);
    gfx.fillRect(0, 0, 32, 32);
    
    // Top-Right (Index 1): Wall (Gray)
    gfx.fillStyle(0x666666);
    gfx.fillRect(32, 0, 32, 32);

    // Bottom-Left (Index 2): Low Wall (Dark)
    gfx.fillStyle(0x444444);
    gfx.fillRect(0, 32, 32, 32);

    // Bottom-Right (Index 3): Vent
    gfx.fillStyle(0x222222);
    gfx.fillRect(32, 32, 32, 32);
    gfx.lineStyle(2, 0x8888ff);
    for (let i = 0; i < 32; i += 8) {
      gfx.moveTo(32, 32 + i);
      gfx.lineTo(64, 32 + i);
    }
    gfx.strokePath();

    gfx.generateTexture('tileset', 64, 64);

    // Terminal
    gfx.clear();
    gfx.fillStyle(0x000088); // Dark Blue body
    gfx.fillRect(0, 0, 32, 32);
    gfx.fillStyle(0x00ffff); // Cyan screen
    gfx.fillRect(4, 4, 24, 16);
    gfx.fillStyle(0xcccccc); // Keyboard area
    gfx.fillRect(4, 24, 24, 4);
    gfx.generateTexture('terminal', 32, 32);
  }

  create() {
    this.scene.start('GameScene');
  }
}
