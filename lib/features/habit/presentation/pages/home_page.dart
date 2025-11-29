import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/app_theme.dart';
import '../../domain/models/habit.dart';
import '../providers/habit_providers.dart';
import '../widgets/habit_card.dart';
import 'create_habit_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Set<int> _dismissedHabitIds = <int>{};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _dismissedHabitIds.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'TinyWins',
          style: AppTheme.appTextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppTheme.secondaryColor,
          ),
        ),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.secondaryColor.withOpacity(0.6),
          indicatorColor: AppTheme.primaryColor,
          labelStyle: AppTheme.appTextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: AppTheme.appTextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          tabs: const [
            Tab(text: 'Today'),
            Tab(text: 'All'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTodayHabits(),
          _buildAllHabits(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateHabit(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTodayHabits() {
    final todayHabitsAsync = ref.watch(todayHabitsProvider);

    return todayHabitsAsync.when(
      data: (habits) => _buildHabitsList(context, ref, habits, isTodayTab: true),
      loading: () => const Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryColor,
        ),
      ),
      error: (error, _) => _buildErrorState(context, error.toString()),
    );
  }

  Widget _buildAllHabits() {
    final allHabitsAsync = ref.watch(allHabitsProvider);

    return allHabitsAsync.when(
      data: (habits) => _buildHabitsList(context, ref, habits, isTodayTab: false),
      loading: () => const Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryColor,
        ),
      ),
      error: (error, _) => _buildErrorState(context, error.toString()),
    );
  }

  Widget _buildHabitsList(BuildContext context, WidgetRef ref, List<Habit> habits, {required bool isTodayTab}) {
    final visibleHabits = habits.where((habit) => !_dismissedHabitIds.contains(habit.id)).toList();
    final sortedHabits = _sortHabitsByReminderTime(visibleHabits);

    if (sortedHabits.isEmpty) {
      return _buildEmptyState(context, isTodayTab);
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isTodayTab ? 'Today' : 'All',
            style: AppTheme.appTextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppTheme.secondaryColor,
            ),
          ),

          const SizedBox(height: 8),

          if (isTodayTab) ...[
            Text(
              _getMotivationalText(sortedHabits),
              style: AppTheme.appTextStyle(
                fontSize: 16,
                color: AppTheme.secondaryColor.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
          ] else ...[
            const SizedBox(height: 16),
          ],

          Expanded(
            child: ListView.builder(
              itemCount: sortedHabits.length,
              itemBuilder: (context, index) {
                final habit = sortedHabits[index];
                final isAvailableToday = _isHabitAvailableToday(habit);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Dismissible(
                    key: ValueKey('habit_${habit.id}'),
                    direction: DismissDirection.horizontal,
                    background: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Text(
                            'Edit',
                            style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    secondaryBackground: Container(
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(Icons.delete_outline, color: Colors.red.shade700),
                          const SizedBox(width: 6),
                          Text(
                            'Delete',
                            style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.endToStart) {
                        // Delete action
                        return await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete habit?'),
                            content: Text('Are you sure you want to delete "${habit.title}"?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(true),
                                child: const Text('Delete', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        ) ?? false;
                      } else {
                        // Edit action
                        _navigateToEditHabit(context, habit);
                        return false; // Don't dismiss the widget for edit
                      }
                    },
                    onDismissed: (direction) async {
                      if (direction == DismissDirection.endToStart) {
                        final deletedHabit = habit; // Keep a copy for undo

                        // Immediately remove the widget from the list to prevent Dismissible errors
                        setState(() {
                          _dismissedHabitIds.add(habit.id);
                        });

                        // Show immediate feedback
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Deleting "${deletedHabit.title}"...'),
                            backgroundColor: Colors.blue.shade400,
                            duration: const Duration(seconds: 2),
                          ),
                        );

                        // Delete habit after showing initial feedback
                        try {
                          await ref.read(habitControllerProvider.notifier).deleteHabit(habit.id);
                          if (!context.mounted) return;

                          // Update the snackbar with success message and undo option
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Deleted "${deletedHabit.title}"'),
                              backgroundColor: Colors.red.shade400,
                              duration: const Duration(seconds: 4),
                              action: SnackBarAction(
                                label: 'UNDO',
                                textColor: Colors.white,
                                onPressed: () {
                                  // Recreate the habit using its previous fields
                                  final request = CreateHabitRequest(
                                    title: deletedHabit.title,
                                    description: deletedHabit.description,
                                    reminderTime: deletedHabit.reminderTime,
                                    targetDays: deletedHabit.targetDays,
                                  );
                                  ref.read(habitControllerProvider.notifier).createHabit(request);
                                },
                              ),
                            ),
                          );
                        } catch (e) {
                          // Restore the habit in the list if deletion failed
                          setState(() {
                            _dismissedHabitIds.remove(habit.id);
                          });

                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to delete: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    child: HabitCard(
                      habit: habit,
                      onCompleted: isAvailableToday ? (isCompleted) => _handleHabitCompleted(
                        context,
                        ref,
                        habit.id,
                        isCompleted,
                      ) : null, // Disable completion button if not available today
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isTodayTab) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isTodayTab ? Icons.today_outlined : Icons.emoji_events_outlined,
              size: 80,
              color: AppTheme.primaryColor.withOpacity(0.6),
            ),

            const SizedBox(height: 24),

            Text(
              isTodayTab ? 'No habits for today' : 'No habits yet',
              style: AppTheme.appTextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppTheme.secondaryColor,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              isTodayTab
                ? 'Enjoy your day! No habits scheduled for today.'
                : 'Create your first habit and begin building\nconsistent, positive routines.',
              textAlign: TextAlign.center,
              style: AppTheme.appTextStyle(
                fontSize: 16,
                color: AppTheme.secondaryColor.withOpacity(0.7),
              ),
            ),

            if (!isTodayTab) ...[
              const SizedBox(height: 32),

              ElevatedButton.icon(
                onPressed: () => _navigateToCreateHabit(context),
                icon: const Icon(Icons.add),
                label: const Text('Create First Habit'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
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
              'Something went wrong',
              style: AppTheme.appTextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.secondaryColor,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              error,
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

  String _getMotivationalText(List<Habit> habits) {
    final completedCount = habits.where((h) => h.isCompletedToday).length;
    final totalCount = habits.length;

    if (completedCount == totalCount && totalCount > 0) {
      return '🎉 Amazing! You\'ve completed all your habits today!';
    } else if (completedCount > 0) {
      return '$completedCount of $totalCount completed. Keep going!';
    } else {
      return 'Ready to make today count? Start with one habit.';
    }
  }

  void _handleHabitCompleted(BuildContext context, WidgetRef ref, int habitId, bool isCompleted) async {
    try {
      await ref.read(habitControllerProvider.notifier).markHabitCompleted(habitId, isCompleted);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isCompleted ? 'Habit completed! 🎉' : 'Habit marked as incomplete',
            ),
            backgroundColor: isCompleted ? AppTheme.successColor : AppTheme.secondaryColor,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating habit: $error'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _navigateToCreateHabit(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateHabitPage(),
      ),
    );
  }

  void _navigateToEditHabit(BuildContext context, Habit habit) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateHabitPage(habit: habit),
      ),
    );
  }

  bool _isHabitAvailableToday(Habit habit) {
    final today = DateTime.now();
    // DateTime.weekday returns 1-7 (Monday to Sunday), which matches our targetDays format
    final todayWeekday = today.weekday;
    return habit.targetDays.contains(todayWeekday);
  }

  List<Habit> _sortHabitsByReminderTime(List<Habit> habits) {
    return habits.toList()..sort((a, b) {
      // First, compare completion status - completed habits go to bottom
      if (a.isCompletedToday != b.isCompletedToday) {
        return a.isCompletedToday ? 1 : -1;
      }

      // If both have the same completion status, sort by reminder time
      final timeA = _parseTime(a.reminderTime);
      final timeB = _parseTime(b.reminderTime);
      return timeA.compareTo(timeB);
    });
  }

  DateTime _parseTime(String timeString) {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = parts.length > 1 ? int.parse(parts[1]) : 0;
    return DateTime(2023, 1, 1, hour, minute); // Use dummy date for time comparison
  }

}