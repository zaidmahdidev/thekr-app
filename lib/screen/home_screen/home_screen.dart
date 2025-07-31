import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:thekr_app/screen/hadith-_awawi/hadith_nawawi.dart';

import '../../network/local/cache_helper.dart';
import '../../shard/components/tools.dart';
import '../../shard/constant/theme.dart';
import '../asmaAllah_screen/asmaAllah_screen.dart';
import '../azkar_screen/azkar_screen.dart';
import '../husinAlMuslim_screen/husinAlMuslim_screen.dart';
import '../qiblah_screen/qiblah_screen.dart';
import '../quran_screen/quran_screen.dart';
import '../sura_screen/sura_screen.dart';




class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if(didPop){
          return;
        }
        _exitMethode(context);
      },
      child: SafeArea(
          child: Scaffold(
              backgroundColor: MyTheme.primaryColor,
              body: Column(
                children: [
                   Expanded(
                    flex: 2,
                    child: Stack(
                      children: [

                        const Image(
                          fit: BoxFit.fill,
                          width: double.infinity,
                          image: AssetImage('assets/images/hero.png'),
                        ),
                        Center(
                          child: Image(
                            width: 220,
                            fit: BoxFit.fill,
                            image: AssetImage('assets/images/quran_logo.png'),
                          ),
                        ),

                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: const BoxDecoration(

                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(60),
                          topRight: Radius.circular(60),
                        ),
                      ),
                      padding: const EdgeInsets.only(bottom: 50),
                      child: Column(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                CategoryWidget(
                                    title: "القران الكريم",
                                    imgUrl: 'assets/images/quran.png',
                                    fun: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SurahScreen(currentPage: CacheHelper.getData(key: 'pageNumber') ??1),
                                        ),
                                      );
                                      // Navigator.push(
                                      //     context,
                                      //     MaterialPageRoute(
                                      //       builder: (context) =>
                                      //           QuranScreenn(),
                                      //     ));
                                    }),
                                CategoryWidget(
                                    title: "الاذكار",
                                    imgUrl: 'assets/images/praying.png',
                                    fun: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => AzkarScreen(),
                                          ));
                                    }),
                                CategoryWidget(
                                    title: "حصن المسلم",
                                    imgUrl: 'assets/images/husnalmoslem.png',
                                    fun: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                HusinAlMuslimScreen(),
                                          ));
                                    }),
                              ],
                            ),
                          ),

                          Expanded(
                            child: Row(
                              children: [
                                CategoryWidget(
                                    title: "الاربعين النووية",
                                    imgUrl: 'assets/images/hadithNawawi.webp',
                                    fun: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const HadithNawawiScreen(),
                                          ));
                                    }),
                                CategoryWidget(
                                    title: "أسماء الله",
                                    imgUrl: 'assets/images/AllahNames.png',
                                    fun: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AsmaAllahScreen(),
                                          ));
                                    }),
                                CategoryWidget(
                                    title: "إتجاة القبلة",
                                    imgUrl: 'assets/images/keblah.png',
                                    fun: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                QiblahScreen(),
                                          ));
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ))),
    );
  }


  void _exitMethode(BuildContext context)  {
    showDialog(
        context: context,
        builder: (context) => CustomDialog(title: 'تنويه',
          message:  'هل أنت متأكد أنك تريد الخروج؟',
          onYes: () => SystemNavigator.pop()  , onCancel: () =>  Navigator.pop(context) ,)
    );
  }


}


class CategoryWidget extends StatelessWidget {
  CategoryWidget({super.key, required this.imgUrl,required this.title , required this.fun});

  String imgUrl;
  String title;
  Function fun;

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: InkWell(
          onTap: () {
            fun();
          },
          child: Container(
            color: Colors.black12,
            margin: const EdgeInsets.symmetric(horizontal: 5 ,vertical: 5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Image(
                    height: MediaQuery.of(context).size.width /5,
                    fit: BoxFit.fill,
                    image: AssetImage(imgUrl),
                  ),
                ),
                const SizedBox(height: 5,),
                Text(title , style: TextStyle(color: Colors.white , fontSize: 15 , fontWeight: FontWeight.bold),),
              ],
            ),
          ),
        ));
  }
}

