import 'dart:async';
import 'package:cahaya_mulya_abadi/components/dashboard_tile.dart';
import 'package:cahaya_mulya_abadi/components/my_line_chart.dart';
import 'package:cahaya_mulya_abadi/components/outstanding_tile.dart';
import 'package:cahaya_mulya_abadi/pages/outstanding/outstanding_detail_page.dart';
import 'package:cahaya_mulya_abadi/pages/outstanding/outstanding_page.dart';
import 'package:cahaya_mulya_abadi/services/auth/auth_service.dart';
import 'package:cahaya_mulya_abadi/services/database/database_service.dart';
import 'package:cahaya_mulya_abadi/themes/app_pallete.dart';
import 'package:cahaya_mulya_abadi/utils/battery_optimization.dart';
import 'package:cahaya_mulya_abadi/utils/calculate_line_chart.dart';
import 'package:cahaya_mulya_abadi/utils/format_date.dart';
import 'package:cahaya_mulya_abadi/utils/show_snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // database & auth service
  final databaseService = DatabaseService();
  final authService = AuthService();

  // variables
  String userUid = '';
  String name = '';
  String role = '';
  int totalProduct = 0;
  double totalStock = 0;
  //String formattedTotalStock = '';
  String unit = 'Kg';
  int totalOrder = 0;
  int totalActiveOrder = 0;
  List<FlSpot> lineChartCoordinate = [];
  bool isNotificationOn = false;
  int outstandingIndex = 0;
  List<int> totalOutstandingOrder = [];
  late StreamSubscription userSubscription;
  late StreamSubscription productSubscription;
  late StreamSubscription stockSubscription;
  late StreamSubscription orderSubscription;
  late StreamSubscription outstandingSubscription;

  // format date
  String formatDate(Timestamp date) {
    Timestamp timestamp = date;
    DateTime dateTime = timestamp.toDate();
    return formatDateBydMy(dateTime);
  }

  // retrieve user profile
  void onRetrieveUserProfile(Map<String, dynamic> userProfile) {
    setState(() {
      userUid = userProfile['uid'];
      name = userProfile['name'];
      role = userProfile['role'];
      isNotificationOn = userProfile['notification'];
    });
  }

  // retrieve product data
  void onRetrieveProduct(QuerySnapshot<Object?> event) {
    // reset value
    totalProduct = 0;

    final productData = event.docs;
    for (var data in productData) {
      setState(() {
        totalProduct += int.parse(data['jumlahBarang']);
      });
    }
  }

  // retrieve stock data
  void onRetrieveStock(QuerySnapshot<Object?> event) {
    // reset value
    totalStock = 0;
    //formattedTotalStock = '';
    unit = 'Kg';

    final stockData = event.docs;
    double tempStock = 0;
    for (var data in stockData) {
      if (data['unit'].toString().toLowerCase().contains('kg')) {
        setState(() {
          tempStock = double.parse(data['jumlahBarang']) * 1000;
          totalStock += tempStock;
        });
      } else {
        setState(() {
          totalStock += double.parse(data['jumlahBarang']);
        });
      }
    }

    // convert to kg
    totalStock = totalStock / 1000;

    // formatted total stock, only show 3 fraction digits
    //formattedTotalStock = totalStock.toStringAsFixed(3);

    // if total stock is less than 1 kg, change format to Gram
    if (totalStock < 1) {
      setState(() {
        totalStock = totalStock * 1000;
        unit = 'Gram';
      });
    }
  }

  // retrieve order data
  void onRetrieveOrder(QuerySnapshot<Object?> event) {
    // reset value
    totalOrder = 0;
    totalActiveOrder = 0;

    final orderData = event.docs;
    final List<int> numOrderPerMonth = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

    for (var data in orderData) {
      // total order
      setState(() {
        totalOrder++;
      });

      // total active order
      if (data['status'].toString().toLowerCase().contains('process')) {
        setState(() {
          totalActiveOrder++;
        });
      }

      // current year
      final String currentYear = formatDateByYYYY(DateTime.now());

      // data obtained from firestore
      final Timestamp timestamp = data['timestamp'];
      final DateTime dateTime = timestamp.toDate();
      final String time = formatDateBydMMMYYYY(dateTime);
      final String month = formatDateByMMM(dateTime);

      // check current year
      if (time.toLowerCase().contains(currentYear)) {
        // check every month
        switch (month.toLowerCase()) {
          case 'jan':
            numOrderPerMonth[0]++;
            break;
          case 'feb':
            numOrderPerMonth[1]++;
            break;
          case 'mar':
            numOrderPerMonth[2]++;
            break;
          case 'apr':
            numOrderPerMonth[3]++;
            break;
          case 'may':
            numOrderPerMonth[4]++;
            break;
          case 'jun':
            numOrderPerMonth[5]++;
            break;
          case 'jul':
            numOrderPerMonth[6]++;
            break;
          case 'aug':
            numOrderPerMonth[7]++;
            break;
          case 'sep':
            numOrderPerMonth[8]++;
            break;
          case 'oct':
            numOrderPerMonth[9]++;
            break;
          case 'nov':
            numOrderPerMonth[10]++;
            break;
          case 'dec':
            numOrderPerMonth[11]++;
            break;
        }
      }
    }

    lineChartCoordinate = calculateLineChart(numOrderPerMonth);
  }

  // calculate outstanding
  void calculateOutstanding(QuerySnapshot<Object?> event) {
    final orderData = event.docs;

    // reset value
    totalOutstandingOrder = [];

    for (var data in orderData) {
      // temp variables
      int tempTotalOrder = 0;

      for (var tempOrder in data['orderItemQuantity']) {
        tempTotalOrder += int.parse(tempOrder);
      }

      // add to list
      totalOutstandingOrder.add(tempTotalOrder);
    }
  }

  @override
  void initState() {
    super.initState();

    // retrieve user profile
    userSubscription =
        authService.getUserProfile().listen(onRetrieveUserProfile);

    // retrieve product data
    productSubscription =
        databaseService.getProduct().listen(onRetrieveProduct);

    // retrieve stock data
    stockSubscription = databaseService.getStock().listen(onRetrieveStock);

    // retrieve order data
    orderSubscription = databaseService.getOrder().listen(onRetrieveOrder);

    // retrieve outstanding
    outstandingSubscription =
        databaseService.getOrder().listen(calculateOutstanding);
  }

  @override
  void dispose() {
    // dispose subscription to prevent memory leaks
    userSubscription.cancel();
    productSubscription.cancel();
    stockSubscription.cancel();
    orderSubscription.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // profile name
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    left: 15,
                    top: 14,
                    right: 5,
                    bottom: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // name & role
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // name
                            Text(
                              name.isNotEmpty ? name : '...',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),

                            const SizedBox(height: 2),

                            // role
                            Text(
                              role,
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 20),

                      // notification icon
                      IconButton(
                        onPressed: () {
                          setState(() {
                            isNotificationOn = !isNotificationOn;
                          });
                          databaseService.updateNotification(
                            userUid,
                            isNotificationOn,
                          );
                          if (isNotificationOn) {
                            checkBatteryOptimization(context);
                            showSnackbar(context, 'Notification set up');
                          } else {
                            showSnackbar(context, 'Notification cancelled');
                          }
                        },
                        icon: isNotificationOn
                            ? const Icon(Icons.notifications_outlined)
                            : const Icon(Icons.notifications_off_outlined),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                // dashboard title
                const Text(
                  'Dashboard',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),

                const SizedBox(height: 5),

                // dashboard tile row 1
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: DashboardTile(
                        title: 'Total Produksi',
                        description: '$totalProduct Pcs',
                        iconAsset: 'assets/total_produksi.svg',
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      flex: 1,
                      child: DashboardTile(
                        title: 'Sisa Bahan Baku',
                        description: '$totalStock $unit',
                        iconAsset: 'assets/sisa_bahan_baku.svg',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 5),

                // dashboard tile row 2
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: DashboardTile(
                        title: 'Total Pesanan',
                        description: '$totalOrder Order',
                        iconAsset: 'assets/total_pesanan.svg',
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      flex: 1,
                      child: DashboardTile(
                        title: 'Pesanan Aktif',
                        description: '$totalActiveOrder Order',
                        iconAsset: 'assets/pesanan_aktif.svg',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                // order graphic title
                const Text(
                  'Grafik Pemesanan',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),

                const SizedBox(height: 5),

                // order graphic's line chart
                MyLineChart(
                  lineChartCoordinate: lineChartCoordinate,
                ),

                const SizedBox(height: 15),

                // outstanding history title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // title
                    const Text(
                      'Outstanding History',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),

                    // view all
                    ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return const LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            AppPallete.peach,
                            AppPallete.pink,
                          ],
                        ).createShader(bounds);
                      },
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            OutstandingPage.route(),
                          );
                        },
                        child: const Text(
                          'View All',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // outstanding history list
                StreamBuilder(
                  stream: databaseService.getOrder(),
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
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      separatorBuilder: (context, index) {
                        return const SizedBox(
                          height: 0,
                          child: Divider(
                            color: Colors.grey,
                          ),
                        );
                      },
                      itemCount: orderData.length,
                      itemBuilder: (context, index) {
                        // only show 3 data in dashboard
                        if (outstandingIndex < 3) {
                          final data = orderData[index];

                          // only show when orderLeftovers > 0
                          if (int.parse(data['orderLeftovers'].toString()) >
                              0) {
                            // increment index
                            outstandingIndex++;

                            return OutstandingTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  OutstandingDetailPage.route(data.id),
                                );
                              },
                              backgroundColor: AppPallete.lightWhite,
                              customerName: data['customerName'],
                              totalOrder:
                                  totalOutstandingOrder[index].toString(),
                              unit: 'Pcs',
                              date: formatDate(data['timestamp'] as Timestamp),
                              leftovers: data['orderLeftovers'],
                            );
                          }
                        }

                        return Container();
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
}
