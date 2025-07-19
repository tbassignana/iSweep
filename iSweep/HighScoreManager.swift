import Foundation

struct HighScore: Codable {
    let time: Int
    let difficulty: GameDifficulty
    let date: Date
    
    var formattedTime: String {
        let minutes = time / 60
        let seconds = time % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

class HighScoreManager: ObservableObject {
    private let userDefaults = UserDefaults.standard
    private let highScoresKey = "HighScores"
    
    @Published var highScores: [GameDifficulty: HighScore] = [:]
    
    init() {
        loadHighScores()
    }
    
    func checkAndSaveHighScore(time: Int, difficulty: GameDifficulty) -> Bool {
        let currentBest = highScores[difficulty]
        let isNewRecord = currentBest == nil || time < currentBest!.time
        
        if isNewRecord {
            let newHighScore = HighScore(time: time, difficulty: difficulty, date: Date())
            highScores[difficulty] = newHighScore
            saveHighScores()
        }
        
        return isNewRecord
    }
    
    func getHighScore(for difficulty: GameDifficulty) -> HighScore? {
        return highScores[difficulty]
    }
    
    private func saveHighScores() {
        do {
            let data = try JSONEncoder().encode(highScores)
            userDefaults.set(data, forKey: highScoresKey)
        } catch {
            print("Failed to save high scores: \(error)")
        }
    }
    
    private func loadHighScores() {
        guard let data = userDefaults.data(forKey: highScoresKey) else { return }
        
        do {
            highScores = try JSONDecoder().decode([GameDifficulty: HighScore].self, from: data)
        } catch {
            print("Failed to load high scores: \(error)")
        }
    }
}
