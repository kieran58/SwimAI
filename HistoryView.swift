import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var store: SwimStore

    var body: some View {
        NavigationStack {
            List {
                Section("This week") {
                    Text("\(store.weeklyVolumeMetres) m swum")
                        .font(.headline)
                }

                Section("Races") {
                    ForEach(store.races) { race in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(race.eventName).font(.headline)
                            Text("\(race.stroke.rawValue), \(race.distanceMetres) m, \(formatted(race.timeSeconds))")
                                .font(.subheadline)
                            if let diff = race.difference {
                                Text(diff <= 0 ? "Ahead of target by \(formatted(abs(diff)))" : "Behind target by \(formatted(diff))")
                                    .font(.caption)
                                    .foregroundStyle(diff <= 0 ? .green : .red)
                            }
                        }
                    }
                    .onDelete { store.deleteRace(at: $0) }
                }

                Section("Training") {
                    ForEach(store.sessions) { session in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(session.stroke.rawValue), \(session.distanceMetres) m")
                                .font(.headline)
                            Text(session.date.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .onDelete { store.deleteSession(at: $0) }
                }
            }
            .navigationTitle("History")
        }
    }

    private func formatted(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let secs = seconds.truncatingRemainder(dividingBy: 60)
        return minutes > 0 ? String(format: "%d:%05.2f", minutes, secs) : String(format: "%.2f s", secs)
    }
}

#Preview {
    HistoryView()
        .environmentObject(SwimStore())
}
