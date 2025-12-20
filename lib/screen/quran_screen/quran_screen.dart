
import 'package:flutter/material.dart';
import '../../network/local/cache_helper.dart';
import '../../shard/components/tools.dart';
import '../sura_screen/sura_screen.dart';

class QuranScreenn extends StatefulWidget {
  QuranScreenn({Key? key}) : super(key: key);

  String searchText = '';

  @override
  State<QuranScreenn> createState() => _QuranScreennState();
}

class _QuranScreennState extends State<QuranScreenn> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child:  Scaffold(
        appBar: AppBar(
          actions: [
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SurahScreen(currentPage: CacheHelper.getData(key: 'mark') ??1),
                  ),
                );
              },
              child: const Padding(
                padding: EdgeInsets.all(15),
                child: Icon(Icons.bookmark_border),
              ),
            ),
          ],
          centerTitle: true,
          title: const Text('القران الكريم'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                cursorColor: Colors.white,
                style: const TextStyle(color: Colors.orange),
                onChanged: (value) {
                  setState(() {
                    widget.searchText = value;
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'ابحث عن سورة',
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.search , color: Colors.grey,),
                ),
              ),
            ),
          ),
        ),

        body: ListView.builder(
          itemCount: nameOfQuranAyah.length,
          itemBuilder: (BuildContext context, int index) {
            final surah = nameOfQuranAyah[index]['surah'];
            final name = nameOfQuranAyah[index]['name'];
            final type = nameOfQuranAyah[index]['type'];
            final pagenumberr = pageNumberr[index];
            final count = countOfVerses[index];

            if (widget.searchText.isNotEmpty && !name.contains(widget.searchText)) {
              return const SizedBox();
            }

            return CustomContainer(
              title: name,
              subTitle: 'عدد الآيات: $count',
              leading: surah,
              trailing: type,
              fun: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SurahScreen(currentPage: pagenumberr),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}