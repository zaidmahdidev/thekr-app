import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/live_stream_model.dart';

final selectedStreamProvider = StateProvider<LiveStream>((ref) {
  return LiveStream.defaults.first;
});
