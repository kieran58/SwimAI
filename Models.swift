import Foundation

enum Stroke: String, Codable, CaseIterable, Identifiable {
    case freestyle = "Freestyle"
    case backstroke = "Backstroke"
    case breaststroke = "Breaststroke"
    case butterfly = "Butterfly"
    case medley = "Medley"

    var id: String { rawValue }
}

struct SwimSession: Identifiable, Codable {
    var id: UUID = UUID()
    var date: Date
    var stroke: Stroke
    var distanceMetres: Int
    var durationSeconds: Double
    var notes: String?

    var paceMinutesPer100m: Double {
        guard distanceMetres > 0 else { return 0 }
        let seconds100m = durationSeconds / (Double(distanceMetres) / 100.0)
        return seconds100m / 60.0
    }
}

struct RaceResult: Identifiable, Codable {
    var id: UUID = UUID()
    var eventName: String
    var date: Date
    var stroke: Stroke
    var distanceMetres: Int
    var timeSeconds: Double
    var targetTimeSeconds: Double?

    var difference: Double? {
        guard let target = targetTimeSeconds else { return nil }
        return timeSeconds - target
    }
}
