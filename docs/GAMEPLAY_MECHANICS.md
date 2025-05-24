# Gameplay Mechanics Document
## Drone Recon Ops

**Version**: 1.0  
**Date**: December 2024  
**Status**: MVP Mechanics Design  

---

## 1. Core Mechanics Overview

### 1.1 Design Philosophy
**Drone Recon Ops** emphasizes tension through vulnerability rather than power. The player's drone is a precision tool, not a weapon. Success comes from intelligence, planning, and careful execution rather than reflexes or firepower.

### 1.2 Fundamental Mechanics
1. **Stealth-Based Movement**: Avoid detection through careful positioning
2. **Resource Management**: Battery life creates urgency and strategic decisions
3. **Information Gathering**: Primary objective is reconnaissance, not destruction
4. **Risk vs. Reward**: Better intel requires more dangerous positions

---

## 2. Drone Control System

### 2.1 Movement Mechanics

#### 2.1.1 Flight Physics
- **Momentum-Based Movement**: Realistic inertia and acceleration
- **Thrust Vector Control**: WASD for directional movement
- **Speed Modulation**: Hold Shift for precision mode (slower, quieter)
- **Altitude Awareness**: Higher altitude = wider detection range but safer from ground patrols

#### 2.1.2 Control Scheme
```
W/A/S/D: Directional movement
Shift: Precision mode (50% speed, 25% noise)
Space: Emergency stop (drains battery quickly)
E: Interact (camera, hacking, marking)
Q: Toggle night vision
Tab: Mission objectives panel
M: Minimap toggle
ESC: Pause/Options menu
```

#### 2.1.3 Physics Parameters
- **Max Speed**: 150 units/second (normal), 75 units/second (precision)
- **Acceleration**: 300 units/second²
- **Deceleration**: 500 units/second² (drag)
- **Turn Rate**: 180 degrees/second
- **Mass**: Affects momentum and collision response

### 2.2 Battery System

#### 2.2.1 Energy Consumption
- **Hover**: 1% per 10 seconds (baseline consumption)
- **Movement**: +0.5% per second while moving
- **Precision Mode**: -50% movement consumption
- **Systems Active**: +0.2% per second (camera, sensors)
- **Emergency Stop**: -5% instant

#### 2.2.2 Battery States
- **100-75%**: Full operational capacity
- **75-50%**: Yellow warning indicator
- **50-25%**: Orange warning, systems efficiency reduced
- **25-10%**: Red critical, forced precision mode
- **10-0%**: Emergency landing sequence initiated

#### 2.2.3 Strategic Implications
- **Route Planning**: Optimal paths to conserve energy
- **Risk Assessment**: Low battery forces riskier, direct approaches
- **Extraction Timing**: Must reserve energy for escape
- **Equipment Trade-offs**: Some upgrades consume more power

---

## 3. Stealth & Detection System

### 3.1 Detection Mechanics

#### 3.1.1 Visual Detection
- **Line of Sight**: Enemies must have clear view to detect
- **Detection Distance**: 
  - Guards: 80 units maximum range
  - Cameras: 120 units maximum range
  - Spotlights: 200 units in cone
- **Angle of View**: 
  - Guards: 90-degree cone
  - Cameras: 60-degree fixed cone
  - Spotlights: 45-degree sweeping cone

#### 3.1.2 Audio Detection
- **Noise Generation**:
  - Idle hover: 0 noise units
  - Normal movement: 2 noise units
  - Fast movement: 5 noise units
  - Collision: 8 noise units
  - System activation: 1 noise unit

- **Detection Radius**:
  - Guards: 40 units for 5+ noise
  - Security stations: 60 units for 3+ noise
  - Civilians: 20 units for 7+ noise

#### 3.1.3 Environmental Factors
- **Cover Objects**: Buildings, trees, vehicles block line of sight
- **Lighting Conditions**:
  - Bright areas: +25% detection chance
  - Shadows: -50% detection chance
  - Night vision zones: Normal detection for equipped enemies
- **Weather Effects** (future expansion):
  - Rain: -30% audio detection
  - Wind: Affects drone movement, masks noise

### 3.2 Detection States

#### 3.2.1 Safe (Green)
- **Condition**: No enemies aware of drone presence
- **Feedback**: Green HUD indicator, quiet ambient audio
- **Mechanics**: Full movement speed available, all systems optimal

#### 3.2.2 Caution (Yellow)
- **Condition**: Enemy suspicious but no direct detection
- **Triggers**: Recent noise, patrol pattern disruption
- **Feedback**: Yellow indicator, increased heartbeat audio
- **Mechanics**: Enemies more alert, faster detection if spotted

#### 3.2.3 Alert (Orange)
- **Condition**: Drone detected but location unknown
- **Triggers**: Brief line-of-sight contact, confirmed noise
- **Feedback**: Orange indicator, tension music, enemy chatter
- **Mechanics**: 
  - Enemies investigate last known position
  - Patrol patterns change to search mode
  - 30-second timer to return to Caution if not re-detected

#### 3.2.4 Discovered (Red)
- **Condition**: Drone location confirmed by enemy
- **Triggers**: Sustained line-of-sight, close proximity
- **Feedback**: Red indicator, alarm sounds, urgent music
- **Mechanics**:
  - Active pursuit by nearest enemies
  - All patrols converge on drone position
  - Mission failure if sustained for 10 seconds
  - Can escape by breaking line-of-sight and distance

### 3.3 Countermeasures

#### 3.3.1 Evasion Techniques
- **Environmental Cover**: Use buildings, trees, terrain
- **Timing Windows**: Move between patrol rotations
- **Altitude Management**: Higher = harder to spot from ground
- **Speed Control**: Precision mode for critical sections

#### 3.3.2 Distraction (Limited Use)
- **Noise Makers**: 2 uses per mission, create audio distraction
- **Electronic Interference**: 1 use per mission, disable camera for 15 seconds
- **Emergency Shutdown**: Become invisible for 5 seconds, major battery cost

---

## 4. Mission System

### 4.1 Objective Types

#### 4.1.1 Surveillance Missions
**Primary Goal**: Photograph designated targets

**Mechanics**:
- **Target Acquisition**: Frame target in camera view for 3 seconds
- **Photo Quality Factors**:
  - Distance: Closer = better quality
  - Angle: Front/side views preferred
  - Lighting: Well-lit targets score higher
  - Stability: Movement reduces quality

**Scoring**:
- **Perfect Photo (100 points)**: Optimal distance, angle, lighting
- **Good Photo (75 points)**: Minor deficiencies
- **Acceptable Photo (50 points)**: Meets minimum requirements
- **Poor Photo (25 points)**: Barely identifiable

**Sub-objectives**:
- Multiple angle shots (+25% bonus)
- Stealth completion (+50% bonus)
- Time bonus (complete under target time)

#### 4.1.2 Data Extraction Missions
**Primary Goal**: Access and download information from computer terminals

**Mechanics**:
- **Terminal Access**: Approach within 5 units, press E to interact
- **Hacking Minigame**: Simple pattern matching or timing game
- **Download Progress**: 10-30 seconds depending on data size
- **Vulnerability Window**: Drone is stationary during download

**Scoring**:
- **Complete Download (100 points)**: All data successfully extracted
- **Partial Download (50 points)**: Download interrupted but some data recovered
- **Failed Download (0 points)**: No data extracted

**Sub-objectives**:
- Access multiple terminals (+25% per additional)
- No alerts during download (+50% bonus)
- Bonus data discovery (+25% bonus)

#### 4.1.3 Target Marking Missions
**Primary Goal**: Identify and GPS-tag strategic positions

**Mechanics**:
- **Position Verification**: Must maintain position for 5 seconds for accurate GPS lock
- **Multiple Targets**: Typically 3-5 positions per mission
- **Precision Requirements**: Must be within 2 units of exact target location

**Scoring**:
- **Precise Mark (100 points)**: Perfect positioning within 1 unit
- **Accurate Mark (75 points)**: Within 2 units
- **Approximate Mark (50 points)**: Within 5 units
- **Missed Mark (0 points)**: Outside acceptable range

**Sub-objectives**:
- Mark all targets (+100% bonus)
- Mark optional targets (+25% each)
- Speed completion (+25% bonus)

### 4.2 Mission Structure

#### 4.2.1 Pre-Mission Phase
1. **Briefing Screen**: Objective description, target area overview
2. **Intelligence Review**: Enemy patrol patterns, key locations
3. **Equipment Selection**: Choose specialized gear (future expansion)
4. **Route Planning**: Study map, identify approach vectors

#### 4.2.2 Mission Execution
1. **Insertion**: Start at designated infiltration point
2. **Navigation**: Reach target area while avoiding detection
3. **Objective Completion**: Execute primary and secondary goals
4. **Extraction**: Return to extraction point or reach safe zone

#### 4.2.3 Post-Mission Debrief
1. **Performance Analysis**: Stealth rating, time taken, objectives completed
2. **Score Calculation**: Points based on performance factors
3. **Progression Unlocks**: New missions, equipment, difficulty options
4. **Statistics Tracking**: Personal best times, completion rates

### 4.3 Scoring System

#### 4.3.1 Base Score Components
- **Primary Objectives**: 100-500 points each
- **Secondary Objectives**: 50-200 points each
- **Stealth Rating**: 0-500 point multiplier
- **Time Bonus**: 0-200 points based on completion time

#### 4.3.2 Penalty System
- **Detection Events**: -50 points per alert
- **Discovery**: -200 points per discovered state
- **Damage**: -100 points per collision
- **Incomplete Objectives**: 0 points for failed objectives

#### 4.3.3 Star Rating System
- **★☆☆ (1 Star)**: Mission completed, basic objectives met
- **★★☆ (2 Stars)**: Good performance, most objectives completed with minimal alerts
- **★★★ (3 Stars)**: Perfect stealth run, all objectives, time bonus achieved

---

## 5. Progression System

### 5.1 MVP Progression
- **Linear Mission Unlock**: Complete missions to access new ones
- **Difficulty Scaling**: Each mission introduces new challenges
- **Performance Tracking**: Statistics for replay value

### 5.2 Future Progression Features
- **Equipment Upgrades**: Battery capacity, stealth improvements, new tools
- **Skill Trees**: Specialized abilities for different mission types
- **Achievement System**: Challenges for specific play styles
- **Custom Difficulty**: Player-adjustable parameters

---

## 6. User Interface & Feedback

### 6.1 HUD Elements

#### 6.1.1 Essential Information
- **Battery Level**: Visual bar with percentage, color-coded warnings
- **Detection Status**: Color-coded indicator (Green/Yellow/Orange/Red)
- **Objective Progress**: Current objective description and progress
- **Minimap**: Simplified top-down view of immediate area

#### 6.1.2 Contextual Information
- **Interaction Prompts**: "Press E to hack terminal" when near interactive objects
- **Distance Indicators**: Range to objectives when targeted
- **Audio Visualizer**: Visual representation of noise levels for accessibility

### 6.2 Accessibility Features

#### 6.2.1 Visual Accessibility
- **Colorblind Support**: Detection states indicated by shape and color
- **High Contrast Mode**: Enhanced visibility for low-vision players
- **Text Scaling**: Adjustable UI element sizes
- **Motion Sensitivity**: Reduced camera shake and effects options

#### 6.2.2 Audio Accessibility
- **Subtitles**: All dialogue and important sound effects
- **Visual Sound Indicators**: Directional indicators for audio cues
- **Audio Description**: Optional narration of visual events

#### 6.2.3 Motor Accessibility
- **Keyboard Only**: Full game playable without mouse
- **Configurable Controls**: Remappable key bindings
- **Hold/Toggle Options**: Choice between hold and toggle for sustained actions
- **Difficulty Adjustments**: Slower detection, extended battery life options

---

## 7. Balancing Considerations

### 7.1 Challenge Curve
- **Tutorial Mission**: No time pressure, visible detection zones
- **Early Missions**: Simple patrol patterns, forgiving detection
- **Mid-game**: Complex patrol routes, multiple detection types
- **Advanced Missions**: Tight timing windows, environmental hazards

### 7.2 Difficulty Factors
- **Enemy Density**: Number of guards and cameras per area
- **Detection Sensitivity**: How quickly enemies spot the drone
- **Patrol Complexity**: Predictable vs. randomized movement patterns
- **Time Pressure**: Mission time limits and battery constraints

### 7.3 Player Agency
- **Multiple Solutions**: Various approaches to each objective
- **Risk/Reward Trade-offs**: Safer routes vs. faster completion
- **Skill Expression**: Expert players can achieve perfect stealth
- **Recovery Mechanisms**: Ability to recover from minor mistakes

---

*Document Version: 1.0*  
*Last Updated: December 2024*  
*Next Review: January 2025* 