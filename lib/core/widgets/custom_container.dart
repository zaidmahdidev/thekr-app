import 'package:flutter/material.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/extensions/size_extension.dart';
import 'package:thekr_app/core/theme/tokens/typography.dart';
import 'package:thekr_app/core/utils/constants/app_assets.dart';

class CustomContainer extends StatelessWidget {
  const CustomContainer({
    Key? key,
    required this.title,
    this.subTitle,
    this.leading,
    this.trailing,
    this.fun,
    this.isHighlighted = false,
  }) : super(key: key);

  final String title;
  final String? subTitle;
  final String? leading;
  final String? trailing;
  final Function? fun;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (fun != null) fun!();
      },
      child: Container(
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: isHighlighted
              ? Border.all(color: Colors.white, width: 2)
              : null,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isHighlighted
                ? [
                    context.colors.secondary.withValues(alpha: 0.8),
                    context.colors.primary,
                    context.colors.primary,
                  ]
                : [
                    context.colors.primary,
                    context.colors.primary,
                    context.colors.primary,
                  ],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (leading != null)
              Container(
                width: context.getWidth(12),
                height: context.getWidth(12),
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AppAssets.around),
                    fit: BoxFit.contain,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 2,
                  ), // Slight adjustment for optical centering
                  child: Text(
                    '$leading',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            else
              const SizedBox(),
            Flexible(
              child: Column(
                children: [
                  Text(
                    '$title',
                    textAlign: TextAlign.center,
                    style: AppTypography.h3.copyWith(
                      color: context.colors.secondary,
                      height: 1.3,
                    ),
                  ),
                  if (subTitle != null)
                    const SizedBox(height: 7)
                  else
                    const SizedBox(),
                  if (subTitle != null)
                    Text(
                      '$subTitle',
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.white,
                      ),
                    )
                  else
                    const SizedBox(),
                ],
              ),
            ),
            if (trailing != null)
              Text(
                '$trailing',
                style: AppTypography.bodyMedium.copyWith(color: Colors.white),
              )
            else
              const SizedBox(),
          ],
        ),
      ),
    );
  }
}
