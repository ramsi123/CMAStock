import 'package:flutter/material.dart';

class OutstandingDetailCard extends StatelessWidget {
  final String date;
  final String amount;
  final String note;
  const OutstandingDetailCard({
    super.key,
    required this.date,
    required this.amount,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 15,
        horizontal: 15,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // date
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tanggal : ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Expanded(
                child: Text(
                  date,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.visible,
                ),
              ),
            ],
          ),

          const SizedBox(height: 3),

          // amount
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Jumlah : ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Expanded(
                child: Text(
                  '$amount Pcs',
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.visible,
                ),
              ),
            ],
          ),

          const SizedBox(height: 3),

          // note
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Note : ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Expanded(
                child: Text(
                  note,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.visible,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
