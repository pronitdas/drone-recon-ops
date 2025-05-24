# Development Workflow Guide: Drone Recon Ops
## 🛠️ Best Practices for Junior Developers

**Version**: 1.0  
**Date**: December 2024  
**Status**: Implementation Ready  

---

## 📋 Overview

This guide establishes best practices for developing Drone Recon Ops. It covers everything from daily development routines to testing strategies, helping junior developers build professional habits and deliver quality code.

### What You'll Learn:
- **Git workflow** and version control best practices
- **Testing strategies** for game systems
- **Debugging techniques** for common issues
- **Code review process** and quality standards
- **Performance optimization** guidelines
- **Deployment workflow** for releases

---

## 🎯 Development Principles

### 1. Code Quality Standards

**Always follow these principles:**

- **Write self-documenting code** with clear variable and function names
- **Add comments** for complex logic, but avoid obvious comments
- **Keep functions small** - ideally under 50 lines
- **Use TypeScript strictly** - no `any` types without good reason
- **Test early and often** - write tests as you develop features

### 2. The "Three Pillars" Rule

Every feature should be:

1. **Functional** - Does it work correctly?
2. **Testable** - Can we verify it works?
3. **Maintainable** - Can other developers understand and modify it?

---

## 🔀 Git Workflow

### 1. Branch Naming Convention

```bash
# Feature branches
feature/drone-physics-system
feature/detection-audio-zones
feature/ui-battery-indicator

# Bug fix branches
bugfix/drone-collision-detection
bugfix/audio-memory-leak

# Hotfix branches (for urgent production fixes)
hotfix/battery-drain-calculation
```

### 2. Daily Development Workflow

```bash
# Start your day
git checkout main
git pull origin main

# Create feature branch
git checkout -b feature/your-feature-name

# Work on your feature...
# Make small, frequent commits with clear messages

# Push your work
git push -u origin feature/your-feature-name

# Create pull request when ready
```

### 3. Commit Message Standards

**Format**: `type(scope): description`

```bash
# Good examples
feat(drone): add precision flight mode
fix(detection): resolve line-of-sight calculation bug
docs(setup): update installation instructions
test(ai): add patrol behavior unit tests
refactor(systems): improve event bus performance

# Types:
# feat: New feature
# fix: Bug fix
# docs: Documentation
# test: Tests
# refactor: Code restructuring
# perf: Performance improvement
# chore: Maintenance tasks
```

### 4. Pull Request Process

**Before creating a PR:**

```bash
# Run all checks
npm run type-check     # TypeScript compilation
npm run lint          # Code style
npm run test          # Unit tests
npm run build         # Production build
```

**PR Template:**
```markdown
## Description
Brief description of what this PR does.

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests pass
- [ ] Manual testing completed
- [ ] No console errors

## Screenshots (if applicable)
Add screenshots for UI changes.

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex logic
- [ ] Tests added for new functionality
```

---

## 🧪 Testing Strategy

### 1. Testing Pyramid

Our testing approach follows the testing pyramid:

```
    🔺 E2E Tests (Few)
   ────────────────
  🔺🔺 Integration Tests (Some)
 ──────────────────────
🔺🔺🔺 Unit Tests (Many)
```

### 2. Unit Testing Guidelines

**Test Structure: Arrange, Act, Assert**

```typescript
// Example: Testing drone battery system
describe('Drone Battery System', () => {
  let drone: Drone;
  let scene: Phaser.Scene;
  
  beforeEach(() => {
    // Arrange - Set up test environment
    scene = new MockScene();
    const config: DroneConfig = {
      maxSpeed: 100,
      acceleration: 200,
      drag: 300,
      batteryCapacity: 100,
      position: { x: 0, y: 0 }
    };
    drone = new Drone(scene, config);
  });

  it('should drain battery during movement', () => {
    // Arrange
    const initialBattery = drone.getBatteryLevel();
    
    // Act
    drone.setMovementInput({ x: 1, y: 0 }); // Move right
    drone.update(1000); // Update for 1 second
    
    // Assert
    expect(drone.getBatteryLevel()).toBeLessThan(initialBattery);
  });

  it('should force precision mode when battery is critical', () => {
    // Arrange
    drone.setBatteryLevel(20); // Set to critical level
    
    // Act
    drone.update(100);
    
    // Assert
    expect(drone.isPrecisionModeActive()).toBe(true);
  });
});
```

### 3. Test Organization

```
tests/
├── unit/
│   ├── entities/
│   │   ├── Drone.test.ts
│   │   └── AIGuard.test.ts
│   ├── systems/
│   │   ├── DetectionSystem.test.ts
│   │   └── AISystem.test.ts
│   └── utils/
│       └── LineOfSight.test.ts
├── integration/
│   ├── DroneDetection.test.ts
│   └── AIBehavior.test.ts
└── e2e/
    ├── GameplayFlow.test.ts
    └── MissionCompletion.test.ts
```

### 4. Testing Utilities

Create helper functions for common test scenarios:

```typescript
// tests/utils/TestHelpers.ts
export class TestHelpers {
  static createMockScene(): Phaser.Scene {
    return {
      add: { existing: jest.fn() },
      physics: { add: { existing: jest.fn() } },
      events: { emit: jest.fn(), on: jest.fn() }
    } as any;
  }

  static createTestDrone(overrides?: Partial<DroneConfig>): Drone {
    const defaultConfig: DroneConfig = {
      maxSpeed: 100,
      acceleration: 200,
      drag: 300,
      batteryCapacity: 100,
      position: { x: 0, y: 0 }
    };
    
    const config = { ...defaultConfig, ...overrides };
    return new Drone(this.createMockScene(), config);
  }

  static simulateInput(system: DroneInputSystem, keys: string[], duration: number): void {
    // Simulate key presses for testing
    keys.forEach(key => {
      const mockKey = { isDown: true };
      // Mock the key being pressed
    });
    
    system.update(duration);
  }
}
```

### 5. Test Coverage Goals

- **Unit Tests**: 80%+ coverage for core systems
- **Integration Tests**: Cover system interactions
- **E2E Tests**: Cover critical user journeys

```bash
# Check test coverage
npm run test:coverage

# Should see output like:
# File         | % Stmts | % Branch | % Funcs | % Lines
# All files    |   85.2  |   78.4   |   92.1  |   84.8
```

---

## 🐛 Debugging Techniques

### 1. Development Tools Setup

**Browser DevTools Configuration:**

```typescript
// Add to your main.ts for debugging
if (process.env.NODE_ENV === 'development') {
  // Enable Phaser debug mode
  window.game = gameEngine; // Expose game to console
  
  // Add debug helpers
  window.debug = {
    drone: () => gameEngine.getSystem('DroneSystem'),
    detection: () => gameEngine.getSystem('DetectionSystem'),
    ai: () => gameEngine.getSystem('AISystem')
  };
}
```

### 2. Logging Strategy

**Use structured logging:**

```typescript
// utils/Logger.ts
export enum LogLevel {
  DEBUG = 0,
  INFO = 1,
  WARN = 2,
  ERROR = 3
}

export class Logger {
  private static level: LogLevel = LogLevel.INFO;
  
  static debug(message: string, data?: any): void {
    if (this.level <= LogLevel.DEBUG) {
      console.log(`🐛 [DEBUG] ${message}`, data || '');
    }
  }
  
  static info(message: string, data?: any): void {
    if (this.level <= LogLevel.INFO) {
      console.log(`ℹ️ [INFO] ${message}`, data || '');
    }
  }
  
  static warn(message: string, data?: any): void {
    if (this.level <= LogLevel.WARN) {
      console.warn(`⚠️ [WARN] ${message}`, data || '');
    }
  }
  
  static error(message: string, error?: Error): void {
    if (this.level <= LogLevel.ERROR) {
      console.error(`❌ [ERROR] ${message}`, error || '');
    }
  }
}

// Usage in your systems
Logger.debug('Drone position updated', { x: drone.x, y: drone.y });
Logger.warn('Battery level critical', { level: batteryLevel });
Logger.error('Failed to initialize system', error);
```

### 3. Visual Debugging

**Debug visualization for game systems:**

```typescript
// utils/DebugRenderer.ts
export class DebugRenderer {
  private static scene: Phaser.Scene;
  private static graphics: Phaser.GameObjects.Graphics;
  
  static initialize(scene: Phaser.Scene): void {
    this.scene = scene;
    this.graphics = scene.add.graphics();
  }
  
  static drawDetectionRange(detector: IDetector): void {
    if (!this.graphics) return;
    
    this.graphics.lineStyle(2, 0xff0000, 0.5);
    this.graphics.strokeCircle(
      detector.position.x, 
      detector.position.y, 
      detector.range
    );
    
    // Draw field of view
    if (detector.fieldOfView < 360) {
      const startAngle = detector.direction - detector.fieldOfView / 2;
      const endAngle = detector.direction + detector.fieldOfView / 2;
      
      this.graphics.lineStyle(1, 0x00ff00, 0.3);
      this.graphics.arc(
        detector.position.x,
        detector.position.y,
        detector.range,
        Phaser.Math.DegToRad(startAngle),
        Phaser.Math.DegToRad(endAngle)
      );
    }
  }
  
  static drawPatrolRoute(guard: AIGuard): void {
    const waypoints = guard.getWaypoints();
    if (waypoints.length < 2) return;
    
    this.graphics.lineStyle(2, 0x0000ff, 0.6);
    this.graphics.beginPath();
    this.graphics.moveTo(waypoints[0].position.x, waypoints[0].position.y);
    
    for (let i = 1; i < waypoints.length; i++) {
      this.graphics.lineTo(waypoints[i].position.x, waypoints[i].position.y);
    }
    
    this.graphics.strokePath();
  }
  
  static clear(): void {
    if (this.graphics) {
      this.graphics.clear();
    }
  }
}
```

### 4. Common Issues & Solutions

**Issue: Phaser not loading**
```bash
# Check console for errors
# Common causes:
# 1. Missing asset files
# 2. Incorrect import paths
# 3. Version conflicts

# Debug steps:
1. Check network tab for failed asset loads
2. Verify import statements
3. Check Phaser version compatibility
```

**Issue: Physics not working correctly**
```typescript
// Debug physics issues
if (process.env.NODE_ENV === 'development') {
  // Enable physics debug visualization
  this.physics.world.drawDebug = true;
  
  // Log physics body properties
  console.log('Body velocity:', body.velocity);
  console.log('Body acceleration:', body.acceleration);
  console.log('World bounds:', this.physics.world.bounds);
}
```

**Issue: Performance problems**
```typescript
// Performance debugging
const stats = {
  frameTime: 0,
  updateTime: 0,
  renderTime: 0
};

// In your update loop
const startTime = performance.now();
// ... your update logic
stats.updateTime = performance.now() - startTime;

// Log performance data periodically
if (Date.now() % 5000 < 16) { // Every 5 seconds
  console.log('Performance:', stats);
}
```

---

## ⚡ Performance Guidelines

### 1. General Performance Rules

**Do:**
- ✅ Pool game objects instead of creating/destroying them
- ✅ Use object pooling for bullets, particles, effects
- ✅ Limit the number of physics bodies
- ✅ Optimize asset sizes (compress images, use appropriate formats)
- ✅ Use efficient data structures (Maps for lookups, Arrays for iteration)

**Don't:**
- ❌ Create objects in update loops
- ❌ Use complex calculations in every frame
- ❌ Keep references to destroyed objects
- ❌ Use too many event listeners

### 2. Object Pooling Example

```typescript
// utils/ObjectPool.ts
export class ObjectPool<T> {
  private pool: T[] = [];
  private createFn: () => T;
  private resetFn: (obj: T) => void;
  
  constructor(createFn: () => T, resetFn: (obj: T) => void, initialSize = 10) {
    this.createFn = createFn;
    this.resetFn = resetFn;
    
    // Pre-populate pool
    for (let i = 0; i < initialSize; i++) {
      this.pool.push(this.createFn());
    }
  }
  
  get(): T {
    if (this.pool.length > 0) {
      return this.pool.pop()!;
    }
    return this.createFn();
  }
  
  release(obj: T): void {
    this.resetFn(obj);
    this.pool.push(obj);
  }
}

// Usage for drone trail effects
const trailPool = new ObjectPool(
  () => this.add.circle(0, 0, 2, 0x00ff00),
  (circle) => {
    circle.setVisible(false);
    circle.setPosition(0, 0);
  },
  50
);
```

### 3. Frame Rate Monitoring

```typescript
// utils/PerformanceMonitor.ts
export class PerformanceMonitor {
  private frameCount = 0;
  private lastTime = performance.now();
  private fps = 60;
  
  update(): void {
    this.frameCount++;
    const currentTime = performance.now();
    
    if (currentTime - this.lastTime >= 1000) {
      this.fps = Math.round((this.frameCount * 1000) / (currentTime - this.lastTime));
      this.frameCount = 0;
      this.lastTime = currentTime;
      
      // Warn if FPS drops significantly
      if (this.fps < 50) {
        Logger.warn(`Low FPS detected: ${this.fps}`);
      }
    }
  }
  
  getFPS(): number {
    return this.fps;
  }
}
```

---

## 🚀 Build & Deployment

### 1. Build Process

```bash
# Development build (with source maps and debugging)
npm run dev

# Production build (optimized and minified)
npm run build

# Preview production build locally
npm run preview
```

### 2. Environment Configuration

```typescript
// src/config/Environment.ts
export const Environment = {
  isDevelopment: process.env.NODE_ENV === 'development',
  isProduction: process.env.NODE_ENV === 'production',
  
  // Game settings
  debug: {
    showPhysicsDebug: process.env.NODE_ENV === 'development',
    showPerformanceStats: process.env.NODE_ENV === 'development',
    enableConsoleCommands: process.env.NODE_ENV === 'development'
  },
  
  // API endpoints
  api: {
    baseUrl: process.env.VITE_API_URL || 'http://localhost:3001',
    websocket: process.env.VITE_WS_URL || 'ws://localhost:3001'
  }
};
```

### 3. Continuous Integration

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
        cache: 'npm'
    
    - name: Install dependencies
      run: npm ci
    
    - name: Run type check
      run: npm run type-check
    
    - name: Run linting
      run: npm run lint
    
    - name: Run tests
      run: npm run test:coverage
    
    - name: Build project
      run: npm run build
```

### 4. Deployment Checklist

**Before deploying:**

- [ ] All tests pass
- [ ] Code review completed
- [ ] Performance tested
- [ ] Assets optimized
- [ ] Error handling tested
- [ ] Browser compatibility verified
- [ ] Version number updated

**Deployment steps:**

```bash
# 1. Create release branch
git checkout -b release/v1.0.0

# 2. Update version
npm version patch  # or minor/major

# 3. Build and test
npm run build
npm run test

# 4. Deploy to staging
npm run deploy:staging

# 5. Test on staging environment
# Manual testing of critical features

# 6. Deploy to production
npm run deploy:production

# 7. Tag release
git tag v1.0.0
git push origin v1.0.0
```

---

## 📊 Code Review Guidelines

### 1. What to Look For

**Functionality:**
- Does the code do what it's supposed to do?
- Are edge cases handled?
- Is error handling appropriate?

**Code Quality:**
- Is the code readable and well-commented?
- Are functions and variables named clearly?
- Is the code following our style guidelines?

**Performance:**
- Are there any obvious performance issues?
- Is the code creating unnecessary objects?
- Are there memory leaks?

**Testing:**
- Are there appropriate tests?
- Do the tests cover the main functionality?
- Are the tests clear and maintainable?

### 2. Review Checklist

**For Authors:**
- [ ] Self-review completed
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] No console.log statements left
- [ ] Performance implications considered

**For Reviewers:**
- [ ] Code functionality verified
- [ ] Style guidelines followed
- [ ] Tests are adequate
- [ ] Documentation is clear
- [ ] No obvious bugs or issues

### 3. Giving Good Feedback

**Good feedback examples:**

```markdown
# Be specific and constructive
❌ "This is wrong"
✅ "Consider using Array.find() instead of filter()[0] for better performance"

# Explain the why
❌ "Change this"
✅ "This could cause a memory leak because the event listener isn't removed. Consider adding cleanup in the shutdown method."

# Suggest alternatives
❌ "I don't like this approach"
✅ "What do you think about using the Strategy pattern here? It might make this easier to test and extend."
```

---

## 🎯 Daily Development Routine

### Morning Routine (15 minutes)
1. ☕ Get coffee/tea
2. 📧 Check for PR reviews and team updates
3. 🔄 Pull latest changes from main
4. 📋 Review your task list and priorities
5. 🧪 Run tests to ensure everything is working

### Development Session
1. 🎯 Pick one focused task
2. 🌿 Create a feature branch
3. 🔴 Write failing tests (TDD approach)
4. 💚 Implement the feature to make tests pass
5. ♻️ Refactor and optimize
6. 📝 Document any complex logic
7. 💾 Commit with clear message

### End of Day (10 minutes)
1. 🧹 Clean up any debug code
2. 📤 Push your work to remote
3. 📊 Check test coverage
4. 📝 Update task status
5. 📋 Plan tomorrow's priorities

---

## 🆘 Getting Help

### When You're Stuck

1. **Try for 30 minutes** - Give yourself time to solve it
2. **Check documentation** - Look at existing docs and examples
3. **Search online** - Stack Overflow, Phaser forums, GitHub issues
4. **Ask for help** - Don't stay stuck too long

### How to Ask for Help

**Good help request:**

```markdown
## Problem
I'm trying to implement line-of-sight detection, but the raycast isn't working correctly.

## What I've tried
- Checked that coordinates are correct
- Verified that obstacles are properly registered
- Tested with simple cases

## Code
[Include relevant code snippet]

## Expected vs Actual
Expected: Ray should be blocked by walls
Actual: Ray passes through walls

## Question
Am I using the Phaser Line-to-Rectangle intersection correctly?
```

### Resources

- 📚 [Phaser Documentation](https://photonstorm.github.io/phaser3-docs/)
- 💬 [Phaser Discord](https://discord.gg/phaser)
- 📖 [TypeScript Handbook](https://www.typescriptlang.org/docs/)
- 🎮 [Game Programming Patterns](https://gameprogrammingpatterns.com/)

---

## 🎉 Summary

Following this workflow will help you:

- ✅ Write maintainable, testable code
- ✅ Catch bugs early through testing
- ✅ Collaborate effectively with team members
- ✅ Deploy confidently with proper processes
- ✅ Learn and improve continuously

Remember: **Good habits compound over time.** Start with small, consistent practices and build from there.

**Questions?** Check the `PATTERNS_AND_SOLUTIONS.md` guide for common challenges and solutions.

Happy coding! 🚁✨ 