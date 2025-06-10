import 'package:cahaya_mulya_abadi/themes/app_pallete.dart';
import 'package:cahaya_mulya_abadi/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class OrderTile extends StatefulWidget {
  final String title;
  final String description;
  final String status;
  final String userRole;
  final Function(BuildContext)? navigateToDetailOrderPage;
  final Function(BuildContext)? onPressedDelete;
  const OrderTile({
    super.key,
    required this.title,
    required this.description,
    required this.status,
    required this.userRole,
    required this.navigateToDetailOrderPage,
    required this.onPressedDelete,
  });

  @override
  State<OrderTile> createState() => _OrderTileState();
}

class _OrderTileState extends State<OrderTile> {
  // color variables
  Color lightColor = AppPallete.lightYellow;
  Color darkColor = AppPallete.yellowWarning;

  @override
  void initState() {
    super.initState();
    if (widget.status.toLowerCase().contains('not yet')) {
      lightColor = AppPallete.lightRed;
      darkColor = AppPallete.redDanger;
    } else if (widget.status.toLowerCase().contains('process')) {
      lightColor = AppPallete.lightYellow;
      darkColor = AppPallete.yellowWarning;
    } else if (widget.status.toLowerCase().contains('done')) {
      lightColor = AppPallete.lightGreen;
      darkColor = AppPallete.greenSuccess;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
      child: Slidable(
        endActionPane: widget.userRole.contains('owner')
            ? ActionPane(
                extentRatio: 0.35,
                motion: const StretchMotion(),
                children: [
                  // edit
                  SlidableAction(
                    onPressed: widget.navigateToDetailOrderPage,
                    icon: Icons.edit_outlined,
                    label: Constants.edit,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    padding: const EdgeInsets.all(0),
                  ),

                  // delete
                  SlidableAction(
                    onPressed: widget.onPressedDelete,
                    icon: Icons.delete_outline,
                    label: Constants.delete,
                    foregroundColor: AppPallete.redDanger,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    padding: const EdgeInsets.all(0),
                  ),
                ],
              )
            : ActionPane(
                extentRatio: 0.35,
                motion: const StretchMotion(),
                children: [
                  // go to detail order page
                  SlidableAction(
                    onPressed: widget.navigateToDetailOrderPage,
                    icon: Icons.remove_red_eye_outlined,
                    label: Constants.observeDetail,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    padding: const EdgeInsets.all(0),
                  ),
                ],
              ),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 22,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // title, and description
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // title
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),

                    // description
                    Text(
                      widget.description,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 35),

              // status
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 14,
                ),
                decoration: BoxDecoration(
                  color: lightColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: darkColor,
                  ),
                ),
                child: Text(
                  widget.status,
                  style: TextStyle(
                    color: darkColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
