import 'package:flutter/material.dart';

class MyOutlinedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Color iconColor;
  final Gradient gradient;

  const MyOutlinedButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.iconColor,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2), // Border thickness
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: SizedBox(
            height: 40,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide.none, // Remove default border
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(0, 40), // Ensures height is controlled
              ),
              onPressed: onPressed,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // icon
                  Icon(
                    Icons.add,
                    color: iconColor,
                  ),

                  const SizedBox(width: 10),

                  // text
                  ShaderMask(
                    shaderCallback: (bounds) {
                      return gradient.createShader(
                        Rect.fromLTWH(
                          0,
                          0,
                          bounds.width,
                          bounds.height,
                        ),
                      );
                    },
                    child: Text(
                      text,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
