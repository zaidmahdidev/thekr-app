import 'umrah_steps_data.dart';

/// Plain-text summary of the guide, for sharing or printing so the pilgrim can
/// carry it on paper instead of looking at the phone.
class UmrahSummary {
  UmrahSummary._();

  static String build() {
    final buffer = StringBuffer()
      ..writeln('ملخص مناسك العمرة')
      ..writeln()
      ..writeln('نصيحة: اقرأ هذا الملخص قبل السفر، وأثناء العمرة تفرّغ للعبادة.')
      ..writeln();

    for (final step in UmrahStepsData.all) {
      buffer
        ..writeln('${step.number}. ${step.title}')
        ..writeln('   ${step.summary}');
      for (final line in step.how) {
        buffer.writeln('   - $line');
      }
      buffer.writeln();
    }

    buffer
      ..writeln('التلبية:')
      ..writeln(UmrahStepsData.talbiyah)
      ..writeln()
      ..writeln('المواقيت: ذو الحليفة لأهل المدينة، الجحفة لأهل الشام ومصر والمغرب، '
          'قرن المنازل لأهل نجد، يلملم لأهل اليمن، ذات عرق لأهل العراق.')
      ..writeln()
      ..writeln('تقبّل الله منك.');
    return buffer.toString();
  }
}
