import 'package:cahaya_mulya_abadi/themes/app_pallete.dart';
import 'package:flutter/material.dart';

class OptionalTextfield extends StatelessWidget {
  final TextEditingController controller;
  final String title;
  final String hintText;
  final bool obscureText;
  final bool? enabled;
  final FocusNode? focusNode;

  const OptionalTextfield({
    super.key,
    required this.controller,
    required this.title,
    required this.hintText,
    required this.obscureText,
    this.enabled,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // title
        Text(
          title,
        ),

        const SizedBox(height: 5),

        // textfield
        TextField(
          controller: controller,
          obscureText: obscureText,
          focusNode: focusNode,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: AppPallete.grey,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: AppPallete.grey,
              ),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.secondary,
            hintText: hintText,
            hintStyle: TextStyle(
              color: AppPallete.grey,
            ),
          ),
          maxLines: obscureText ? 1 : null,
          enabled: enabled,
        ),
      ],
    );
  }
}
