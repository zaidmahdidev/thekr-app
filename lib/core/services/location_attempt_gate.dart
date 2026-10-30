/// Decides when the app may ask the phone for its position.
///
/// Prayer times are calculated often (every time the app is opened, pulled to
/// refresh, or a setting changes). If each calculation without a saved
/// position asked the phone again, the requests would pile up and the user
/// would be bothered over and over. This gate allows one attempt at a time, and
/// automatic attempts only now and then.
class LocationAttemptGate {
  LocationAttemptGate({
    this.minInterval = const Duration(minutes: 10),
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  /// The least time between two automatic attempts.
  final Duration minInterval;
  final DateTime Function() _clock;

  DateTime? _lastAttempt;
  bool _inFlight = false;

  bool get inFlight => _inFlight;

  /// For an attempt the app starts by itself. False if one is running, or a
  /// recent one already tried.
  bool tryStartAutomatic() {
    if (_inFlight) return false;
    final now = _clock();
    final last = _lastAttempt;
    if (last != null && now.difference(last) < minInterval) return false;
    _inFlight = true;
    _lastAttempt = now;
    return true;
  }

  /// For an attempt the user asked for (pull to refresh, a button). It does
  /// not wait for the interval, only for a running attempt to finish.
  bool tryStartManual() {
    if (_inFlight) return false;
    _inFlight = true;
    _lastAttempt = _clock();
    return true;
  }

  /// Call when the attempt is over, whether it worked or not.
  void finish() => _inFlight = false;
}
