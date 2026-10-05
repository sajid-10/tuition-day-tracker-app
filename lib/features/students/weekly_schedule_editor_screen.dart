import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/database/app_database.dart';
import '../../l10n/app_localizations.dart';
import 'student_providers.dart';

class WeeklyScheduleEditorScreen extends ConsumerWidget {
  const WeeklyScheduleEditorScreen({required this.student, super.key});

  final Student student;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<Schedule>>(
      future: ref.read(studentRepositoryProvider).getSchedules(student.id),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.weeklySchedule),
            ),
            body: Center(
              child: Text(AppLocalizations.of(context)!.unknownError),
            ),
          );
        }
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.weeklySchedule),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        return _WeeklyScheduleForm(
          student: student,
          schedules: snapshot.data!,
        );
      },
    );
  }
}

class _WeeklyScheduleForm extends ConsumerStatefulWidget {
  const _WeeklyScheduleForm({required this.student, required this.schedules});

  final Student student;
  final List<Schedule> schedules;

  @override
  ConsumerState<_WeeklyScheduleForm> createState() =>
      _WeeklyScheduleFormState();
}

class _WeeklyScheduleFormState extends ConsumerState<_WeeklyScheduleForm> {
  static const _defaultTime = TimeOfDay(hour: 17, minute: 0);
  final Map<int, TimeOfDay> _times = {};
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    for (final schedule in widget.schedules) {
      final parts = schedule.startTime.split(':');
      _times[schedule.dayOfWeek] = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final dayNames = [
      strings.monday,
      strings.tuesday,
      strings.wednesday,
      strings.thursday,
      strings.friday,
      strings.saturday,
      strings.sunday,
    ];

    return Scaffold(
      appBar: AppBar(title: Text(strings.weeklySchedule)),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(strings.saveSchedule),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            widget.student.name,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          for (var index = 0; index < dayNames.length; index++)
            Card(
              child: CheckboxListTile(
                value: _times.containsKey(index + 1),
                onChanged: (enabled) {
                  setState(() {
                    if (enabled == true) {
                      _times[index + 1] = _defaultTime;
                    } else {
                      _times.remove(index + 1);
                    }
                  });
                },
                title: Text(dayNames[index]),
                secondary: _times.containsKey(index + 1)
                    ? TextButton.icon(
                        onPressed: () => _chooseTime(index + 1),
                        icon: const Icon(Icons.schedule),
                        label: Text(_times[index + 1]!.format(context)),
                      )
                    : null,
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _chooseTime(int day) async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _times[day] ?? _defaultTime,
      helpText: AppLocalizations.of(context)!.chooseTime,
    );
    if (selected != null) setState(() => _times[day] = selected);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final dayToStartTime = {
        for (final entry in _times.entries)
          entry.key:
              '${entry.value.hour.toString().padLeft(2, '0')}:'
              '${entry.value.minute.toString().padLeft(2, '0')}',
      };
      await ref.read(studentRepositoryProvider).saveWeeklySchedule(
        studentId: widget.student.id,
        dayToStartTime: dayToStartTime,
        expectedDurationMinutes: widget.student.sessionDurationMinutes,
      );
      if (mounted) Navigator.of(context).pop(true);
    } on Exception catch (error) {
      debugPrint('Unable to save weekly schedule: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.scheduleSaveFailed),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
