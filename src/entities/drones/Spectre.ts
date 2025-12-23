import { Scene } from 'phaser';
import { BaseDrone } from './BaseDrone';

export class Spectre extends BaseDrone {
  constructor(scene: Scene, x: number, y: number) {
    super(scene, x, y, 'drone_air');
    
    // Physics Config: Drifty, Fast
    this.accelerationSpeed = 800;
    this.dragForce = 400; 
    this.maxVelocitySpeed = 400;

    this.setDrag(this.dragForce);
    this.setMaxVelocity(this.maxVelocitySpeed);
  }

  updateControl(cursors: Phaser.Types.Input.Keyboard.CursorKeys) {
    if (!this.isActive) return;

    // Reset drag to normal in case it was high from deactivation
    this.setDrag(this.dragForce);

    const accelX = cursors.left.isDown ? -this.accelerationSpeed : cursors.right.isDown ? this.accelerationSpeed : 0;
    const accelY = cursors.up.isDown ? -this.accelerationSpeed : cursors.down.isDown ? this.accelerationSpeed : 0;

    this.setAcceleration(accelX, accelY);

    // Visual Rotation (face movement direction)
    if (this.body && this.body.velocity.length() > 10) {
      this.rotation = this.body.velocity.angle() + Math.PI / 2;
    }
  }
}
