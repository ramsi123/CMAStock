import 'dart:async';
import 'package:cahaya_mulya_abadi/components/my_button.dart';
import 'package:cahaya_mulya_abadi/services/database/database_service.dart';
import 'package:cahaya_mulya_abadi/themes/app_pallete.dart';
import 'package:cahaya_mulya_abadi/utils/show_snackbar.dart';
import 'package:flutter/material.dart';

class RequestStockDetailPage extends StatefulWidget {
  static route(
    String docId,
  ) =>
      MaterialPageRoute(
        builder: (context) => RequestStockDetailPage(
          docId: docId,
        ),
      );
  final String docId;
  const RequestStockDetailPage({
    super.key,
    required this.docId,
  });

  @override
  State<RequestStockDetailPage> createState() => _RequestStockDetailPageState();
}

class _RequestStockDetailPageState extends State<RequestStockDetailPage> {
  // database service
  final databaseService = DatabaseService();

  // variables
  String namaBarang = '';
  String jumlahBarang = '';
  String unit = '';
  String deskripsiBarang = '';
  String status = '';
  late StreamSubscription stockDetailReqSubscription;

  void givePermission(
    BuildContext context,
    String docId,
    String status,
  ) async {
    try {
      await databaseService.givePermissionStockRequest(docId, status);
    } catch (e) {
      if (context.mounted) {
        showSnackbar(context, e.toString());
      }
    }
  }

  void onStockDetailRequest(Map<String, dynamic> stockRequestDetail) {
    setState(() {
      namaBarang = stockRequestDetail['namaBarang'];
      jumlahBarang = stockRequestDetail['jumlahBarang'];
      unit = stockRequestDetail['unit'];
      deskripsiBarang = stockRequestDetail['deskripsiBarang'];
      status = stockRequestDetail['status'];
    });
  }

  @override
  void initState() {
    super.initState();

    // retrieve data from firestore, then store it into variable
    stockDetailReqSubscription = databaseService
        .getDetailStockRequest(widget.docId)
        .listen(onStockDetailRequest);
  }

  @override
  void dispose() {
    // dispose the subscription to prevent memory leaks
    stockDetailReqSubscription.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Stock Detail'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // information
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 15,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    // name
                    Row(
                      children: [
                        const Text(
                          'Nama Barang : ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          namaBarang,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 3),

                    // amount
                    Row(
                      children: [
                        const Text(
                          'Jumlah : ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '$jumlahBarang $unit',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 3),

                    // status
                    Row(
                      children: [
                        const Text(
                          'Status : ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          status,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 3),

                    // description
                    Row(
                      children: [
                        const Text(
                          'Deskripsi/Notes : ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          deskripsiBarang,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // approve button
              MyButton(
                onTap: () {
                  givePermission(context, widget.docId, 'Approve');
                  Navigator.pop(context);
                  showSnackbar(context, 'Request stock diberikan.');
                },
                text: 'Approve',
                backgroundColor: const [
                  AppPallete.greenSuccess,
                  AppPallete.greenSuccess,
                ],
              ),

              const SizedBox(height: 5),

              // reject button
              MyButton(
                onTap: () {
                  givePermission(context, widget.docId, 'Reject');
                  Navigator.pop(context);
                  showSnackbar(context, 'Request stock ditolak.');
                },
                text: 'Reject',
                backgroundColor: const [
                  AppPallete.redDanger,
                  AppPallete.redDanger,
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
