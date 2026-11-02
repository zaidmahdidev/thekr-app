import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thekr_app/core/services/cache_helper.dart';
import 'package:thekr_app/features/misbaha/providers/misbaha_provider.dart';
import 'package:thekr_app/features/sync/services/sync_rules.dart';

Future<MisbahaNotifier> _fresh([Map<String, Object> saved = const {}]) async {
  SharedPreferences.setMockInitialValues(saved);
  await CacheHelper.init();
  return MisbahaNotifier();
}

void main() {
  test('a written dhikr is added, counted and saved', () async {
    final n = await _fresh();
    expect(n.addCustom('اللهم صلِّ على محمد'), isNull);
    expect(n.state.currentZikr.isCustom, true);
    n.increment();
    n.increment();
    expect(n.state.count, 2);

    final again = await _fresh({
      for (final k in CacheHelper.sharedPreferences.getKeys())
        k: CacheHelper.sharedPreferences.get(k)!,
    });
    expect(again.state.customAzkar.single.label, 'اللهم صلِّ على محمد');
    final id = again.state.customAzkar.single.id;
    expect(again.state.zikrCounts[id], 2);
  });

  test('empty, long, repeated and too many are refused or cut', () async {
    final n = await _fresh();
    expect(n.addCustom('   '), isNotNull);
    expect(n.addCustom('سبحان الله'), isNotNull); // already a built-in one

    n.addCustom('ا' * 200);
    expect(n.state.customAzkar.single.label.length, maxCustomZikrLength);

    n.addCustom('مع\nسطرين');
    expect(n.state.customAzkar.last.label, 'مع سطرين');

    for (var i = 0; i < 20; i++) {
      n.addCustom('ذكر $i');
    }
    expect(n.state.customAzkar.length, maxCustomAzkar);
  });

  test('deleting one goes back to the first built-in dhikr', () async {
    final n = await _fresh();
    n.addCustom('ذكري');
    final mine = n.state.currentZikr;
    n.deleteCustom(mine);
    expect(n.state.customAzkar, isEmpty);
    expect(n.state.currentZikr, builtInAzkar.first);
  });

  test('built-in counts saved before this feature are kept', () async {
    final n = await _fresh({'misbaha_zikr_allahuAkbar': 7});
    expect(n.state.zikrCounts['allahuAkbar'], 7);
  });

  test('a bad or oversized list from a backup is cleaned', () async {
    final big = [
      for (var i = 0; i < 30; i++) {'id': 'c$i', 'label': 'ب' * 100},
      {'id': 'x', 'label': ''},
    ];
    final n = await _fresh({'misbaha_custom_azkar': json.encode(big)});
    expect(n.state.customAzkar.length, maxCustomAzkar);
    expect(
      n.state.customAzkar.every((z) => z.label.length <= maxCustomZikrLength),
      true,
    );

    final broken = await _fresh({'misbaha_custom_azkar': 'not json'});
    expect(broken.state.customAzkar, isEmpty);
  });

  test('the list and its counts go into the backup', () {
    expect(SyncRules.kindOf('misbaha_custom_azkar'), isNotNull);
    expect(SyncRules.kindOf('misbaha_zikr_c123'), isNotNull);
  });
}
