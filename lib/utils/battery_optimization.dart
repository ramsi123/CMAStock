import 'package:app_settings/app_settings.dart';
import 'package:cahaya_mulya_abadi/utils/dialog_box.dart';
import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:flutter/material.dart';

void checkBatteryOptimization(BuildContext context) async {
  bool? isBatteryOptimizationDisabled =
      await DisableBatteryOptimization.isBatteryOptimizationDisabled;

  if (isBatteryOptimizationDisabled != null && !isBatteryOptimizationDisabled) {
    if (context.mounted) {
      showBatteryOptimizationDialog(context);
    }
  }
}

// show battery optimization dialog
void showBatteryOptimizationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return DialogBox(
        onAllow: () {
          AppSettings.openAppSettings(
            type: AppSettingsType.settings,
          );
          Navigator.of(context).pop();
        },
        onDeny: Navigator.of(context).pop,
        title: 'Your device has additional battery optimization',
        description:
            'Please disable the battery optimizations or allow for background activity in the settings to allow smooth functioning of this app.',
        allowText: 'Allow',
        denyText: 'Deny',
      );
    },
  );
}
