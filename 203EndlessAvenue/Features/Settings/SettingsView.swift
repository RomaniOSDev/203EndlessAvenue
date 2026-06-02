import SwiftUI
import UIKit
import StoreKit
import UniformTypeIdentifiers

struct SettingsView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var showResetAlert = false
    @State private var showImportPicker = false
    @State private var showImportAlert = false
    @State private var importSuccess = false
    @State private var exportDocument: ExportDocument?

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PatternBackground()
                ScrollView {
                    VStack(spacing: 16) {
                    ScreenHeader(title: "Settings", subtitle: "Data & preferences")

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        StatTile(title: "Entries", value: "\(store.totalCards)", icon: "square.stack.3d.up.fill")
                        StatTile(title: "Minutes", value: "\(store.totalMinutesUsed)", icon: "clock.fill")
                        StatTile(title: "Streak", value: "\(store.streakDays)d", icon: "flame.fill")
                        StatTile(title: "Sessions", value: "\(store.totalSessionsCompleted)", icon: "play.circle.fill")
                    }
                    .padding(.horizontal, 16)

                    VStack(spacing: 10) {
                        SettingsCell(title: "Export All Data", icon: "square.and.arrow.up") {
                            prepareExport()
                        }
                        SettingsCell(title: "Import Data", icon: "square.and.arrow.down") {
                            showImportPicker = true
                        }
                        SettingsCell(title: "Reset All Data", icon: "trash.fill", isDestructive: true) {
                            showResetAlert = true
                        }
                    }
                    .padding(.horizontal, 16)

                    SectionHeader(title: "Legal")

                    VStack(spacing: 10) {
                        SettingsCell(title: "Rate Us", icon: "star.fill") {
                            rateApp()
                        }
                        SettingsCell(title: "Privacy", icon: "hand.raised.fill") {
                            openPrivacyPolicy()
                        }
                        SettingsCell(title: "Terms", icon: "doc.text.fill") {
                            openTermsOfService()
                        }
                    }
                    .padding(.horizontal, 16)

                    Text("Version \(appVersion)")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .frame(maxWidth: .infinity)
                        .padding(.top, 8)
                        .padding(.bottom, 24)
                    }
                }
                .appScrollStyle()
            }
            .appScreenStyle()
            .navigationBarHidden(true)
            .sheet(item: $exportDocument) { doc in
                ShareSheet(items: [doc.url])
            }
            .fileImporter(
                isPresented: $showImportPicker,
                allowedContentTypes: [.json],
                allowsMultipleSelection: false
            ) { result in
                handleImport(result)
            }
            .alert("Reset All Data?", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) { HapticManager.lightTap() }
                Button("Reset", role: .destructive) {
                    HapticManager.mediumImpact()
                    store.resetAllData()
                }
            } message: {
                Text("This will permanently delete all topics, progress, and achievements.")
            }
            .alert(importSuccess ? "Import Complete" : "Import Failed", isPresented: $showImportAlert) {
                Button("OK", role: .cancel) { HapticManager.lightTap() }
            } message: {
                Text(importSuccess ? "Your data was imported successfully." : "Could not read the selected file.")
            }
        }
    }

    private func prepareExport() {
        guard let data = store.exportJSON() else {
            HapticManager.warning()
            return
        }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("learnsphere-backup.json")
        do {
            try data.write(to: url)
            exportDocument = ExportDocument(url: url)
            HapticManager.mediumImpact()
            SoundManager.playSuccess()
        } catch {
            HapticManager.warning()
        }
    }

    private func handleImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first, url.startAccessingSecurityScopedResource() else {
                importSuccess = false
                showImportAlert = true
                return
            }
            defer { url.stopAccessingSecurityScopedResource() }
            if let data = try? Data(contentsOf: url), store.importJSON(data) {
                importSuccess = true
                HapticManager.success()
                SoundManager.playSuccess()
            } else {
                importSuccess = false
                HapticManager.warning()
            }
            showImportAlert = true
        case .failure:
            importSuccess = false
            showImportAlert = true
        }
    }

    private func openPrivacyPolicy() {
        HapticManager.lightTap()
        if let url = AppLegalURL.privacyPolicy.url {
            UIApplication.shared.open(url)
        }
    }

    private func openTermsOfService() {
        HapticManager.lightTap()
        if let url = AppLegalURL.termsOfService.url {
            UIApplication.shared.open(url)
        }
    }

    private func rateApp() {
        HapticManager.lightTap()
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}

private struct ExportDocument: Identifiable {
    let id = UUID()
    let url: URL
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
