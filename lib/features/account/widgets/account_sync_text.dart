import 'package:intl/intl.dart';
import 'package:thekr_app/features/sync/providers/sync_controller.dart';

/// One line saying how the backup is doing, shared by the card and the sheet.
String accountSyncText(SyncState sync) {
  if (sync.isSyncing) return 'جارٍ الحفظ…';
  if (sync.phase == SyncPhase.failed) return 'تعذّرت المزامنة، سنحاول لاحقاً';
  final at = sync.lastSyncAt;
  if (at == null) return 'لم تُحفظ نسخة بعد';
  return 'آخر نسخة: ${DateFormat('d MMM، h:mm a', 'ar').format(at)}';
}
