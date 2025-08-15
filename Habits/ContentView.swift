//
//  ContentView.swift
//  Habits
//
//  Created by Abderrahim on 15/08/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var habitStore = HabitDataStore()
    @State private var selectedDate: Date?
    @State private var showDayDetail = false
    @State private var showSettings = false
    @State private var selectedHabitType: HabitType?
    @State private var showHabitPicker = false
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Habits")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {
                    showSettings = true
                }) {
                    Image(systemName: "gearshape.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
            
            // Contribution Chart - 3 Months Progress
            InteractiveContributionChart(
                data: habitStore.getThreeMonthsData(),
                rows: 7,
                columns: 13,
                targetValue: 1.0,
                blockColor: .green,
                blockBackgroundColor: Color.background,
                rectangleWidth: 16.0,
                rectangleSpacing: 2.0,
                rectangleRadius: 3.0,
                onDayTapped: { dayIndex in
                    let chartData = habitStore.getThreeMonthsData()
                    if dayIndex < chartData.count && chartData[dayIndex] >= 0 {
                        selectedDate = getDateForIndex(dayIndex)
                        showDayDetail = true
                    }
                }
            )
            .frame(height: 140)
            
            // Logging Buttons
            habitPickerButtonView
            
            // GitHub-style commit view
            todayCommitsView
            
            Spacer()
        }
        .padding()
        .sheet(isPresented: $showDayDetail) {
            if let date = selectedDate {
                DayDetailView(date: date, habitStore: habitStore)
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(habitStore: habitStore)
        }
        .actionSheet(isPresented: $showHabitPicker) {
            ActionSheet(
                title: Text("Select Habit to Log"),
                buttons: habitStore.habitTypes.map { habitType in
                    .default(Text(habitType.name)) {
                        habitStore.logHabitSession(habitType: habitType)
                    }
                } + [.cancel()]
            )
        }
    }
    
    private var todayCommitsView: some View {
        let todayHabitSessions = habitStore.getTodayHabitSessions()
        
        return VStack(alignment: .leading, spacing: 12) {
            if todayHabitSessions.isEmpty {
                HStack {
                    Image(systemName: "circle.dotted")
                        .foregroundColor(.gray)
                    Text("No habits logged today")
                        .foregroundColor(.gray)
                    Spacer()
                }
                .padding()
                .background(Color.secondaryBackground)
                .cornerRadius(8)
            } else {
                ForEach(todayHabitSessions, id: \.id) { session in
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(session.habitName) logged")
                                .font(.system(size: 14, weight: .medium))
                            Text("at \(formatTime(session.date))")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color.secondaryBackground)
                    .cornerRadius(8)
                }
            }
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func getDateForIndex(_ index: Int) -> Date {
        let calendar = Calendar.current
        let now = Date()
        let lastMonth = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        let startDate = calendar.dateInterval(of: .month, for: lastMonth)?.start ?? lastMonth
        let startDayOfWeek = calendar.component(.weekday, from: startDate) - 1
        
        let adjustedIndex = index - startDayOfWeek
        return calendar.date(byAdding: .day, value: adjustedIndex, to: startDate) ?? startDate
    }
    
    private var habitPickerButtonView: some View {
        Button(action: {
            if habitStore.habitTypes.count == 1 {
                habitStore.logHabitSession(habitType: habitStore.habitTypes.first!)
            } else {
                showHabitPicker = true
            }
        }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                Text("Log Habit")
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue.opacity(0.2))
            .foregroundColor(.blue)
            .cornerRadius(10)
        }
    }
}

struct DayDetailView: View {
    let date: Date
    let habitStore: HabitDataStore
    @Environment(\.dismiss) private var dismiss
    
    private var dayData: DayData? {
        habitStore.getDayData(for: date)
    }
    
    private var sessions: [HabitSession] {
        return dayData?.sessions.sorted { $0.date < $1.date } ?? []
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text(formatDate(date))
                    .font(.title2)
                    .fontWeight(.semibold)
                
                if sessions.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "circle.dotted")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        Text("No habits logged on this day")
                            .foregroundColor(.gray)
                    }
                    .padding()
                } else {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("\(sessions.count) habit\(sessions.count == 1 ? "" : "s") logged")
                            .font(.headline)
                            .padding(.bottom, 8)
                        
                        ForEach(sessions, id: \.id) { session in
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("\(session.habitName) logged")
                                        .font(.system(size: 16, weight: .medium))
                                    Text("at \(formatTime(session.date))")
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                            }
                            .padding()
                            .background(Color.secondaryBackground)
                            .cornerRadius(8)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Day Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    ContentView()
}
