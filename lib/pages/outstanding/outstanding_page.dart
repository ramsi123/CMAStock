import 'dart:async';
import 'package:cahaya_mulya_abadi/components/my_searchbar.dart';
import 'package:cahaya_mulya_abadi/components/outstanding_tile.dart';
import 'package:cahaya_mulya_abadi/services/database/database_service.dart';
import 'package:cahaya_mulya_abadi/utils/format_date.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'outstanding_detail_page.dart';

class OutstandingPage extends StatefulWidget {
  static route() =>
      MaterialPageRoute(builder: (context) => const OutstandingPage());
  const OutstandingPage({super.key});

  @override
  State<OutstandingPage> createState() => _OutstandingPageState();
}

class _OutstandingPageState extends State<OutstandingPage> {
  // database service
  final databaseService = DatabaseService();

  // variables
  String searchedItem = '';
  List<int> totalOrder = [];
  Stream<QuerySnapshot<Object?>>? getOrder;
  late StreamSubscription orderSubscription;

  void calculateTotalOrder(QuerySnapshot<Object?> event) {
    final orderData = event.docs;

    // reset value
    totalOrder = [];

    for (var data in orderData) {
      // temp variables
      int tempTotalOrder = 0;

      for (var tempOrder in data['orderItemQuantity']) {
        tempTotalOrder += int.parse(tempOrder);
      }

      // add to list
      totalOrder.add(tempTotalOrder);
    }
  }

  @override
  void initState() {
    super.initState();

    // retrieve all order
    getOrder = databaseService.getOrder();

    // subscribe to order data stream to calculate total order
    orderSubscription = databaseService.getOrder().listen(calculateTotalOrder);
  }

  @override
  void dispose() {
    // dispose subscription to prevent memory leaks
    orderSubscription.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Outstanding History'),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // search bar
                MySearchbar(
                  hintText: 'Search',
                  onChanged: (value) {
                    setState(() {
                      searchedItem = value;
                    });
                  },
                ),

                const SizedBox(height: 15),

                // list of item
                Expanded(
                  child: StreamBuilder(
                    stream: getOrder,
                    builder: (context, snapshot) {
                      // error
                      if (snapshot.hasError) {
                        return const Center(
                          child: Text('Error'),
                        );
                      }

                      // loading..
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      final orderData = snapshot.data!.docs;

                      // no data
                      if (orderData.isEmpty) {
                        return Container(
                          alignment: Alignment.center,
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // animation
                                Lottie.asset('assets/empty-item.json'),

                                // text
                                const Text('No outstanding history'),
                              ],
                            ),
                          ),
                        );
                      }

                      // load complete
                      if (searchedItem.isEmpty) {
                        return ListView.separated(
                          separatorBuilder: (context, index) {
                            return const SizedBox(height: 10);
                          },
                          itemCount: orderData.length,
                          itemBuilder: (context, index) {
                            final data = orderData[index];
                            Timestamp timestamp = data['timestamp'];
                            DateTime dateTime = timestamp.toDate();
                            String formattedDate = formatDateBydMy(dateTime);

                            // only show when orderLeftovers > 0
                            if (int.parse(data['orderLeftovers'].toString()) >
                                0) {
                              return OutstandingTile(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    OutstandingDetailPage.route(data.id),
                                  );
                                },
                                backgroundColor:
                                    Theme.of(context).colorScheme.tertiary,
                                customerName: data['customerName'],
                                totalOrder: totalOrder[index].toString(),
                                unit: 'Pcs',
                                date: formattedDate,
                                leftovers: data['orderLeftovers'],
                              );
                            }
                            return Container();
                          },
                        );
                      } else {
                        return ListView.separated(
                          separatorBuilder: (context, index) {
                            return const SizedBox(height: 10);
                          },
                          itemCount: orderData.length,
                          itemBuilder: (context, index) {
                            final data = orderData[index];
                            Timestamp timestamp = data['timestamp'];
                            DateTime dateTime = timestamp.toDate();
                            String formattedDate = formatDateBydMy(dateTime);

                            if (data['customerName']
                                .toString()
                                .toLowerCase()
                                .contains(
                                  searchedItem.toLowerCase(),
                                )) {
                              // only show when orderLeftovers > 0
                              if (int.parse(data['orderLeftovers'].toString()) >
                                  0) {
                                return OutstandingTile(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      OutstandingDetailPage.route(data.id),
                                    );
                                  },
                                  backgroundColor:
                                      Theme.of(context).colorScheme.tertiary,
                                  customerName: data['customerName'],
                                  totalOrder: totalOrder[index].toString(),
                                  unit: 'Pcs',
                                  date: formattedDate,
                                  leftovers: data['orderLeftovers'],
                                );
                              }
                              return Container();
                            }

                            return Container();
                          },
                        );
                      }
                    },
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
