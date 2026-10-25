import 'package:audio_service/audio_service.dart';
import '../models/radio_station.dart';
import '../providers/radio_controller.dart';

/// Shows the radio in the system media notification and on the lock screen, and
/// keeps the playback in a foreground service so Android does not stop it when
/// the app is left.
///
/// The radio controller still owns the real player. This handler only mirrors
/// its state and forwards the buttons of the notification back to it.
class RadioAudioHandler extends BaseAudioHandler {
  RadioAudioHandler();

  Future<void> Function() _onPlay = () async {};
  Future<void> Function() _onPause = () async {};
  Future<void> Function() _onStop = () async {};

  /// Points the notification buttons at the radio screen that is open now. The
  /// handler lives as long as the app, the controller does not.
  void bind({
    required Future<void> Function() onPlay,
    required Future<void> Function() onPause,
    required Future<void> Function() onStop,
  }) {
    _onPlay = onPlay;
    _onPause = onPause;
    _onStop = onStop;
  }

  /// Whether the Quran library already started the app's one [AudioService].
  /// Only one handler can exist per app, so then the radio plays without a
  /// notification of its own rather than replace the Quran player's.
  static bool get isAudioServiceTaken {
    try {
      // ignore: deprecated_member_use
      AudioService.playbackState;
      return true;
    } catch (_) {
      return false;
    }
  }

  static const AudioServiceConfig config = AudioServiceConfig(
    androidNotificationChannelId: 'com.zaid.thekr_app.radio',
    androidNotificationChannelName: 'تشغيل الإذاعة',
    androidNotificationOngoing: true,
    androidStopForegroundOnPause: true,
  );

  /// Mirrors the controller's state into the notification.
  void show(RadioStation? station, RadioStatus status) {
    if (station == null) return;

    final shown = switch (status) {
      RadioStatus.idle ||
      RadioStatus.offline ||
      RadioStatus.error => false,
      _ => true,
    };
    if (!shown) {
      hide();
      return;
    }

    mediaItem.add(
      MediaItem(id: station.id, title: station.name, artist: station.subtitle),
    );

    final playing =
        status == RadioStatus.playing ||
        status == RadioStatus.connecting ||
        status == RadioStatus.buffering;

    playbackState.add(
      PlaybackState(
        controls: [
          playing ? MediaControl.pause : MediaControl.play,
          MediaControl.stop,
        ],
        androidCompactActionIndices: const [0, 1],
        processingState: switch (status) {
          RadioStatus.connecting => AudioProcessingState.loading,
          RadioStatus.buffering => AudioProcessingState.buffering,
          _ => AudioProcessingState.ready,
        },
        playing: playing,
      ),
    );
  }

  /// Removes the notification.
  void hide() {
    playbackState.add(
      PlaybackState(
        processingState: AudioProcessingState.idle,
        playing: false,
      ),
    );
  }

  @override
  Future<void> play() => _onPlay();

  @override
  Future<void> pause() => _onPause();

  @override
  Future<void> stop() async {
    await _onStop();
    hide();
  }
}
