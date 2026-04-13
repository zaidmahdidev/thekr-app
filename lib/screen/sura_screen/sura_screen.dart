import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:thekr_app/shard/components/tools.dart';

import '../../network/local/cache_helper.dart';
import '../../shard/constant/theme.dart';
import '../quran_screen/quran_screen.dart';

class SurahScreen extends StatefulWidget {
  SurahScreen({Key? key, required this.currentPage}) : super(key: key);
  final int currentPage;

  @override
  _SurahScreenState createState() => _SurahScreenState();
}

class _SurahScreenState extends State<SurahScreen> with WidgetsBindingObserver {
  var slidController = PageController();
  bool isTextVisible = false;
  bool isDarkMode = false;
  int mark = 1;
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    slidController = PageController(initialPage: widget.currentPage - 1);
    mark = widget.currentPage;
    isDarkMode = CacheHelper.getData(key: 'isDarkMode') ?? false;

    // Allow rotation on this screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void toggleDarkMode() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
    CacheHelper.saveData(key: 'isDarkMode', value: isDarkMode);
  }

  void toggleTextVisibility() {
    setState(() {
      isTextVisible = !isTextVisible;
    });
  }

  int getSurahIndexByPage(int page) {
    int surahIndex = 0;
    for (int i = 0; i < pageNumberr.length; i++) {
      if (pageNumberr[i] <= page) {
        surahIndex = i;
      } else {
        break;
      }
    }
    return surahIndex;
  }

  String getSurahNameByPage(int page) {
    return nameOfQuranAyah[getSurahIndexByPage(page)]['name'];
  }

  Future<void> _sharePage() async {
    try {
      // Get current page asset path
      String assetPath =
          'assets/quran-images/page${mark.toString().padLeft(3, '0')}.png';

      // Precache logo to ensure it's ready for capture
      await precacheImage(const AssetImage('assets/images/thekr.png'), context);

      final uint8list = await _screenshotController.captureFromWidget(
        Material(
          color: Colors.transparent,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(20),
                width: 400,
                decoration: BoxDecoration(
                  color: const Color(0xfffffbec), // Light Cream Background
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: MyTheme.primaryColor.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Decorative header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: Image.asset(
                            'assets/images/thekr.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        Text(
                          'سورة ${getSurahNameByPage(mark)}',
                          style: const TextStyle(
                            color: MyTheme.primaryColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 40),
                      ],
                    ),
                    const Divider(color: MyTheme.primaryColor, thickness: 1),
                    const SizedBox(height: 10),
                    // The Quran Page
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(assetPath, fit: BoxFit.contain),
                    ),
                    const SizedBox(height: 15),
                    // Footer
                    Text(
                      'صفحة رقم $mark',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        context: context,
        delay: const Duration(milliseconds: 500),
        pixelRatio: 2.0,
      );

      final directory = await getTemporaryDirectory();
      final file = await File(
        '${directory.path}/quran_page_$mark.png',
      ).create();
      await file.writeAsBytes(uint8list);

      await Share.shareXFiles(
        [XFile(file.path)],
        text:
            'رابط تحميل التطبيق \n https://play.google.com/store/apps/details?id=com.zaid.thekr_app',
      );
    } catch (e) {
      showToast(text: 'حدث خطأ أثناء المشاركة');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    CacheHelper.saveData(key: 'pageNumber', value: mark);

    // Reset orientation to portrait when leaving
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      CacheHelper.saveData(key: 'pageNumber', value: mark);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: isDarkMode ? Colors.black : const Color(0xfffffbec),
        body: GestureDetector(
          onTap: () {
            toggleTextVisibility();
          },
          child: Stack(
            children: [
              PageView.builder(
                controller: slidController,
                itemCount: 604,
                onPageChanged: (index) {
                  setState(() {
                    mark = index + 1;
                  });
                  CacheHelper.saveData(key: 'pageNumber', value: mark);
                },
                itemBuilder: (context, index) {
                  int i = index + 1;
                  return ColorFiltered(
                    colorFilter: isDarkMode
                        ? const ColorFilter.matrix([
                            -1,
                            0,
                            0,
                            0,
                            255,
                            0,
                            -1,
                            0,
                            0,
                            255,
                            0,
                            0,
                            -1,
                            0,
                            255,
                            0,
                            0,
                            0,
                            1,
                            0,
                          ])
                        : const ColorFilter.mode(
                            Colors.transparent,
                            BlendMode.multiply,
                          ),
                    child: OrientationBuilder(
                      builder: (context, orientation) {
                        bool isPortrait = orientation == Orientation.portrait;

                        return isPortrait
                            ? Image(
                                image: AssetImage(
                                  'assets/quran-images/page${i.toString().padLeft(3, '0')}.png',
                                ),
                                fit: BoxFit.fill,
                              )
                            : SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: Image(
                                  image: AssetImage(
                                    'assets/quran-images/page${i.toString().padLeft(3, '0')}.png',
                                  ),
                                  fit: BoxFit.fitWidth,
                                ),
                              );
                      },
                    ),
                  );
                },
              ),
              if (isTextVisible)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    color: MyTheme.primaryColor.withValues(alpha: 0.9),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 40), // Spacer for balance
                        Expanded(
                          child: Center(
                            child: Text(
                              'سورة ${getSurahNameByPage(mark)} - صفحة $mark',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _sharePage,
                          icon: const Icon(
                            Icons.share_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (isTextVisible)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(1),
                    color: MyTheme.primaryColor.withValues(alpha: 0.9),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextButton.icon(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      backgroundColor: MyTheme.primaryColor,
                                      title: const Text(
                                        'حفظ علامة',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      content: Text(
                                        'هل تريد حفظ الصفحة رقم $mark كعلامة؟',
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text(
                                            'تراجع',
                                            style: TextStyle(
                                              color: Colors.orange,
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            CacheHelper.saveData(
                                              key: 'mark',
                                              value: mark,
                                            );
                                            Navigator.pop(context);
                                            showToast(
                                              text: 'تم الحفظ بنجاح',
                                              bgColoe: MyTheme.primaryColor,
                                              textColor: Colors.white,
                                            );
                                          },
                                          child: const Text(
                                            'حفظ',
                                            style: TextStyle(
                                              color: Colors.orange,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.bookmark_add,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                label: const Text(
                                  'حفظ علامة',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: TextButton.icon(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SurahScreen(
                                        currentPage:
                                            CacheHelper.getData(key: 'mark') ??
                                            1,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.bookmark_outlined,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                label: const Text(
                                  'انتقال للعلامة',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(color: Colors.white30, height: 1),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton.icon(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => QuranScreenn(
                                        highlightedSurahIndex:
                                            getSurahIndexByPage(mark),
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.list_alt_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                label: const Text(
                                  'الفهرس',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: TextButton.icon(
                                onPressed: toggleDarkMode,
                                icon: Icon(
                                  isDarkMode
                                      ? Icons.brightness_7
                                      : Icons.brightness_4,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                label: Text(
                                  isDarkMode ? 'الوضع الفاتح' : 'الوضع الليلي',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

List<int> countOfVerses = [
  7,
  286,
  200,
  176,
  120,
  165,
  206,
  75,
  129,
  109,
  123,
  111,
  43,
  52,
  99,
  128,
  111,
  110,
  98,
  135,
  112,
  78,
  118,
  64,
  77,
  227,
  93,
  88,
  69,
  60,
  34,
  30,
  73,
  54,
  45,
  83,
  182,
  88,
  75,
  85,
  54,
  53,
  89,
  59,
  37,
  35,
  38,
  29,
  18,
  45,
  60,
  49,
  62,
  55,
  78,
  96,
  29,
  22,
  24,
  13,
  14,
  11,
  11,
  18,
  12,
  12,
  30,
  52,
  52,
  44,
  28,
  28,
  20,
  56,
  40,
  31,
  50,
  40,
  46,
  42,
  29,
  19,
  36,
  25,
  22,
  17,
  19,
  26,
  30,
  20,
  15,
  21,
  11,
  8,
  8,
  19,
  5,
  8,
  8,
  11,
  11,
  8,
  3,
  9,
  5,
  4,
  7,
  3,
  6,
  3,
  5,
  4,
  5,
  6,
];

List<Map<String, dynamic>> nameOfQuranAyah = [
  {
    "surah": "1",
    "name": "الفاتحة",
    "type": "مكية",
    "pagenumber": "  1",
    "countofverses": "  7 ",
  },
  {
    "surah": "2",
    "name": "البقرة",
    "type": "مدنية",
    "pagenumber": "  2",
    "countofverses": "  286 ",
  },
  {
    "surah": "3",
    "name": "آل عمران",
    "type": "مدنية",
    "pagenumber": "  45",
    "countofverses": "  200 ",
  },
  {
    "surah": "4",
    "name": "النساء",
    "type": "مدنية",
    "pagenumber": "  69",
    "countofverses": "  176 ",
  },
  {
    "surah": "5",
    "name": "المائدة",
    "type": "مدنية",
    "pagenumber": "  95",
    "countofverses": "  120 ",
  },
  {
    "surah": "6",
    "name": "الأنعام",
    "type": "مكية",
    "pagenumber": "  115",
    "countofverses": "  165 ",
  },
  {
    "surah": "7",
    "name": "الأعراف",
    "type": "مكية",
    "pagenumber": "  136",
    "countofverses": "  206 ",
  },
  {
    "surah": "8",
    "name": "الأنفال",
    "type": "مدنية",
    "pagenumber": "  160",
    "countofverses": "  75 ",
  },
  {
    "surah": "9",
    "name": "التوبة",
    "type": "مدنية",
    "pagenumber": "  169",
    "countofverses": "  129 ",
  },
  {
    "surah": "10",
    "name": "يونس",
    "type": "مكية",
    "pagenumber": "  187",
    "countofverses": "  109 ",
  },
  {
    "surah": "11",
    "name": "هود",
    "type": "مكية",
    "pagenumber": "  199",
    "countofverses": "  123 ",
  },
  {
    "surah": "12",
    "name": "يوسف",
    "type": "مكية",
    "pagenumber": "  212",
    "countofverses": "  111 ",
  },
  {
    "surah": "13",
    "name": "الرعد",
    "type": "مدنية",
    "pagenumber": "  225",
    "countofverses": "  43 ",
  },
  {
    "surah": "14",
    "name": "ابراهيم",
    "type": "مكية",
    "pagenumber": "  231",
    "countofverses": "  52 ",
  },
  {
    "surah": "15",
    "name": "الحجر",
    "type": "مكية",
    "pagenumber": "  237",
    "countofverses": "  99 ",
  },
  {
    "surah": "16",
    "name": "النحل",
    "type": "مكية",
    "pagenumber": "  242",
    "countofverses": "  128 ",
  },
  {
    "surah": "17",
    "name": "الإسراء",
    "type": "مكية",
    "pagenumber": "  255",
    "countofverses": "  111 ",
  },
  {
    "surah": "18",
    "name": "الكهف",
    "type": "مكية",
    "pagenumber": "  266",
    "countofverses": "  110 ",
  },
  {
    "surah": "19",
    "name": "مريم",
    "type": "مكية",
    "pagenumber": "  277",
    "countofverses": "  98 ",
  },
  {
    "surah": "20",
    "name": "طه",
    "type": "مكية",
    "pagenumber": "  284",
    "countofverses": "  135 ",
  },
  {
    "surah": "21",
    "name": "الأنبياء",
    "type": "مكية",
    "pagenumber": "  294",
    "countofverses": "  112 ",
  },
  {
    "surah": "22",
    "name": "الحج",
    "type": "مدنية",
    "pagenumber": "  302",
    "countofverses": "  78 ",
  },
  {
    "surah": "23",
    "name": "المؤمنون",
    "type": "مكية",
    "pagenumber": "  311",
    "countofverses": "  118 ",
  },
  {
    "surah": "24",
    "name": "النور",
    "type": "مدنية",
    "pagenumber": "  319",
    "countofverses": "  64 ",
  },
  {
    "surah": "25",
    "name": "الفرقان",
    "type": "مكية",
    "pagenumber": "  329",
    "countofverses": "  77 ",
  },
  {
    "surah": "26",
    "name": "الشعراء",
    "type": "مكية",
    "pagenumber": "  335",
    "countofverses": "  227 ",
  },
  {
    "surah": "27",
    "name": "النمل",
    "type": "مكية",
    "pagenumber": "  345",
    "countofverses": "  93 ",
  },
  {
    "surah": "28",
    "name": "القصص",
    "type": "مكية",
    "pagenumber": "  354",
    "countofverses": "  88 ",
  },
  {
    "surah": "29",
    "name": "العنكبوت",
    "type": "مكية",
    "pagenumber": "  364",
    "countofverses": "  69 ",
  },
  {
    "surah": "30",
    "name": "الروم",
    "type": "مكية",
    "pagenumber": "  371",
    "countofverses": "  60 ",
  },
  {
    "surah": "31",
    "name": "لقمان",
    "type": "مكية",
    "pagenumber": "  377",
    "countofverses": "  34 ",
  },
  {
    "surah": "32",
    "name": "السجدة",
    "type": "مكية",
    "pagenumber": "  381",
    "countofverses": "  30 ",
  },
  {
    "surah": "33",
    "name": "الأحزاب",
    "type": "مدنية",
    "pagenumber": "  383",
    "countofverses": "  73 ",
  },
  {
    "surah": "34",
    "name": "سبإ",
    "type": "مكية",
    "pagenumber": "  393",
    "countofverses": "  54 ",
  },
  {
    "surah": "35",
    "name": "فاطر",
    "type": "مكية",
    "pagenumber": "  399",
    "countofverses": "  45 ",
  },
  {
    "surah": "36",
    "name": "يس",
    "type": "مكية",
    "pagenumber": "  404",
    "countofverses": "  83 ",
  },
  {
    "surah": "37",
    "name": "الصافات",
    "type": "مكية",
    "pagenumber": "  410",
    "countofverses": "  182 ",
  },
  {
    "surah": "38",
    "name": "ص",
    "type": "مكية",
    "pagenumber": "  417",
    "countofverses": "  88 ",
  },
  {
    "surah": "39",
    "name": "الزمر",
    "type": "مكية",
    "pagenumber": "  422",
    "countofverses": "  75 ",
  },
  {
    "surah": "40",
    "name": "غافر",
    "type": "مكية",
    "pagenumber": "  431",
    "countofverses": "  85 ",
  },
  {
    "surah": "41",
    "name": "فصلت",
    "type": "مكية",
    "pagenumber": "  439",
    "countofverses": "  54 ",
  },
  {
    "surah": "42",
    "name": "الشورى",
    "type": "مكية",
    "pagenumber": "  445",
    "countofverses": "  53 ",
  },
  {
    "surah": "43",
    "name": "الزخرف",
    "type": "مكية",
    "pagenumber": "  451",
    "countofverses": "  89 ",
  },
  {
    "surah": "44",
    "name": "الدخان",
    "type": "مكية",
    "pagenumber": "  457",
    "countofverses": "  59 ",
  },
  {
    "surah": "45",
    "name": "الجاثية",
    "type": "مكية",
    "pagenumber": "  460",
    "countofverses": "  37 ",
  },
  {
    "surah": "46",
    "name": "الأحقاف",
    "type": "مكية",
    "pagenumber": "  464",
    "countofverses": "  35 ",
  },
  {
    "surah": "47",
    "name": "محمد",
    "type": "مدنية",
    "pagenumber": "  468",
    "countofverses": "  38 ",
  },
  {
    "surah": "48",
    "name": "الفتح",
    "type": "مدنية",
    "pagenumber": "  472",
    "countofverses": "  29 ",
  },
  {
    "surah": "49",
    "name": "الحجرات",
    "type": "مدنية",
    "pagenumber": "  477",
    "countofverses": "  18 ",
  },
  {
    "surah": "50",
    "name": "ق",
    "type": "مكية",
    "pagenumber": "  479",
    "countofverses": "  45 ",
  },
  {
    "surah": "51",
    "name": "الذاريات",
    "type": "مكية",
    "pagenumber": "  482",
    "countofverses": "  60 ",
  },
  {
    "surah": "52",
    "name": "الطور",
    "type": "مكية",
    "pagenumber": "  485",
    "countofverses": "  49 ",
  },
  {
    "surah": "53",
    "name": "النجم",
    "type": "مكية",
    "pagenumber": "  487",
    "countofverses": "  62 ",
  },
  {
    "surah": "54",
    "name": "القمر",
    "type": "مكية",
    "pagenumber": "  490",
    "countofverses": "  55 ",
  },
  {
    "surah": "55",
    "name": "الرحمن",
    "type": "مدنية",
    "pagenumber": "  493",
    "countofverses": "  78 ",
  },
  {
    "surah": "56",
    "name": "الواقعة",
    "type": "مكية",
    "pagenumber": "  496",
    "countofverses": "  96 ",
  },
  {
    "surah": "57",
    "name": "الحديد",
    "type": "مدنية",
    "pagenumber": "  499",
    "countofverses": "  29 ",
  },
  {
    "surah": "58",
    "name": "المجادلة",
    "type": "مدنية",
    "pagenumber": "  504",
    "countofverses": "  22 ",
  },
  {
    "surah": "59",
    "name": "الحشر",
    "type": "مدنية",
    "pagenumber": "  507",
    "countofverses": "  24 ",
  },
  {
    "surah": "60",
    "name": "الممتحنة",
    "type": "مدنية",
    "pagenumber": "  510",
    "countofverses": "  13 ",
  },
  {
    "surah": "61",
    "name": "الصف",
    "type": "مدنية",
    "pagenumber": "  513",
    "countofverses": "  14 ",
  },
  {
    "surah": "62",
    "name": "الجمعة",
    "type": "مدنية",
    "pagenumber": "  515",
    "countofverses": "  11 ",
  },
  {
    "surah": "63",
    "name": "المنافقون",
    "type": "مدنية",
    "pagenumber": "  516",
    "countofverses": "  11 ",
  },
  {
    "surah": "64",
    "name": "التغابن",
    "type": "مدنية",
    "pagenumber": "  518",
    "countofverses": "  18 ",
  },
  {
    "surah": "65",
    "name": "الطلاق",
    "type": "مدنية",
    "pagenumber": "  520",
    "countofverses": "  12 ",
  },
  {
    "surah": "66",
    "name": "التحريم",
    "type": "مدنية",
    "pagenumber": "  522",
    "countofverses": "  12 ",
  },
  {
    "surah": "67",
    "name": "الملك",
    "type": "مكية",
    "pagenumber": "  524",
    "countofverses": "  30 ",
  },
  {
    "surah": "68",
    "name": "القلم",
    "type": "مكية",
    "pagenumber": "  526",
    "countofverses": "  52 ",
  },
  {
    "surah": "69",
    "name": "الحاقة",
    "type": "مكية",
    "pagenumber": "  529",
    "countofverses": "  52 ",
  },
  {
    "surah": "70",
    "name": "المعارج",
    "type": "مكية",
    "pagenumber": "  531",
    "countofverses": "  44 ",
  },
  {
    "surah": "71",
    "name": "نوح",
    "type": "مكية",
    "pagenumber": "  533",
    "countofverses": "  28 ",
  },
  {
    "surah": "72",
    "name": "الجن",
    "type": "مكية",
    "pagenumber": "  534",
    "countofverses": "  28 ",
  },
  {
    "surah": "73",
    "name": "المزمل",
    "type": "مكية",
    "pagenumber": "  537",
    "countofverses": "  20 ",
  },
  {
    "surah": "74",
    "name": "المدثر",
    "type": "مكية",
    "pagenumber": "  538",
    "countofverses": "  56 ",
  },
  {
    "surah": "75",
    "name": "القيامة",
    "type": "مكية",
    "pagenumber": "  540",
    "countofverses": "  40 ",
  },
  {
    "surah": "76",
    "name": "الانسان",
    "type": "مدنية",
    "pagenumber": "  542",
    "countofverses": "  31 ",
  },
  {
    "surah": "77",
    "name": "المرسلات",
    "type": "مكية",
    "pagenumber": "  544",
    "countofverses": "  50 ",
  },
  {
    "surah": "78",
    "name": "النبإ",
    "type": "مكية",
    "pagenumber": "  545",
    "countofverses": "  40 ",
  },
  {
    "surah": "79",
    "name": "النازعات",
    "type": "مكية",
    "pagenumber": "  547",
    "countofverses": "  46 ",
  },
  {
    "surah": "80",
    "name": "عبس",
    "type": "مكية",
    "pagenumber": "  548",
    "countofverses": "  42 ",
  },
  {
    "surah": "81",
    "name": "التكوير",
    "type": "مكية",
    "pagenumber": "  550",
    "countofverses": "  29 ",
  },
  {
    "surah": "82",
    "name": "الإنفطار",
    "type": "مكية",
    "pagenumber": "  551",
    "countofverses": "  19 ",
  },
  {
    "surah": "83",
    "name": "المطففين",
    "type": "مكية",
    "pagenumber": "  552",
    "countofverses": "  36 ",
  },
  {
    "surah": "84",
    "name": "الإنشقاق",
    "type": "مكية",
    "pagenumber": "  553",
    "countofverses": "  25 ",
  },
  {
    "surah": "85",
    "name": "البروج",
    "type": "مكية",
    "pagenumber": "  554",
    "countofverses": "  22 ",
  },
  {
    "surah": "86",
    "name": "الطارق",
    "type": "مكية",
    "pagenumber": "  555",
    "countofverses": "  17 ",
  },
  {
    "surah": "87",
    "name": "الأعلى",
    "type": "مكية",
    "pagenumber": "  556",
    "countofverses": "  19 ",
  },
  {
    "surah": "88",
    "name": "الغاشية",
    "type": "مكية",
    "pagenumber": "  556",
    "countofverses": "  26 ",
  },
  {
    "surah": "89",
    "name": "الفجر",
    "type": "مكية",
    "pagenumber": "  557",
    "countofverses": "  30 ",
  },
  {
    "surah": "90",
    "name": "البلد",
    "type": "مكية",
    "pagenumber": "  559",
    "countofverses": "  20 ",
  },
  {
    "surah": "91",
    "name": "الشمس",
    "type": "مكية",
    "pagenumber": "  559",
    "countofverses": "  15 ",
  },
  {
    "surah": "92",
    "name": "الليل",
    "type": "مكية",
    "pagenumber": "  560",
    "countofverses": "  21 ",
  },
  {
    "surah": "93",
    "name": "الضحى",
    "type": "مكية",
    "pagenumber": "  561",
    "countofverses": "  11 ",
  },
  {
    "surah": "94",
    "name": "الشرح",
    "type": "مكية",
    "pagenumber": "  561",
    "countofverses": "  8 ",
  },
  {
    "surah": "95",
    "name": "التين",
    "type": "مكية",
    "pagenumber": "  562",
    "countofverses": "  8 ",
  },
  {
    "surah": "96",
    "name": "العلق",
    "type": "مكية",
    "pagenumber": "  562",
    "countofverses": "  19 ",
  },
  {
    "surah": "97",
    "name": "القدر",
    "type": "مكية",
    "pagenumber": "  563",
    "countofverses": "  5 ",
  },
  {
    "surah": "98",
    "name": "البينة",
    "type": "مدنية",
    "pagenumber": "  563",
    "countofverses": "  8 ",
  },
  {
    "surah": "99",
    "name": "الزلزلة",
    "type": "مدنية",
    "pagenumber": "  564",
    "countofverses": "  8 ",
  },
  {
    "surah": "100",
    "name": "العاديات",
    "type": "مكية",
    "pagenumber": "  564",
    "countofverses": "  11 ",
  },
  {
    "surah": "101",
    "name": "القارعة",
    "type": "مكية",
    "pagenumber": "  565",
    "countofverses": "  11 ",
  },
  {
    "surah": "102",
    "name": "التكاثر",
    "type": "مكية",
    "pagenumber": "  565",
    "countofverses": "  8 ",
  },
  {
    "surah": "103",
    "name": "العصر",
    "type": "مكية",
    "pagenumber": "  566",
    "countofverses": "  3 ",
  },
  {
    "surah": "104",
    "name": "الهمزة",
    "type": "مكية",
    "pagenumber": "  566",
    "countofverses": "  9 ",
  },
  {
    "surah": "105",
    "name": "الفيل",
    "type": "مكية",
    "pagenumber": "  566",
    "countofverses": "  5 ",
  },
  {
    "surah": "106",
    "name": "قريش",
    "type": "مكية",
    "pagenumber": "  567",
    "countofverses": "  4 ",
  },
  {
    "surah": "107",
    "name": "الماعون",
    "type": "مكية",
    "pagenumber": "  567",
    "countofverses": "  7 ",
  },
  {
    "surah": "108",
    "name": "الكوثر",
    "type": "مكية",
    "pagenumber": "  567",
    "countofverses": "  3 ",
  },
  {
    "surah": "109",
    "name": "الكافرون",
    "type": "مكية",
    "pagenumber": "  568",
    "countofverses": "  6 ",
  },
  {
    "surah": "110",
    "name": "النصر",
    "type": "مدنية",
    "pagenumber": "  568",
    "countofverses": "  3 ",
  },
  {
    "surah": "111",
    "name": "المسد",
    "type": "مكية",
    "pagenumber": "  568",
    "countofverses": "  5 ",
  },
  {
    "surah": "112",
    "name": "الإخلاص",
    "type": "مكية",
    "pagenumber": "  569",
    "countofverses": "  4 ",
  },
  {
    "surah": "113",
    "name": "الفلق",
    "type": "مكية",
    "pagenumber": "  569",
    "countofverses": "  5 ",
  },
  {
    "surah": "114",
    "name": "الناس",
    "type": "مكية",
    "pagenumber": "  569",
    "countofverses": " 6  ",
  },
];

List<int> pageNumberr = [
  1,
  2,
  50,
  77,
  106,
  128,
  151,
  177,
  187,
  208,
  221,
  235,
  249,
  255,
  262,
  267,
  282,
  293,
  305,
  312,
  322,
  332,
  342,
  350,
  359,
  367,
  377,
  385,
  396,
  404,
  411,
  415,
  418,
  428,
  434,
  440,
  446,
  453,
  458,
  467,
  477,
  483,
  489,
  496,
  499,
  502,
  507,
  511,
  515,
  518,
  520,
  523,
  526,
  528,
  531,
  534,
  537,
  542,
  545,
  549,
  551,
  553,
  554,
  556,
  558,
  560,
  562,
  564,
  566,
  568,
  570,
  572,
  574,
  575,
  577,
  578,
  580,
  582,
  583,
  585,
  586,
  587,
  587,
  589,
  590,
  591,
  591,
  592,
  593,
  594,
  595,
  595,
  596,
  596,
  597,
  597,
  598,
  598,
  599,
  599,
  600,
  600,
  601,
  601,
  601,
  602,
  602,
  602,
  603,
  603,
  603,
  604,
  604,
  604,
];
