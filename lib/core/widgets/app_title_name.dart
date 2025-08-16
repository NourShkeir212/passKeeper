import 'package:flutter/material.dart';

class AppTitleNameWidget extends StatelessWidget {
  final double? fontSize;

  const AppTitleNameWidget({super.key, this.fontSize});

  @override
  Widget build(BuildContext context) {
    return RichText(
      overflow: TextOverflow.ellipsis,
      maxLines: 2,
      text: TextSpan(
        // Sets the default style for all text spans below
        style: Theme
            .of(context)
            .textTheme
            .headlineMedium,
        children: <TextSpan>[
          TextSpan(
            text: 'Pass',
            // Overrides the default style with the primary color
            style: TextStyle(
                color: Theme
                    .of(context)
                    .colorScheme
                    .primary,
                fontSize: fontSize ?? 28.0
            ),
          ),
          TextSpan(
              text: 'Keeper',
              style: TextStyle(
                  fontSize: fontSize ?? 28.0
              )
          ),
        ],
      ),
    );
  }
}
