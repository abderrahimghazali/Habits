//
//  SettingsView.swift
//  Habits
//
//  Created by Abderrahim on 15/08/2025.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var habitStore: HabitDataStore
    @Environment(\.dismiss) private var dismiss
    @State private var showingAddHabit = false
    
    var body: some View {
        NavigationView {
            List {
                Section("Habit Reminders") {
                    ForEach(habitStore.habitTypes) { habitType in
                        NavigationLink(destination: HabitDetailView(habitType: habitType, habitStore: habitStore)) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(habitType.name)
                                    .font(.headline)
                                
                                if habitType.reminders.isEmpty {
                                    Text("No reminders set")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                } else {
                                    Text("\(habitType.reminders.count) reminder\(habitType.reminders.count == 1 ? "" : "s")")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .onDelete(perform: deleteHabit)
                    
                    Button(action: {
                        showingAddHabit = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                            Text("Add New Habit")
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingAddHabit) {
                AddHabitView(habitStore: habitStore)
            }
        }
    }
    
    private func deleteHabit(at offsets: IndexSet) {
        for index in offsets {
            habitStore.deleteHabitType(habitStore.habitTypes[index])
        }
    }
}

struct AddHabitView: View {
    @ObservedObject var habitStore: HabitDataStore
    @Environment(\.dismiss) private var dismiss
    @State private var habitName = ""
    @State private var reminders: [ReminderTime] = []
    
    var body: some View {
        NavigationView {
            Form {
                Section("Habit Details") {
                    TextField("Habit name (e.g., Take medicine, Brush teeth)", text: $habitName)
                }
                
                Section("Reminders") {
                    ForEach(reminders.indices, id: \.self) { index in
                        HStack {
                            DatePicker("Time", selection: Binding(
                                get: { reminderDate(reminders[index]) },
                                set: { newValue in
                                    updateReminder(at: index, with: newValue)
                                }
                            ), displayedComponents: .hourAndMinute)
                            
                            Button("Remove") {
                                reminders.remove(at: index)
                            }
                            .foregroundColor(.red)
                        }
                    }
                    
                    Button("Add Reminder") {
                        let newReminder = ReminderTime(hour: 9, minute: 0)
                        reminders.append(newReminder)
                    }
                }
            }
            .navigationTitle("New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveHabit()
                    }
                    .disabled(habitName.isEmpty)
                }
            }
        }
    }
    
    private func reminderDate(_ reminder: ReminderTime) -> Date {
        Calendar.current.date(bySettingHour: reminder.hour, minute: reminder.minute, second: 0, of: Date()) ?? Date()
    }
    
    private func updateReminder(at index: Int, with date: Date) {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        reminders[index] = ReminderTime(hour: components.hour ?? 9, minute: components.minute ?? 0)
    }
    
    private func saveHabit() {
        let newHabit = HabitType(name: habitName, reminders: reminders)
        habitStore.addHabitType(newHabit)
        dismiss()
    }
}

struct HabitDetailView: View {
    @State var habitType: HabitType
    @ObservedObject var habitStore: HabitDataStore
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Form {
            Section("Habit Details") {
                TextField("Habit name", text: $habitType.name)
                Toggle("Enable notifications", isOn: $habitType.isEnabled)
            }
            
            Section("Reminders") {
                ForEach(habitType.reminders.indices, id: \.self) { index in
                    HStack {
                        DatePicker("Time", selection: Binding(
                            get: { reminderDate(habitType.reminders[index]) },
                            set: { newValue in
                                updateReminderInDetail(at: index, with: newValue)
                            }
                        ), displayedComponents: .hourAndMinute)
                        
                        Toggle("", isOn: $habitType.reminders[index].isEnabled)
                    }
                }
                .onDelete(perform: deleteReminder)
                
                Button("Add Reminder") {
                    let newReminder = ReminderTime(hour: 9, minute: 0)
                    habitType.reminders.append(newReminder)
                }
            }
        }
        .navigationTitle(habitType.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    habitStore.updateHabitType(habitType)
                    dismiss()
                }
            }
        }
    }
    
    private func reminderDate(_ reminder: ReminderTime) -> Date {
        Calendar.current.date(bySettingHour: reminder.hour, minute: reminder.minute, second: 0, of: Date()) ?? Date()
    }
    
    private func updateReminderInDetail(at index: Int, with date: Date) {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        habitType.reminders[index] = ReminderTime(hour: components.hour ?? 9, minute: components.minute ?? 0)
    }
    
    private func deleteReminder(at offsets: IndexSet) {
        habitType.reminders.remove(atOffsets: offsets)
    }
}

#Preview {
    SettingsView(habitStore: HabitDataStore())
}