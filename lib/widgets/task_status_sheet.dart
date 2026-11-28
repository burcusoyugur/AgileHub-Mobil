import 'package:flutter/material.dart';

import '../models/task.dart';
import '../services/task_service.dart';
import '../theme/app_theme.dart';
import 'state_views.dart';

/// Görevin durumunu seçmek için alttan açılan pencere.
///
/// Dört durum listelenir, mevcut durum işaretlidir. Seçilen yeni durumu
/// döndürür; pencere kapatılırsa ya da mevcut duruma dokunulursa (değişiklik
/// yok) `null` döner.
Future<TaskStatus?> showTaskStatusSheet(BuildContext context, Task task) {
  return showModalBottomSheet<TaskStatus>(
    context: context,
    showDragHandle: true,
    builder: (_) => _TaskStatusSheet(task: task),
  );
}

/// Panodaki kartın durum düğmesi (`TaskCard.onStatusTap`) için hazır akış:
///
/// 1. [showTaskStatusSheet] açılır; kullanıcı vazgeçerse hiçbir şey olmaz.
/// 2. **İyimser güncelleme:** [onChanged] yeni durumla hemen çağrılır; kart
///    sunucuyu beklemeden yeni sekmeye geçer.
/// 3. [TaskService.updateStatus] çağrılır. Başarılıysa sunucunun döndürdüğü
///    görevle [onChanged] tekrar çağrılır ve kısa bir bildirim gösterilir.
/// 4. Hata olursa [onChanged] eski görevle çağrılır (kart eski yerine döner)
///    ve hata Türkçe mesajla gösterilir.
///
/// Pano ekranında kullanım:
/// ```dart
/// TaskCard(
///   task: task,
///   onStatusTap: () => changeTaskStatus(
///     context,
///     task: task,
///     service: context.read<TaskService>(),
///     onChanged: _replaceTask,
///   ),
/// )
///
/// // Listedeki görevi aynı id'li yenisiyle değiştirir.
/// void _replaceTask(Task updated) {
///   if (!mounted) return;
///   setState(() {
///     _tasks = [for (final t in _tasks) t.id == updated.id ? updated : t];
///   });
/// }
/// ```
Future<void> changeTaskStatus(
  BuildContext context, {
  required Task task,
  required TaskService service,
  required ValueChanged<Task> onChanged,
}) async {
  final newStatus = await showTaskStatusSheet(context, task);
  if (newStatus == null || newStatus == task.status || !context.mounted) {
    return;
  }

  // Kart yeni sekmeye geçince bu context ekrandan kalkar; bildirimleri yine
  // de gösterebilmek için ScaffoldMessenger beklemeden önce alınır.
  final messenger = ScaffoldMessenger.of(context);

  onChanged(task.copyWith(status: newStatus));
  try {
    final saved = await service.updateStatus(task.id, newStatus);
    onChanged(saved);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text("Görev '${saved.status.label}' sütununa taşındı"),
        ),
      );
  } catch (e) {
    onChanged(task);
    showErrorSnackBarOn(messenger, e);
  }
}

class _TaskStatusSheet extends StatelessWidget {
  final Task task;

  const _TaskStatusSheet({required this.task});

  Color _statusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return AppTheme.todoColor;
      case TaskStatus.inProgress:
        return AppTheme.inProgressColor;
      case TaskStatus.testing:
        return AppTheme.testingColor;
      case TaskStatus.done:
        return AppTheme.doneColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Durumu değiştir', style: textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    task.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            for (final status in TaskStatus.values)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                leading: Icon(
                  Icons.circle,
                  size: 12,
                  color: _statusColor(status),
                ),
                title: Text(status.label),
                selected: status == task.status,
                trailing: status == task.status
                    ? Icon(
                        Icons.check,
                        color: colors.primary,
                        semanticLabel: 'Mevcut durum',
                      )
                    : null,
                // Mevcut duruma dokunmak değişiklik sayılmaz.
                onTap: () =>
                    Navigator.of(context)
                        .pop(status == task.status ? null : status),
              ),
          ],
        ),
      ),
    );
  }
}
