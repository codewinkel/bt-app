import Foundation

enum TranscriptionQualityService {
    static let minimumRecordingDuration: TimeInterval = 0.3

    // Known Whisper hallucinations produced on silence or near-silence.
    private static let knownArtifacts: [String] = [
        "amara.org",
        "untertitel",
        "subtitles by",
        "subcaption",
        "vielen dank für",
        "vielen dank fürs zuschauen",
        "danke fürs zuschauen",
        "copyright wdr",
        "im auftrag des zdf",
        "www.facebook.com",
        "www.twitter.com",
        "[ stille ]",
        "[stille]",
        "[ musik ]",
        "[musik]",
        "[ applaus ]",
        "[applaus]",
        "♪♪♪",
        "you",
    ]

    static func shouldRejectRecording(duration: TimeInterval) -> Bool {
        duration < minimumRecordingDuration
    }

    static func cleanedTranscript(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func isLikelyArtifact(_ text: String, recordingDuration: TimeInterval) -> Bool {
        let cleaned = cleanedTranscript(text)
        guard !cleaned.isEmpty else { return true }

        let lowercased = cleaned.lowercased()
        if knownArtifacts.contains(where: { lowercased.contains($0) }) {
            return true
        }

        let words = cleaned.split { $0.isWhitespace || $0.isNewline }
        let letters = cleaned.unicodeScalars.filter { CharacterSet.letters.contains($0) }.count

        if letters == 0 {
            return true
        }

        if recordingDuration < 0.55 && (words.count >= 5 || cleaned.count >= 32) {
            return true
        }

        if recordingDuration < 0.8 && cleaned.count >= 56 {
            return true
        }

        return false
    }
}
