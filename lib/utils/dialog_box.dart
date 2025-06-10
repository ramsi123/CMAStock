import 'package:flutter/material.dart';

// ignore: must_be_immutable
class DialogBox extends StatelessWidget {
  VoidCallback onAllow;
  VoidCallback onDeny;
  String title;
  String description;
  String allowText;
  String denyText;
  DialogBox({
    super.key,
    required this.onAllow,
    required this.onDeny,
    required this.title,
    required this.description,
    required this.allowText,
    required this.denyText,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      content: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // title
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 5),

            // description
            Text(
              description,
            ),

            /* const SizedBox(height: 5),

            const SizedBox(
              width: double.infinity,
              child: Text(
                'You can change this later from Settings > Application > App Info > Battery Usage.',
              ),
            ), */

            const SizedBox(height: 10),

            // buttons -> deny + allow
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // deny button
                MaterialButton(
                  onPressed: onDeny,
                  /* color: Colors.grey.shade100,
                  elevation: 4, */
                  child: Text(
                    denyText,
                    style: const TextStyle(color: Colors.blueAccent),
                  ),
                ),

                const SizedBox(width: 8),

                // allow button
                MaterialButton(
                  onPressed: onAllow,
                  /* color: Colors.grey.shade100,
                  elevation: 4, */
                  child: Text(
                    allowText,
                    style: const TextStyle(color: Colors.blueAccent),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
