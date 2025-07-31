import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:thekr_app/shard/constant/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';




class CustomDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onYes;
  final VoidCallback onCancel;

  const CustomDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onYes,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return BaseAnimationListView(index: 0,
        verticalOffset: 200,
        horizontalOffset: 0,
        child: CupertinoAlertDialog(
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 15),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: onYes,
              isDestructiveAction: true,
              child: const Text('نعم'),
            ),
            CupertinoDialogAction(
              onPressed: onCancel,
              isDefaultAction: true,
              child: const Text('لا'),
            ),
          ],
          insetAnimationCurve: Curves.easeInOut,
          insetAnimationDuration: const Duration(milliseconds: 300),
        ));
  }
}


class BaseAnimationListView extends StatelessWidget {
  BaseAnimationListView({
    super.key,
    required this.index,
    required this.child,
    this.duration,
    this.horizontalOffset = 200,
    this.verticalOffset = 0,
  });

  final int index;
  final Widget child;
  final int? duration;
  final double horizontalOffset;
  final double verticalOffset;

  @override
  Widget build(BuildContext context) {
    return AnimationConfiguration.staggeredList(
      position: index,
      duration: Duration(milliseconds: duration ?? 800),
      child: SlideAnimation(
        horizontalOffset: horizontalOffset,
        verticalOffset: verticalOffset,
        child: FadeInAnimation(
          child: child,
        ),
      ),
    );
  }
}







class CustomTextFormAuth extends StatelessWidget {
  final String hinttext;
  final String labeltext;
  final IconData? iconData;
  final TextEditingController? mycontroller;
  final bool isNumber;
  final bool? obscureText;
  final void Function()? onTapIcon;
  final IconData prefixIcon;
  final String? Function(String?) valid;
  final IconData? suffix;
  final Function? suffixPressed;

  const CustomTextFormAuth(
      {Key? key,
        this.obscureText,
        this.onTapIcon,
        required this.hinttext,
        required this.labeltext,
        this.iconData,
        required this.mycontroller,
        required this.isNumber,
        required this.prefixIcon,
        required this.valid ,
        this.suffix,
        this.suffixPressed,

      })
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        keyboardType: isNumber
            ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        controller: mycontroller,
        obscureText: obscureText == null || obscureText == false ? false : true,
        validator: valid,
        decoration: InputDecoration(
            hintText: hinttext,
            hintStyle: const TextStyle(fontSize: 14),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            contentPadding:
            const EdgeInsets.symmetric(vertical: 5, horizontal: 30),
            label: Container(
                margin: const EdgeInsets.symmetric(horizontal: 9),
                child: Text(labeltext)),
            prefixIcon: Icon(prefixIcon),
            suffixIcon: suffix != null
                ? IconButton(
              onPressed: suffixPressed!(),
              icon: Icon(
                suffix,
              ),
            )
                : null,
            border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(30))),
      ),
    );
  }
}


// enum
enum ToastStates { SUCCESS, ERROR, WARNING }

Color chooseToastColor(ToastStates state) {
  Color color;

  switch (state) {
    case ToastStates.SUCCESS:
      color = Colors.green;
      break;
    case ToastStates.ERROR:
      color = Colors.red;
      break;
    case ToastStates.WARNING:
      color = MyTheme.primaryColor;
      break;
  }

  return color;
}



Widget defaultButton({
  double width = double.infinity,
  Color background = MyTheme.primaryColor,
  bool isUpperCase = true,
  double radius = 3.0,
  required Function fun,
  required String text,
}) =>
    Container(
      width: width,
      height: 50.0,
      child: MaterialButton(
        onPressed: () {
          fun();
        },
        child: Text(
          isUpperCase ? text.toUpperCase() : text,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          radius,
        ),
        color: background,
      ),
    );

Widget defaultFormField({
  required TextEditingController controller,
  required TextInputType type,
  Function()? onSubmit,
  Function()? onChange,
  Function()? onTap,
  bool isPassword = false,
  required Function validate,
  required String label,
  required IconData prefix,
  IconData? suffix,
  Function()? suffixPressed,
  bool isClickable = true,
  String? suffixtext,
  int? maxlenght,
}) =>
    TextFormField(
      controller: controller,
      keyboardType: type,
      obscureText: isPassword,
      enabled: isClickable,
      // onFieldSubmitted: onSubmit,
      // onChanged: onChange,
      onTap: onTap,
      maxLength: maxlenght,
      validator: (value) {
        validate(value);
      },
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffixtext,
        prefixIcon: Icon(
          prefix,
        ),
        suffixIcon: suffix != null
            ? IconButton(
                onPressed: suffixPressed,
                icon: Icon(
                  suffix,
                ),
              )
            : null,
        border: OutlineInputBorder(),
      ),
    );

// Widget defaultFormField({
//   required TextEditingController controller,
//   required TextInputType type,
//   required Function onSubmit,
//   Function? onChange,
//   Function? onTap,
//   bool isPassword = false,
//   required Function validate,
//   required String label,
//   required IconData prefix,
//   IconData? suffix,
//   Function? suffixPressed,
//   bool isClickable = true,
// }) =>
//     TextFormField(
//       keyboardType: type,
//       obscureText: isPassword,
//       enabled: isClickable,
//       onFieldSubmitted: onSubmit(),
//       onChanged: onChange!(),
//       onTap: onTap!(),
//       validator: validate(),
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: Icon(
//           prefix,
//         ),
//         suffixIcon: suffix != null
//             ? IconButton(
//           onPressed: suffixPressed!(),
//           icon: Icon(
//             suffix,
//           ),
//         )
//             : null,
//         border: OutlineInputBorder(),
//       ),
//     );

Widget ff({
  TextInputType? type,
  String? hint,
  IconData? pref,
  Function? onch,
}) =>
    TextFormField(
      validator: (value) {
        if (value!.isEmpty) {
          return ' kdjfkjljf ';
        }
        return null;
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        isDense: true,
        suffixText: "+967",
        prefixIcon: Icon(pref),
        label: Text('kj'),
        hintText: hint,
      ),
      maxLength: 9,
      keyboardType: type,
      onChanged: onch!(),
    );

//////////////////////////// //

Widget appbar({
  required String title,
  required String image,
  Function()? add,
}) =>
    Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 15, 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            child: Image.asset(
              image,
              width: 85,
            ),
            backgroundColor: Colors.transparent,
          ),
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey.withOpacity(0.1),
                child: FittedBox(
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.add,
                      color: Colors.black,
                      size: 26,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: Colors.grey.withOpacity(0.1),
                child: FittedBox(
                  child: IconButton(
                    onPressed: add!(),
                    icon: const Icon(
                      Icons.brightness_4,
                      color: Colors.black,
                      size: 26,
                    ),
                  ),
                ),
              ),
              Badge(
                child: IconButton (
                  onPressed: (){},
                   icon: Icon( Icons.shopping_cart_outlined)),
                label: Text('7'),
              ),
            ],
          ),
        ],
      ),
    );




Widget section(
{
  Function()? fun,
   String? title
}
    )=>   Padding(
  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 5),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        children:  [
          CircleAvatar(
            // backgroundColor: LightColors.yellow,
            radius: 13,
            child: FittedBox(
              child: Icon(
                CupertinoIcons.collections,
                color: Colors.white,
                size: 15,
              ),
            ),
          ),
          SizedBox(width: 3),
          Text( title??"",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      // TextButton.icon(
      //   onPressed:fun,
      //   label: const Icon(
      //     Icons.arrow_back_ios_new_rounded,
      //     size: 18,
      //     color: MyColors.primaryColor,
      //   ),
      //   icon: const Text(
      //     style: TextStyle(color: MyColors.primaryColor),
      //     "عرض الكل",
      //   ),
      // ),
    ],
  ),
);