import { Scene } from 'phaser';

export class BootScene extends Scene {
  constructor() {
    super('BootScene');
  }

  preload() {
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

    // Wall (Gray Block)
    gfx.clear();
    gfx.fillStyle(0x666666);
    gfx.fillRect(0, 0, 32, 32);
    gfx.generateTexture('wall', 32, 32);
    
    // Low Wall (Darker Block)
    gfx.clear();
    gfx.fillStyle(0x444444);
    gfx.fillRect(0, 0, 32, 32);
    gfx.generateTexture('wall_low', 32, 32);
  }

  create() {
    this.scene.start('GameScene');
  }
}
