import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/app_theme.dart';
import '../../domain/models/habit.dart';
import '../pages/habit_detail_page.dart';

class HabitCard extends StatefulWidget {
  final Habit habit;
  final Function(bool) onCompleted;

  const HabitCard({
    super.key,
    required this.habit,
    required this.onCompleted,
  });

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late bool _isCompleted;

  @override
  void initState() {
    super.initState();
    _isCompleted = widget.habit.isCompletedToday;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'habit_${widget.habit.id}',
      child: Card(
        elevation: _isCompleted ? 1 : 2,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _navigateToDetail(context),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: _isCompleted 
                  ? AppTheme.primaryColor.withOpacity(0.05)
                  : AppTheme.surfaceColor,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.habit.title,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: _isCompleted 
                              ? AppTheme.secondaryColor.withOpacity(0.7)
                              : AppTheme.secondaryColor,
                          decoration: _isCompleted 
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      if (widget.habit.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.habit.description!,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppTheme.secondaryColor.withOpacity(0.6),
                            decoration: _isCompleted 
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 16,
                            color: AppTheme.secondaryColor.withOpacity(0.5),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.habit.reminderTime,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppTheme.secondaryColor.withOpacity(0.5),
                            ),
                          ),
                          const SizedBox(width: 16),
                          if (widget.habit.currentStreak > 0) ...[
                            Icon(
                              Icons.local_fire_department,
                              size: 16,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.habit.currentStreak} day streak',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.orange,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                ScaleTransition(
                  scale: _scaleAnimation,
                  child: GestureDetector(
                    onTapDown: (_) => _animationController.forward(),
                    onTapUp: (_) => _handleCheckTap(),
                    onTapCancel: () => _animationController.reverse(),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: _isCompleted 
                            ? AppTheme.successColor
                            : AppTheme.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _isCompleted
                              ? AppTheme.successColor
                              : AppTheme.primaryColor,
                          width: 2,
                        ),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: _isCompleted
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 28,
                                key: ValueKey('completed'),
                              )
                            : Icon(
                                Icons.circle_outlined,
                                color: AppTheme.primaryColor,
                                size: 28,
                                key: const ValueKey('incomplete'),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleCheckTap() {
    _animationController.reverse();

    setState(() {
      _isCompleted = !_isCompleted;
    });

    if (_isCompleted) {
      _showCompletionAnimation();
    }

    widget.onCompleted(_isCompleted);
  }

  void _showCompletionAnimation() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  void _navigateToDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HabitDetailPage(habitId: widget.habit.id),
      ),
    );
  }
}