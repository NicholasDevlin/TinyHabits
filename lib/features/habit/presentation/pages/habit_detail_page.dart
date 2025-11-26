import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/app_theme.dart';
import '../providers/habit_providers.dart';
import '../../domain/models/habit.dart';

class HabitDetailPage extends ConsumerWidget {
  final int habitId;

  const HabitDetailPage({
    super.key,
    required this.habitId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitAsync = ref.watch(habitProvider(habitId));
    final completedDatesAsync = ref.watch(habitCompletedDatesProvider(habitId));

    return Scaffold(
      appBar: AppBar(
        title: habitAsync.when(
          data: (habit) => Text(
            habit?.title ?? 'Habit Details',
            style: AppTheme.appTextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.secondaryColor,
            ),
          ),
          loading: () => Text(
            'Loading...',
            style: AppTheme.appTextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.secondaryColor,
            ),
          ),
          error: (_, __) => Text(
            'Error',
            style: AppTheme.appTextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.secondaryColor,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showDeleteConfirmation(context, ref),
          ),
        ],
      ),
      body: habitAsync.when(
        data: (habit) {
          if (habit == null) {
            return _buildErrorState('Habit not found');
          }

          return _buildHabitDetail(context, ref, habit, completedDatesAsync);
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
        error: (error, _) => _buildErrorState(error.toString()),
      ),
    );
  }

  Widget _buildHabitDetail(
    BuildContext context,
    WidgetRef ref,
    Habit habit,
    AsyncValue<List<DateTime>> completedDatesAsync,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Hero(
            tag: 'habit_${habit.id}',
            child: Material(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.title,
                        style: AppTheme.appTextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.secondaryColor,
                        ),
                      ),

                      if (habit.description != null) ...[
                        const SizedBox(height: 8),

                        Text(
                          habit.description!,
                          style: AppTheme.appTextStyle(
                            fontSize: 16,
                            color: AppTheme.secondaryColor.withOpacity(0.7),
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 20,
                            color: AppTheme.primaryColor,
                          ),

                          const SizedBox(width: 8),

                          Text(
                            'Reminder at ${habit.reminderTime}',
                            style: AppTheme.appTextStyle(
                              fontSize: 14,
                              color: AppTheme.secondaryColor.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Icon(
                            Icons.repeat,
                            size: 20,
                            color: AppTheme.primaryColor,
                          ),

                          const SizedBox(width: 8),

                          Text(
                            _formatTargetDays(habit.targetDays),
                            style: AppTheme.appTextStyle(
                              fontSize: 14,
                              color: AppTheme.secondaryColor.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'Statistics',
            style: AppTheme.appTextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.secondaryColor,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Current Streak',
                  '${habit.currentStreak}',
                  'days',
                  Icons.local_fire_department,
                  Colors.orange,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _buildStatCard(
                  'Total Completed',
                  '${habit.totalCompletions}',
                  'times',
                  Icons.check_circle,
                  AppTheme.successColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Text(
            'Calendar',
            style: AppTheme.appTextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.secondaryColor,
            ),
          ),

          const SizedBox(height: 12),

          completedDatesAsync.when(
            data: (completedDates) => _buildCalendar(completedDates),
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            ),
            error: (error, _) => _buildErrorState('Failed to load calendar'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String unit,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),

                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    title,
                    style: AppTheme.appTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.secondaryColor.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              value,
              style: AppTheme.appTextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.secondaryColor,
              ),
            ),

            Text(
              unit,
              style: AppTheme.appTextStyle(
                fontSize: 12,
                color: AppTheme.secondaryColor.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar(List<DateTime> completedDates) {
    // Convert to Set for O(1) lookups
    final completedDatesSet = completedDates.map((date) {
      return DateTime(date.year, date.month, date.day);
    }).toSet();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TableCalendar<DateTime>(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: DateTime.now(),
          calendarFormat: CalendarFormat.month,
          startingDayOfWeek: StartingDayOfWeek.monday,
          calendarStyle: CalendarStyle(
            // Completed days
            markerDecoration: BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
            ),
            // Today
            todayDecoration: BoxDecoration(
              color: AppTheme.secondaryColor.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            // Selected day (none for now)
            selectedDecoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.7),
              shape: BoxShape.circle,
            ),
            // Default day style
            defaultTextStyle: AppTheme.appTextStyle(
              color: AppTheme.secondaryColor,
            ),
            weekendTextStyle: AppTheme.appTextStyle(
              color: AppTheme.secondaryColor.withOpacity(0.7),
            ),
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: AppTheme.appTextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.secondaryColor,
            ),
            leftChevronIcon: Icon(
              Icons.chevron_left,
              color: AppTheme.primaryColor,
            ),
            rightChevronIcon: Icon(
              Icons.chevron_right,
              color: AppTheme.primaryColor,
            ),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: AppTheme.appTextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.secondaryColor,
            ),
            weekendStyle: AppTheme.appTextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.secondaryColor.withOpacity(0.7),
            ),
          ),
          eventLoader: (day) {
            final dayOnly = DateTime(day.year, day.month, day.day);

            return completedDatesSet.contains(dayOnly) ? [day] : [];
          },
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              if (events.isNotEmpty) {
                return Positioned(
                  bottom: 4,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }
              return null;
            },
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.errorColor.withOpacity(0.7),
            ),

            const SizedBox(height: 16),

            Text(
              'Oops!',
              style: AppTheme.appTextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.secondaryColor,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTheme.appTextStyle(
                fontSize: 14,
                color: AppTheme.secondaryColor.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTargetDays(List<int> targetDays) {
    if (targetDays.length == 7) {
      return 'Every day';
    }

    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final selectedDays = targetDays.map((day) => dayNames[day - 1]).join(', ');

    return selectedDays;
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Habit',
          style: AppTheme.appTextStyle(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to delete this habit? This action cannot be undone.',
          style: AppTheme.appTextStyle(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: AppTheme.appTextStyle(color: AppTheme.secondaryColor),
            ),
          ),

          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to previous screen

              try {
                await ref.read(habitControllerProvider.notifier).deleteHabit(habitId);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Habit deleted successfully'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                }
              } catch (error) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete habit: $error'),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                }
              }
            },
            child: Text(
              'Delete',
              style: AppTheme.appTextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}