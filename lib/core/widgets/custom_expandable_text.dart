import 'package:flutter/material.dart';
import 'package:secure_accounts/l10n/app_localizations.dart';

import 'custom_text.dart';


class CustomExpandableText extends StatefulWidget {
  final String text;
  final int trimLength;
  final TextStyle? style;

  const CustomExpandableText(
      this.text, {
        super.key,
        this.trimLength = 18,
        this.style,
      });

  @override
  State<CustomExpandableText> createState() => _CustomExpandableTextState();
}

class _CustomExpandableTextState extends State<CustomExpandableText> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final bool isLongText = widget.text.length > widget.trimLength;

    // The main text widget
    final textWidget = CustomText(
      maxLines: _isExpanded ? 5 :1,
      isLongText && !_isExpanded
          ? '${widget.text.substring(0, widget.trimLength)}...'
          : widget.text,
      style: widget.style,
    );

    // If the text isn't long, just show the text
    if (!isLongText) {
      return textWidget;
    }

    // If it's long, show the text and the button
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        textWidget,
        TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onPressed: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Text(_isExpanded ? AppLocalizations.of(context)!.expandedTextShowLess : AppLocalizations.of(context)!.expandedTextShowMore),
        ),
      ],
    );
  }
}