import 'dart:async';
import 'package:cahaya_mulya_abadi/components/my_button.dart';
import 'package:cahaya_mulya_abadi/services/database/database_service.dart';
import 'package:cahaya_mulya_abadi/themes/app_pallete.dart';
import 'package:cahaya_mulya_abadi/utils/dialog_box.dart';
import 'package:cahaya_mulya_abadi/utils/show_snackbar.dart';
import 'package:flutter/material.dart';

class PackagingDetailPage extends StatefulWidget {
  static route(
    String packagingId,
    String productId,
  ) =>
      MaterialPageRoute(
        builder: (context) => PackagingDetailPage(
          packagingId: packagingId,
          productId: productId,
        ),
      );
  final String packagingId;
  final String productId;
  const PackagingDetailPage({
    super.key,
    required this.packagingId,
    required this.productId,
  });

  @override
  State<PackagingDetailPage> createState() => _PackagingDetailPageState();
}

class _PackagingDetailPageState extends State<PackagingDetailPage> {
  // database service
  final databaseService = DatabaseService();

  // variables
  String namaBarang = '';
  String jumlahBarang = '';
  String jumlahRequest = '';
  String status = '';
  int totalQty = 0;
  late StreamSubscription packagingReqSubscription;
  late StreamSubscription product;

  // when staff finished the packaging
  void finishedPackaging(
    BuildContext context,
    String packagingId,
    String productId,
    String status,
  ) async {
    try {
      // finished packaging
      await databaseService.finishedPackaging(packagingId, status);

      // update product quantity
      await databaseService.editProductQuantity(
        productId,
        totalQty.toString(),
      );
    } catch (e) {
      if (context.mounted) {
        showSnackbar(context, e.toString());
      }
    }
  }

  // fetch packaging data from firebase
  void onRetrievePackagingDetail(Map<String, dynamic> packagingRequestDetail) {
    setState(() {
      namaBarang = packagingRequestDetail['namaBarang'];
      jumlahRequest = packagingRequestDetail['jumlahRequest'];
      status = packagingRequestDetail['status'];
    });
  }

  // fetch product data from firebase
  void onRetrieveProduct(Map<String, dynamic> productData) {
    jumlahBarang = productData['jumlahBarang'];

    // subtract product
    totalQty = int.parse(jumlahBarang) - int.parse(jumlahRequest);
  }

  @override
  void initState() {
    super.initState();

    // retrieve data from firestore, then store it into variable
    packagingReqSubscription = databaseService
        .getDetailPackaging(widget.packagingId)
        .listen(onRetrievePackagingDetail);

    // fetch product data
    product = databaseService
        .getDetailProduct(widget.productId)
        .listen(onRetrieveProduct);
  }

  @override
  void dispose() {
    // dispose the subscription to prevent memory leaks
    packagingReqSubscription.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Packaging'),
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
                          'Jumlah Request : ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          jumlahRequest,
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
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // approve button
              MyButton(
                onTap: () {
                  if (status.toLowerCase().contains('waiting')) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return DialogBox(
                          onAllow: () {
                            if (int.parse(jumlahBarang) <
                                int.parse(jumlahRequest)) {
                              Navigator.pop(context);
                              showSnackbar(
                                  context, 'Stok barang tidak memadai.');
                            } else {
                              finishedPackaging(
                                context,
                                widget.packagingId,
                                widget.productId,
                                'Done',
                              );
                              Navigator.pop(context);
                              Navigator.pop(context);
                              showSnackbar(context, 'Packaging telah selesai.');
                            }
                          },
                          onDeny: Navigator.of(context).pop,
                          title: 'Selesaikan Packaging',
                          description: 'Apakah packaging sudah selesai?',
                          allowText: 'Ya',
                          denyText: 'Tidak',
                        );
                      },
                    );
                  }
                },
                text: 'Done',
                backgroundColor: status.toLowerCase().contains('waiting')
                    ? const [
                        AppPallete.greenSuccess,
                        AppPallete.greenSuccess,
                      ]
                    : const [
                        AppPallete.mainGridLineColor,
                        AppPallete.mainGridLineColor,
                      ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
