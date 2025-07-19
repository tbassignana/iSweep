import Foundation

// MARK: - Game Difficulty
enum GameDifficulty: CaseIterable {
    case beginner
    case intermediate  
    case expert
    
    var gridSize: (width: Int, height: Int) {
        switch self {
        case .beginner: return (9, 9)
        case .intermediate: return (16, 16)
        case .expert: return (30, 16)
        }
    }
    
    var mineCount: Int {
        switch self {
        case .beginner: return 10
        case .intermediate: return 40
        case .expert: return 99
        }
    }
    
    var displayName: String {
        switch self {
        case .beginner: return "Beginner"
        case .intermediate: return "Intermediate"
        case .expert: return "Expert"
        }
    }
}

// MARK: - Game State
enum GameState {
    case playing
    case won
    case lost
    case notStarted
}

// MARK: - Cell Model
struct Cell: Identifiable {
    let id = UUID()
    var isMine: Bool = false
    var isRevealed: Bool = false
    var isFlagged: Bool = false
    var adjacentMines: Int = 0
    
    var displayText: String {
        if isFlagged {
            return "🚩"
        } else if !isRevealed {
            return ""
        } else if isMine {
            return "💣"
        } else if adjacentMines > 0 {
            return "\(adjacentMines)"
        } else {
            return ""
        }
    }
    
    var backgroundColor: String {
        if !isRevealed {
            return "unrevealed"
        } else if isMine {
            return "mine"
        } else {
            return "revealed"
        }
    }
    
    var textColor: String {
        switch adjacentMines {
        case 1: return "blue"
        case 2: return "green"
        case 3: return "red"
        case 4: return "purple"
        case 5: return "brown"
        case 6: return "pink"
        case 7: return "black"
        case 8: return "gray"
        default: return "black"
        }
    }
}

// MARK: - Game Model
class GameModel: ObservableObject {
    @Published var cells: [[Cell]] = []
    @Published var gameState: GameState = .notStarted
    @Published var difficulty: GameDifficulty = .beginner
    @Published var flagCount: Int = 0
    @Published var timeElapsed: Int = 0
    @Published var isFirstMove: Bool = true
    
    private var timer: Timer?
    private var width: Int { difficulty.gridSize.width }
    private var height: Int { difficulty.gridSize.height }
    private var totalMines: Int { difficulty.mineCount }
    
    init(difficulty: GameDifficulty = .beginner) {
        self.difficulty = difficulty
        initializeGame()
    }
    
    // MARK: - Game Initialization
    func initializeGame() {
        gameState = .notStarted
        flagCount = 0
        timeElapsed = 0
        isFirstMove = true
        stopTimer()
        
        // Create empty grid
        cells = Array(repeating: Array(repeating: Cell(), count: width), count: height)
        
        // Initialize cells with unique IDs
        for row in 0..<height {
            for col in 0..<width {
                cells[row][col] = Cell()
            }
        }
    }
    
    // MARK: - Mine Generation
    private func generateMines(avoiding firstTapRow: Int, firstTapCol: Int) {
        var minesPlaced = 0
        
        while minesPlaced < totalMines {
            let randomRow = Int.random(in: 0..<height)
            let randomCol = Int.random(in: 0..<width)
            
            // Don't place mine on first tap location or if already has mine
            if (randomRow == firstTapRow && randomCol == firstTapCol) || cells[randomRow][randomCol].isMine {
                continue
            }
            
            cells[randomRow][randomCol].isMine = true
            minesPlaced += 1
        }
        
        // Calculate adjacent mine counts
        calculateAdjacentMines()
    }
    
    private func calculateAdjacentMines() {
        for row in 0..<height {
            for col in 0..<width {
                if !cells[row][col].isMine {
                    cells[row][col].adjacentMines = countAdjacentMines(row: row, col: col)
                }
            }
        }
    }
    
    private func countAdjacentMines(row: Int, col: Int) -> Int {
        var count = 0
        for deltaRow in -1...1 {
            for deltaCol in -1...1 {
                if deltaRow == 0 && deltaCol == 0 { continue }
                
                let newRow = row + deltaRow
                let newCol = col + deltaCol
                
                if isValidPosition(row: newRow, col: newCol) && cells[newRow][newCol].isMine {
                    count += 1
                }
            }
        }
        return count
    }
    
    // MARK: - Game Actions
    func cellTapped(row: Int, col: Int) {
        guard gameState == .playing || gameState == .notStarted else { return }
        guard !cells[row][col].isFlagged else { return }
        
        // First move - generate mines and start timer
        if isFirstMove {
            generateMines(avoiding: row, firstTapCol: col)
            gameState = .playing
            isFirstMove = false
            startTimer()
        }
        
        // If tapped on mine, game over
        if cells[row][col].isMine {
            gameState = .lost
            revealAllMines()
            stopTimer()
            return
        }
        
        // Reveal cell and adjacent empty cells
        revealCell(row: row, col: col)
        
        // Check win condition
        checkWinCondition()
    }
    
    func cellLongPressed(row: Int, col: Int) {
        guard gameState == .playing || gameState == .notStarted else { return }
        
        // If cell is already revealed, perform chording
        if cells[row][col].isRevealed && cells[row][col].adjacentMines > 0 {
            performChording(row: row, col: col)
            return
        }
        
        guard !cells[row][col].isRevealed else { return }
        
        if cells[row][col].isFlagged {
            cells[row][col].isFlagged = false
            flagCount -= 1
        } else if flagCount < totalMines {
            cells[row][col].isFlagged = true
            flagCount += 1
        }
        
        // Check win condition in case all mines are flagged
        checkWinCondition()
    }
    
    // MARK: - Chording
    private func performChording(row: Int, col: Int) {
        let cell = cells[row][col]
        guard cell.isRevealed && cell.adjacentMines > 0 else { return }
        
        // Count flagged adjacent cells
        var flaggedCount = 0
        var adjacentCells: [(Int, Int)] = []
        
        for deltaRow in -1...1 {
            for deltaCol in -1...1 {
                if deltaRow == 0 && deltaCol == 0 { continue }
                
                let newRow = row + deltaRow
                let newCol = col + deltaCol
                
                if isValidPosition(row: newRow, col: newCol) {
                    adjacentCells.append((newRow, newCol))
                    if cells[newRow][newCol].isFlagged {
                        flaggedCount += 1
                    }
                }
            }
        }
        
        // Only perform chording if the number of flags equals the adjacent mine count
        guard flaggedCount == cell.adjacentMines else { return }
        
        // Reveal all unflagged adjacent cells
        for (adjRow, adjCol) in adjacentCells {
            let adjCell = cells[adjRow][adjCol]
            if !adjCell.isFlagged && !adjCell.isRevealed {
                if adjCell.isMine {
                    // Hit a mine during chording - game over
                    gameState = .lost
                    revealAllMines()
                    stopTimer()
                    return
                } else {
                    // Reveal the cell
                    revealCell(row: adjRow, col: adjCol)
                }
            }
        }
        
        // Check win condition after chording
        checkWinCondition()
    }
    
    private func revealCell(row: Int, col: Int) {
        guard isValidPosition(row: row, col: col) else { return }
        guard !cells[row][col].isRevealed else { return }
        guard !cells[row][col].isFlagged else { return }
        
        cells[row][col].isRevealed = true
        
        // If cell has no adjacent mines, reveal surrounding cells
        if cells[row][col].adjacentMines == 0 {
            for deltaRow in -1...1 {
                for deltaCol in -1...1 {
                    if deltaRow == 0 && deltaCol == 0 { continue }
                    revealCell(row: row + deltaRow, col: col + deltaCol)
                }
            }
        }
    }
    
    private func revealAllMines() {
        for row in 0..<height {
            for col in 0..<width {
                if cells[row][col].isMine {
                    cells[row][col].isRevealed = true
                }
            }
        }
    }
    
    private func checkWinCondition() {
        var revealedCount = 0
        var correctFlags = 0
        
        for row in 0..<height {
            for col in 0..<width {
                let cell = cells[row][col]
                if cell.isRevealed && !cell.isMine {
                    revealedCount += 1
                }
                if cell.isFlagged && cell.isMine {
                    correctFlags += 1
                }
            }
        }
        
        // Win condition: all non-mine cells revealed
        let totalNonMineCells = (width * height) - totalMines
        if revealedCount == totalNonMineCells {
            gameState = .won
            stopTimer()
            
            // Auto-flag remaining mines
            for row in 0..<height {
                for col in 0..<width {
                    if cells[row][col].isMine && !cells[row][col].isFlagged {
                        cells[row][col].isFlagged = true
                        flagCount += 1
                    }
                }
            }
        }
    }
    
    // MARK: - Timer Management
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.timeElapsed += 1
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Utility
    private func isValidPosition(row: Int, col: Int) -> Bool {
        return row >= 0 && row < height && col >= 0 && col < width
    }
    
    func resetGame() {
        initializeGame()
    }
    
    func changeDifficulty(to newDifficulty: GameDifficulty) {
        difficulty = newDifficulty
        initializeGame()
    }
    
    // MARK: - Computed Properties
    var remainingMines: Int {
        return totalMines - flagCount
    }
    
    var smileyFace: String {
        switch gameState {
        case .notStarted, .playing:
            return "😊"
        case .won:
            return "😎"
        case .lost:
            return "😵"
        }
    }
}
