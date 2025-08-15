import 'package:flutter/material.dart';

class AppTitleNameWidget extends StatelessWidget {
  const AppTitleNameWidget({super.key});

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
                fontSize: 28.0
            ),
          ),
          const TextSpan(
              text: 'Keeper',
              style: TextStyle(
                  fontSize: 28.0
              )
          ),
        ],
      ),
    );
  }
}
