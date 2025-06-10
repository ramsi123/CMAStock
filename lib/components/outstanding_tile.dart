import 'package:flutter/material.dart';

class OutstandingTile extends StatelessWidget {
  final Function()? onTap;
  final Color backgroundColor;
  final String customerName;
  final String totalOrder;
  final String unit;
  final String date;
  final String leftovers;

  const OutstandingTile({
    super.key,
    required this.onTap,
    required this.backgroundColor,
    required this.customerName,
    required this.totalOrder,
    required this.unit,
    required this.date,
    required this.leftovers,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
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
                  // customer name
                  Text(
                    customerName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),

                  // total order
                  Text(
                    'Total Order: $totalOrder $unit',
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 3),

                  // timestamp
                  Text(
                    date,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 35),

            // leftovers
            Text(
              '$leftovers Left',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
