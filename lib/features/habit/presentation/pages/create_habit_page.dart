import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/app_theme.dart';
import '../../domain/models/habit.dart';
import '../providers/habit_providers.dart';

class CreateHabitPage extends ConsumerStatefulWidget {
  final Habit? habit;

  const CreateHabitPage({super.key, this.habit});

  @override
  ConsumerState<CreateHabitPage> createState() => _CreateHabitPageState();
}

class _CreateHabitPageState extends ConsumerState<CreateHabitPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _hasInteracted = false;

  TimeOfDay _selectedTime = TimeOfDay.now();
  Set<int> _selectedDays = <int>{};

  final List<String> _dayNames = [
    'Monday',
    'Tuesday', 
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  void initState() {
    super.initState();

    if (widget.habit != null) {
      _titleController.text = widget.habit!.title;
      if (widget.habit!.description != null) {
        _descriptionController.text = widget.habit!.description!;
      }

      final timeParts = widget.habit!.reminderTime.split(':');
      _selectedTime = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      );

      _selectedDays = widget.habit!.targetDays.toSet();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final habitController = ref.watch(habitControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.habit != null ? 'Edit Habit' : 'Create Habit',
          style: AppTheme.appTextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: habitController.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            )
          : _buildForm(context),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: habitController.isLoading ? null : _saveHabit,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              widget.habit != null ? 'Update Habit' : 'Create Habit',
              style: AppTheme.appTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Habit Name',
              style: AppTheme.appTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'e.g., Drink 8 glasses of water',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a habit name';
                }

                return null;
              },
            ),

            const SizedBox(height: 24),

            Text(
              'Description (Optional)',
              style: AppTheme.appTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                hintText: 'Add motivation or details...',
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 24),

            Text(
              'Reminder Time',
              style: AppTheme.appTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            InkWell(
              onTap: _selectTime,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppTheme.secondaryColor.withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      color: Colors.black.withOpacity(0.5),
                    ),

                    const SizedBox(width: 12),

                    Text(
                      _formatTime(_selectedTime),
                      style: AppTheme.appTextStyle(
                        fontSize: 16,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),

                    const Spacer(),

                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Repeat Days',
              style: AppTheme.appTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            CheckboxListTile(
              title: Text(
                'Everyday',
                style: AppTheme.appTextStyle(fontWeight: FontWeight.w500),
              ),
              value: _selectedDays.length == 7,
              onChanged: (value) {
                setState(() {
                  _hasInteracted = true;

                  if (value == true) {
                    _selectedDays = {1, 2, 3, 4, 5, 6, 7};
                  } else {
                    _selectedDays.clear();
                  }
                });
              },
              activeColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),

            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(7, (index) {
                final dayNumber = index + 1;
                final isSelected = _selectedDays.contains(dayNumber);

                return FilterChip(
                  label: Text(_dayNames[index]),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _hasInteracted = true;

                      if (selected) {
                        _selectedDays.add(dayNumber);
                      } else {
                        _selectedDays.remove(dayNumber);
                      }
                    });
                  },
                  selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                  checkmarkColor: AppTheme.primaryColor,
                  side: BorderSide(
                    color: isSelected 
                        ? AppTheme.primaryColor
                        : AppTheme.secondaryColor.withOpacity(0.3),
                  ),
                );
              }),
            ),

            if (_hasInteracted && _selectedDays.isEmpty) ...[
              const SizedBox(height: 8),

              Text(
                'Please select at least one day',
                style: AppTheme.appTextStyle(
                  fontSize: 12,
                  color: AppTheme.errorColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppTheme.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one day'),
          backgroundColor: AppTheme.errorColor,
        ),
      );

      return;
    }

    final request = CreateHabitRequest(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      reminderTime: _formatTime(_selectedTime),
      targetDays: _selectedDays.toList()..sort(),
    );

    try {
      if (widget.habit != null) {
        await ref.read(habitControllerProvider.notifier).updateHabit(widget.habit!.id, request);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Habit updated successfully! 🎉'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          Navigator.of(context).pop();
        }
      } else {
        await ref.read(habitControllerProvider.notifier).createHabit(request);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Habit created successfully! 🎉'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          Navigator.of(context).pop();
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to ${widget.habit != null ? 'update' : 'create'} habit: $error'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
}