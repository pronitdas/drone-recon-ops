import 'phaser';
import { BootScene } from './scenes/BootScene';
import { GameScene } from './scenes/GameScene';

const config: Phaser.Types.Core.GameConfig = {
  type: Phaser.AUTO,
  width: 1280,
  height: 720,
  parent: 'game-container',
  backgroundColor: '#0a0a0a',
  physics: {
    default: 'arcade',
    arcade: {
      debug: true, // Enabled for development
      gravity: { x: 0, y: 0 } // Top-down game, no gravity
    }
  },
  scene: [BootScene, GameScene]
};

new Phaser.Game(config);
