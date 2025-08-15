# Habits

A simple and elegant habit tracking app for iOS that helps you build and maintain daily routines with visual progress tracking and smart notifications.

## Features

### 📊 Visual Progress Tracking
- **3-month contribution chart** showing your habit consistency over time
- **Color-coded visualization**: Grey (no activity), Light green (some activity), Green (full activity)
- **Interactive chart**: Tap any day to see detailed logs for that date
- **GitHub-style interface** for familiar and intuitive progress viewing

### 🔔 Smart Notifications
- **Custom reminder times** for each habit (e.g., 3 times daily for medicine, 2 times for brushing teeth)
- **Personalized notifications** with habit-specific messages
- **Flexible scheduling** - set as many reminders as needed per habit
- **Easy management** - enable/disable notifications per habit or per reminder

### 📝 Multi-Habit Support
- **Unlimited habits** - track medicine, exercise, reading, or any custom routine
- **Named logging** - see exactly which habit was completed at what time
- **Instant logging** - single tap to log when you have one habit, picker for multiple
- **Detailed history** - view all sessions for any day with timestamps

### ⚙️ Simple Settings
- **Easy setup** - add new habits with custom names and reminder schedules
- **Time management** - set specific times for each reminder
- **Habit organization** - edit, enable/disable, or delete habits as needed

## Screenshots

### Main App View
<img src="https://i.imgur.com/itx57mx.png" alt="Main App" width="30%">

### Habit Selection
<img src="https://i.imgur.com/3sOgKmP.png" alt="Habit Logging" width="30%">

### Settings & Configuration
<img src="https://i.imgur.com/lug7mv3.png" alt="Settings" width="30%">

## How It Works

1. **Set up your habits** - Tap the settings gear to add habits like "Take medicine" or "Brush teeth"
2. **Configure reminders** - Set custom notification times for each habit
3. **Log your activities** - Tap "Log Habit" when you complete an activity
4. **Track your progress** - Watch your contribution chart fill up as you build consistency
5. **Stay motivated** - Use the visual feedback to maintain your streaks

## Perfect For

- 💊 **Medication reminders** - Never miss a dose with multiple daily notifications
- 🦷 **Personal hygiene** - Build consistent routines like brushing teeth
- 💧 **Health habits** - Track water intake, vitamins, or supplements
- 📚 **Learning routines** - Reading, language practice, or skill development
- 🏃 **Fitness goals** - Exercise, stretching, or movement reminders

## Installation

This is a native iOS app built with SwiftUI. 

1. Clone the repository
2. Run `xcodegen generate` to generate the Xcode project files
3. Open the generated `.xcodeproj` file in Xcode
4. Build and run on your device

## Built With

- **SwiftUI** - Modern iOS user interface
- **UserNotifications** - Smart reminder system
- **UserDefaults** - Local data persistence