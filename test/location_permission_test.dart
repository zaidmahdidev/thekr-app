import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thekr_app/core/services/cache_helper.dart';
import 'package:thekr_app/core/services/location_permission_service.dart';

class FakeGateway implements LocationPermissionGateway {
  FakeGateway({
    required this.current,
    this.answer = LocationPermission.whileInUse,
    this.foreground = true,
  });

  LocationPermission current;
  LocationPermission answer;
  bool foreground;

  final List<String> calls = [];

  @override
  Future<LocationPermission> check() async {
    calls.add('check');
    return current;
  }

  @override
  Future<LocationPermission> request() async {
    calls.add('request');
    current = answer;
    return answer;
  }

  @override
  Future<void> readLocation() async => calls.add('read');

  @override
  bool get isInForeground => foreground;
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await CacheHelper.init();
  });

  test('first launch: asks, then reads the location when it is given', () async {
    final gateway = FakeGateway(current: LocationPermission.denied);
    final service = LocationPermissionService(gateway: gateway);

    expect(await service.askOnce(), LocationPromptResult.granted);
    expect(gateway.calls, ['check', 'request', 'read']);
    expect(service.alreadyAsked, true);
  });

  test('a refusal is final: it never asks again by itself', () async {
    final gateway = FakeGateway(
      current: LocationPermission.denied,
      answer: LocationPermission.denied,
    );
    final service = LocationPermissionService(gateway: gateway);

    expect(await service.askOnce(), LocationPromptResult.denied);
    expect(gateway.calls, ['check', 'request']); // the location is not read

    gateway.calls.clear();
    expect(await service.askOnce(), LocationPromptResult.notNeeded);
    expect(gateway.calls, isEmpty);
  });

  test('already given: nothing is asked', () async {
    final gateway = FakeGateway(current: LocationPermission.whileInUse);
    final service = LocationPermissionService(gateway: gateway);
    expect(await service.askOnce(), LocationPromptResult.notNeeded);
    expect(gateway.calls, ['check']);
  });

  test('refused for good in the settings: the dialog cannot show, so no ask', () async {
    final gateway = FakeGateway(current: LocationPermission.deniedForever);
    final service = LocationPermissionService(gateway: gateway);
    expect(await service.askOnce(), LocationPromptResult.notNeeded);
    expect(gateway.calls, ['check']);
  });

  test('waits for the notification permissions to finish first', () async {
    final gateway = FakeGateway(current: LocationPermission.denied);
    final service = LocationPermissionService(gateway: gateway);
    final other = Completer<bool>();

    final result = service.askOnce(after: other.future);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(gateway.calls, isEmpty); // still waiting, no second system request

    other.complete(true);
    expect(await result, LocationPromptResult.granted);
    expect(gateway.calls, ['check', 'request', 'read']);
  });

  test('a failing notification request does not block the location one', () async {
    final gateway = FakeGateway(current: LocationPermission.denied);
    final service = LocationPermissionService(gateway: gateway);
    final result = await service.askOnce(
      after: Future<bool>.error(StateError('boom')),
    );
    expect(result, LocationPromptResult.granted);
  });

  test('app not in front (a settings page is open): waits, asks later', () async {
    final gateway = FakeGateway(
      current: LocationPermission.denied,
      foreground: false,
    );
    final service = LocationPermissionService(gateway: gateway);

    expect(await service.askOnce(), LocationPromptResult.deferred);
    expect(gateway.calls, isEmpty);
    expect(service.alreadyAsked, false); // so it will try again

    gateway.foreground = true;
    expect(await service.askOnce(), LocationPromptResult.granted);
  });

  test('two calls at once ask only once', () async {
    final gateway = FakeGateway(current: LocationPermission.denied);
    final service = LocationPermissionService(gateway: gateway);

    final results = await Future.wait([service.askOnce(), service.askOnce()]);
    expect(results.contains(LocationPromptResult.granted), true);
    expect(gateway.calls.where((c) => c == 'request').length, 1);
  });
}
