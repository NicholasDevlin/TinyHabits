# TinyWins - Atomic Habit Tracker

A beautiful, offline-first habit tracking app built with Flutter following clean architecture principles.

## Features

- ✅ **Offline-first**: All data stored locally using Drift (SQLite)
- 🎯 **Daily habit tracking**: Mark habits as complete with satisfying animations
<img width="200" alt="image" src="https://github.com/user-attachments/assets/c4500e25-b793-4083-acdb-7040b241921e" />

- 📊 **Statistics**: Track streaks and total completions
- 📅 **Calendar view**: Visual progress tracking with monthly calendar
<img width="200" alt="image" src="https://github.com/user-attachments/assets/429ed48c-0790-4feb-bff3-58365178d10c" />

- ⏰ **Smart reminders**: Customizable notification times for each habit
- 🎨 **Modern UI**: Clean design with light cyan theme and rounded corners
<img width="200" alt="image" src="https://github.com/user-attachments/assets/6af0395c-edac-43e0-8c21-9771dd18fb20" />
<img width="200" alt="image" src="https://github.com/user-attachments/assets/ded00e1b-1cdf-4efd-a78a-e3ff97387e64" />
<img width="200" alt="image" src="https://github.com/user-attachments/assets/6a92d47f-d939-49f5-85dc-229673f57b2d" />


## Tech Stack

- **Framework**: Flutter (Latest Stable)
- **State Management**: Riverpod with code generation
- **Database**: Drift (Room equivalent for Flutter)
- **Notifications**: flutter_local_notifications
- **Architecture**: Clean Architecture (Presentation, Domain, Data layers)
- **UI**: Material Design 3 with custom theme

## Getting Started

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Generate code:**
   ```bash
   flutter packages pub run build_runner build
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── core/
│   ├── app_theme.dart          # App-wide theme and colors
│   ├── database/               # Database setup and configuration
│   │   ├── app_database.dart   # Main database class
│   │   ├── tables/             # Database table definitions
│   │   └── daos/              # Data access objects
│   ├── services/              # App services
│   └── utils/                 # Utility functions
├── features/
│   └── habit/
│       ├── data/              # Data layer
│       ├── domain/            # Business logic layer
│       └── presentation/      # UI layer
└── main.dart                  # App entry point
```

## Key Features Implementation

### 🎯 Habit Tracking
- Create habits with custom schedules (specific days or everyday)
- Set reminder times for notifications
- Mark habits as complete with micro-interactions

### 📊 Statistics
- **Current Streak**: Consecutive days completed
- **Total Completions**: Overall completion count
- Real-time calculation from database entries

### 📅 Calendar View
- Monthly calendar with completion highlights
- Primary color (#85d8ea) marks for completed days
- Easy visual progress tracking

### 🔔 Smart Notifications
- Daily reminders at custom times
- Scheduled only for target days
- Handles app restarts and device reboots

## Design System

### Color Palette
- **Primary**: #85d8ea (Light Cyan/Blue) - Active states and highlights
- **Secondary**: #546a7b (Blue Grey) - Text and inactive elements
- **Background**: White/Light grey for contrast
- **Success**: Green for completions
- **Error**: Red for destructive actions

### UI Guidelines
- 12-16px rounded corners for friendly feel
- Hero animations between screens
- Satisfying micro-interactions for habit completion
- Material Design 3 components

## Database Schema

### Habits Table
- `id`: Primary key
- `title`: Habit name
- `description`: Optional motivation text
- `reminderTime`: Time in "HH:mm" format
- `targetDays`: Comma-separated days (1-7)
- `createdAt`: Timestamp

### HabitEntries Table
- `id`: Primary key
- `habitId`: Foreign key to habits
- `date`: Date (time stripped)
- `isCompleted`: Boolean completion status

## Performance Optimizations

- Lazy database connection initialization
- Efficient streak calculation algorithms
- Provider invalidation for reactive UI updates
- Background database operations

## Future Enhancements

- Export/import data functionality
- Habit categories and tags
- Advanced statistics and insights
- Social features and sharing
- Widget support for home screen
- Dark mode support

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes following the existing architecture
4. Add tests for new features
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
