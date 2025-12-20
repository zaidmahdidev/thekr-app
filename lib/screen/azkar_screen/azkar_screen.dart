import 'package:flutter/material.dart';
import 'package:thekr_app/model/azkar_model.dart';
import '../../shard/components/tools.dart';
import '../azkar_details_screen/azkar_details_screen.dart';

class AzkarScreen extends StatelessWidget {
  const AzkarScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('أذكار المسلم'),
      ),
      body: ListView.builder(
        itemCount: azkarList.length,
        itemBuilder: (context, index) {
          String key = azkarList.keys.elementAt(index);

          return CustomContainer(
            title: key,
            fun: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AzkarListScreen(azkarList: azkarList[key] , type: key),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
