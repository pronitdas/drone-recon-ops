import { Scene } from 'phaser';
import { IInteractable } from '../../interfaces/IInteractable';

export class Terminal extends Phaser.GameObjects.Sprite implements IInteractable {
  private isHacked: boolean = false;

  constructor(scene: Scene, x: number, y: number) {
    super(scene, x, y, 'terminal'); // Placeholder texture
    scene.add.existing(this);
    // Add physics body for static overlap checks if needed, but manager uses distance
  }

  canInteract(droneType: 'spectre' | 'badger'): boolean {
    // Both can hack terminals? 
    // Guide says: 
    // Air: Can only Hack (Wireless)
    // Ground: Can Hack (Wired)
    // So both return true.
    return !this.isHacked;
  }

  interact(droneType: 'spectre' | 'badger'): void {
    console.log(`[Terminal] Hacked by ${droneType}!`);
    this.isHacked = true;
    this.setTint(0x00ff00); // Green to show hacked
  }

  getInteractionPrompt(): string {
    return this.isHacked ? "System Hacked" : "Press E to Hack";
  }
}
