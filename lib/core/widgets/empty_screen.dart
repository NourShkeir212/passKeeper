import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../generated/assets.dart';
import 'custom_text.dart';

class BuildEmptyWidget extends StatelessWidget {
  final String title;
  final String subTitle;
  const BuildEmptyWidget({super.key, required this.title, required this.subTitle});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              height: screenWidth * 0.4,
              isDarkMode ?  Assets.svgNoDataDarkMode : Assets.svgNoDataLightMode,
            ),
            const SizedBox(height: 24),
            CustomText(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            CustomText(
              subTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
