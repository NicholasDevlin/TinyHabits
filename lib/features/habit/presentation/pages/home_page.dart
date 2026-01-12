import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import '../../../../l10n/app_localizations.dart';

import '../../../../core/app_theme.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/services/tutorial_service.dart';
import '../../domain/models/habit.dart';
import '../providers/habit_providers.dart';
import '../widgets/habit_card.dart';
import '../widgets/tutorial_overlay.dart';
import 'create_habit_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ConfettiController _confettiController;
  final Set<int> _dismissedHabitIds = <int>{};
  bool _hasShownConfetti = false;
  final List<MaterialColor> _confettiColors = [
    Colors.green,
    Colors.blue,
    Colors.pink,
    Colors.orange,
    Colors.purple,
    Colors.yellow,
  ];
  bool _showTutorial = false;
  final GlobalKey _fabKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _checkAndShowTutorial();
  }

  Future<void> _checkAndShowTutorial() async {
    final hasCompleted = await TutorialService.hasCompletedTutorial();
    if (!hasCompleted && mounted) {
      // Delay to ensure the UI is fully built
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() {
          _showTutorial = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _confettiController.dispose();
    _dismissedHabitIds.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);

    return Stack(
      children: [
        _buildMainContent(context, l10n, currentLocale),
        if (_showTutorial)
          TutorialOverlay(
            fabKey: _fabKey,
            onComplete: () async {
              await TutorialService.markTutorialCompleted();
              setState(() {
                _showTutorial = false;
              });
            },
          ),
      ],
    );
  }

  Widget _buildMainContent(BuildContext context, AppLocalizations l10n, Locale? currentLocale) {

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.appTitle,
          style: AppTheme.appTextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  ref.read(localeProvider.notifier).toggleLocale();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.language,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),

                      const SizedBox(width: 6),

                      Text(
                        (currentLocale?.languageCode ?? 'en').toUpperCase(),
                        style: AppTheme.appTextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
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
          tabs: [
            Tab(text: l10n.todayTab),
            Tab(text: l10n.allTab),
          ],
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              _buildTodayHabits(),
              _buildAllHabits(),
            ],
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: -3.14 / 2,
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              maxBlastForce: 20,
              minBlastForce: 8,
              gravity: 0.2,
              shouldLoop: false,
              colors: _confettiColors,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: -3.14 / 2,
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              maxBlastForce: 20,
              minBlastForce: 8,
              gravity: 0.2,
              shouldLoop: false,
              colors: _confettiColors,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        key: _fabKey,
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
    final l10n = AppLocalizations.of(context)!;
    final visibleHabits = habits.where((habit) => !_dismissedHabitIds.contains(habit.id)).toList();
    final sortedHabits = _sortHabitsByReminderTime(visibleHabits);

    if (sortedHabits.isEmpty) {
      return _buildEmptyState(context, isTodayTab);
    }

    if (isTodayTab) {
      _checkAndTriggerConfetti(sortedHabits);
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isTodayTab ? l10n.todayHeader : l10n.allHeader,
            style: AppTheme.appTextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 8),

          if (isTodayTab) ...[
            Text(
              _getMotivationalText(context, sortedHabits),
              style: AppTheme.appTextStyle(
                fontSize: 12,
                color: Colors.black.withOpacity(0.7),
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
                            AppLocalizations.of(context)!.edit,
                            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black.withOpacity(0.5)),
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
                            AppLocalizations.of(context)!.delete,
                            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black.withOpacity(0.5)),
                          ),
                        ],
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      final l10n = AppLocalizations.of(context)!;

                      if (direction == DismissDirection.endToStart) {
                        // Delete action
                        return await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(l10n.deleteHabitTitle),
                            content: Text(l10n.deleteHabitMessage(habit.title)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: Text(
                                  l10n.cancel,
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(true),
                                child: Text(
                                    l10n.delete,
                                    style: const TextStyle(color: Colors.red),
                                ),
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
                        final l10n = AppLocalizations.of(context)!;
                        final deletedHabit = habit; // Keep a copy for undo

                        // Immediately remove the widget from the list to prevent Dismissible errors
                        setState(() {
                          _dismissedHabitIds.add(habit.id);
                        });

                        // Show immediate feedback
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.deletingHabit(deletedHabit.title)),
                            backgroundColor: Colors.blue.shade400,
                            duration: const Duration(seconds: 2),
                          ),
                        );

                        // Delete habit after showing initial feedback
                        try {
                          await ref.read(habitControllerProvider.notifier).deleteHabit(habit.id);
                          if (!context.mounted) return;

                          final l10nAfter = AppLocalizations.of(context)!;
                          // Update the snackbar with success message and undo option
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10nAfter.deletedHabit(deletedHabit.title)),
                              backgroundColor: Colors.red.shade400,
                              duration: const Duration(seconds: 4),
                              action: SnackBarAction(
                                label: l10nAfter.undo,
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

                          final l10nError = AppLocalizations.of(context)!;
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10nError.failedToDelete(e.toString())),
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
    final l10n = AppLocalizations.of(context)!;

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
              isTodayTab ? l10n.noHabitsToday : l10n.noHabitsYet,
              style: AppTheme.appTextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              isTodayTab ? l10n.noHabitsTodayMessage : l10n.noHabitsYetMessage,
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
                icon: const Icon(Icons.add, color: Colors.white),
                label: Text(
                    l10n.createFirstHabit,
                    style: AppTheme.appTextStyle(
                      color: Colors.white,
                    ),
                ),
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
              l10n.somethingWentWrong,
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

  String _getMotivationalText(BuildContext context, List<Habit> habits) {
    final l10n = AppLocalizations.of(context)!;
    final completedCount = habits.where((h) => h.isCompletedToday).length;
    final totalCount = habits.length;

    if (completedCount == totalCount && totalCount > 0) {
      return l10n.motivationalAllComplete;
    } else if (completedCount > 0) {
      return l10n.motivationalProgress(completedCount, totalCount);
    } else {
      return l10n.motivationalStart;
    }
  }

  void _checkAndTriggerConfetti(List<Habit> habits) {
    final completedCount = habits.where((h) => h.isCompletedToday).length;
    final totalCount = habits.length;

    if (completedCount == totalCount && totalCount > 0) {
      if (!_hasShownConfetti) {
        _hasShownConfetti = true;
        _confettiController.play();
      }
    } else {
      _hasShownConfetti = false;
    }
  }

  void _handleHabitCompleted(BuildContext context, WidgetRef ref, int habitId, bool isCompleted) async {
    try {
      await ref.read(habitControllerProvider.notifier).markHabitCompleted(habitId, isCompleted);

      if (context.mounted) {
        final l10nAfter = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isCompleted ? l10nAfter.habitCompleted : l10nAfter.habitIncomplete,
            ),
            backgroundColor: isCompleted ? AppTheme.successColor : AppTheme.secondaryColor,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (error) {
      if (context.mounted) {
        final l10nError = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10nError.errorUpdatingHabit(error.toString())),
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
