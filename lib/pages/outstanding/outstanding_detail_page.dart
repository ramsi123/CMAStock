import 'dart:async';
import 'package:cahaya_mulya_abadi/components/order_detail_card.dart';
import 'package:cahaya_mulya_abadi/components/outstanding_detail_card.dart';
import 'package:cahaya_mulya_abadi/services/database/database_service.dart';
import 'package:cahaya_mulya_abadi/utils/format_date.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class OutstandingDetailPage extends StatefulWidget {
  static route(String docId) => MaterialPageRoute(
        builder: (context) => OutstandingDetailPage(
          docId: docId,
        ),
      );

  final String docId;

  const OutstandingDetailPage({
    super.key,
    required this.docId,
  });

  @override
  State<OutstandingDetailPage> createState() => _OutstandingDetailPageState();
}

class _OutstandingDetailPageState extends State<OutstandingDetailPage> {
  // database service
  final databaseService = DatabaseService();

  // variables
  Stream<Map<String, dynamic>>? getDetailOrder;
  Stream<QuerySnapshot>? getOutstandingHistory;

  // format date
  String formatDate(Timestamp date) {
    Timestamp timestamp = date;
    DateTime dateTime = timestamp.toDate();
    return formatDateBydMy(dateTime);
  }

  // calculate total order
  String calculateTotalOrder(List<dynamic> orderItemQty) {
    int totalOrder = 0;
    for (var data in orderItemQty) {
      totalOrder += int.parse(data);
    }
    return totalOrder.toString();
  }

  // convert order item to List<String>
  List<String> convertOrderItem(List<dynamic> order) {
    List<dynamic> orderItem = order;
    List<String> orderItemList = orderItem.cast<String>();
    return orderItemList;
  }

  @override
  void initState() {
    super.initState();

    // retrieve all order
    getDetailOrder = databaseService.getDetailOrder(widget.docId);

    // retrieve outstanding history
    getOutstandingHistory = databaseService.getOutstanding(widget.docId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Detail'),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // order detail
                StreamBuilder(
                  stream: getDetailOrder,
                  builder: (context, snapshot) {
                    // error
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    // loading..
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _orderDetail(
                        '...',
                        '...',
                        '...',
                        '...',
                        ['...'],
                      );
                    }

                    final orderData = snapshot.data ?? {};

                    // no data
                    if (orderData.isEmpty) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // title
                          Container(
                            alignment: Alignment.centerLeft,
                            child: const Text(
                              'Order Detail',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // animation
                          Container(
                            alignment: Alignment.center,
                            child: Lottie.asset('assets/empty-item.json'),
                          ),

                          // text
                          const Text('No order detail'),

                          const SizedBox(height: 30),
                        ],
                      );
                    }

                    // load complete
                    return _orderDetail(
                      orderData['customerName'],
                      formatDate(orderData['timestamp'] as Timestamp),
                      calculateTotalOrder(orderData['orderItemQuantity']),
                      orderData['deskripsi'],
                      convertOrderItem(orderData['orderItemName']),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // outstanding date history
                StreamBuilder(
                  stream: getOutstandingHistory,
                  builder: (context, snapshot) {
                    // error
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    // loading..
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _outstandingDateHistory(
                        '...',
                        '...',
                        '...',
                      );
                    }

                    final outstandingData = snapshot.data!.docs;

                    // no data
                    if (outstandingData.isEmpty) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // title
                          Container(
                            alignment: Alignment.centerLeft,
                            child: const Text(
                              'Outstanding Date History',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // animation
                          Container(
                            alignment: Alignment.center,
                            child: Lottie.asset('assets/empty-item.json'),
                          ),

                          // text
                          const Text('No outstanding date history'),
                        ],
                      );
                    }

                    // load complete
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: outstandingData.length,
                      itemBuilder: (context, index) {
                        final data = outstandingData[index];

                        return _outstandingDateHistory(
                          formatDate(data['timestamp'] as Timestamp),
                          data['jumlah'],
                          data['note'],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _orderDetail(
    String customerName,
    String orderDate,
    String totalOrder,
    String description,
    List<String> orderProduct,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // order detail title
        const Text(
          'Order Detail',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),

        const SizedBox(height: 10),

        // order detail
        OrderDetailCard(
          customerName: customerName,
          orderDate: orderDate,
          totalOrder: totalOrder,
          description: description,
          orderProduct: orderProduct,
        ),
      ],
    );
  }

  Widget _outstandingDateHistory(
    String date,
    String amount,
    String note,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // outstanding date history title
        const Text(
          'Outstanding Date History',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),

        const SizedBox(height: 10),

        // list of outstanding date history
        OutstandingDetailCard(
          date: date,
          amount: amount,
          note: note,
        ),
      ],
    );
  }
}
