import SwiftUI
import PhotosUI

struct VideoAnalysisView: View {
    @State private var stroke = Stroke.freestyle
    @State private var pickerItem: PhotosPickerItem?
    @State private var videoURL: URL?
    @State private var tips: [String] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let service = VideoAnalysisService()

    var body: some View {
        NavigationStack {
            Form {
                Picker("Stroke", selection: $stroke) {
                    ForEach(Stroke.allCases) { Text($0.rawValue).tag($0) }
                }

                PhotosPicker("Choose a clip", selection: $pickerItem, matching: .videos)

                if videoURL != nil {
                    Button("Analyse") { Task { await analyse() } }
                        .disabled(isLoading)
                }

                if isLoading {
                    ProgressView("Looking at your stroke")
                }

                if !tips.isEmpty {
                    Section("Tips") {
                        ForEach(tips, id: \.self) { tip in
                            Text(tip)
                        }
                    }
                }

                if let errorMessage {
                    Text(errorMessage).foregroundStyle(.red)
                }
            }
            .navigationTitle("Video analysis")
            .onChange(of: pickerItem) { _, newItem in
                Task { await loadVideo(from: newItem) }
            }
        }
    }

    private func loadVideo(from item: PhotosPickerItem?) async {
        guard let item else { return }
        tips = []
        errorMessage = nil
        do {
            guard let data = try await item.loadTransferable(type: Data.self) else { return }
            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("mov")
            try data.write(to: tempURL)
            videoURL = tempURL
        } catch {
            errorMessage = "Could not load that clip."
        }
    }

    private func analyse() async {
        guard let videoURL else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            tips = try await service.analyse(videoURL: videoURL, stroke: stroke)
        } catch {
            errorMessage = "Could not analyse the clip. Check your backend is running."
        }
    }
}

#Preview {
    VideoAnalysisView()
}
