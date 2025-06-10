import 'package:cahaya_mulya_abadi/themes/app_pallete.dart';
import 'package:cahaya_mulya_abadi/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class RequestStockTile extends StatefulWidget {
  final String title;
  final String amount;
  final String unit;
  final String status;
  final Function()? onTap;
  final Function(BuildContext)? onPressedDelete;
  const RequestStockTile({
    super.key,
    required this.title,
    required this.amount,
    required this.unit,
    required this.status,
    required this.onTap,
    required this.onPressedDelete,
  });

  @override
  State<RequestStockTile> createState() => _RequestStockTileState();
}

class _RequestStockTileState extends State<RequestStockTile> {
  // color variables
  Color lightColor = AppPallete.lightYellow;
  Color darkColor = AppPallete.yellowWarning;

  @override
  void initState() {
    super.initState();
    if (widget.status.toLowerCase().contains('waiting')) {
      lightColor = AppPallete.lightYellow;
      darkColor = AppPallete.yellowWarning;
    } else if (widget.status.toLowerCase().contains('approve')) {
      lightColor = AppPallete.lightGreen;
      darkColor = AppPallete.greenSuccess;
    } else if (widget.status.toLowerCase().contains('reject')) {
      lightColor = AppPallete.lightRed;
      darkColor = AppPallete.redDanger;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
      child: Slidable(
        endActionPane: ActionPane(
          extentRatio: 0.25,
          motion: const StretchMotion(),
          children: [
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
        ),
        child: GestureDetector(
          onTap: widget.onTap,
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
                        'Qty: ${widget.amount} ${widget.unit}',
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
      ),
    );
  }
}
