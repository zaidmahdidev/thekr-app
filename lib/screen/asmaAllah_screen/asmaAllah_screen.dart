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
                showDialog(
                  context: context,
                  builder: (context) => Dialog(
                    backgroundColor: MyTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              color: Colors.orange,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            meaning,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              height: 1.5,
                              fontSize: 17,
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              'إغلاق',
                              style: TextStyle(color: Colors.orange),
                            ),
                          ),
                        ],
                      ),
                    ),
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

