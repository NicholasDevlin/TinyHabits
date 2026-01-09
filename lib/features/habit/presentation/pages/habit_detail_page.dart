import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../l10n/app_localizations.dart';

import '../../../../core/app_theme.dart';
import '../../../../core/utils/localization_extensions.dart';
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: habitAsync.when(
          data: (habit) => Text(
            habit?.title ?? l10n.habitDetails,
            style: AppTheme.appTextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          loading: () => Text(
            l10n.loading,
            style: AppTheme.appTextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          error: (_, __) => Text(
            l10n.error,
            style: AppTheme.appTextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.red,
            ),
            onPressed: () => _showDeleteConfirmation(context, ref),
          ),
        ],
      ),
      body: habitAsync.when(
        data: (habit) {
          if (habit == null) {
            return _buildErrorState(context, l10n.habitNotFound);
          }

          return _buildHabitDetail(context, ref, habit, completedDatesAsync);
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
        error: (error, _) => _buildErrorState(context, error.toString()),
      ),
    );
  }

  Widget _buildHabitDetail(
    BuildContext context,
    WidgetRef ref,
    Habit habit,
    AsyncValue<List<DateTime>> completedDatesAsync,
  ) {
    final l10n = AppLocalizations.of(context)!;
    
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
                        ),
                      ),

                      if (habit.description != null) ...[
                        const SizedBox(height: 8),

                        Text(
                          habit.description!,
                          style: AppTheme.appTextStyle(
                            fontSize: 16,
                            color: Colors.black.withOpacity(0.7),
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          const Icon(
                            Icons.schedule,
                            size: 20,
                          ),

                          const SizedBox(width: 8),

                          Text(
                            l10n.reminderAt(habit.reminderTime),
                            style: AppTheme.appTextStyle(
                              fontSize: 14,
                              color: Colors.black.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          const Icon(
                            Icons.repeat,
                            size: 20,
                          ),

                          const SizedBox(width: 8),

                          Text(
                            _formatTargetDays(context, habit.targetDays),
                            style: AppTheme.appTextStyle(
                              fontSize: 14,
                              color: Colors.black.withOpacity(0.7),
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
            l10n.statistics,
            style: AppTheme.appTextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  l10n.currentStreak,
                  '${habit.currentStreak}',
                  l10n.days,
                  '🔥',
                  null,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _buildStatCard(
                  context,
                  l10n.totalCompleted,
                  '${habit.totalCompletions}',
                  l10n.times,
                  Icons.check_circle,
                  AppTheme.successColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Text(
            l10n.calendar,
            style: AppTheme.appTextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 12),

          completedDatesAsync.when(
            data: (completedDates) => _buildCalendar(completedDates),
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            ),
            error: (error, _) => _buildErrorState(context, l10n.failedToLoadCalendar),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    String unit,
    dynamic icon,
    Color? color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                icon is IconData
                    ? Icon(icon, color: color, size: 24)
                    : Text(icon, style: const TextStyle(fontSize: 20),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    title,
                    style: AppTheme.appTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black.withOpacity(0.7),
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
              ),
            ),

            Text(
              unit,
              style: AppTheme.appTextStyle(
                fontSize: 12,
                color: Colors.black.withOpacity(0.5),
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
            markerDecoration: const BoxDecoration(
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
            leftChevronIcon: const Icon(
              Icons.chevron_left,
            ),
            rightChevronIcon: const Icon(
              Icons.chevron_right,
            ),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: AppTheme.appTextStyle(
              fontWeight: FontWeight.w600,
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
                    decoration: const BoxDecoration(
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

  Widget _buildErrorState(BuildContext context, String message) {
    final l10n = AppLocalizations.of(context)!;
    
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
              l10n.oops,
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

  String _formatTargetDays(BuildContext context, List<int> targetDays) {
    final l10n = AppLocalizations.of(context)!;
    
    if (targetDays.length == 7) {
      return l10n.everyDay;
    }

    final selectedDays = targetDays.map((day) => l10n.dayNamesShort[day - 1]).join(', ');

    return selectedDays;
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          l10n.deleteHabit,
          style: AppTheme.appTextStyle(fontWeight: FontWeight.w600),
        ),
        content: Text(
          l10n.deleteHabitConfirmation,
          style: AppTheme.appTextStyle(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              l10n.cancel,
              style: const TextStyle(color: Colors.black),
            ),
          ),

          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to previous screen

              try {
                await ref.read(habitControllerProvider.notifier).deleteHabit(habitId);

                if (context.mounted) {
                  final l10nAfter = AppLocalizations.of(context)!;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10nAfter.habitDeletedSuccessfully),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                }
              } catch (error) {
                if (context.mounted) {
                  final l10nError = AppLocalizations.of(context)!;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10nError.failedToDeleteHabit(error.toString())),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                }
              }
            },
            child: Text(
              l10n.delete,
              style: const TextStyle(color: Colors.red),
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
