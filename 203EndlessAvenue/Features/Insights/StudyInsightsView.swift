import SwiftUI
import Charts

struct StudyInsightsView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var chartRange = 7

    private var activityData: [(date: Date, count: Int)] {
        store.activityForLastDays(chartRange).map { item in
            (item.date, item.activity.cardsReviewed + item.activity.quizzesCompleted)
        }
    }

    var body: some View {
        ZStack {
            PatternBackground()
            ScrollView {
                VStack(spacing: 16) {
                ScreenHeader(title: "Study Insights", subtitle: "Track your learning patterns")

                Picker("Range", selection: $chartRange) {
                    Text("7 Days").tag(7)
                    Text("30 Days").tag(30)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)

                AppCard {
                    VStack(alignment: .leading, spacing: 14) {
                        SectionHeader(title: "Activity", trailing: "\(chartRange)d")
                        if activityData.allSatisfy({ $0.count == 0 }) {
                            Text("No activity recorded yet")
                                .font(.caption)
                                .foregroundStyle(Color("AppTextSecondary"))
                                .frame(maxWidth: .infinity, minHeight: 120)
                        } else {
                            Chart(activityData, id: \.date) { item in
                                BarMark(
                                    x: .value("Day", item.date, unit: .day),
                                    y: .value("Actions", item.count)
                                )
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color("AppPrimary"), Color("AppAccent")],
                                        startPoint: .bottom,
                                        endPoint: .top
                                    )
                                )
                                .cornerRadius(6)
                            }
                            .frame(height: 180)
                            .chartXAxis {
                                AxisMarks(values: .automatic) { _ in
                                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                                        .foregroundStyle(Color("AppTextSecondary").opacity(0.2))
                                    AxisValueLabel(format: .dateTime.day().month(.narrow))
                                        .foregroundStyle(Color("AppTextSecondary"))
                                }
                            }
                            .chartYAxis {
                                AxisMarks { _ in
                                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                                        .foregroundStyle(Color("AppTextSecondary").opacity(0.2))
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    StatTile(
                        title: "Avg Quiz Score",
                        value: store.completedQuizzes.isEmpty ? "—" : "\(store.averageQuizScore)%",
                        icon: "percent"
                    )
                    StatTile(title: "Best Study Day", value: store.bestStudyWeekday, icon: "calendar")
                    StatTile(
                        title: "Weakest Topic",
                        value: store.weakestTopic?.title ?? "—",
                        icon: "arrow.down.circle"
                    )
                    StatTile(
                        title: "Weakest %",
                        value: store.weakestTopic.map { "\(Int($0.progressPercentage))%" } ?? "—",
                        icon: "chart.bar"
                    )
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
                }
            }
            .appScrollStyle()
        }
        .appScreenStyle()
        .navigationBarTitleDisplayMode(.inline)
    }
}
