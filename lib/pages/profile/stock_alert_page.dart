import 'dart:async';
import 'package:cahaya_mulya_abadi/components/my_button.dart';
import 'package:cahaya_mulya_abadi/components/number_of_goods_textfield.dart';
import 'package:cahaya_mulya_abadi/services/database/database_service.dart';
import 'package:cahaya_mulya_abadi/themes/app_pallete.dart';
import 'package:cahaya_mulya_abadi/utils/battery_optimization.dart';
import 'package:cahaya_mulya_abadi/utils/show_snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StockAlertPage extends StatefulWidget {
  static route(
    String docId,
    String stockAlertAmount,
    String stockAlertUnit,
  ) =>
      MaterialPageRoute(
        builder: (context) => StockAlertPage(
          docId: docId,
          stockAlertAmount: stockAlertAmount,
          stockAlertUnit: stockAlertUnit,
        ),
      );

  final String docId;
  final String stockAlertAmount;
  final String stockAlertUnit;

  const StockAlertPage({
    super.key,
    required this.docId,
    required this.stockAlertAmount,
    required this.stockAlertUnit,
  });

  @override
  State<StockAlertPage> createState() => _StockAlertPageState();
}

class _StockAlertPageState extends State<StockAlertPage> {
  // database service
  final databaseService = DatabaseService();

  // reminder at controllers
  final _stockAlertAmountController = TextEditingController();

  // form key
  final formKey = GlobalKey<FormState>();

  // stock name and quantity (kg) list availability
  final List<String> _stockName = [];
  final List<double> _stockQuantity = [];

  // selected stock
  final List<String> _selectedStock = [];

  // variables
  String unit = 'Kg';
  String text = 'stop service';
  late StreamSubscription stockSubscription;

  // calculate stock alert
  void calculateStockAlert() {
    // check the amount that user input
    double tempStockAmount = 0;
    if (widget.stockAlertUnit.toLowerCase().contains('gram')) {
      tempStockAmount = double.parse(widget.stockAlertAmount) / 1000;
    } else {
      tempStockAmount = double.parse(widget.stockAlertAmount);
    }

    int index = 0;
    for (var stockName in _stockName) {
      if (_stockQuantity[index] <= tempStockAmount) {
        setState(() {
          _selectedStock.add(stockName);
        });
      }

      index++;
    }
  }

  // save stock alert changes
  void saveStockAlert(
    BuildContext context,
    String docId,
    String stockAlertAmount,
    String stockAlertUnit,
  ) async {
    try {
      await databaseService.saveStockAlert(
        docId,
        stockAlertAmount,
        stockAlertUnit,
      );
    } catch (e) {
      if (context.mounted) {
        showSnackbar(context, e.toString());
      }
    }
  }

  // retrieve stock data
  void onRetrieveStock(QuerySnapshot<Object?> event) {
    double quantity = 0;
    final stockData = event.docs;
    for (var data in stockData) {
      setState(() {
        // store stock name
        _stockName.add(data['namaBarang']);

        // convert to kg first, then store stock quantity
        if (data['unit'].toString().toLowerCase().contains('gram')) {
          quantity = double.parse(data['jumlahBarang']) / 1000;
        } else {
          quantity = double.parse(data['jumlahBarang']);
        }
        _stockQuantity.add(quantity);
      });
    }

    // calculate stock data
    calculateStockAlert();
  }

  @override
  void initState() {
    super.initState();

    // initialize stock amount and unit
    _stockAlertAmountController.text = widget.stockAlertAmount;
    setState(() {
      unit = widget.stockAlertUnit;
    });

    // get stock data
    stockSubscription = databaseService.getStock().listen(onRetrieveStock);

    // check battery optimization
    checkBatteryOptimization(context);
  }

  @override
  void dispose() {
    // dispose subscription to prevent memory leaks
    stockSubscription.cancel();

    // dispose controller
    _stockAlertAmountController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Alert Bahan Baku'),
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    // reminder at
                    NumberOfGoodsTextfield(
                      controller: _stockAlertAmountController,
                      title: 'Reminder At',
                      hintText: 'Masukkan minimal bahan baku',
                      unit: unit,
                      onAmountChanged: (newValue) {},
                      onUnitChanged: (newUnit) {
                        setState(() {
                          unit = newUnit;
                        });
                      },
                      prevAmount: 0,
                      prevAmountUnit: '',
                      currentAmountUnit: '',
                      isItemLimitOn: false,
                      stockStatus: 0,
                      isRawMaterial: true,
                      isEnabled: true,
                    ),

                    const SizedBox(height: 25),

                    // save button
                    MyButton(
                      onTap: () {
                        if (formKey.currentState!.validate()) {
                          saveStockAlert(
                            context,
                            widget.docId,
                            _stockAlertAmountController.text
                                    .replaceAll(' ', '')
                                    .isNotEmpty
                                ? _stockAlertAmountController.text
                                    .replaceAll(' ', '')
                                : '0',
                            unit,
                          );
                          Navigator.pop(context);
                          showSnackbar(
                            context,
                            'Alert bahan baku berhasil diubah.',
                          );
                        }
                      },
                      text: "Simpan",
                      backgroundColor: const [
                        AppPallete.peach,
                        AppPallete.pink,
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
