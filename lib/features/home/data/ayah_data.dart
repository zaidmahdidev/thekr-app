class AyahModel {
  final String text;
  final String surah;
  final int ayahNumber;
  final int page;

  const AyahModel({
    required this.text,
    required this.surah,
    required this.ayahNumber,
    required this.page,
  });
}

const List<AyahModel> dailyAyahs = [
  AyahModel(
    text: "فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ",
    surah: "البقرة",
    ayahNumber: 152,
    page: 23,
  ),
  AyahModel(
    text: "وَإِذَا سَأَلَكَ عِبَادِي عَنِّي فَإِنِّي قَرِيبٌ ۖ أُجِيبُ دَعْوَةَ الدَّاعِ إِذَا دَعَانِ",
    surah: "البقرة",
    ayahNumber: 186,
    page: 28,
  ),
  AyahModel(
    text: "أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ",
    surah: "الرعد",
    ayahNumber: 28,
    page: 252,
  ),
  AyahModel(
    text: "وَتَوَكَّلْ عَلَى الْحَيِّ الَّذِي لَا يَمُوتُ وَسَبِّحْ بِحَمْدِهِ",
    surah: "الفرقان",
    ayahNumber: 58,
    page: 364,
  ),
  AyahModel(
    text: "رَبِّ اشْرَحْ لِي صَدْرِي * وَيَسِّرْ لِي أَمْرِي",
    surah: "طه",
    ayahNumber: 25,
    page: 313,
  ),
  AyahModel(
    text: "إِنَّ مَعَ الْعُسْرِ يُسْرًا",
    surah: "الشرح",
    ayahNumber: 6,
    page: 596,
  ),
  AyahModel(
    text: "وَقُل رَّبِّ زِدْنِي عِلْمًا",
    surah: "طه",
    ayahNumber: 114,
    page: 320,
  ),
  AyahModel(
    text: "لَا نُكَلِّفُ نَفْسًا إِلَّا وُسْعَهَا",
    surah: "الأعراف",
    ayahNumber: 42,
    page: 155,
  ),
  AyahModel(
    text: "أَمَّن يُجِيبُ الْمُضْطَرَّ إِذَا دَعَاهُ وَيَكْشِفُ السُّوءَ",
    surah: "النمل",
    ayahNumber: 62,
    page: 382,
  ),
  AyahModel(
    text: "فَسَبِّحْ بِحَمْدِ رَبِّكَ وَكُن مِّنَ السَّاجِدِينَ",
    surah: "الحجر",
    ayahNumber: 98,
    page: 267,
  ),
  AyahModel(
    text: "وَاصْبِرْ لِحُكْمِ رَبِّكَ فَإِنَّكَ بِأَعْيُنِنَا",
    surah: "الطور",
    ayahNumber: 48,
    page: 525,
  ),
  AyahModel(
    text: "نَبِّئْ عِبَادِي أَنِّي أَنَا الْغَفُورُ الرَّحِيمُ",
    surah: "الحجر",
    ayahNumber: 49,
    page: 264,
  ),
  AyahModel(
    text: "فَاصْبِرْ صَبْرًا جَمِيلًا",
    surah: "المعارج",
    ayahNumber: 5,
    page: 568,
  ),
  AyahModel(
    text: "وَسَيُجَنَّبُهَا الْأَتْقَى * الَّذِي يُؤْتِي مَالَهُ يَتَزَكَّى",
    surah: "الليل",
    ayahNumber: 17,
    page: 595,
  ),
  AyahModel(
    text: "وَآتَاكُم مِّن كُلِّ مَا سَأَلْتُمُوهُ ۚ وَإِن تَعُدُّوا نِعْمَتَ اللَّهِ لَا تُحْصُوهَا",
    surah: "إبراهيم",
    ayahNumber: 34,
    page: 259,
  ),
  AyahModel(
    text: "۞ قُلْ يَا عِبَادِيَ الَّذِينَ أَسْرَفُوا عَلَىٰ أَنفُسِهِمْ لَا تَقْنَطُوا مِن رَّحْمَةِ اللَّهِ",
    surah: "الزمر",
    ayahNumber: 53,
    page: 464,
  ),
  AyahModel(
    text: "وَقَالَ رَبُّكُمُ ادْعُونِي أَسْتَجِبْ لَكُمْ",
    surah: "غافر",
    ayahNumber: 60,
    page: 474,
  ),
  AyahModel(
    text: "وَنُنَزِّلُ مِنَ الْقُرْآنِ مَا هُوَ شِفَاءٌ وَرَحْمَةٌ لِّلْمُؤْمِنِينَ",
    surah: "الإسراء",
    ayahNumber: 82,
    page: 290,
  ),
  AyahModel(
    text: "رَبِّ إِنِّي لِمَا أَنزَلْتَ إِلَيَّ مِنْ خَيْرٍ فَقِيرٌ",
    surah: "القصص",
    ayahNumber: 24,
    page: 388,
  ),
  AyahModel(
    text: "مَا وَدَّعَكَ رَبُّكَ وَمَا قَلَىٰ",
    surah: "الضحى",
    ayahNumber: 3,
    page: 596,
  ),
  AyahModel(
    text: "فَقُلْتُ اسْتَغْفِرُوا رَبَّكُمْ إِنَّهُ كَانَ غَفَّارًا",
    surah: "نوح",
    ayahNumber: 10,
    page: 570,
  ),
  AyahModel(
    text: "وَلَا تَهِنُوا وَلَا تَحْزَنُوا وَأَنتُمُ الْأَعْلَوْنَ إِن كُنتُم مُّؤْمِنِينَ",
    surah: "آل عمران",
    ayahNumber: 139,
    page: 67,
  ),
  AyahModel(
    text: "يَا أَيُّهَا الْإِنسَانُ مَا غَرَّكَ بِرَبِّكَ الْكَرِيمِ",
    surah: "الانفطار",
    ayahNumber: 6,
    page: 587,
  ),
  AyahModel(
    text: "إِنَّ اللَّهَ مَعَ الَّذِينَ اتَّقَوا وَّالَّذِينَ هُم مُّحْسِنُونَ",
    surah: "النحل",
    ayahNumber: 128,
    page: 281,
  ),
  AyahModel(
    text: "إِنَّمَا الْمُؤْمِنُونَ الَّذِينَ إِذَا ذُكِرَ اللَّهُ وَجِلَتْ قُلُوبُهُمْ",
    surah: "الأنفال",
    ayahNumber: 2,
    page: 177,
  ),
  AyahModel(
    text: "وَنَحْنُ أَقْرَبُ إِلَيْهِ مِنْ حَبْلِ الْوَرِيدِ",
    surah: "ق",
    ayahNumber: 16,
    page: 519,
  ),
  AyahModel(
    text: "وَاذْكُر رَّبِّكَ إِذَا نَسِيتَ وَقُلْ عَسَىٰ أَن يَهْدِيَنِ رَبِّي لِأَقْرَبَ مِنْ هَٰذَا رَشَدًا",
    surah: "الكهف",
    ayahNumber: 24,
    page: 296,
  ),
  AyahModel(
    text: "وَقُل رَّبِّ اغْفِرْ وَارْحَمْ وَأَنتَ خَيْرُ الرَّاحِمِينَ",
    surah: "المؤمنون",
    ayahNumber: 118,
    page: 349,
  ),
  AyahModel(
    text: "إِنَّ رَبَّكَ وَاسِعُ الْمَغْفِرَةِ",
    surah: "النجم",
    ayahNumber: 32,
    page: 527,
  ),
  AyahModel(
    text: "لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا",
    surah: "البقرة",
    ayahNumber: 286,
    page: 49,
  ),
];
