import 'hajj_days_data.dart';
import 'hajj_types_data.dart';

/// Plain-text summary of the guide, for sharing or printing so the pilgrim can
/// carry it on paper instead of looking at the phone.
class HajjSummary {
  HajjSummary._();

  static String build() {
    final buffer = StringBuffer()
      ..writeln('ملخص مناسك الحج')
      ..writeln()
      ..writeln('نصيحة: اقرأ هذا الملخص قبل السفر، وأثناء الحج تفرّغ للعبادة.')
      ..writeln()
      ..writeln('أنواع النسك:');
    for (final type in HajjTypesData.all) {
      buffer.writeln('- ${type.title}: ${type.talbiyah}');
    }
    buffer.writeln();

    for (final day in HajjDaysData.all) {
      buffer
        ..writeln('${day.number}. ${day.title} (${day.dayLabel})')
        ..writeln('   ${day.summary}');
      for (final rite in day.rites) {
        buffer.writeln('   ${rite.title}:');
        for (final step in rite.steps) {
          buffer.writeln('   - $step');
        }
      }
      buffer.writeln();
    }

    buffer.writeln('تقبّل الله منك.');
    return buffer.toString();
  }
}
