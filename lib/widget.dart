

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:thekr_app/shard/components/tools.dart';
import 'package:thekr_app/shard/constant/theme.dart';
import 'package:readmore/readmore.dart';


class CustomContainer extends StatelessWidget {
   CustomContainer({Key? key , required this.title , this.subTitle , this.leading , this.trailing , this.fun}) : super(key: key);
  String title;
  String ?subTitle;
  String ?leading;
  String ?trailing;
  Function ?fun;

  @override
  Widget build(BuildContext context) {
    return BaseAnimationListView(index: 0,
        child: InkWell(
          onTap: () {
            fun!();
          },
          child: Container(
              margin: const EdgeInsets.all(5),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      MyTheme.primaryColor,
                      MyTheme.primaryColor,
                      MyTheme.primaryColor,
                    ]),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (leading != null)
                    CircleAvatar(
                        backgroundColor: Colors.transparent,
                        backgroundImage: const AssetImage('assets/images/around.png'),
                        child: Text(
                          '$leading',
                          style: const TextStyle(color: Colors.white),
                        ))
                  else const SizedBox(),
                  Column(
                    children: [
                      Text('$title',
                        style: MyTheme.textStyle22
                            .copyWith(color: Colors.orange), ),
                      if (subTitle != null)
                        const SizedBox(height: 7,)
                      else  const SizedBox(),
                      if (subTitle != null)
                        Text('$subTitle' ,style: const TextStyle(color: Colors.white),)
                      else  const SizedBox()
                    ],
                  ),
                  if (trailing != null)  Text('$trailing' , style: MyTheme.textStyle15.copyWith(color: Colors.white ))
                  else  const SizedBox()
                ],
              )),
        ));
  }
}



class CustomAzkarWidget extends StatelessWidget {
   CustomAzkarWidget({Key? key , required this.details , this.repet ,this.bless }) : super(key: key);
   String details;
   String ?bless;
   String ?repet;

  @override
  Widget build(BuildContext context) {
    return  BaseAnimationListView(index: 0,
        child: Stack(
          children: [
            Container(
                width: double.infinity,
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.only(top: 25 , left: 20 , right: 20 , bottom: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          MyTheme.primaryColor,
                          MyTheme.primaryColor,
                          MyTheme.primaryColor,
                        ])),
                child:Column(
                  children: [
                    Text(details , style: const TextStyle(color: Colors.white , fontSize: 15 , height: 2 , fontWeight: FontWeight.bold),textAlign: TextAlign.center ),
                    const SizedBox(height: 10,),


                    ReadMoreText(
                        bless!,
                        trimLines: 2,
                        textAlign: TextAlign.justify,
                        trimMode: TrimMode.Line,
                        trimCollapsedText: 'قراءة المزيد',
                        trimExpandedText: ' قراءة اقل',
                        lessStyle: const TextStyle(color:Colors.orange),
                        moreStyle: const TextStyle(color: Colors.orange),
                        style: const TextStyle(color: Colors.grey)
                    ),
                    const SizedBox(height: 10,),
                    if(repet != null)
                      Text("التكرار : $repet" , style: const TextStyle(color: Colors.orange),)
                    else const SizedBox()
                  ],
                )

            ),
            Positioned(
                top: 20,
                left: 20,
                child: InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: '$details' ));
                    showToast(text: 'تم النسخ' , textColor: MyTheme.primaryColor , bgColoe: Colors.white);
                  },
                  child: Icon(Icons.copy, color: Colors.white),
                )),
          ],
        ));
  }
}



void showToast({
  required String text,
  Color ?textColor = Colors.white,
  Color ?bgColoe = MyTheme.primaryColor,
}) =>
    Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 3,
      backgroundColor: bgColoe,
      textColor: textColor,
      fontSize: 16.0,
    );



///////////////////////////
//
// class CustomAppBarClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     final double curveHeight = 50.0; // زيادة ارتفاع المنحنى
//     final Path path = Path();
//     path.lineTo(0, size.height - curveHeight);
//     path.quadraticBezierTo(
//         size.width / 2, size.height, size.width, size.height - curveHeight);
//     path.lineTo(size.width, 0);
//     path.close();
//     return path;
//   }
//
//   @override
//   bool shouldReclip(CustomClipper<Path> oldClipper) => false;
// }
//
//
// appBar: PreferredSize(
// preferredSize: Size.fromHeight(kToolbarHeight + 100.0), // زيادة الارتفاع
// child: ClipPath(
// clipper: CustomAppBarClipper(),
// child: AppBar(
// title: Text(
// 'My App',
// style: TextStyle(
// fontSize: 24,
// fontWeight: FontWeight.bold,
// color: Colors.white,
// ),
// ),
// centerTitle: true,
// ),
// ),
// ),