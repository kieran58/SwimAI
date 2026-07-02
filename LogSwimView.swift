import SwiftUI

struct LogSwimView: View {
    @EnvironmentObject private var store: SwimStore
    @State private var logType = LogType.session

    enum LogType: String, CaseIterable, Identifiable {
        case session = "Training"
        case race = "Race"
        var id: String { rawValue }
    }

    // Training fields
    @State private var date = Date()
    @State private var stroke = Stroke.freestyle
    @State private var distance = ""
    @State private var minutes = ""
    @State private var seconds = ""
    @State private var notes = ""

    // Race fields
    @State private var eventName = ""
    @State private var raceTimeMinutes = ""
    @State private var raceTimeSeconds = ""
    @State private var targetMinutes = ""
    @State private var targetSeconds = ""

    var body: some View {
        NavigationStack {
            Form {
                Picker("Type", selection: $logType) {
                    ForEach(LogType.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)

                Section("Details") {
                    DatePicker("Date", selection: $date, displayedComponents: [.date])
                    Picker("Stroke", selection: $stroke) {
                        ForEach(Stroke.allCases) { Text($0.rawValue).tag($0) }
                    }

                    if logType == .session {
                        TextField("Distance (metres)", text: $distance)
                            .keyboardType(.numberPad)
                        HStack {
                            TextField("Minutes", text: $minutes)
                                .keyboardType(.numberPad)
                            TextField("Seconds", text: $seconds)
                                .keyboardType(.numberPad)
                        }
                        TextField("Notes", text: $notes)
                    } else {
                        TextField("Event name", text: $eventName)
                        TextField("Distance (metres)", text: $distance)
                            .keyboardType(.numberPad)
                        HStack {
                            TextField("Minutes", text: $raceTimeMinutes)
                                .keyboardType(.numberPad)
                            TextField("Seconds", text: $raceTimeSeconds)
                                .keyboardType(.numberPad)
                        }
                        HStack {
                            TextField("Target min", text: $targetMinutes)
                                .keyboardType(.numberPad)
                            TextField("Target sec", text: $targetSeconds)
                                .keyboardType(.numberPad)
                        }
                    }
                }

                Button("Save") { save() }
                    .disabled(distance.isEmpty)
            }
            .navigationTitle("Log a swim")
        }
    }

    private func save() {
        let distanceMetres = Int(distance) ?? 0

        if logType == .session {
            let total = (Double(minutes) ?? 0) * 60 + (Double(seconds) ?? 0)
            let session = SwimSession(
                date: date,
                stroke: stroke,
                distanceMetres: distanceMetres,
                durationSeconds: total,
                notes: notes.isEmpty ? nil : notes
            )
            store.addSession(session)
        } else {
            let total = (Double(raceTimeMinutes) ?? 0) * 60 + (Double(raceTimeSeconds) ?? 0)
            var target: Double?
            if !targetMinutes.isEmpty || !targetSeconds.isEmpty {
                target = (Double(targetMinutes) ?? 0) * 60 + (Double(targetSeconds) ?? 0)
            }
            let race = RaceResult(
                eventName: eventName.isEmpty ? "Race" : eventName,
                date: date,
                stroke: stroke,
                distanceMetres: distanceMetres,
                timeSeconds: total,
                targetTimeSeconds: target
            )
            store.addRace(race)
        }
        resetForm()
    }

    private func resetForm() {
        distance = ""; minutes = ""; seconds = ""; notes = ""
        eventName = ""; raceTimeMinutes = ""; raceTimeSeconds = ""
        targetMinutes = ""; targetSeconds = ""
    }
}

#Preview {
    LogSwimView()
        .environmentObject(SwimStore())
}
