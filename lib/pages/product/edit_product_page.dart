import 'dart:async';
import 'dart:io';
import 'package:cahaya_mulya_abadi/components/my_dropdown_button.dart';
import 'package:cahaya_mulya_abadi/components/my_outlined_button.dart';
import 'package:cahaya_mulya_abadi/components/my_sticky_button.dart';
import 'package:cahaya_mulya_abadi/components/quantity_textfield.dart';
import 'package:cahaya_mulya_abadi/themes/app_pallete.dart';
import 'package:cahaya_mulya_abadi/utils/constants.dart';
import 'package:cahaya_mulya_abadi/utils/show_snackbar.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import '../../components/mandatory_textfield.dart';
import '../../components/number_of_goods_textfield.dart';
import '../../components/optional_textfield.dart';
import '../../services/database/database_service.dart';
import '../../utils/pick_image.dart';

class EditProductPage extends StatefulWidget {
  static route(
    String docId,
    String userRole,
  ) =>
      MaterialPageRoute(
        builder: (context) => EditProductPage(
          docId: docId,
          userRole: userRole,
        ),
      );

  final String docId;
  final String userRole;

  const EditProductPage({
    super.key,
    required this.docId,
    required this.userRole,
  });

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  // database service
  final databaseService = DatabaseService();

  // controllers
  final _nameController = TextEditingController();
  final _numberOfGoodsController = TextEditingController();
  final _descriptionController = TextEditingController();

  // form key
  final formKey = GlobalKey<FormState>();

  // item and quantity list availability from stock
  final List<String> _stockId = [];
  final List<String> _stockItem = [];
  final List<double> _stockQuantity = [];
  final List<String> _stockUnit = [];

  // item and quantity list selected by user
  final List<String?> _stockItemSelected = [];
  final List<TextEditingController> _quantityControllers = [];
  final List<String> _stockUnitSelected = [];
  // _stockItemIndex used to check stock limit
  final List<int> _stockItemIndex = [];

  // item, quantity, and unit selected from previous input before update
  int productAmountPrev = 0;
  final List<String> _stockItemPrev = [];
  final List<double> _stockQuantityPrev = [];
  final List<String> _stockUnitPrev = [];

  // updated stock quantity after material got returned.
  final List<num> _updatedStockQuantity = [];

  // variables
  String productImageId = '';
  String productImageUrl = '';
  String productAmount = '';
  String unit = 'Pcs';
  File? image;
  late StreamSubscription detailProductSubscription;

  // select image
  void selectImage() async {
    final pickedImage = await pickImage();
    if (pickedImage != null) {
      setState(() {
        image = pickedImage;
      });
    }
  }

  // updated material limit
  void updateMaterialLimit() async {
    // get stock data
    final event = await databaseService.getStock().first;
    final stockData = event.docs;

    for (var data in stockData) {
      setState(() {
        _updatedStockQuantity.add(double.parse(data['jumlahBarang']));
      });
    }

    // return material to stock before updating
    int index = 0;
    for (var stockItem in List.from(_stockItem)) {
      int stockSelectedIndex = 0;
      double stockQuantity = 0;
      String stockUnit = '';
      double stockQuantitySelected = 0;
      String stockUnitSelected = '';
      for (var stockItemSelected in List.from(_stockItemPrev)) {
        if (stockItem.contains(stockItemSelected ?? '')) {
          // initialize variable
          stockQuantity = _stockQuantity[index];
          stockUnit = _stockUnit[index];
          stockQuantitySelected =
              _stockQuantityPrev[stockSelectedIndex] * productAmountPrev;
          stockUnitSelected = _stockUnitPrev[stockSelectedIndex];

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

  // update product
  void updateProduct(
    BuildContext context,
    String docId,
    String name,
    String numberOfGoods,
    String description,
    File? image,
    String imageId,
    String imageUrl,
    List<String> item,
    List<String> itemQuantity,
    List<String> itemUnit,
  ) async {
    // return material to stock before updating
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
        showSnackbar(context, 'Return to stock before update: ${e.toString()}');
      }
    }

    // subtract the material
    try {
      int stockIndex = 0;
      for (var stockItem in List.from(_stockItem)) {
        int stockSelectedIndex = 0;
        num stockQuantity = 0;
        String stockUnit = '';
        double stockQuantitySelected = 0;
        String stockUnitSelected = '';
        for (var stockItemSelected in List.from(_stockItemSelected)) {
          if (stockItem.contains(stockItemSelected)) {
            // initialize variable
            stockQuantity = _updatedStockQuantity[stockIndex];
            stockUnit = _stockUnit[stockIndex];
            stockQuantitySelected =
                double.parse(_quantityControllers[stockSelectedIndex].text) *
                    double.parse(_numberOfGoodsController.text);
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
            double finalStockQuantity = stockQuantity - stockQuantitySelected;
            String finalStockUnit = _stockUnit[stockIndex];

            // convert to original unit
            // if the original unit is Kg, divided with 1000
            if (!finalStockUnit
                .toLowerCase()
                .contains(stockUnitSelected.toLowerCase())) {
              finalStockQuantity = finalStockQuantity / 1000;
            }

            // save the subtracted material to firestore
            await databaseService.editQuantityStock(
              _stockId[stockIndex],
              finalStockQuantity.toString(),
            );
          }
          stockSelectedIndex++;
        }
        stockIndex++;
      }
    } catch (e) {
      if (context.mounted) {
        showSnackbar(context, 'Subtract the material: ${e.toString()}');
      }
    }

    // update product
    try {
      await databaseService.updateProduct(
        docId,
        name,
        numberOfGoods,
        description,
        image,
        imageId,
        imageUrl,
        item,
        itemQuantity,
        itemUnit,
      );
    } catch (e) {
      if (context.mounted) {
        showSnackbar(context, 'Update product: ${e.toString()}');
      }
    }
  }

  // Add a stock item and quantity controllers
  void _addStockItem() {
    setState(() {
      _stockItemSelected.add(null);
      _quantityControllers.add(TextEditingController());
      _stockUnitSelected.add('Kg');
      _stockItemIndex.add(0);
    });
  }

  // remove a stock item and quantity controllers
  void _removeStockItem(int index) {
    setState(() {
      _stockItemSelected.removeAt(index);
      _quantityControllers.removeAt(index);
      _stockUnitSelected.removeAt(index);
      _stockItemIndex.removeAt(index);
    });
  }

  // Add a drop down menu item
  void _addDropDownMenuItem(
    String id,
    String value,
    double amount,
    String unit,
  ) {
    setState(() {
      _stockId.add(id);
      _stockItem.add(value);
      _stockQuantity.add(amount);
      _stockUnit.add(unit);
    });
  }

  // get material data and send it to _addDropDownMenuItem list
  void onRetrieveStock() async {
    final event = await databaseService.getStock().first;
    final stockData = event.docs;

    for (var data in stockData) {
      _addDropDownMenuItem(
        data.id,
        data['namaBarang'],
        double.parse(data['jumlahBarang']),
        data['unit'],
      );
    }
  }

  // get detail product
  void onDetailProduct(Map<String, dynamic> productDetail) {
    // store stockItem name, stockQuantity, and stockUnit to a variable
    List<dynamic> tempStockItem = productDetail['materialName'];
    List<String> tempStockItemList = tempStockItem.cast<String>();
    List<dynamic> tempStockQuantity = productDetail['materialQuantity'];
    List<String> tempStockQuantityList = tempStockQuantity.cast<String>();
    List<dynamic> tempStockUnit = productDetail['materialUnit'];
    List<String> tempStockUnitList = tempStockUnit.cast<String>();

    // initialize the text field & variable
    productImageId = productDetail['imageId'];
    productImageUrl = productDetail['imageUrl'];
    _nameController.text = productDetail['namaBarang'];
    _numberOfGoodsController.text = productDetail['jumlahBarang'];
    _descriptionController.text = productDetail['deskripsiBarang'];
    productAmount = productDetail['jumlahBarang'];

    // prev input
    productAmountPrev = int.parse(productDetail['jumlahBarang']);

    // initialize stock drop down button
    tempStockItemList.map((value) {
      setState(() {
        _stockItemSelected.add(value);

        // prev input
        _stockItemPrev.add(value);
      });
    }).toList();

    // initialize unit drop down button
    tempStockUnitList.map((value) {
      setState(() {
        _stockUnitSelected.add(value);

        // prev input
        _stockUnitPrev.add(value);
      });
    }).toList();

    // initialize stock limit in _stockItemIndex and initialize
    // _quantityControllers text field
    int index = 0;
    for (var data in tempStockQuantityList) {
      if (_stockItem.contains(_stockItemSelected[index])) {
        int stockIndex = 0;
        for (var stockData in _stockItem) {
          if (stockData.contains(_stockItemSelected[index]!)) {
            setState(() {
              _stockItemIndex.add(stockIndex);
            });
          }
          stockIndex++;
        }
      } else {
        setState(() {
          _stockItemIndex.add(0);
        });
      }
      setState(() {
        _quantityControllers.add(TextEditingController());
        _quantityControllers[index].text = data;

        // prev input
        _stockQuantityPrev.add(double.parse(data));
      });
      index++;
    }
  }

  @override
  void initState() {
    super.initState();

    // get stock data
    onRetrieveStock();

    // get detail product
    detailProductSubscription =
        databaseService.getDetailProduct(widget.docId).listen(onDetailProduct);

    // update material limit
    updateMaterialLimit();
  }

  @override
  void dispose() {
    // dispose subscription to prevent memory leaks
    detailProductSubscription.cancel();

    // dispose controller
    _nameController.dispose();
    _numberOfGoodsController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: widget.userRole.contains('owner')
              ? const Text('Edit Produk')
              : const Text('Edit Stok Produk'),
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
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // picture
                  widget.userRole.contains('owner')
                      ? image != null
                          ? GestureDetector(
                              onTap: selectImage,
                              child: SizedBox(
                                width: double.infinity,
                                height: 150,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    image!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )
                          : GestureDetector(
                              onTap: () {
                                selectImage();
                              },
                              child: productImageUrl.isNotEmpty
                                  ? Container(
                                      height: 150,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          productImageUrl,
                                          fit: BoxFit.fitWidth,
                                        ),
                                      ),
                                    )
                                  : DottedBorder(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      dashPattern: const [10, 4],
                                      radius: const Radius.circular(10),
                                      borderType: BorderType.RRect,
                                      strokeCap: StrokeCap.round,
                                      child: const SizedBox(
                                        height: 150,
                                        width: double.infinity,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.folder_open,
                                              size: 40,
                                            ),
                                            SizedBox(height: 15),
                                            Text(
                                              'Select your image',
                                              style: TextStyle(
                                                fontSize: 15,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                            )
                      : productImageUrl.isNotEmpty
                          ? Container(
                              height: 150,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  productImageUrl,
                                  fit: BoxFit.fitWidth,
                                ),
                              ),
                            )
                          : DottedBorder(
                              color: Theme.of(context).colorScheme.primary,
                              dashPattern: const [10, 4],
                              radius: const Radius.circular(10),
                              borderType: BorderType.RRect,
                              strokeCap: StrokeCap.round,
                              child: const SizedBox(
                                height: 150,
                                width: double.infinity,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image_outlined,
                                      size: 40,
                                    ),
                                    SizedBox(height: 15),
                                    Text(
                                      'No image',
                                      style: TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                  const SizedBox(height: 15),

                  // name
                  MandatoryTextfield(
                    controller: _nameController,
                    title: 'Nama Barang',
                    hintText: 'Masukkan nama barang',
                    obscureText: false,
                    enabled: widget.userRole.contains('owner') ? true : false,
                  ),

                  const SizedBox(height: 15),

                  // number of goods
                  NumberOfGoodsTextfield(
                    controller: _numberOfGoodsController,
                    title: 'Jumlah Barang',
                    hintText: 'Masukkan jumlah barang',
                    unit: unit,
                    onAmountChanged: (newValue) {
                      setState(() {
                        productAmount = newValue;
                      });
                    },
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
                    isRawMaterial: false,
                    isEnabled: widget.userRole.contains('owner') ? false : true,
                  ),

                  const SizedBox(height: 15),

                  // description
                  OptionalTextfield(
                    controller: _descriptionController,
                    title: 'Deskripsi Barang',
                    hintText: 'Masukkan deskripsi barang',
                    obscureText: false,
                    enabled: widget.userRole.contains('owner') ? true : false,
                  ),

                  _stockItemSelected.isEmpty
                      ? Container()
                      : const SizedBox(height: 20),

                  // order item title
                  _stockItemSelected.isEmpty
                      ? Container()
                      : const Text(
                          'Bahan Baku / Item',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                  _stockItemSelected.isEmpty
                      ? Container()
                      : const SizedBox(height: 10),

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
                                flex: 1,
                                child: MyDropdownButton(
                                  dropdownItem: _stockItem,
                                  item: _stockItem
                                          .contains(_stockItemSelected[index])
                                      ? _stockItemSelected[index]
                                      : null,
                                  title: 'Nama Bahan ${index + 1}',
                                  hint: _stockItemSelected[index] == null
                                      ? 'Pilih item'
                                      : '${_stockItemSelected[index]} tidak tersedia',
                                  onChanged: (newItem) {
                                    setState(() {
                                      _stockItemSelected[index] = newItem;
                                    });
                                  },
                                  onIndexSelected: (itemIndex) {
                                    _stockItemIndex[index] = itemIndex;
                                  },
                                  isEnabled: widget.userRole.contains('owner')
                                      ? false
                                      : true,
                                  isValidatorEnabled:
                                      widget.userRole.contains('owner')
                                          ? false
                                          : true,
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
                                  unit: _stockUnitSelected[index],
                                  onUnitChanged: (newUnit) {
                                    setState(() {
                                      _stockUnitSelected[index] = newUnit;
                                    });
                                  },
                                  isRawMaterial: true,
                                  itemLimit: _updatedStockQuantity.isNotEmpty
                                      ? _updatedStockQuantity[
                                          _stockItemIndex[index]]
                                      : 0,
                                  itemLimitUnit: _stockUnit.isNotEmpty
                                      ? _stockUnit[_stockItemIndex[index]]
                                      : 'Kg',
                                  isItemLimitOn: true,
                                  productAmount: productAmount.isEmpty ||
                                          productAmount.contains('.') ||
                                          productAmount.contains(',') ||
                                          productAmount.contains('-')
                                      ? 0
                                      : int.parse(
                                          productAmount.replaceAll(' ', '')),
                                  enabled: widget.userRole.contains('owner')
                                      ? false
                                      : true,
                                  isValidatorEnabled:
                                      widget.userRole.contains('owner')
                                          ? false
                                          : true,
                                ),
                              ),

                              // delete button
                              widget.userRole.contains('owner')
                                  ? Container()
                                  : Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: IconButton.outlined(
                                        onPressed: () {
                                          _removeStockItem(index);
                                          if (_stockItemSelected.isEmpty) {
                                            _addStockItem();
                                          }
                                        },
                                        icon: const Icon(
                                          Icons.delete_outlined,
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  widget.userRole.contains('owner')
                      ? Container()
                      : const SizedBox(height: 15),

                  widget.userRole.contains('owner')
                      ? Container()
                      : MyOutlinedButton(
                          onPressed: _addStockItem,
                          text: 'Tambah Bahan Baku',
                          iconColor: AppPallete.pink,
                          gradient: const LinearGradient(
                            begin: Alignment.centerRight,
                            end: Alignment.centerLeft,
                            colors: [
                              AppPallete.peach,
                              AppPallete.pink,
                            ],
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: MyStickyButton(
          onTap: () {
            if (formKey.currentState!.validate()) {
              updateProduct(
                context,
                widget.docId,
                _nameController.text,
                int.parse(_numberOfGoodsController.text.replaceAll(' ', ''))
                    .toString(),
                _descriptionController.text,
                image,
                productImageId,
                productImageUrl,
                _stockItemSelected.map((value) {
                  return value!;
                }).toList(),
                _quantityControllers.map((value) {
                  if (value.text.isEmpty) {
                    return value.text;
                  } else {
                    return value.text.contains('.')
                        ? double.parse(
                            value.text.replaceAll(' ', ''),
                          ).toString()
                        : int.parse(
                            value.text.replaceAll(' ', ''),
                          ).toString();
                  }
                }).toList(),
                _stockUnitSelected.map((value) {
                  return value;
                }).toList(),
              );
              Navigator.pop(context);
              showSnackbar(context, Constants.updateItemToast);
            }
          },
          text: Constants.save,
          backgroundColor: const [
            AppPallete.peach,
            AppPallete.pink,
          ],
        ),
      ),
    );
  }
}
