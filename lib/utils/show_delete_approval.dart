import 'package:cahaya_mulya_abadi/themes/app_pallete.dart';
import 'package:cahaya_mulya_abadi/utils/show_snackbar.dart';
import 'package:flutter/material.dart';
import '../components/my_button.dart';
import 'constants.dart';

void showDeleteApproval(
  BuildContext context,
  String toastMessage,
  dynamic Function()? onTap,
) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.only(left: 14, top: 18, right: 14, bottom: 8),
        child: SizedBox(
          height: 270,
          child: Center(
            child: ListView(
              children: [
                Column(
                  children: [
                    // icon
                    ClipOval(
                      child: Container(
                        color: Theme.of(context).colorScheme.tertiary,
                        padding: const EdgeInsets.only(
                          left: 6,
                          right: 5,
                          bottom: 8,
                        ),
                        child: const Icon(
                          Icons.warning_amber_rounded,
                          size: 75,
                          color: AppPallete.redDanger,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // title
                    const Text(
                      Constants.deleteApprovalTitle,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // description
                    const Text(
                      Constants.deleteApprovalDescription,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 20),

                    // delete button
                    MyButton(
                      onTap: () {
                        Navigator.pop(context);
                        showSnackbar(context, toastMessage);
                        onTap!();
                      },
                      text: Constants.deleteApprovalButton,
                      backgroundColor: const [
                        AppPallete.redDanger,
                        AppPallete.redDanger,
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
