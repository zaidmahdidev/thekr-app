import 'package:flutter_riverpod/flutter_riverpod.dart';

final currentTimeProvider = StreamProvider<DateTime>((ref) {
  return Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
});
