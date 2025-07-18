# iSweep

A faithful 1:1 copy of the classic Windows Minesweeper game for iOS, built with SwiftUI.

## Features

### Classic Windows Minesweeper Gameplay
- **Exact Rules**: Faithful recreation of the original Windows Minesweeper
- **Three Difficulty Levels**:
  - Beginner: 9×9 grid with 10 mines
  - Intermediate: 16×16 grid with 40 mines
  - Expert: 30×16 grid with 99 mines
- **Classic Controls**:
  - Tap to reveal cells
  - Long press to flag/unflag cells
- **Recursive Revealing**: Empty areas reveal adjacent cells automatically
- **Mine Counter**: Digital display showing remaining mines
- **Timer**: Tracks time elapsed during gameplay
- **Smiley Face**: Status indicator that changes based on game state
  - 😊 Playing/Not Started
  - 😎 Won
  - 😵 Lost
- **Win/Lose Conditions**: 
  - Win: All non-mine cells revealed
  - Lose: Mine detonated
- **First Click Safety**: Mines are generated after first tap to ensure safe start

### Technical Implementation
- **SwiftUI**: Modern iOS interface
- **MVVM Architecture**: Clean separation of concerns
- **Responsive Design**: Adapts to different screen sizes
- **State Management**: Proper game state handling
- **Timer Integration**: Real-time updates

## Screenshots

The app recreates the classic Windows Minesweeper interface with:
- Digital mine counter and timer displays
- 3D-styled cells with proper borders
- Color-coded number display (1=blue, 2=green, 3=red, etc.)
- Flag icons for marked cells
- Bomb icons for revealed mines

## Building the Project

### Prerequisites
- Xcode 15.0 or later
- iOS 17.0 or later (deployment target)
- macOS with Apple Silicon or Intel processor

### Build Instructions

1. **Open the Project**:
   ```bash
   # Navigate to the project directory
   cd /path/to/iSweep
   
   # Open the Xcode project
   open iSweep.xcodeproj
   ```

2. **Select Target Device**:
   - In Xcode, select your target device or simulator from the dropdown next to the play button
   - Recommended: iPhone 15 Pro simulator or any physical iOS device

3. **Build and Run**:
   - Press `Cmd + R` or click the "Play" button in Xcode
   - The app will compile and launch on your selected device/simulator

### Alternative Build Methods

#### Command Line Build:
```bash
# Build for simulator
xcodebuild -project iSweep.xcodeproj -scheme iSweep -destination 'platform=iOS Simulator,name=iPhone 15 Pro' build

# Build for device (requires proper provisioning)
xcodebuild -project iSweep.xcodeproj -scheme iSweep -destination 'platform=iOS,name=Your Device Name' build
```

#### Archive for Distribution:
```bash
# Create archive
xcodebuild -project iSweep.xcodeproj -scheme iSweep -archivePath iSweep.xcarchive archive

# Export IPA (requires export options plist)
xcodebuild -exportArchive -archivePath iSweep.xcarchive -exportPath ./export -exportOptionsPlist ExportOptions.plist
```

### Project Structure
```
iSweep/
├── iSweep.xcodeproj/          # Xcode project file
├── iSweep/                    # Main source directory
│   ├── iSweepApp.swift        # App entry point
│   ├── ContentView.swift      # Main UI view
│   ├── GameModel.swift        # Core game logic and data model
│   ├── GameViewModel.swift    # View model layer
│   ├── MineCell.swift         # Individual cell component
│   ├── Assets.xcassets/       # App assets
│   └── Preview Content/       # SwiftUI preview assets
└── README.md                  # This file
```

### Key Files Description

- **GameModel.swift**: Contains the core game logic including mine placement, cell revealing, win/lose detection, and timer management
- **GameViewModel.swift**: Bridges the model and view, handling user interactions and UI state
- **ContentView.swift**: Main SwiftUI view with the game board, header, and controls
- **MineCell.swift**: Individual cell component with proper styling and interaction handling

### Development Notes

- The app uses SwiftUI's `@Published` properties for reactive updates
- Game state is managed through ObservableObject pattern
- Timer functionality uses Foundation's Timer class
- Random mine placement ensures fair gameplay
- Recursive cell revealing implemented with proper boundary checking

### Troubleshooting

1. **Build Errors**: Ensure you have the latest Xcode version and iOS SDK
2. **Simulator Issues**: Try resetting the simulator or choosing a different device
3. **Performance**: The app is optimized for smooth gameplay even on older devices

### License

This project is a recreation of the classic Windows Minesweeper game for educational purposes.

---

**Enjoy playing iSweep! 💣**
