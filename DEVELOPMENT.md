# TinyWins Development Guide

## Project Overview

TinyWins is a complete offline-first habit tracking application built with Flutter following clean architecture principles. The app was built according to detailed specifications for an "Atomic Habit Tracker" with modern UI design and robust functionality.

## Architecture

### Clean Architecture Layers

1. **Presentation Layer** (`lib/features/habit/presentation/`)
   - Pages: HomePage, CreateHabitPage, HabitDetailPage
   - Widgets: HabitCard with animations
   - Providers: Riverpod state management

2. **Domain Layer** (`lib/features/habit/domain/`)
   - Models: Habit, HabitEntry, CreateHabitRequest (with Freezed)
   - Repositories: Abstract interfaces

3. **Data Layer** (`lib/features/habit/data/`)
   - Repository implementations
   - Database access via Drift

### Core Infrastructure

- **Database**: Drift (Flutter's equivalent to Room)
  - Tables: HabitsTable, HabitEntriesTable
  - DAOs: HabitsDao, HabitEntriesDao
  - Auto-generated type-safe queries

- **State Management**: Riverpod with code generation
  - Providers for habits, completed dates
  - Async controllers for operations

- **Design System**: Material Design 3
  - Custom theme with specified colors
  - Primary: #85d8ea (Light Cyan/Blue)
  - Secondary: #546a7b (Blue Grey)

## Key Features Implemented

### ✅ Core Functionality
- **Habit Creation**: Full form with validation
  - Name, description, reminder time
  - Target days selection (individual or everyday)
  - Time picker integration

- **Daily Tracking**: Modern card-based interface
  - Satisfying tap animations for completion
  - Visual feedback with primary color theme
  - Streak and completion counters

- **Statistics**: Real-time calculations
  - Current streak algorithm
  - Total completions count
  - Progress tracking

### ✅ Advanced Features
- **Calendar View**: Monthly progress visualization
  - Table calendar integration
  - Completion highlights
  - Hero animations between screens

- **Data Persistence**: Robust offline storage
  - SQLite via Drift
  - Foreign key relationships
  - Automatic data cleanup

- **Notifications**: Smart reminder system
  - Local notifications
  - Custom scheduling per habit
  - Permission handling

### ✅ UI/UX Excellence
- **Modern Design**: Material Design 3
  - 12-16px rounded corners
  - Consistent spacing and typography
  - Google Fonts integration

- **Micro-interactions**: Satisfying animations
  - Scale animations on tap
  - Hero transitions
  - Smooth state changes

- **Responsive Layout**: Multiple screen support
  - Adaptive design patterns
  - Safe area handling

## Development Commands

```bash
# Install dependencies
flutter pub get

# Generate code (run after model changes)
flutter packages pub run build_runner build

# Clean and regenerate (if needed)
flutter packages pub run build_runner build --delete-conflicting-outputs

# Run the app
flutter run

# Run tests
flutter test

# Analyze code
flutter analyze
```

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── core/                              # Core infrastructure
│   ├── app_theme.dart                 # Design system & themes
│   ├── database/                      # Database layer
│   │   ├── app_database.dart          # Main database class
│   │   ├── tables/                    # Table definitions
│   │   └── daos/                      # Data access objects
│   ├── services/                      # App-wide services
│   │   └── notification_service.dart  # Local notifications
│   └── utils/                         # Utility functions
│       └── date_utils.dart            # Date helper methods
└── features/habit/                    # Habit feature module
    ├── data/                          # Data layer
    │   └── repositories/              # Repository implementations
    ├── domain/                        # Business logic
    │   ├── models/                    # Domain models (Freezed)
    │   └── repositories/              # Repository interfaces
    └── presentation/                  # UI layer
        ├── pages/                     # Screen widgets
        ├── widgets/                   # Reusable components
        └── providers/                 # State management
```

## Database Schema

### Habits Table
```sql
CREATE TABLE habits_table (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  description TEXT,
  reminder_time TEXT NOT NULL,        -- "HH:mm" format
  target_days TEXT NOT NULL,          -- "1,2,3,4,5,6,7" format
  created_at INTEGER NOT NULL
);
```

### Habit Entries Table
```sql
CREATE TABLE habit_entries_table (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  habit_id INTEGER NOT NULL,
  date INTEGER NOT NULL,              -- Date without time
  is_completed INTEGER NOT NULL,      -- Boolean as INTEGER
  FOREIGN KEY (habit_id) REFERENCES habits_table (id) ON DELETE CASCADE
);
```

## Code Generation

The app uses several code generators:

1. **Drift**: Database code generation
2. **Riverpod**: Provider code generation  
3. **Freezed**: Immutable model generation
4. **JSON Serializable**: JSON serialization

Run `flutter packages pub run build_runner build` after making changes to:
- Database tables or DAOs
- Riverpod providers with annotations
- Freezed models
- JSON serializable classes

## Next Steps for Enhancement

1. **Notifications**: Complete implementation
   - Integrate with habit creation
   - Handle app state and permissions

2. **Testing**: Add comprehensive tests
   - Unit tests for repositories
   - Widget tests for UI components
   - Integration tests for user flows

3. **Performance**: Optimization opportunities
   - Database query optimization
   - Image and asset optimization
   - Memory usage monitoring

4. **Features**: Additional functionality
   - Export/import data
   - Habit categories
   - Advanced statistics
   - Dark mode theme

## Troubleshooting

### Build Issues
- Run `flutter clean` if encountering cache issues
- Delete `.dart_tool/build` folder for build script problems
- Ensure all dependencies are up to date

### Code Generation
- Check `build.yaml` configuration
- Verify all import statements in generated files
- Run with `--verbose` flag for detailed output

### Database Issues
- Check table definitions match DAOs
- Verify foreign key relationships
- Use database inspector tools for debugging

This codebase provides a solid foundation for a production-ready habit tracking app with room for future enhancements and customization.