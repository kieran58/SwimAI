import Foundation

@MainActor
final class SwimStore: ObservableObject {
    @Published var sessions: [SwimSession] = []
    @Published var races: [RaceResult] = []

    private let sessionsURL: URL
    private let racesURL: URL

    init() {
        let folder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        sessionsURL = folder.appendingPathComponent("sessions.json")
        racesURL = folder.appendingPathComponent("races.json")
        load()
    }

    func addSession(_ session: SwimSession) {
        sessions.append(session)
        sessions.sort { $0.date > $1.date }
        save()
    }

    func addRace(_ race: RaceResult) {
        races.append(race)
        races.sort { $0.date > $1.date }
        save()
    }

    func deleteSession(at offsets: IndexSet) {
        sessions.remove(atOffsets: offsets)
        save()
    }

    func deleteRace(at offsets: IndexSet) {
        races.remove(atOffsets: offsets)
        save()
    }

    // Total distance swum this week, in metres. Used for the weekly volume figure.
    var weeklyVolumeMetres: Int {
        let calendar = Calendar.current
        let now = Date()
        return sessions
            .filter { calendar.isDate($0.date, equalTo: now, toGranularity: .weekOfYear) }
            .reduce(0) { $0 + $1.distanceMetres }
    }

    // Pace for each session, oldest first, for a trend chart.
    var paceTrend: [(date: Date, pace: Double)] {
        sessions
            .sorted { $0.date < $1.date }
            .map { (date: $0.date, pace: $0.paceMinutesPer100m) }
    }

    private func save() {
        do {
            let sessionData = try JSONEncoder().encode(sessions)
            try sessionData.write(to: sessionsURL, options: .atomic)
            let raceData = try JSONEncoder().encode(races)
            try raceData.write(to: racesURL, options: .atomic)
        } catch {
            print("Could not save swim data: \(error)")
        }
    }

    private func load() {
        if let data = try? Data(contentsOf: sessionsURL),
           let decoded = try? JSONDecoder().decode([SwimSession].self, from: data) {
            sessions = decoded
        }
        if let data = try? Data(contentsOf: racesURL),
           let decoded = try? JSONDecoder().decode([RaceResult].self, from: data) {
            races = decoded
        }
    }
}
