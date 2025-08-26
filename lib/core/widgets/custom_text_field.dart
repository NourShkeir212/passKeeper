import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final bool isPassword;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final void Function(String)? onChanged;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.prefixIcon,
    this.validator,
    this.isPassword = false,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: Theme
          .of(context)
          .textTheme
          .bodyLarge,
      obscureText: isPassword,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
                color: Theme
                    .of(context)
                    .colorScheme
                    .primary
                    .withOpacity(0.3)
            )
        ),
        disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
                color: Theme
                    .of(context)
                    .colorScheme
                    .primary
                    .withOpacity(0.3)
            )
        ),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
                color: Theme
                    .of(context)
                    .colorScheme
                    .primary
                    .withOpacity(0.3)
            )
        ),
        fillColor: Theme.of(context).colorScheme.background,
        labelText: labelText,
        prefixIcon: prefixIcon !=null ? Icon(prefixIcon!, color: Theme.of(context).colorScheme.primary) :null,
        suffixIcon: suffixIcon,
      ),
      validator: validator,
    );
  }
}