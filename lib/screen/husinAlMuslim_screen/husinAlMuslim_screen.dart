import 'package:flutter/material.dart';
import 'package:thekr_app/model/husin_almuslim_model.dart';
import 'package:thekr_app/screen/husin_almuslim_details_screen/husin_almuslim_details_screen.dart';
import 'package:thekr_app/shard/components/tools.dart';

class HusinAlMuslimScreen extends StatelessWidget {
  const HusinAlMuslimScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text('حُصن المسلم')),
      body: ListView.builder(
        itemCount: husinAlMuslim.length,
        itemBuilder: (context, index) {
          String key = husinAlMuslim.keys.elementAt(index);
          return CustomContainer(
            fun: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HusinAlMuslimDetailsScreen(
                    title: key,
                    dhikrData: husinAlMuslim[key],
                  ),
                ),
              );
            },
            leading: '${index + 1}',
            title: key,
          );
        },
      ),
    );
  }
}
