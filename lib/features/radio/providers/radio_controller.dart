import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:thekr_app/core/services/cache_helper.dart';
import 'package:thekr_app/core/utils/connectivity_utils.dart';
import '../models/radio_station.dart';
import '../services/radio_notification_service.dart';

enum RadioStatus {
  /// Nothing has been started yet.
  idle,

  /// Opening the stream (also shown while a failed attempt is retried).
  connecting,

  /// Stream is open but the buffer ran dry.
  buffering,
  playing,
  paused,

  /// The device has no connection; playback resumes by itself when it returns.
  offline,

  /// Every retry failed; the user has to tap retry.
  error,
}

class RadioState {
  const RadioState({
    this.station,
    this.status = RadioStatus.idle,
    this.sleepEndsAt,
  });

  final RadioStation? station;
  final RadioStatus status;
  final DateTime? sleepEndsAt;

  bool get isPlaying => status == RadioStatus.playing;

  /// Audio is on, or about to be: the main button shows "pause".
  bool get isActive =>
      status == RadioStatus.playing ||
      status == RadioStatus.connecting ||
      status == RadioStatus.buffering;

  bool get isLoading =>
      status == RadioStatus.connecting || status == RadioStatus.buffering;

  RadioState copyWith({
    RadioStation? station,
    RadioStatus? status,
    DateTime? sleepEndsAt,
    bool clearSleep = false,
  }) {
    return RadioState(
      station: station ?? this.station,
      status: status ?? this.status,
      sleepEndsAt: clearSleep ? null : (sleepEndsAt ?? this.sleepEndsAt),
    );
  }
}

/// Owns the audio player for the radio screen.
///
/// Streams are live, so "pause" stops the player and "resume" reconnects at the
/// live edge instead of replaying stale buffered audio.
class RadioController extends StateNotifier<RadioState> {
  RadioController()
    : super(
        RadioState(
          station: RadioStation.byId(
            CacheHelper.getData(key: _lastStationKey) as String?,
          ),
        ),
      ) {
    _init();
  }

  static const String _lastStationKey = 'radio_last_station';
  static const int _maxRetries = 3;
  static const Duration _connectTimeout = Duration(seconds: 20);

  final AudioPlayer _player = AudioPlayer();
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  Timer? _retryTimer;
  Timer? _sleepTimer;

  /// Bumped on every user-initiated start so late results of an older attempt
  /// are ignored.
  int _generation = 0;
  int _retries = 0;

  /// What the user last asked for; decides whether to reconnect on failure.
  bool _wantsPlaying = false;
  bool _resumeAfterInterruption = false;

  Future<void> _init() async {
    // The notification (and the foreground service behind it) follows what
    // the screen shows, and its stop button stops the radio.
    RadioNotificationService.onStop = pause;
    addListener(_syncNotification, fireImmediately: false);
    _subscriptions.add(
      _player.playerStateStream.listen(_onPlayerState, onError: (_) {}),
    );
    _subscriptions.add(
      _player.playbackEventStream.listen(
        (_) {},
        onError: (Object error, StackTrace _) => _onFailure(error),
      ),
    );
    _subscriptions.add(
      Connectivity().onConnectivityChanged.listen(_onConnectivityChanged),
    );

    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
      if (!mounted) return;
      _subscriptions.add(
        session.becomingNoisyEventStream.listen((_) => pause()),
      );
      _subscriptions.add(session.interruptionEventStream.listen(_onInterruption));
    } catch (e) {
      debugPrint('Radio: audio session setup failed: $e');
    }
  }

  // --- Commands -------------------------------------------------------------

  Future<void> play(RadioStation station) async {
    final generation = ++_generation;
    _retryTimer?.cancel();
    _retries = 0;
    _wantsPlaying = true;
    CacheHelper.saveData(key: _lastStationKey, value: station.id);
    state = state.copyWith(station: station, status: RadioStatus.connecting);
    await _start(station, generation);
  }


  Future<void> pause() async {
    _retryTimer?.cancel();
    _wantsPlaying = false;
    _generation++;
    if (state.station == null || !mounted) return;
    state = state.copyWith(status: RadioStatus.paused);
    try {
      await _player.stop();
    } catch (_) {}
  }

  /// Main button: pause when audio is on, otherwise (re)start the station.
  Future<void> toggle(List<RadioStation> fallbackQueue) async {
    if (state.isActive) {
      await pause();
      return;
    }
    final station =
        state.station ?? (fallbackQueue.isEmpty ? null : fallbackQueue.first);
    if (station != null) await play(station);
  }

  Future<void> next(List<RadioStation> queue) => _step(queue, 1);

  Future<void> previous(List<RadioStation> queue) => _step(queue, -1);

  Future<void> _step(List<RadioStation> queue, int delta) async {
    if (queue.isEmpty) return;
    final current = queue.indexWhere((s) => s.id == state.station?.id);
    final index = current == -1
        ? 0
        : (current + delta + queue.length) % queue.length;
    await play(queue[index]);
  }

  void setSleepTimer(Duration? duration) {
    _sleepTimer?.cancel();
    if (duration == null) {
      state = state.copyWith(clearSleep: true);
      return;
    }
    state = state.copyWith(sleepEndsAt: DateTime.now().add(duration));
    _sleepTimer = Timer(duration, _onSleepElapsed);
  }

  // --- Internals ------------------------------------------------------------

  Future<void> _start(RadioStation station, int generation) async {
    if (!await ConnectivityUtils.hasInternet()) {
      if (mounted && generation == _generation) {
        state = state.copyWith(status: RadioStatus.offline);
      }
      return;
    }
    try {
      final session = await AudioSession.instance;
      await session.setActive(true);
      await _player
          .setAudioSource(AudioSource.uri(Uri.parse(station.url)))
          .timeout(_connectTimeout);
      if (!mounted || generation != _generation) return;
      // play() only completes when playback ends, so it must not be awaited.
      unawaited(_player.play());
    } catch (e) {
      if (generation == _generation) _onFailure(e);
    }
  }

  void _onPlayerState(PlayerState playerState) {
    if (!mounted || state.station == null || !_wantsPlaying) return;
    switch (playerState.processingState) {
      case ProcessingState.loading:
        _setStatus(RadioStatus.connecting);
      case ProcessingState.buffering:
        _setStatus(RadioStatus.buffering);
      case ProcessingState.ready:
        if (playerState.playing) {
          _retries = 0;
          _setStatus(RadioStatus.playing);
        }
      case ProcessingState.completed:
        // A live stream should never end; treat it as a dropped connection.
        _onFailure('stream ended');
      case ProcessingState.idle:
        break;
    }
  }

  void _setStatus(RadioStatus status) {
    if (mounted && state.status != status) {
      state = state.copyWith(status: status);
    }
  }

  void _onFailure(Object error) {
    final station = state.station;
    if (!mounted || !_wantsPlaying || station == null) return;
    debugPrint('Radio: playback failed ($error)');

    if (_retries < _maxRetries) {
      _retries++;
      state = state.copyWith(status: RadioStatus.connecting);
      final generation = _generation;
      _retryTimer?.cancel();
      _retryTimer = Timer(
        Duration(seconds: 2 * _retries),
        () => _start(station, generation),
      );
      return;
    }

    _wantsPlaying = false;
    state = state.copyWith(status: RadioStatus.error);
    _player.stop().catchError((_) {});
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final online = !results.contains(ConnectivityResult.none);
    final station = state.station;
    if (!mounted || !online || station == null) return;
    // Came back online while we were waiting for it: pick up where we left off.
    if (_wantsPlaying && state.status == RadioStatus.offline) {
      _retries = 0;
      state = state.copyWith(status: RadioStatus.connecting);
      _start(station, ++_generation);
    }
  }

  void _onInterruption(AudioInterruptionEvent event) {
    if (!mounted) return;
    if (event.begin) {
      if (event.type == AudioInterruptionType.duck) {
        _player.setVolume(0.3);
      } else if (state.isActive) {
        _resumeAfterInterruption = true;
        pause();
      }
    } else {
      if (event.type == AudioInterruptionType.duck) {
        _player.setVolume(1);
      } else if (_resumeAfterInterruption && state.station != null) {
        _resumeAfterInterruption = false;
        play(state.station!);
      }
    }
  }

  Future<void> _onSleepElapsed() async {
    if (!mounted) return;
    for (var step = 9; step >= 0; step--) {
      await _player.setVolume(step / 10);
      await Future<void>.delayed(const Duration(milliseconds: 150));
      if (!mounted) return;
    }
    await pause();
    await _player.setVolume(1);
    if (mounted) state = state.copyWith(clearSleep: true);
  }

  void _syncNotification(RadioState s) {
    final station = s.station;
    if (station != null && s.isActive) {
      RadioNotificationService.show(station.name, playing: s.isPlaying);
    } else {
      RadioNotificationService.hide();
    }
  }

  @override
  void dispose() {
    RadioNotificationService.hide();
    RadioNotificationService.onStop = null;
    _retryTimer?.cancel();
    _sleepTimer?.cancel();
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _player.dispose();
    super.dispose();
  }
}
