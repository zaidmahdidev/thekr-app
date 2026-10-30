import 'package:flutter_test/flutter_test.dart';
import 'package:thekr_app/core/services/location_attempt_gate.dart';

void main() {
  late DateTime now;
  late LocationAttemptGate gate;

  setUp(() {
    now = DateTime(2026, 10, 30, 12);
    gate = LocationAttemptGate(
      minInterval: const Duration(minutes: 10),
      clock: () => now,
    );
  });

  test('the first automatic attempt is allowed', () {
    expect(gate.tryStartAutomatic(), true);
    expect(gate.inFlight, true);
  });

  test('while one is running, no other starts (the dialogs piled up before)', () {
    expect(gate.tryStartAutomatic(), true);
    expect(gate.tryStartAutomatic(), false);
    expect(gate.tryStartAutomatic(), false);
    expect(gate.tryStartManual(), false);
  });

  test('automatic attempts are spaced out, even after one failed', () {
    expect(gate.tryStartAutomatic(), true);
    gate.finish(); // it failed, for example the user said "No thanks"

    // The next recalculation of the prayer times, a minute later: not again.
    now = now.add(const Duration(minutes: 1));
    expect(gate.tryStartAutomatic(), false);

    now = now.add(const Duration(minutes: 8));
    expect(gate.tryStartAutomatic(), false); // 9 minutes in

    now = now.add(const Duration(minutes: 2));
    expect(gate.tryStartAutomatic(), true); // 11 minutes in
  });

  test('a user request is not held back by the interval', () {
    expect(gate.tryStartAutomatic(), true);
    gate.finish();
    now = now.add(const Duration(seconds: 5));
    expect(gate.tryStartManual(), true);
    gate.finish();
  });

  test('after finishing, a user request can start again at once', () {
    expect(gate.tryStartManual(), true);
    gate.finish();
    expect(gate.tryStartManual(), true);
  });

  test('a manual attempt also counts for the automatic interval', () {
    expect(gate.tryStartManual(), true);
    gate.finish();
    now = now.add(const Duration(minutes: 2));
    expect(gate.tryStartAutomatic(), false);
  });
}
