import 'package:hugeicons/hugeicons.dart';
import '../models/umrah_models.dart';

/// Packing list for the pilgrim. The ids are stored with the user's ticks, so
/// they must stay stable even if a label is reworded.
class UmrahChecklistData {
  UmrahChecklistData._();

  static const List<ChecklistGroup> groups = [
    ChecklistGroup(
      title: 'الوثائق والتصاريح',
      icon: HugeIcons.strokeRoundedPassport,
      items: [
        ChecklistItem(
          id: 'doc_passport',
          label: 'جواز السفر ساري المفعول',
          hint: 'تأكد أن صلاحيته لا تقل عن ستة أشهر.',
        ),
        ChecklistItem(
          id: 'doc_visa',
          label: 'تأشيرة العمرة',
          hint: 'تُصدر عبر المنصات المعتمدة من وزارة الحج والعمرة.',
        ),
        ChecklistItem(
          id: 'doc_nusuk',
          label: 'تطبيق «نسك» وتصريح العمرة',
          hint: 'المنصة الرسمية لحجز مواعيد العمرة وإصدار التصاريح.',
        ),
        ChecklistItem(id: 'doc_booking', label: 'حجز السكن والنقل'),
        ChecklistItem(id: 'doc_insurance', label: 'التأمين الصحي (إن لزم)'),
        ChecklistItem(
          id: 'doc_copies',
          label: 'نسخ ورقية ورقمية من الوثائق',
        ),
      ],
    ),
    ChecklistGroup(
      title: 'ملابس الإحرام',
      icon: HugeIcons.strokeRoundedShirt01,
      items: [
        ChecklistItem(
          id: 'cloth_ihram',
          label: 'إزار ورداء للإحرام (للرجال)',
          hint: 'يُستحب أن يكون معك طقم احتياطي.',
        ),
        ChecklistItem(
          id: 'cloth_women',
          label: 'ملابس ساترة فضفاضة (للنساء)',
        ),
        ChecklistItem(
          id: 'cloth_sandals',
          label: 'نعلان مريحان',
          hint: 'السنة للرجل أن يحرم في نعلين.',
        ),
        ChecklistItem(
          id: 'cloth_belt',
          label: 'هميان أو حزام لحفظ النقود (للرجال)',
        ),
        ChecklistItem(
          id: 'cloth_bag',
          label: 'كيس لحمل الحذاء عند دخول المسجد',
        ),
      ],
    ),
    ChecklistGroup(
      title: 'النظافة (غير معطّرة)',
      icon: HugeIcons.strokeRoundedDroplet,
      items: [
        ChecklistItem(
          id: 'care_soap',
          label: 'صابون وشامبو غير معطّرين',
          hint: 'الأحوط تجنّب العطر بعد الإحرام.',
        ),
        ChecklistItem(
          id: 'care_wipes',
          label: 'مناديل ومعقّم غير معطّرين',
        ),
        ChecklistItem(id: 'care_tools', label: 'فرشاة ومعجون أسنان وسواك'),
        ChecklistItem(id: 'care_towel', label: 'منشفة صغيرة'),
      ],
    ),
    ChecklistGroup(
      title: 'الصحة',
      icon: HugeIcons.strokeRoundedMedicine01,
      items: [
        ChecklistItem(
          id: 'health_meds',
          label: 'الأدوية الشخصية مع وصفاتها',
        ),
        ChecklistItem(
          id: 'health_sunscreen',
          label: 'واقي شمس غير معطّر',
        ),
        ChecklistItem(
          id: 'health_umbrella',
          label: 'مظلة للاستظلال',
          hint: 'الاستظلال بالمظلة جائز للمحرم.',
        ),
        ChecklistItem(
          id: 'health_water',
          label: 'زجاجة ماء قابلة لإعادة التعبئة',
        ),
      ],
    ),
    ChecklistGroup(
      title: 'أغراض أخرى',
      icon: HugeIcons.strokeRoundedBackpack01,
      items: [
        ChecklistItem(id: 'misc_charger', label: 'شاحن وبطارية محمولة'),
        ChecklistItem(id: 'misc_cash', label: 'نقود وبطاقة مصرفية'),
        ChecklistItem(id: 'misc_prayer', label: 'سجادة صلاة صغيرة'),
        ChecklistItem(id: 'misc_book', label: 'كتيّب أدعية أو هذا الدليل'),
        ChecklistItem(
          id: 'misc_contact',
          label: 'بطاقة بعنوان السكن ورقم المرافق',
          hint: 'تفيدك إن تهت في الزحام.',
        ),
      ],
    ),
  ];

  static int get totalItems =>
      groups.fold(0, (sum, group) => sum + group.items.length);
}
