import 'package:flutter/material.dart';

class MyStickyButton extends StatelessWidget {
  final Function()? onTap;
  final String text;
  final List<Color> backgroundColor;

  const MyStickyButton({
    super.key,
    required this.onTap,
    required this.text,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            colors: backgroundColor,
          ),
        ),
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50), // Full-width button
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
          ),
          child: Text(text),
        ),
      ),
    );
  }
}
