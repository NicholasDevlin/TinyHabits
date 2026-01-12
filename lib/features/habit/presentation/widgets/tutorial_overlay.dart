import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/app_theme.dart';

class TutorialOverlay extends StatefulWidget {
  final VoidCallback onComplete;
  final GlobalKey fabKey;

  const TutorialOverlay({
    super.key,
    required this.onComplete,
    required this.fabKey,
  });

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay> with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<TutorialStep> _steps = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context)!;
    
    // Initialize tutorial steps with localized content
    _steps.clear();
    _steps.addAll([
      TutorialStep(
        title: l10n.tutorialWelcomeTitle,
        description: l10n.tutorialWelcomeDescription,
        targetKey: null,
        highlightPosition: TutorialHighlightPosition.center,
        icon: Icons.waving_hand,
      ),
      TutorialStep(
        title: l10n.tutorialCreateTitle,
        description: l10n.tutorialCreateDescription,
        targetKey: widget.fabKey,
        highlightPosition: TutorialHighlightPosition.bottomRight,
        icon: Icons.add_circle_outline,
      ),
      TutorialStep(
        title: l10n.tutorialSwipeLeftTitle,
        description: l10n.tutorialSwipeLeftDescription,
        targetKey: null,
        highlightPosition: TutorialHighlightPosition.center,
        icon: Icons.edit_outlined,
        showSwipeAnimation: true,
        swipeDirection: SwipeDirection.leftToRight,
      ),
      TutorialStep(
        title: l10n.tutorialSwipeRightTitle,
        description: l10n.tutorialSwipeRightDescription,
        targetKey: null,
        highlightPosition: TutorialHighlightPosition.center,
        icon: Icons.delete_outline,
        showSwipeAnimation: true,
        swipeDirection: SwipeDirection.rightToLeft,
      ),
      TutorialStep(
        title: l10n.tutorialCompleteTitle,
        description: l10n.tutorialCompleteDescription,
        targetKey: null,
        highlightPosition: TutorialHighlightPosition.center,
        icon: Icons.check_circle_outline,
      ),
    ]);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
      });
      _animationController.reset();
      _animationController.forward();
    } else {
      _completeTutorial();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _animationController.reset();
      _animationController.forward();
    }
  }

  void _completeTutorial() {
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStep];
    final l10n = AppLocalizations.of(context)!;

    return Material(
      color: Colors.black.withOpacity(0.85),
      child: Stack(
        children: [
          // Highlight target if exists
          if (step.targetKey != null)
            _buildHighlight(step.targetKey!, step.highlightPosition),

          // Tutorial content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Icon
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                step.icon,
                                size: 64,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Title
                            Text(
                              step.title,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),

                            // Description
                            Text(
                              step.description,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            // Swipe animation if needed
                            if (step.showSwipeAnimation) ...[
                              const SizedBox(height: 32),
                              _buildSwipeAnimation(step.swipeDirection),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Bottom navigation
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        // Step indicator
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _steps.length,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: index == _currentStep ? 32 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: index == _currentStep
                                    ? AppTheme.primaryColor
                                    : Colors.white30,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Navigation buttons
                        Row(
                          children: [
                            if (_currentStep > 0)
                              TextButton(
                                onPressed: _previousStep,
                                child: Text(
                                  l10n.tutorialBack,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            const Spacer(),
                            TextButton(
                              onPressed: _completeTutorial,
                              child: Text(
                                l10n.tutorialSkip,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: _nextStep,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                _currentStep < _steps.length - 1
                                    ? l10n.tutorialNext
                                    : l10n.tutorialGetStarted,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlight(GlobalKey targetKey, TutorialHighlightPosition position) {
    final RenderBox? renderBox = targetKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return const SizedBox.shrink();

    final targetSize = renderBox.size;
    final targetPosition = renderBox.localToGlobal(Offset.zero);

    return Positioned(
      left: targetPosition.dx - 8,
      top: targetPosition.dy - 8,
      child: Container(
        width: targetSize.width + 16,
        height: targetSize.height + 16,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primaryColor,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwipeAnimation(SwipeDirection direction) {
    return SizedBox(
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Card background
          Container(
            width: 200,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white30),
            ),
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.tutorialSwipeCard,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ),

          // Animated swipe indicator
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              final offset = direction == SwipeDirection.leftToRight
                  ? Offset(-60 + (value * 60), 0)
                  : Offset(60 - (value * 60), 0);
              
              return Transform.translate(
                offset: offset,
                child: Icon(
                  direction == SwipeDirection.leftToRight
                      ? Icons.arrow_forward
                      : Icons.arrow_back,
                  color: direction == SwipeDirection.leftToRight
                      ? Colors.blue.withOpacity(0.5 + (value * 0.5))
                      : Colors.red.withOpacity(0.5 + (value * 0.5)),
                  size: 40,
                ),
              );
            },
            onEnd: () {
              // Restart animation
              setState(() {});
            },
          ),
        ],
      ),
    );
  }
}

class TutorialStep {
  final String title;
  final String description;
  final GlobalKey? targetKey;
  final TutorialHighlightPosition highlightPosition;
  final IconData icon;
  final bool showSwipeAnimation;
  final SwipeDirection swipeDirection;

  TutorialStep({
    required this.title,
    required this.description,
    this.targetKey,
    required this.highlightPosition,
    required this.icon,
    this.showSwipeAnimation = false,
    this.swipeDirection = SwipeDirection.leftToRight,
  });
}

enum TutorialHighlightPosition {
  center,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

enum SwipeDirection {
  leftToRight,
  rightToLeft,
}
