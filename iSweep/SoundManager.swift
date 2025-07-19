import Foundation
import AudioToolbox

class SoundManager: ObservableObject {
    @Published var isSoundEnabled = true
    
    enum GameSound: String {
        case restart = "restart"
        case mine = "mine"
        case touch = "touch"
        case flag = "flag"
        case unflag = "unflag"
        case win = "win"
        case chord = "chord"
        
        var systemSoundID: SystemSoundID {
            switch self {
            case .restart: return 1104  // SMS received sound
            case .mine: return 1006     // Low power sound
            case .touch: return 1123    // Keyboard click
            case .flag: return 1105     // New mail
            case .unflag: return 1003   // Delete key
            case .win: return 1016      // Complete sound
            case .chord: return 1057    // Multiway join sound
            }
        }
    }
    
    init() {
        loadSoundSetting()
    }
    
    func playSound(_ sound: GameSound) {
        guard isSoundEnabled else { return }
        AudioServicesPlaySystemSound(sound.systemSoundID)
    }
    
    func toggleSound() {
        isSoundEnabled.toggle()
        UserDefaults.standard.set(isSoundEnabled, forKey: "SoundEnabled")
    }
    
    private func loadSoundSetting() {
        isSoundEnabled = UserDefaults.standard.object(forKey: "SoundEnabled") as? Bool ?? true
    }
}
