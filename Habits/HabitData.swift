//
//  HabitData.swift
//  Habits
//
//  Created by Abderrahim on 15/08/2025.
//

import Foundation
import UserNotifications

class HabitDataStore: ObservableObject {
    @Published var habitSessions: [String: DayData] = [:]
    @Published var habitTypes: [HabitType] = []
    private let userDefaults = UserDefaults.standard
    private let saveKey = "HabitSessions"
    private let habitTypesKey = "HabitTypes"
    
    init() {
        loadData()
        setupDefaultHabits()
        requestNotificationPermission()
    }
    
    func logHabitSession(habitType: HabitType, date: Date = Date()) {
        let dateKey = dateKey(for: date)
        
        if habitSessions[dateKey] == nil {
            habitSessions[dateKey] = DayData(date: date)
        }
        
        // Add a new habit session
        let session = HabitSession(date: date, habitTypeId: habitType.id, habitName: habitType.name)
        habitSessions[dateKey]?.sessions.append(session)
        
        saveData()
    }
    
    func addHabitType(_ habitType: HabitType) {
        habitTypes.append(habitType)
        saveHabitTypes()
        scheduleNotifications(for: habitType)
    }
    
    func updateHabitType(_ habitType: HabitType) {
        if let index = habitTypes.firstIndex(where: { $0.id == habitType.id }) {
            habitTypes[index] = habitType
            saveHabitTypes()
            scheduleNotifications(for: habitType)
        }
    }
    
    func deleteHabitType(_ habitType: HabitType) {
        habitTypes.removeAll { $0.id == habitType.id }
        saveHabitTypes()
        cancelNotifications(for: habitType)
    }
    
    private func setupDefaultHabits() {
        if habitTypes.isEmpty {
            let defaultHabit = HabitType(name: "General Habit")
            habitTypes.append(defaultHabit)
            saveHabitTypes()
        }
    }
    
    func getThreeMonthsData() -> [Double] {
        let calendar = Calendar.current
        let now = Date()
        
        // Get last month, current month, next month
        let lastMonth = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        let nextMonth = calendar.date(byAdding: .month, value: 1, to: now) ?? now
        
        // Get the start of last month and end of next month
        let startDate = calendar.dateInterval(of: .month, for: lastMonth)?.start ?? lastMonth
        let endDate = calendar.dateInterval(of: .month, for: nextMonth)?.end ?? nextMonth
        
        // Calculate total days from start of last month to end of next month
        let totalDays = calendar.dateComponents([.day], from: startDate, to: endDate).day!
        
        var data: [Double] = []
        
        // Get the day of week for the start date (0 = Sunday, 1 = Monday, etc.)
        let startDayOfWeek = calendar.component(.weekday, from: startDate) - 1 // Convert to 0-based
        
        // Add padding at the beginning to align the first date with the correct day of week
        for _ in 0..<startDayOfWeek {
            data.append(-1.0) // Empty cells before the start date
        }
        
        // Get data for each day from start of last month to end of next month
        for i in 0..<totalDays {
            let date = calendar.date(byAdding: .day, value: i, to: startDate) ?? startDate
            let key = dateKey(for: date)
            let dayData = habitSessions[key]
            
            // Determine if this is a past, current, or future date
            if date > now {
                // Future dates (next month) - show as empty
                data.append(-1.0)
            } else {
                // Past and current dates - show actual data
                let completionValue = dayData?.completionValue ?? 0.0
                data.append(completionValue)
            }
        }
        
        // Pad to fill complete weeks (7 rows * 13 weeks = 91 cells for 3 months)
        let requiredElements = 91
        while data.count < requiredElements {
            data.append(-1.0) // Empty cells to complete the grid
        }
        
        // If we have more data than needed, take the first elements
        if data.count > requiredElements {
            data = Array(data.prefix(requiredElements))
        }
        
        return data
    }
    
    func getTodaySessionCount() -> Int {
        let today = dateKey(for: Date())
        let dayData = habitSessions[today]
        return dayData?.sessionCount ?? 0
    }
    
    func getDayData(for date: Date) -> DayData? {
        let key = dateKey(for: date)
        return habitSessions[key]
    }
    
    func getTodayHabitSessions() -> [HabitSession] {
        let today = dateKey(for: Date())
        let dayData = habitSessions[today]
        return dayData?.sessions.sorted { $0.date < $1.date } ?? []
    }
    
    private func dateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    private func saveData() {
        if let encoded = try? JSONEncoder().encode(habitSessions) {
            userDefaults.set(encoded, forKey: saveKey)
        }
    }
    
    private func saveHabitTypes() {
        if let encoded = try? JSONEncoder().encode(habitTypes) {
            userDefaults.set(encoded, forKey: habitTypesKey)
        }
    }
    
    private func loadData() {
        guard let data = userDefaults.data(forKey: saveKey),
              let decoded = try? JSONDecoder().decode([String: DayData].self, from: data) else {
            return
        }
        habitSessions = decoded
        
        // Load habit types
        guard let habitTypesData = userDefaults.data(forKey: habitTypesKey),
              let decodedHabitTypes = try? JSONDecoder().decode([HabitType].self, from: habitTypesData) else {
            return
        }
        habitTypes = decodedHabitTypes
    }
    
    // MARK: - Notification Methods
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else {
                print("Notification permission denied")
            }
        }
    }
    
    private func scheduleNotifications(for habitType: HabitType) {
        cancelNotifications(for: habitType)
        
        guard habitType.isEnabled else { return }
        
        for reminder in habitType.reminders where reminder.isEnabled {
            let content = UNMutableNotificationContent()
            content.title = "Habit Reminder"
            content.body = "Time to \(habitType.name.lowercased())"
            content.sound = .default
            
            var dateComponents = DateComponents()
            dateComponents.hour = reminder.hour
            dateComponents.minute = reminder.minute
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let identifier = "\(habitType.id)-\(reminder.id)"
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error)")
                }
            }
        }
    }
    
    private func cancelNotifications(for habitType: HabitType) {
        let identifiers = habitType.reminders.map { "\(habitType.id)-\($0.id)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
}