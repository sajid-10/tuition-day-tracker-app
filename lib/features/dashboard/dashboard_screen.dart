import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../students/student_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({required this.onOpenStudents, super.key});

  final VoidCallback onOpenStudents;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context)!;
    final students = ref.watch(activeStudentsProvider);
    final colors = Theme.of(context).colorScheme;
    //final settings = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          strings.dashboardSubtitle,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        Text(strings.today, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.event_available, color: colors.primary, size: 30),
                const SizedBox(height: 12),
                students.maybeWhen(
                  data: (items) => Text(
                    items.isEmpty
                        ? strings.noStudentsTitle
                        : strings.studentCount(items.length),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  orElse: () => const SizedBox.shrink(),
                ),
                const SizedBox(height: 6),
                students.maybeWhen(
                  data: (items) => Text(
                    items.isEmpty
                        ? strings.noStudentsMessage
                        : strings.studentsSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  orElse: () => const SizedBox.shrink(),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: onOpenStudents,
                  icon: const Icon(Icons.person_add_alt_1),
                  label: Text(strings.addStudent),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(strings.activeStudents, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        students.when(
          data: (items) => Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(Icons.groups_outlined, color: colors.primary),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(strings.students),
                  ),
                  Text(
                    '${items.length}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          error: (error, stackTrace) => _ErrorCard(message: strings.unknownError),
          loading: () => const LinearProgressIndicator(),
        ),
      ],
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Text(message),
    ),
  );
}
