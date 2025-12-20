import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:thekr_app/model/asmaAllah_model.dart';
import 'package:thekr_app/shard/components/tools.dart';
import 'package:thekr_app/shard/constant/theme.dart';

class AsmaAllahScreen extends StatelessWidget {
  AsmaAllahScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('أسماء الله الحسنى'),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemCount: asmaAllah.length,
          itemBuilder: (context, index) {
            String name = asmaAllah.keys.elementAt(index);
            String meaning = asmaAllah.values.elementAt(index);
            return CustomContainer(
              title: name,
              leading: '${index + 1}',
              fun: () {
                AwesomeDialog(
                  context: context,
                  dialogBackgroundColor: MyTheme.primaryColor,
                  dialogType: DialogType.noHeader,
                  desc: meaning,
                  descTextStyle: const TextStyle(
                    color: Colors.white,
                    height: 1.5,
                    fontSize: 17,
                  ),
                  title: name,
                  titleTextStyle: const TextStyle(
                    color: Colors.orange,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ).show();
              },
            );
          },
        ),
      ),
    );
  }
}

