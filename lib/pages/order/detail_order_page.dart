import 'dart:async';
import 'package:cahaya_mulya_abadi/components/mandatory_textfield.dart';
import 'package:cahaya_mulya_abadi/components/my_dropdown_button.dart';
import 'package:cahaya_mulya_abadi/components/my_outlined_button.dart';
import 'package:cahaya_mulya_abadi/components/my_sticky_button.dart';
import 'package:cahaya_mulya_abadi/components/optional_textfield.dart';
import 'package:cahaya_mulya_abadi/components/quantity_textfield.dart';
import 'package:cahaya_mulya_abadi/services/database/database_service.dart';
import 'package:cahaya_mulya_abadi/themes/app_pallete.dart';
import 'package:cahaya_mulya_abadi/utils/constants.dart';
import 'package:cahaya_mulya_abadi/utils/show_snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DetailOrderPage extends StatefulWidget {
  static route(
    String docId,
    String userRole,
  ) =>
      MaterialPageRoute(
        builder: (context) => DetailOrderPage(
          docId: docId,
          userRole: userRole,
        ),
      );

  final String docId;
  final String userRole;

  const DetailOrderPage({
    super.key,
    required this.docId,
    required this.userRole,
  });

  @override
  State<DetailOrderPage> createState() => _DetailOrderPageState();
}

class _DetailOrderPageState extends State<DetailOrderPage> {
  // database service
  final databaseService = DatabaseService();

  // controllers
  final _customerNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();

  // form key
  final formKey = GlobalKey<FormState>();

  // item and quantity list availability
  List<String> _dropdownMenuItem = [];
  final List<int> _productQuantity = [];

  // item and quantity list selected by user
  final List<String?> _orderItem = [];
  final List<int> _orderItemIndex = [];
  final List<TextEditingController> _quantityControllers = [];

  // variables
  late StreamSubscription productSubscription;
  late StreamSubscription detailOrderSubscription;

  // Add an order item and quantity controllers
  void _addOrderItem() {
    setState(() {
      _orderItem.add(null);
      _orderItemIndex.add(0);
      _quantityControllers.add(TextEditingController());
    });
  }

  // remove an order item and quantity controllers
  void _removeOrderItem(int index) {
    setState(() {
      _orderItem.removeAt(index);
      _orderItemIndex.removeAt(index);
      _quantityControllers.removeAt(index);
    });
  }

  // update order to firestore
  void _updateOrder(
    BuildContext context,
    String customerName,
    String address,
    String description,
    List<String> item,
    List<String> itemQuantity,
  ) async {
    try {
      // calculate total order qty
      int totalOrder = 0;
      for (var item in itemQuantity) {
        totalOrder += int.parse(item);
      }

      await databaseService.updateOrder(
        widget.docId,
        customerName,
        address,
        description,
        item,
        itemQuantity,
        totalOrder.toString(),
      );
    } catch (e) {
      if (context.mounted) {
        showSnackbar(context, e.toString());
      }
    }
  }

  // Add a drop down menu item
  void _addDropDownMenuItem(String value) {
    setState(() {
      _dropdownMenuItem.add(value);
    });
  }

  // get product data and send it to _addDropDownMenuItem list
  void onRetrieveProduct(QuerySnapshot<Object?> event) {
    final productData = event.docs;
    for (var data in productData) {
      _addDropDownMenuItem(data['namaBarang']);
      setState(() {
        _productQuantity.add(int.parse(data['jumlahBarang']));
      });
    }
  }

  // get product detail order
  void onDetailOrder(Map<String, dynamic> orderDetail) {
    // store orderItemName and orderItemQuantity to a variable
    List<dynamic> orderItem = orderDetail['orderItemName'];
    List<String> orderItemList = orderItem.cast<String>();
    List<dynamic> orderItemQuantity = orderDetail['orderItemQuantity'];
    List<String> orderItemQuantityList = orderItemQuantity.cast<String>();

    // initialize the text field
    _customerNameController.text = orderDetail['customerName'];
    _addressController.text = orderDetail['alamat'];
    _descriptionController.text = orderDetail['deskripsi'];

    // initialize the drop down button
    orderItemList.map((value) {
      setState(() {
        _orderItem.add(value);
      });
    }).toList();

    // initialize order limit in _orderItemIndex and initialize
    // _quantityControllers text field
    int index = 0;
    for (var data in orderItemQuantityList) {
      if (_dropdownMenuItem.contains(_orderItem[index])) {
        int productIndex = 0;
        for (var productData in _dropdownMenuItem) {
          if (productData.contains(_orderItem[index]!)) {
            setState(() {
              _orderItemIndex.add(productIndex);
            });
          }
          productIndex++;
        }
      } else {
        setState(() {
          _orderItemIndex.add(0);
        });
      }
      setState(() {
        _quantityControllers.add(TextEditingController());
        _quantityControllers[index].text = data;
      });
      index++;
    }
  }

  @override
  void initState() {
    super.initState();

    // initialize dropdown menu item list
    _dropdownMenuItem = [];

    // get product data
    productSubscription =
        databaseService.getProduct().listen(onRetrieveProduct);

    // get detail order
    detailOrderSubscription =
        databaseService.getDetailOrder(widget.docId).listen(onDetailOrder);
  }

  @override
  void dispose() {
    // dispose subscription to prevent memory leaks
    productSubscription.cancel();
    detailOrderSubscription.cancel();

    // dispose controllers to free resources
    _customerNameController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    for (var controller in _quantityControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(Constants.detailOrder),
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
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // customer name
                  MandatoryTextfield(
                    controller: _customerNameController,
                    title: 'Nama Customer',
                    hintText: 'Masukkan nama customer',
                    obscureText: false,
                    enabled: widget.userRole.contains('owner') ? true : false,
                  ),

                  const SizedBox(height: 15),

                  // address
                  OptionalTextfield(
                    controller: _addressController,
                    title: 'Alamat',
                    hintText: 'Masukkan alamat',
                    obscureText: false,
                    enabled: widget.userRole.contains('owner') ? true : false,
                  ),

                  const SizedBox(height: 15),

                  // description
                  OptionalTextfield(
                    controller: _descriptionController,
                    title: 'Deskripsi',
                    hintText: 'Masukkan deskripsi',
                    obscureText: false,
                    enabled: widget.userRole.contains('owner') ? true : false,
                  ),

                  const SizedBox(height: 20),

                  // order item title
                  const Text(
                    'Order Item',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // order item tile
                  SingleChildScrollView(
                    child: ListView.builder(
                      itemCount: _quantityControllers.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // item name dropdown button
                              Expanded(
                                flex: 2,
                                child: MyDropdownButton(
                                  dropdownItem: _dropdownMenuItem,
                                  item: _dropdownMenuItem
                                          .contains(_orderItem[index])
                                      ? _orderItem[index]
                                      : null,
                                  title: 'Nama Barang ${index + 1}',
                                  hint: _orderItem[index] == null
                                      ? 'Pilih item'
                                      : '"${_orderItem[index]}" tidak tersedia',
                                  onChanged: (newItem) {
                                    setState(() {
                                      _orderItem[index] = newItem;
                                    });
                                  },
                                  onIndexSelected: (itemIndex) {
                                    _orderItemIndex[index] = itemIndex;
                                  },
                                  isEnabled: widget.userRole.contains('owner')
                                      ? true
                                      : false,
                                ),
                              ),

                              const SizedBox(width: 10),

                              // quantity text field
                              Expanded(
                                flex: 1,
                                child: QuantityTextfield(
                                  key: UniqueKey(),
                                  controller: _quantityControllers[index],
                                  title: 'Qty',
                                  hintText: '',
                                  unit: '',
                                  onUnitChanged: (newUnit) {},
                                  isRawMaterial: false,
                                  /* itemLimit: _productQuantity.isNotEmpty &&
                                          _dropdownMenuItem
                                              .contains(_orderItem[index])
                                      ? _productQuantity[_orderItemIndex[index]]
                                      : 0, */
                                  itemLimit: 0,
                                  itemLimitUnit: 'Pcs',
                                  isItemLimitOn: false,
                                  productAmount: 0,
                                  enabled: widget.userRole.contains('owner')
                                      ? true
                                      : false,
                                ),
                              ),

                              // delete button
                              _quantityControllers.length > 1 &&
                                      widget.userRole.contains('owner')
                                  ? Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: IconButton.outlined(
                                        onPressed: () {
                                          _removeOrderItem(index);
                                        },
                                        icon: const Icon(Icons.delete_outlined),
                                      ),
                                    )
                                  : Container(),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  widget.userRole.contains('owner')
                      ? const SizedBox(height: 15)
                      : Container(),

                  widget.userRole.contains('owner')
                      ? MyOutlinedButton(
                          onPressed: _addOrderItem,
                          text: 'Tambah Barang',
                          iconColor: AppPallete.pink,
                          gradient: const LinearGradient(
                            begin: Alignment.centerRight,
                            end: Alignment.centerLeft,
                            colors: [
                              AppPallete.peach,
                              AppPallete.pink,
                            ],
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: widget.userRole.contains('owner')
            ? MyStickyButton(
                onTap: () {
                  if (formKey.currentState!.validate()) {
                    _updateOrder(
                      context,
                      _customerNameController.text,
                      _addressController.text,
                      _descriptionController.text,
                      _orderItem.map((value) {
                        return value!;
                      }).toList(),
                      _quantityControllers.map((value) {
                        return int.parse(
                          value.text.replaceAll(' ', ''),
                        ).toString();
                      }).toList(),
                    );
                    Navigator.pop(context);
                    showSnackbar(context, 'Update Order Berhasil.');
                  }
                },
                text: Constants.save,
                backgroundColor: const [
                  AppPallete.peach,
                  AppPallete.pink,
                ],
              )
            : null,
      ),
    );
  }
}
