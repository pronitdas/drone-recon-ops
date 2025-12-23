import { Scene, Physics } from 'phaser';

export abstract class BaseDrone extends Physics.Arcade.Sprite {
  protected accelerationSpeed!: number;
  protected dragForce!: number;
  protected maxVelocitySpeed!: number;
  public isActive: boolean = false;

  constructor(scene: Scene, x: number, y: number, texture: string) {
    super(scene, x, y, texture);
    scene.add.existing(this);
    scene.physics.add.existing(this);

    this.setCollideWorldBounds(true);
  }

  abstract updateControl(cursors: Phaser.Types.Input.Keyboard.CursorKeys): void;

  activate() {
    this.isActive = true;
    this.setTint(0xffffff); // Reset tint
    this.setAlpha(1);
  }

  deactivate() {
    this.isActive = false;
    this.setAcceleration(0, 0);
    this.setDrag(this.dragForce * 2); // Extra drag when inactive (parking brake)
    this.setAlpha(0.6); // Dim to show inactive
  }
}
