import SwiftUI

struct CoachView: View {
    @EnvironmentObject private var store: SwimStore
    @State private var stroke = Stroke.freestyle
    @State private var tip: String?
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let service = CoachService()

    var body: some View {
        NavigationStack {
            Form {
                Picker("Stroke", selection: $stroke) {
                    ForEach(Stroke.allCases) { Text($0.rawValue).tag($0) }
                }

                Section("Tip") {
                    if isLoading {
                        ProgressView()
                    } else if let tip {
                        Text(tip)
                    } else if let errorMessage {
                        Text(errorMessage).foregroundStyle(.red)
                    } else {
                        Text("Ask for a tip on your chosen stroke.")
                            .foregroundStyle(.secondary)
                    }
                }

                Button("Get a tip") { Task { await getTip() } }
                    .disabled(isLoading)
            }
            .navigationTitle("Coach")
        }
    }

    private func getTip() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        let recentPace = store.paceTrend.last?.pace
        do {
            tip = try await service.fetchTip(forStroke: stroke, recentPace: recentPace)
        } catch {
            errorMessage = "Could not fetch a tip. Check your backend is running."
        }
    }
}

#Preview {
    CoachView()
        .environmentObject(SwimStore())
}
