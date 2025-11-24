import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/app_theme.dart';
import '../../domain/models/habit.dart';
import '../providers/habit_providers.dart';
import '../widgets/habit_card.dart';
import 'create_habit_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayHabitsAsync = ref.watch(todayHabitsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'TinyWins',
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppTheme.secondaryColor,
          ),
        ),
        centerTitle: false,
      ),
      body: todayHabitsAsync.when(
        data: (habits) => _buildHabitsList(context, ref, habits),
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AppTheme.primaryColor,
          ),
        ),
        error: (error, _) => _buildErrorState(context, error.toString()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateHabit(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHabitsList(BuildContext context, WidgetRef ref, List<Habit> habits) {
    if (habits.isEmpty) {
      return _buildEmptyState(context);
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Habits',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppTheme.secondaryColor,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            _getMotivationalText(habits),
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AppTheme.secondaryColor.withOpacity(0.7),
            ),
          ),

          const SizedBox(height: 24),

          Expanded(
            child: ListView.separated(
              itemCount: habits.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final habit = habits[index];

                return Dismissible(
                  key: ValueKey('habit_${habit.id}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
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
                  confirmDismiss: (_) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete habit?'),
                        content: Text('Are you sure you want to delete "${habit.title}"? This cannot be undone.'),
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
                  },
                  onDismissed: (_) async {
                    final deletedHabit = habit; // Keep a copy for undo
                    try {
                      await ref.read(habitControllerProvider.notifier).deleteHabit(habit.id);
                      if (!context.mounted) return;

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
                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to delete: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: HabitCard(
                    habit: habit,
                    onCompleted: (isCompleted) => _handleHabitCompleted(
                      context,
                      ref,
                      habit.id,
                      isCompleted,
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

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 80,
              color: AppTheme.primaryColor.withOpacity(0.6),
            ),

            const SizedBox(height: 24),

            Text(
              'Start Your Journey',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppTheme.secondaryColor,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'Create your first habit and begin building\nconsistent, positive routines.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: AppTheme.secondaryColor.withOpacity(0.7),
              ),
            ),

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
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.secondaryColor,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              error,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
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
}