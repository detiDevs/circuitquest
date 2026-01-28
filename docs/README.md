# CircuitQuest UI Screens

This directory contains the Flutter screens for CircuitQuest.

## Screens Overview

### 1. Home Screen (`home_screen.dart`)
The main entry point for the application.

**Features:**
- Displays the CircuitQuest app logo
- Two main mode buttons:
  - **Level Mode**: Progress through structured circuit challenges
  - **Sandbox Mode**: Free-form circuit design and experimentation
- Responsive design with proper spacing and visual hierarchy
- Navigation to other screens

**Structure:**
- `HomeScreen` - Main widget
- `_ModeButton` - Reusable button component for mode selection

### 2. Level Selection Screen (`level_selection_screen.dart`)
Displays all available levels organized by category.

**Features:**
- Loads levels from JSON files using `LevelLoader`
- Organizes levels by category blocks (e.g., "Basic Gates", "Further Gates")
- Expandable category sections for clean UI
- Grid layout of level cards
- Recommended level badges
- Tap to start playing a level
- Error handling with retry functionality

**Structure:**
- `LevelSelectionScreen` - Main screen widget
- `_LevelCategory` - Widget for each category section
- `_LevelCard` - Individual level card with title and metadata

### 3. Level Screen (`level_screen.dart`)
The main gameplay screen where players solve circuit puzzles.

**Features:**
- **Responsive Layout**:
  - Desktop (>1200px): Info panel | Palette | Canvas | Controls (4-column)
  - Mobile/Tablet: Collapsible sections with vertical stacking
- **Level Information Panel**:
  - Level title and difficulty badge
  - Description
  - Numbered objectives
  - Helpful hints with lightbulb icons
- **Limited Component Palette**:
  - Only shows components allowed for the level
  - Reuses draggable component implementation from sandbox
- **Circuit Canvas**:
  - Shared implementation from sandbox mode
  - Full grid-based circuit design
- **Control Panel**:
  - Shared implementation from sandbox mode
  - Simulation controls and evaluation
- **Difficulty Badges**:
  - Color-coded (Green=Easy, Orange=Medium, Red=Hard)
  - Icons to indicate difficulty level

**Structure:**
- `LevelScreen` - Main screen widget
- `_LevelScreenBody` - Responsive layout manager
- `_LevelInfoPanel` - Level information display
- `_DifficultyBadge` - Difficulty indicator
- `_LimitedComponentPalette` - Filtered component palette
- `_PaletteItem` - Draggable component item (reused from sandbox)
- `_ComponentIcon` - SVG icon display for components
- Helper function `_getCurrentLevel()` - Gets current level from widget tree

## Reused Components

The level screen reuses several widgets and logic from sandbox mode:

### From `component_palette.dart`:
- `ComponentType` - Data model for component definitions
- `availableComponents` - List of all available component types
- `_PaletteItem` - Draggable palette item component
- `_ComponentIcon` - SVG icon rendering

### From `circuit_canvas.dart`:
- `CircuitCanvas` - The main grid-based circuit editor
- All canvas interaction logic

### From `control_panel.dart`:
- `ControlPanel` - Simulation controls and circuit evaluation
- All simulation controls

## Code Reuse Strategy

The architecture maximizes code reuse:

1. **Canvas Logic**: The same `CircuitCanvas` widget is used in both sandbox and level modes
2. **Control Panel**: The same `ControlPanel` handles all simulation controls
3. **Component System**: The component palette system is shared, but filtered per level
4. **State Management**: The `sandboxProvider` manages the circuit state for both modes

## Navigation Flow

```
HomeScreen
├── → LevelSelectionScreen
│   └── → LevelScreen (per level)
│       ├── CircuitCanvas (shared)
│       ├── ControlPanel (shared)
│       └── LimitedComponentPalette
│
└── → SandboxScreen
    ├── CircuitCanvas (shared)
    ├── ComponentPalette (all components)
    └── ControlPanel (shared)
```

## Responsive Design Breakpoints

- **Desktop**: width > 1200px
  - 4-column layout: Info | Palette | Canvas | Controls
- **Tablet**: 800px < width <= 1200px
  - Vertical sections with collapsible expansion tiles
- **Mobile**: width <= 800px
  - Full vertical stack with expansion tiles
  - Canvas takes priority space

## State Management

All screens use Riverpod for state management:
- `sandboxProvider` - Manages circuit state
- `LevelLoader` - Loads level data from assets
- Local widget state for UI elements (loading, errors)

## Error Handling

The screens implement proper error handling:
- Level loading failures in `LevelSelectionScreen`
- Graceful fallbacks for missing assets
- User-friendly error messages
- Retry mechanisms

## Future Enhancements

Potential improvements to the screens:

1. **Level Filtering/Searching** - Add search and filter options in level selection
2. **Progress Display** - Show completion status and stars for levels
3. **Tutorial System** - Interactive tutorials for new players
4. **Leaderboard** - Display scores or completion times
5. **Save/Load** - Save circuit designs in levels
6. **Test Validation** - Display test case status during gameplay
7. **Animations** - Add transitions and animations between screens
8. **Accessibility** - Improve keyboard navigation and screen reader support

## Testing

To test the screens:

```bash
# Run the app
flutter run

# Run tests
flutter test

# Build for web
flutter build web

# Build for Android
flutter build apk

# Build for iOS
flutter build ios
```

## File Organization

```
lib/ui/screens/
├── home_screen.dart           # Home/mode selection
├── level_selection_screen.dart # Level browser
├── level_screen.dart          # Level gameplay
└── sandbox_screen.dart        # Sandbox mode (existing)
```
