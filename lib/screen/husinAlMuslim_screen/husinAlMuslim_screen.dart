import 'package:flutter/material.dart';
import 'package:thekr_app/model/husin_almuslim_model.dart';
import 'package:thekr_app/screen/husin_almuslim_details_screen/husin_almuslim_details_screen.dart';
import 'package:thekr_app/shard/components/tools.dart';
import '../../shard/constant/theme.dart';

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
          // return InkWell(
          //   onTap: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => HusinAlMuslimDetailsScreen(
          //           title: key,
          //           dhikrData: husinAlMuslim[key],
          //         ),
          //       ),
          //     );
          //   },
          //   child: Container(
          //     margin: const EdgeInsets.all(8),
          //     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          //     decoration: BoxDecoration(
          //       borderRadius: BorderRadius.circular(15),
          //       gradient: const LinearGradient(
          //         begin: Alignment.topLeft,
          //         end: Alignment.bottomRight,
          //         colors: [MyTheme.primaryColor, MyTheme.primaryColor],
          //       ),
          //       boxShadow: [
          //         BoxShadow(
          //           color: MyTheme.primaryColor.withValues(alpha: 0.3),
          //           blurRadius: 8,
          //           offset: const Offset(0, 4),
          //         ),
          //       ],
          //     ),
          //     child: Row(
          //       children: [
          //         Container(
          //           width: 50,
          //           height: 50,
          //           decoration: BoxDecoration(
          //             color: Colors.white.withValues(alpha: 0.2),
          //             borderRadius: BorderRadius.circular(25),
          //             border: Border.all(
          //               color: Colors.white.withValues(alpha: 0.3),
          //               width: 1,
          //             ),
          //           ),
          //           child: Center(
          //             child: Text(
          //               '${index + 1}',
          //               style: const TextStyle(
          //                 color: Colors.white,
          //                 fontSize: 18,
          //                 fontWeight: FontWeight.bold,
          //               ),
          //             ),
          //           ),
          //         ),
          //         const SizedBox(width: 15),
          //         Expanded(
          //           child: Text(
          //             key,
          //             style: MyTheme.textStyle22.copyWith(
          //               color: Colors.white,
          //               fontSize: 16,
          //               fontWeight: FontWeight.w900,
          //               height: 1.4,
          //             ),
          //           ),
          //         ),
          //         const SizedBox(width: 10),
          //         Container(
          //           padding: const EdgeInsets.all(8),
          //           decoration: BoxDecoration(
          //             color: Colors.white.withValues(alpha: 0.2),
          //             borderRadius: BorderRadius.circular(20),
          //           ),
          //           child: const Icon(
          //             Icons.arrow_forward_ios,
          //             color: Colors.white,
          //             size: 16,
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // );
        },
      ),
    );
  }
}
