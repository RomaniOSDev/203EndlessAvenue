import SwiftUI

struct ConceptMapView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var selectedSourceID: String?
    @State private var showAddConnection = false
    @State private var connectionLabel = "related to"

    private var nodes: [(id: String, title: String, isTopic: Bool)] {
        store.mapNodes()
    }

    var body: some View {
        ZStack {
            PatternBackground()
            ScrollView([.horizontal, .vertical]) {
                VStack(alignment: .leading, spacing: 16) {
                ScreenHeader(
                    title: "Concept Map",
                    subtitle: "\(store.conceptConnections.count) connections"
                )

                if nodes.isEmpty {
                    EmptyStateView(
                        systemImage: "point.3.connected.trianglepath.dotted",
                        message: "Add topics to build your concept map"
                    )
                } else {
                    AppCard {
                        ZStack {
                            Canvas { context, size in
                                for connection in store.conceptConnections {
                                    guard let from = position(for: connection.sourceID, in: size),
                                          let to = position(for: connection.targetID, in: size) else { continue }
                                    var path = Path()
                                    path.move(to: from)
                                    path.addLine(to: to)
                                    context.stroke(path, with: .color(Color("AppAccent")), lineWidth: 2)
                                }
                            }

                            ForEach(Array(nodes.enumerated()), id: \.element.id) { index, node in
                                ConceptNodeView(
                                    title: node.title,
                                    isTopic: node.isTopic,
                                    isSelected: selectedSourceID == node.id
                                )
                                .position(defaultPosition(for: node.id, index: index))
                                .onTapGesture {
                                    HapticManager.lightTap()
                                    handleNodeTap(node.id)
                                }
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            store.updateNodePosition(
                                                node.id,
                                                position: NodePosition(x: value.location.x, y: value.location.y)
                                            )
                                        }
                                )
                            }
                        }
                        .frame(width: 320, height: 360)
                    }
                    .padding(.horizontal, 16)

                    if !store.conceptConnections.isEmpty {
                        SectionHeader(title: "Connections", trailing: "\(store.conceptConnections.count)")
                        LazyVStack(spacing: 10) {
                            ForEach(store.conceptConnections) { connection in
                                AppCard {
                                    HStack {
                                        IconBadge(systemName: "link", size: 36, filled: false)
                                        Text(connectionLabel(for: connection))
                                            .font(.caption)
                                            .foregroundStyle(Color("AppTextSecondary"))
                                            .lineLimit(2)
                                        Spacer()
                                        Button("Remove") {
                                            HapticManager.lightTap()
                                            store.removeConnection(connection.id)
                                        }
                                        .font(.caption.bold())
                                        .foregroundStyle(.red)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }

                    PrimaryButton(title: "Add Connection", icon: "plus.circle.fill") {
                        HapticManager.lightTap()
                        showAddConnection = true
                    }
                    .padding(16)
                }
                }
            }
            .padding(.bottom, 24)
            .appScrollStyle()
        }
        .appScreenStyle()
        .sheet(isPresented: $showAddConnection) {
            AddConnectionSheet(
                nodes: nodes,
                selectedSourceID: selectedSourceID,
                onSave: { source, target, label in
                    let success = store.addConnection(from: source, to: target, label: label)
                    if success {
                        HapticManager.mediumImpact()
                        SoundManager.playSuccess()
                    } else {
                        HapticManager.warning()
                    }
                    showAddConnection = false
                }
            )
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private func handleNodeTap(_ nodeID: String) {
        if let source = selectedSourceID, source != nodeID {
            _ = store.addConnection(from: source, to: nodeID)
            HapticManager.mediumImpact()
            SoundManager.playSuccess()
            selectedSourceID = nil
        } else {
            selectedSourceID = nodeID
        }
    }

    private func defaultPosition(for nodeID: String, index: Int) -> CGPoint {
        if let pos = store.nodePositions[nodeID] {
            return CGPoint(x: pos.x, y: pos.y)
        }
        let angle = Double(index) * 0.8
        return CGPoint(x: cos(angle) * 100 + 170, y: sin(angle) * 90 + 200)
    }

    private func position(for nodeID: String, in size: CGSize) -> CGPoint? {
        guard let pos = store.nodePositions[nodeID] else { return nil }
        return CGPoint(x: pos.x, y: pos.y)
    }

    private func connectionLabel(for connection: ConceptConnection) -> String {
        let nodes = store.mapNodes()
        let source = nodes.first { $0.id == connection.sourceID }?.title ?? "?"
        let target = nodes.first { $0.id == connection.targetID }?.title ?? "?"
        return "\(source) → \(connection.label) → \(target)"
    }
}

private struct ConceptNodeView: View {
    let title: String
    let isTopic: Bool
    let isSelected: Bool

    var body: some View {
        Text(title)
            .font(isTopic ? .caption.bold() : .caption2)
            .foregroundStyle(Color("AppTextPrimary"))
            .lineLimit(2)
            .minimumScaleFactor(0.7)
            .multilineTextAlignment(.center)
            .frame(width: isTopic ? 80 : 64, height: isTopic ? 80 : 64)
            .background(
                Circle()
                    .fill(
                        isSelected
                            ? LinearGradient(colors: [Color("AppAccent"), Color("AppPrimary")], startPoint: .topLeading, endPoint: .bottomTrailing)
                            : LinearGradient(colors: [isTopic ? Color("AppPrimary") : Color("AppSurface"), isTopic ? Color("AppAccent").opacity(0.7) : Color("AppBackground")], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
            )
            .overlay(
                Circle()
                    .stroke(isSelected ? Color("AppTextPrimary").opacity(0.5) : Color.clear, lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
    }
}

private struct AddConnectionSheet: View {
    let nodes: [(id: String, title: String, isTopic: Bool)]
    let selectedSourceID: String?
    let onSave: (String, String, String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var sourceID = ""
    @State private var targetID = ""
    @State private var label = "related to"

    var body: some View {
        NavigationStack {
            ZStack {
                PatternBackground()
                Form {
                    Picker("From", selection: $sourceID) {
                        ForEach(nodes, id: \.id) { node in
                            Text(node.title).tag(node.id)
                        }
                    }
                    Picker("To", selection: $targetID) {
                        ForEach(nodes, id: \.id) { node in
                            Text(node.title).tag(node.id)
                        }
                    }
                    TextField("Label", text: $label)
                }
                .scrollContentBackground(.hidden)
                .appScrollStyle()
            }
            .appScreenStyle()
            .navigationTitle("New Connection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        onSave(sourceID, targetID, label)
                        dismiss()
                    }
                }
            }
            .onAppear {
                if let selectedSourceID { sourceID = selectedSourceID }
                if sourceID.isEmpty, let first = nodes.first { sourceID = first.id }
                if targetID.isEmpty, nodes.count > 1 { targetID = nodes[1].id }
            }
        }
    }
}
