import SwiftUI
import Charts

struct PaceTrendView: View {
    @EnvironmentObject private var store: SwimStore

    var body: some View {
        NavigationStack {
            VStack {
                if store.paceTrend.isEmpty {
                    ContentUnavailableView(
                        "No sessions yet",
                        systemImage: "chart.line.uptrend.xyaxis",
                        description: Text("Log a training session to see your pace trend.")
                    )
                } else {
                    Chart(store.paceTrend, id: \.date) { point in
                        LineMark(
                            x: .value("Date", point.date),
                            y: .value("Pace (min per 100 m)", point.pace)
                        )
                        PointMark(
                            x: .value("Date", point.date),
                            y: .value("Pace (min per 100 m)", point.pace)
                        )
                    }
                    .padding()
                }
            }
            .navigationTitle("Pace trend")
        }
    }
}

#Preview {
    PaceTrendView()
        .environmentObject(SwimStore())
}
