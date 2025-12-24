import { Scene } from 'phaser';

export interface IInteractable {
  // Return true if interaction is possible (e.g., in range, correct drone type)
  canInteract(droneType: 'spectre' | 'badger'): boolean;
  
  // Trigger the interaction
  interact(droneType: 'spectre' | 'badger'): void;
  
  // For UI: Get the prompt text (e.g. "Press E to Hack")
  getInteractionPrompt(): string;
  
  // Position for distance checks
  x: number;
  y: number;
}
