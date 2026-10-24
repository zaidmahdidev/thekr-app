import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thekr_app/features/umrah/providers/umrah_checklist_provider.dart';

/// Ticks on the Hajj packing list, saved on the device.
final hajjChecklistProvider =
    StateNotifierProvider<ChecklistNotifier, Set<String>>(
      (ref) => ChecklistNotifier('hajj_checklist'),
    );
