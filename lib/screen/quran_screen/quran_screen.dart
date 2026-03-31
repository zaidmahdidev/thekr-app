import 'package:flutter/material.dart';
import '../../network/local/cache_helper.dart';
import '../../shard/components/tools.dart';
import '../sura_screen/sura_screen.dart';

class QuranScreenn extends StatefulWidget {
  QuranScreenn({Key? key, this.highlightedSurahIndex}) : super(key: key);

  final int? highlightedSurahIndex;

  @override
  State<QuranScreenn> createState() => _QuranScreennState();
}

class _QuranScreennState extends State<QuranScreenn> {
  final ScrollController _scrollController = ScrollController();
  String searchText = '';

  @override
  void initState() {
    super.initState();
    if (widget.highlightedSurahIndex != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Approximate height of each item is 85 pixels
        double offset = widget.highlightedSurahIndex! * 85.0;
        _scrollController.animateTo(
          offset,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Floating App Bar for Title
            SliverAppBar(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
              floating: true,
              elevation: 0,
              pinned: false,
              centerTitle: true,
              title: const Text('القران الكريم'),
              actions: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SurahScreen(
                          currentPage: CacheHelper.getData(key: 'mark') ?? 1,
                        ),
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(15),
                    child: Icon(Icons.bookmark_border),
                  ),
                ),
              ],
            ),
            // Pinned Search Bar
            SliverAppBar(
              pinned: true,
              primary: false,
              automaticallyImplyLeading: false,
              backgroundColor: Theme.of(context).primaryColor,
              elevation: 4, // Add some shadow when pinned
              toolbarHeight: 70,
              title: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: TextField(
                  cursorColor: Colors.white,
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) {
                    setState(() {
                      searchText = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'ابحث عن سورة',
                    hintStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.search, color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.15),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
            // Surah List
            SliverList(
              delegate: SliverChildBuilderDelegate((
                BuildContext context,
                int index,
              ) {
                final surah = nameOfQuranAyah[index]['surah'];
                final name = nameOfQuranAyah[index]['name'];
                final type = nameOfQuranAyah[index]['type'];
                final pagenumberr = pageNumberr[index];
                final count = countOfVerses[index];

                if (searchText.isNotEmpty &&
                    !name.contains(searchText)) {
                  return const SizedBox();
                }

                return CustomContainer(
                  title: name,
                  subTitle: 'عدد الآيات: $count',
                  leading: surah,
                  trailing: type,
                  isHighlighted: index == widget.highlightedSurahIndex,
                  fun: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SurahScreen(currentPage: pagenumberr),
                      ),
                    );
                  },
                );
              }, childCount: nameOfQuranAyah.length),
            ),
          ],
        ),
      ),
    );
  }
}
