import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:thekr_app/features/asma_allah/data/asma_allah_data.dart';
import 'package:thekr_app/core/widgets/widgets.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/theme/tokens/typography.dart';

@RoutePage()
class AsmaAllahScreen extends StatelessWidget {
  const AsmaAllahScreen({Key? key}) : super(key: key);

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
                    backgroundColor: context.colors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(context.corners.xl),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            name,
                            style: AppTypography.h2.copyWith(
                              color: context.colors.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            meaning,
                            textAlign: TextAlign.center,
                            style: AppTypography.bodyLarge.copyWith(
                              color: Colors.white,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'إغلاق',
                              style: AppTypography.button.copyWith(
                                color: context.colors.secondary,
                              ),
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
