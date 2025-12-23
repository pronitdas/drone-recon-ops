import { Scene } from 'phaser';
import { BaseDrone } from './BaseDrone';

export class Badger extends BaseDrone {
  constructor(scene: Scene, x: number, y: number) {
    super(scene, x, y, 'drone_ground');

    // Physics Config: Heavy, Grippy
    this.accelerationSpeed = 1000;
    this.dragForce = 2000; // Stops almost instantly
    this.maxVelocitySpeed = 150;

    this.setDrag(this.dragForce);
    this.setMaxVelocity(this.maxVelocitySpeed);
  }

  updateControl(cursors: Phaser.Types.Input.Keyboard.CursorKeys) {
    if (!this.isActive) return;

    this.setDrag(this.dragForce);

    // Ground movement feels tighter
    const accelX = cursors.left.isDown ? -this.accelerationSpeed : cursors.right.isDown ? this.accelerationSpeed : 0;
    const accelY = cursors.up.isDown ? -this.accelerationSpeed : cursors.down.isDown ? this.accelerationSpeed : 0;

    this.setAcceleration(accelX, accelY);

    // Tank-like rotation (face movement instantly)
    if (accelX !== 0 || accelY !== 0) {
      this.rotation = Math.atan2(accelY, accelX);
    }
  }
}
