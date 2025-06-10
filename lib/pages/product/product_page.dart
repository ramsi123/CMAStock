import 'dart:async';
import 'package:cahaya_mulya_abadi/pages/product/add_product_page.dart';
import 'package:cahaya_mulya_abadi/pages/product/edit_product_page.dart';
import 'package:cahaya_mulya_abadi/themes/app_pallete.dart';
import 'package:cahaya_mulya_abadi/utils/constants.dart';
import 'package:cahaya_mulya_abadi/utils/show_delete_approval.dart';
import 'package:cahaya_mulya_abadi/utils/show_snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../components/item_tile.dart';
import '../../components/my_searchbar.dart';
import '../../services/database/database_service.dart';

class ProductPage extends StatefulWidget {
  final String userRole;
  const ProductPage({
    super.key,
    required this.userRole,
  });

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  // database service
  final databaseService = DatabaseService();

  // item and quantity list availability from stock
  final List<String> _stockId = [];
  final List<String> _stockItem = [];
  final List<double> _stockQty = [];
  final List<String> _stockUnit = [];

  // stora all product to a variable
  final List<Map<String, dynamic>> _products = [];

  // item, quantity, unit, and product amount selected from previous input
  int productAmountSelected = 0;
  final List<String> _stockItemSelected = [];
  final List<double> _stockQtySelected = [];
  final List<String> _stockUnitSelected = [];

  // updated stock quantity after material got returned.
  final List<num> _updatedStockQuantity = [];

  // variables
  String searchedItem = '';
  late StreamSubscription stockSubscription;
  late StreamSubscription productSubscription;

  // retrieve stock
  void onRetrieveStock(QuerySnapshot<Object?> event) async {
    final stockData = event.docs;

    // reset value first
    _stockId.clear();
    _stockItem.clear();
    _stockQty.clear();
    _stockUnit.clear();
    _updatedStockQuantity.clear();

    for (var data in stockData) {
      _stockId.add(data.id);
      _stockItem.add(data['namaBarang']);
      _stockQty.add(double.parse(data['jumlahBarang']));
      _stockUnit.add(data['unit']);
      _updatedStockQuantity.add(double.parse(data['jumlahBarang']));
    }
  }

  // pause stock stream
  void onRetrieveStockPause() {
    stockSubscription.pause();
  }

  // resume stock stream
  void onRetrieveStockResume() {
    stockSubscription.resume();
  }

  // retrieve product
  void onRetrieveProduct(QuerySnapshot<Object?> event) {
    final productData = event.docs;

    // reset value
    _products.clear();

    for (var data in productData) {
      _products.add({
        'id': data.id,
        'namaBarang': data['namaBarang'],
        'jumlahBarang': data['jumlahBarang'],
        'materialName': data['materialName'],
        'materialQuantity': data['materialQuantity'],
        'materialUnit': data['materialUnit'],
      });
    }
  }

  // pause product stream
  void onRetrieveProductPause() {
    productSubscription.pause();
  }

  // resume product stream
  void onRetrieveProductResume() {
    productSubscription.resume();
  }

  // calculate returned material
  void calculateReturnedMaterial(String productId) async {
    // reset selected material
    productAmountSelected = 0;
    _stockItemSelected.clear();
    _stockQtySelected.clear();
    _stockUnitSelected.clear();

    // get selected material from product detail
    for (var product in _products) {
      if (product['id']
          .toString()
          .toLowerCase()
          .contains(productId.toLowerCase())) {
        // product amount
        productAmountSelected = int.parse(product['jumlahBarang']);

        // store stock item selected
        product['materialName'].map((value) {
          _stockItemSelected.add(value);
        }).toList();

        // initialize stock qty selected
        product['materialQuantity'].map((value) {
          _stockQtySelected.add(double.parse(value));
        }).toList();

        // initialize stock unit selected
        product['materialUnit'].map((value) {
          _stockUnitSelected.add(value);
        }).toList();
      }
    }

    // return material to stock before updating
    int index = 0;
    for (var stockItem in List.from(_stockItem)) {
      int stockSelectedIndex = 0;
      double stockQuantity = 0;
      String stockUnit = '';
      double stockQuantitySelected = 0;
      String stockUnitSelected = '';
      for (var stockItemSelected in List.from(_stockItemSelected)) {
        if (stockItem.contains(stockItemSelected ?? '')) {
          // initialize variable
          stockQuantity = _stockQty[index];
          stockUnit = _stockUnit[index];
          stockQuantitySelected =
              _stockQtySelected[stockSelectedIndex] * productAmountSelected;
          stockUnitSelected = _stockUnitSelected[stockSelectedIndex];

          // convert to g
          if (stockUnit.toLowerCase().contains('kg')) {
            stockQuantity = stockQuantity * 1000;
            stockUnit = 'Gram';
          }
          if (stockUnitSelected.toLowerCase().contains('kg')) {
            stockQuantitySelected = stockQuantitySelected * 1000;
            stockUnitSelected = 'Gram';
          }

          // final stock
          double finalStockQuantity = stockQuantity + stockQuantitySelected;
          String finalStockUnit = _stockUnit[index];

          // convert to original unit
          // if the original unit is Kg, divided with 1000
          if (!finalStockUnit
              .toLowerCase()
              .contains(stockUnitSelected.toLowerCase())) {
            finalStockQuantity = finalStockQuantity / 1000;
          }

          setState(() {
            _updatedStockQuantity[index] = finalStockQuantity;
          });
        }
        stockSelectedIndex++;
      }
      index++;
    }
  }

  // update stock
  void updateStock(BuildContext context, String productId) async {
    // pause stock stream. so that i have consistent data when calculating
    onRetrieveStockPause();

    // pause product stream. so that i have consistent data when calculating
    onRetrieveProductPause();

    // calculate
    calculateReturnedMaterial(productId);

    // save updated qty to firestore
    try {
      int index = 0;
      for (num updatedStock in List.from(_updatedStockQuantity)) {
        await databaseService.editQuantityStock(
          _stockId[index],
          updatedStock.toString(),
        );
        index++;
      }
    } catch (e) {
      if (context.mounted) {
        showSnackbar(context, 'Return to stock: ${e.toString()}');
      }
    }

    // resume stock stream
    onRetrieveStockResume();

    // resume product stream
    onRetrieveProductResume();
  }

  // delete product
  void deleteProduct(
    BuildContext context,
    String docId,
    String imageId,
  ) async {
    try {
      await databaseService.deleteProduct(docId, imageId);
    } catch (e) {
      if (context.mounted) {
        showSnackbar(context, e.toString());
      }
    }
  }

  @override
  void initState() {
    super.initState();

    // retrieve stock
    stockSubscription = databaseService.getStock().listen(onRetrieveStock);

    // retrieve product
    productSubscription =
        databaseService.getProduct().listen(onRetrieveProduct);
  }

  @override
  void dispose() {
    // dispose the subscription to prevent memory leaks
    stockSubscription.cancel();
    productSubscription.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: const Text('Product'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Center(
            child: Column(
              children: [
                // search bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: MySearchbar(
                    hintText: 'Search',
                    onChanged: (value) {
                      setState(() {
                        searchedItem = value;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 5),

                // list of item
                Expanded(
                  child: StreamBuilder(
                    stream: databaseService.getProduct(),
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

                      //final stockData = snapshot.data ?? [];
                      final stockData = snapshot.data!.docs;

                      // no data
                      if (stockData.isEmpty) {
                        return Container(
                          alignment: Alignment.center,
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // animation
                                Lottie.asset('assets/empty-item.json'),

                                // text
                                const Text('Empty product'),
                              ],
                            ),
                          ),
                        );
                      }

                      // load complete
                      if (searchedItem.isEmpty) {
                        return ListView.builder(
                          padding: EdgeInsets.only(
                            left: 5,
                            right: 5,
                            bottom: widget.userRole.contains('owner') ? 16 : 80,
                          ),
                          itemCount: stockData.length,
                          itemBuilder: (context, index) {
                            final data = stockData[index];
                            return ItemTile(
                              title: data['namaBarang'],
                              description: data['deskripsiBarang'],
                              numberOfGoods: data['jumlahBarang'],
                              unit: 'Pcs',
                              imageUrl: data['imageUrl'],
                              userRole: widget.userRole,
                              onPressedEdit: (context) {
                                Navigator.push(
                                  context,
                                  EditProductPage.route(
                                    data.id,
                                    widget.userRole,
                                  ),
                                );
                              },
                              onPressedDelete: (context) {
                                showDeleteApproval(
                                  context,
                                  Constants.deleteProductToast,
                                  () {
                                    //updateStock(context, data.id);
                                    deleteProduct(
                                      context,
                                      data.id,
                                      data['imageId'],
                                    );
                                  },
                                );
                              },
                            );
                          },
                        );
                      } else {
                        return ListView.builder(
                          padding: EdgeInsets.only(
                            left: 5,
                            right: 5,
                            bottom: widget.userRole.contains('owner') ? 16 : 80,
                          ),
                          itemCount: stockData.length,
                          itemBuilder: (context, index) {
                            final data = stockData[index];

                            if (data['namaBarang']
                                    .toString()
                                    .toLowerCase()
                                    .contains(
                                      searchedItem.toLowerCase(),
                                    ) ||
                                data['deskripsiBarang']
                                    .toString()
                                    .toLowerCase()
                                    .contains(
                                      searchedItem.toLowerCase(),
                                    )) {
                              return ItemTile(
                                title: data['namaBarang'],
                                description: data['deskripsiBarang'],
                                numberOfGoods: data['jumlahBarang'],
                                unit: 'Pcs',
                                imageUrl: data['imageUrl'],
                                userRole: widget.userRole,
                                onPressedEdit: (context) {
                                  Navigator.push(
                                    context,
                                    EditProductPage.route(
                                      data.id,
                                      widget.userRole,
                                    ),
                                  );
                                },
                                onPressedDelete: (context) {
                                  showDeleteApproval(
                                    context,
                                    Constants.deleteProductToast,
                                    () {
                                      //updateStock(context, data.id);
                                      deleteProduct(
                                        context,
                                        data.id,
                                        data['imageId'],
                                      );
                                    },
                                  );
                                },
                              );
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
        floatingActionButton: widget.userRole.contains('owner')
            ? FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(
                    context,
                    AddProductPage.route(),
                  );
                },
                backgroundColor: Colors.white,
                foregroundColor: AppPallete.pink,
                label: const Text('TAMBAH PRODUK'),
                icon: const Icon(Icons.add),
              )
            : Container(),
      ),
    );
  }
}
