# Drone Recon Ops - Godot Game

A tactical stealth reconnaissance game where you pilot surveillance drones through hostile territory. Complete missions while avoiding detection!

## 🎮 Game Features

- **Physics-based drone flight** - Smooth, weighty movement that feels great
- **Stealth mechanics** - Line-of-sight detection, audio detection zones
- **AI Guards** - Smart patrol patterns with vision cones
- **Mission system** - Surveillance, data extraction, target marking objectives
- **Juicy feedback** - Camera shake, particles, screen effects
- **3 unique levels** - Increasing difficulty

## 🚀 Quick Start

1. Download and install Godot 4.2+
2. Clone this repository
3. Import the `godot_project` folder
4. Press F5 to run!

## 🎯 Controls

| Key               | Action           |
| ----------------- | ---------------- |
| WASD / Arrow Keys | Move drone       |
| SPACE             | Ascend           |
| SHIFT             | Descend          |
| Left Click        | Primary action   |
| Right Click       | Secondary action |
| ESC               | Pause            |

## 🎮 Gameplay Tips

- **Stay in shadows** - Guards can't see what they can't see
- **Listen carefully** - Moving fast makes noise
- **Watch your battery** - Dead drones don't complete missions
- **Plan your route** - Know where guards patrol
- **Use scan wisely** - Reveal nearby enemies

## 🏗️ Architecture

```
godot_project/
├── scenes/           # Game scenes (.tscn)
├── scripts/          # GDScript files (.gd)
├── assets/           # Audio, textures
├── project.godot     # Project configuration
└── icon.svg          # Game icon
```

## 🎨 Core Scripts

- `drone.gd` - Player controller with physics
- `enemy.gd` - AI guard with patrol & detection
- `stealth_system.gd` - Global stealth calculation
- `mission.gd` - Mission objective system
- `game_manager.gd` - Main game orchestration
- `ui_controller.gd` - HUD and menus
- `level_environment.gd` - Level building

## 🔧 Customization

Edit `project.godot` to change:

- Screen resolution
- Physics settings
- Input mappings
- Rendering options

## 🎖️ Achievements

| Achievement    | Requirement                    |
| -------------- | ------------------------------ |
| First Steps    | Complete first mission         |
| Ghost          | Complete 3 missions undetected |
| Elite Operator | Earn 50,000 points             |
| Veteran        | Complete 10 missions           |

## 📝 License

MIT License - Build, modify, share!

## 🤝 Contributing

Pull requests welcome! Areas to help:

- More enemy types
- Additional mission types
- Sound effects & music
- Visual polish
- Level design

---

Built with ❤️ using Godot 4.2+
