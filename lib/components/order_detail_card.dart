import 'package:flutter/material.dart';

class OrderDetailCard extends StatelessWidget {
  final String customerName;
  final String orderDate;
  final String totalOrder;
  final String description;
  final List<String> orderProduct;
  const OrderDetailCard({
    super.key,
    required this.customerName,
    required this.orderDate,
    required this.totalOrder,
    required this.description,
    required this.orderProduct,
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
          // customer name
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nama Customer : ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Expanded(
                child: Text(
                  customerName,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.visible,
                ),
              ),
            ],
          ),

          const SizedBox(height: 3),

          // order date
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tanggal Pesan : ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Expanded(
                child: Text(
                  orderDate,
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
                  '$totalOrder Pcs',
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.visible,
                ),
              ),
            ],
          ),

          const SizedBox(height: 3),

          // description
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Deskripsi : ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Expanded(
                child: Text(
                  description,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.visible,
                ),
              ),
            ],
          ),

          const SizedBox(height: 3),

          // product title
          const Text(
            'Product :',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 3),

          // list of products
          for (var order in orderProduct)
            Text(
              '- $order',
              style: const TextStyle(
                fontSize: 16,
              ),
              overflow: TextOverflow.visible,
            ),
        ],
      ),
    );
  }
}
