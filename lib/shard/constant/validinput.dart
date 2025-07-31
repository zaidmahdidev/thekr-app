import 'package:get/get.dart';

import '../components/tools.dart';

validInput(String val, int min, int max, String type) {
  if (type == "username") {
    if (!GetUtils.isUsername(val)) {
      return "اسم مستخدم غير صحيح ";
    }
  }
  if (type == "email") {
    if (!GetUtils.isEmail(val)) {
      return "ايميل غير صحيح";
    }
  }

  if (type == "phone") {
    if (!GetUtils.isPhoneNumber(val)) {
      return "رقم هاتف غير صحيح";
    }
  }

  if (val.isEmpty) {
    return "يجب تعبئة الحقل";
  }

  if (val.length < min) {
    return " لا يجب ان يكون اصغر من $min" ;
  }

  if (val.length > max) {
    return " لا يجب ان يكون اكبر من $max";
  }
}
