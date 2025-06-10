import 'package:cahaya_mulya_abadi/themes/app_pallete.dart';
import 'package:flutter/material.dart';

class MySearchbar extends StatelessWidget {
  final String hintText;
  final Function(String)? onChanged;
  final FocusNode? focusNode;
  const MySearchbar({
    super.key,
    required this.hintText,
    required this.onChanged,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: focusNode,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: AppPallete.grey,
          ),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.tertiary,
        hintText: hintText,
        hintStyle: TextStyle(
          color: AppPallete.grey,
        ),
        suffixIcon: Icon(
          Icons.search,
          color: AppPallete.grey,
        ),
      ),
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
    );
  }
}
