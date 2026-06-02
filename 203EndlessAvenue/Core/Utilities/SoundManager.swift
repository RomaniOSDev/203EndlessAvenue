import AudioToolbox

enum SoundManager {
    static func playTick() {
        AudioServicesPlaySystemSound(1003)
    }

    static func playSuccess() {
        AudioServicesPlaySystemSound(1057)
    }

    static func playComplete() {
        AudioServicesPlaySystemSound(1103)
    }

    static func playMarkKnown() {
        AudioServicesPlaySystemSound(1104)
    }
}
