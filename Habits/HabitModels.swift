//
//  HabitModels.swift
//  Habits
//
//  Created by Abderrahim on 15/08/2025.
//

import Foundation

struct HabitType: Codable, Identifiable {
    let id = UUID()
    var name: String
    var reminders: [ReminderTime]
    var isEnabled: Bool = true
    
    init(name: String, reminders: [ReminderTime] = []) {
        self.name = name
        self.reminders = reminders
    }
}

struct ReminderTime: Codable, Identifiable {
    let id = UUID()
    var hour: Int
    var minute: Int
    var isEnabled: Bool = true
    
    init(hour: Int, minute: Int) {
        self.hour = hour
        self.minute = minute
    }
    
    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let date = Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) ?? Date()
        return formatter.string(from: date)
    }
}

struct HabitSession: Codable {
    let id = UUID()
    let date: Date
    let habitTypeId: UUID
    let habitName: String
    
    init(date: Date = Date(), habitTypeId: UUID, habitName: String) {
        self.date = date
        self.habitTypeId = habitTypeId
        self.habitName = habitName
    }
}

struct DayData: Codable {
    let date: Date
    var sessions: [HabitSession]
    
    init(date: Date) {
        self.date = date
        self.sessions = []
    }
    
    var completionValue: Double {
        // Each session contributes 0.5, capped at 1.0 for display purposes
        let value = Double(sessions.count) * 0.5
        return min(value, 1.0)
    }
    
    var sessionCount: Int {
        return sessions.count
    }
    
    func sessions(for habitTypeId: UUID) -> [HabitSession] {
        return sessions.filter { $0.habitTypeId == habitTypeId }
    }
}