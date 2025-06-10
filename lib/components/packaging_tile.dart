import 'package:cahaya_mulya_abadi/themes/app_pallete.dart';
import 'package:flutter/material.dart';

class PackagingTile extends StatefulWidget {
  final String title;
  final String amount;
  final String status;
  final Function()? onTap;
  const PackagingTile({
    super.key,
    required this.title,
    required this.amount,
    required this.status,
    required this.onTap,
  });

  @override
  State<PackagingTile> createState() => _PackagingTileState();
}

class _PackagingTileState extends State<PackagingTile> {
  // color variables
  Color lightColor = AppPallete.lightYellow;
  Color darkColor = AppPallete.yellowWarning;

  @override
  void initState() {
    super.initState();
    if (widget.status.toLowerCase().contains('waiting')) {
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
                      'Jumlah Request: ${widget.amount}',
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
