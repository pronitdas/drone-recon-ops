import { Scene } from 'phaser';
import { IInteractable } from '../interfaces/IInteractable';
import { BaseDrone } from '../entities/drones/BaseDrone';
import { Spectre } from '../entities/drones/Spectre';
import { Badger } from '../entities/drones/Badger';

export class InteractionManager {
  private scene: Scene;
  private interactables: IInteractable[] = [];
  private interactKey!: Phaser.Input.Keyboard.Key;
  
  // Interaction Range in pixels
  private readonly INTERACTION_RANGE = 50;

  constructor(scene: Scene) {
    this.scene = scene;
    if (this.scene.input.keyboard) {
        this.interactKey = this.scene.input.keyboard.addKey(Phaser.Input.Keyboard.KeyCodes.E);
    }
  }

  public register(interactable: IInteractable) {
    this.interactables.push(interactable);
  }

  public unregister(interactable: IInteractable) {
    this.interactables = this.interactables.filter(i => i !== interactable);
  }

  public update(activeDrone: BaseDrone) {
    // 1. Check for input
    if (Phaser.Input.Keyboard.JustDown(this.interactKey)) {
      this.attemptInteraction(activeDrone);
    }

    // 2. (Optional) Check for UI hints - nearest object
    // Could return this to the UI system to draw "Press E"
  }

  private attemptInteraction(activeDrone: BaseDrone) {
    const droneType = activeDrone instanceof Spectre ? 'spectre' : 'badger';
    
    // Find nearest valid interactable
    let nearest: IInteractable | null = null;
    let minDist = Infinity;

    for (const item of this.interactables) {
      const dist = Phaser.Math.Distance.Between(
        activeDrone.x, activeDrone.y,
        item.x, item.y
      );

      if (dist <= this.INTERACTION_RANGE && dist < minDist) {
        if (item.canInteract(droneType)) {
          minDist = dist;
          nearest = item;
        }
      }
    }

    if (nearest) {
      nearest.interact(droneType);
      console.log(`Interacted with object at ${nearest.x},${nearest.y}`);
    }
  }
}
