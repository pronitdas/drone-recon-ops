import { Scene } from 'phaser';
import { BaseDrone } from '../entities/drones/BaseDrone';

export class DroneManager {
  private scene: Scene;
  private activeDrone: BaseDrone;
  private drones: BaseDrone[];
  private cursors: Phaser.Types.Input.Keyboard.CursorKeys;

  constructor(scene: Scene, drone1: BaseDrone, drone2: BaseDrone) {
    this.scene = scene;
    this.drones = [drone1, drone2];
    this.activeDrone = drone1;
    
    this.cursors = this.scene.input.keyboard!.createCursorKeys();
    
    // Initialize
    drone1.activate();
    drone2.deactivate();
  }

  update(_time: number, _delta: number) {
    this.activeDrone.updateControl(this.cursors);
  }

  switchDrone() {
    // Find next drone
    const currentIndex = this.drones.indexOf(this.activeDrone);
    const nextIndex = (currentIndex + 1) % this.drones.length;
    const nextDrone = this.drones[nextIndex];

    // Toggle states
    this.activeDrone.deactivate();
    this.activeDrone = nextDrone;
    this.activeDrone.activate();

    // Update Camera
    this.scene.cameras.main.startFollow(this.activeDrone, true, 0.1, 0.1);
  }

  getActiveDrone(): BaseDrone {
    return this.activeDrone;
  }
}
