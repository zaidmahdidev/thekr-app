import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:thekr_app/core/utils/app_digits.dart';
import 'package:thekr_app/core/utils/quran_text.dart';

void main() {
  test('numbers are written with 0-9', () {
    expect(AppDigits.of(0), '0');
    expect(AppDigits.of(1234), '1234');
    expect(AppDigits.of(40), '40');
  });

  test('Arabic-Indic and Persian digits become 0-9, other text is kept', () {
    expect(AppDigits.latin('٠١٢٣٤٥٦٧٨٩'), '0123456789');
    expect(AppDigits.latin('۰۱۲۳۴۵۶۷۸۹'), '0123456789');
    expect(AppDigits.latin('آخر نسخة: ٢٦ أكتوبر، ٤:٣٠ م'), 'آخر نسخة: 26 أكتوبر، 4:30 م');
    expect(AppDigits.latin('٧٥٪'), '75%');
    expect(AppDigits.latin('Time 5:02'), 'Time 5:02');
  });

  test('a date formatted in Arabic comes out with 0-9', () async {
    await initializeDateFormatting('ar', null);
    final text = AppDigits.latin(DateFormat('d MMM، h:mm a', 'ar').format(DateTime(2026, 10, 26, 16, 30)));
    expect(RegExp('[\u0660-\u0669]').hasMatch(text), false);
    expect(text.contains('26'), true);
    expect(text.contains('4:30'), true);
  });

  test('verse numbers inside Quran text keep Arabic-Indic digits', () {
    expect(QuranText.digits(12), '١٢');
  });
}
