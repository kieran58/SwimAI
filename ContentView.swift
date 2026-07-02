import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HistoryView()
                .tabItem { Label("History", systemImage: "clock") }

            LogSwimView()
                .tabItem { Label("Log", systemImage: "plus.circle") }

            PaceTrendView()
                .tabItem { Label("Trends", systemImage: "chart.line.uptrend.xyaxis") }

            CoachView()
                .tabItem { Label("Coach", systemImage: "figure.pool.swim") }

            VideoAnalysisView()
                .tabItem { Label("Video", systemImage: "video") }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(SwimStore())
}
