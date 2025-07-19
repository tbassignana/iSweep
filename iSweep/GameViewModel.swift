import Foundation
import SwiftUI
import Combine

class GameViewModel: ObservableObject {
    @Published var gameModel: GameModel
    private var cancellables = Set<AnyCancellable>()
    
    init(difficulty: GameDifficulty = .beginner) {
        self.gameModel = GameModel(difficulty: difficulty)
        
        // Forward all changes from gameModel to this view model
        gameModel.objectWillChange.sink { [weak self] in
            self?.objectWillChange.send()
        }.store(in: &cancellables)
    }
    
    // MARK: - Game Actions
    func cellTapped(row: Int, col: Int) {
        // Bounds checking
        guard row >= 0 && row < gridHeight && col >= 0 && col < gridWidth else {
            return
        }
        gameModel.cellTapped(row: row, col: col)
    }
    
    func cellLongPressed(row: Int, col: Int) {
        // Bounds checking
        guard row >= 0 && row < gridHeight && col >= 0 && col < gridWidth else {
            return
        }
        gameModel.cellLongPressed(row: row, col: col)
    }
    
    func resetGame() {
        gameModel.resetGame()
    }
    
    func changeDifficulty(to difficulty: GameDifficulty) {
        gameModel.changeDifficulty(to: difficulty)
    }
    
    // MARK: - Computed Properties for View
    var cells: [[Cell]] {
        gameModel.cells
    }
    
    var gameState: GameState {
        gameModel.gameState
    }
    
    var difficulty: GameDifficulty {
        gameModel.difficulty
    }
    
    var remainingMines: Int {
        gameModel.remainingMines
    }
    
    var timeElapsed: Int {
        gameModel.timeElapsed
    }
    
    var smileyFace: String {
        gameModel.smileyFace
    }
    
    var gridWidth: Int {
        gameModel.difficulty.gridSize.width
    }
    
    var gridHeight: Int {
        gameModel.difficulty.gridSize.height
    }
    
    // MARK: - Formatting Helpers
    func formattedTime() -> String {
        let minutes = timeElapsed / 60
        let seconds = timeElapsed % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func formattedMineCount() -> String {
        let count = max(0, remainingMines) // Don't show negative numbers
        return String(format: "%03d", count)
    }
    
    // MARK: - UI Helpers
    var cellSize: CGFloat {
        switch difficulty {
        case .beginner:
            return 35
        case .intermediate:
            return 25
        case .expert:
            return 20
        }
    }
    
    var fontSize: CGFloat {
        switch difficulty {
        case .beginner:
            return 18
        case .intermediate:
            return 14
        case .expert:
            return 12
        }
    }
    
    var gridSpacing: CGFloat {
        return 1
    }
}
