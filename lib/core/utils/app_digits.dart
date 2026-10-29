/// How numbers are written in the app: always with the digits 0-9.
///
/// The one exception is the verse number inside Quran text (see
/// `QuranText.digits`), which keeps the traditional Arabic-Indic digits as part
/// of the Quran's own look.
class AppDigits {
  AppDigits._();

  /// [number] in digits 0-9.
  static String of(int number) => number.toString();

  /// [text] with any Arabic-Indic digits (٠-٩, ۰-۹) turned into 0-9. For text
  /// that a library formats with the Arabic locale, such as dates.
  static String latin(String text) {
    final out = StringBuffer();
    for (final unit in text.runes) {
      if (unit >= 0x0660 && unit <= 0x0669) {
        out.writeCharCode(0x30 + unit - 0x0660);
      } else if (unit >= 0x06F0 && unit <= 0x06F9) {
        out.writeCharCode(0x30 + unit - 0x06F0);
      } else if (unit == 0x066A) {
        out.write('%'); // Arabic percent sign
      } else {
        out.writeCharCode(unit);
      }
    }
    return out.toString();
  }
}
