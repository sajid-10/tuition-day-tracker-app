import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import 'student_providers.dart';

class StudentListScreen extends ConsumerWidget {
  const StudentListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context)!;
    final students = ref.watch(activeStudentsProvider);
    final colors = Theme.of(context).colorScheme;

    return students.when(
      data: (items) {
        if (items.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.groups_outlined, size: 56, color: colors.primary),
                  const SizedBox(height: 16),
                  Text(
                    strings.noStudentsTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    strings.noStudentsMessage,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: colors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          itemCount: items.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final student = items[index];
            return Card(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: CircleAvatar(
                  backgroundColor: colors.primaryContainer,
                  foregroundColor: colors.onPrimaryContainer,
                  child: Text(student.name.characters.first.toUpperCase()),
                ),
                title: Text(student.name),
                subtitle: Text(
                  student.address ?? strings.noAddress,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: PopupMenuButton<String>(
                  tooltip: strings.archiveStudent,
                  onSelected: (value) {
                    if (value == 'archive') {
                      _archiveStudent(context, ref, student.id, student.name);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'archive',
                      child: Text(strings.archiveStudent),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      error: (error, stackTrace) => Center(child: Text(strings.unknownError)),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }

  Future<void> _archiveStudent(
    BuildContext context,
    WidgetRef ref,
    String id,
    String name,
  ) async {
    final strings = AppLocalizations.of(context)!;
    final shouldArchive = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.archiveStudent),
        content: Text(strings.archiveStudentPrompt(name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(strings.archive),
          ),
        ],
      ),
    );

    if (shouldArchive == true) {
      try {
        await ref.read(studentRepositoryProvider).archiveStudent(id);
      } on Exception catch (error) {
        debugPrint('Unable to archive student: $error');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(strings.unknownError)),
          );
        }
        return;
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(strings.studentArchived)));
      }
    }
  }
}
