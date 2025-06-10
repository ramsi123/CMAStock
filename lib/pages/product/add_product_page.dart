import 'dart:async';
import 'dart:io';
import 'package:cahaya_mulya_abadi/components/mandatory_textfield.dart';
import 'package:cahaya_mulya_abadi/components/my_sticky_button.dart';
import 'package:cahaya_mulya_abadi/components/optional_textfield.dart';
import 'package:cahaya_mulya_abadi/services/database/database_service.dart';
import 'package:cahaya_mulya_abadi/themes/app_pallete.dart';
import 'package:cahaya_mulya_abadi/utils/constants.dart';
import 'package:cahaya_mulya_abadi/utils/pick_image.dart';
import 'package:cahaya_mulya_abadi/utils/show_snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

class AddProductPage extends StatefulWidget {
  static route() =>
      MaterialPageRoute(builder: (context) => const AddProductPage());
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
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

  // variables
  String productAmount = '';
  String unit = 'Pcs';
  File? image;
  late StreamSubscription stockSubscription;

  // select image
  void selectImage() async {
    final pickedImage = await pickImage();
    if (pickedImage != null) {
      setState(() {
        image = pickedImage;
      });
    }
  }

  // add product
  void addProduct(
    BuildContext context,
    String name,
    String numberOfGoods,
    String description,
    File? image,
    List<String> item,
    List<String> itemQuantity,
    List<String> itemUnit,
  ) async {
    try {
      // add product
      await databaseService.addProduct(
        name,
        numberOfGoods,
        description,
        image,
        item,
        itemQuantity,
        itemUnit,
      );
    } catch (e) {
      if (context.mounted) {
        showSnackbar(context, e.toString());
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
  void onData(QuerySnapshot<Object?> event) {
    final productData = event.docs;
    for (var data in productData) {
      _addDropDownMenuItem(
        data.id,
        data['namaBarang'],
        double.parse(data['jumlahBarang']),
        data['unit'],
      );
    }
  }

  @override
  void initState() {
    super.initState();

    // Initialize order item and controllers list
    _addStockItem();

    // get stock data
    stockSubscription = databaseService.getStock().listen(onData);
  }

  @override
  void dispose() {
    // dispose subscription to prevent memory leaks
    stockSubscription.cancel();

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
          title: const Text('Tambah Produk'),
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
                  // picture
                  image != null
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
                          child: DottedBorder(
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
                        ),

                  const SizedBox(height: 15),

                  // name
                  MandatoryTextfield(
                    controller: _nameController,
                    title: 'Nama Barang',
                    hintText: 'Masukkan nama barang',
                    obscureText: false,
                  ),

                  /* const SizedBox(height: 15),

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
                    isRawMaterial: false,
                    isReadOnly: false,
                  ), */

                  const SizedBox(height: 15),

                  // description
                  OptionalTextfield(
                    controller: _descriptionController,
                    title: 'Deskripsi Barang',
                    hintText: 'Masukkan deskripsi barang',
                    obscureText: false,
                  ),

                  /* const SizedBox(height: 20),

                  // order item title
                  const Text(
                    'Bahan Baku / Item',
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
                                flex: 1,
                                child: MyDropdownButton(
                                  dropdownItem: _stockItem,
                                  item: _stockItemSelected[index],
                                  title: 'Nama Bahan ${index + 1}',
                                  hint: 'Pilih item',
                                  onChanged: (newItem) {
                                    setState(() {
                                      _stockItemSelected[index] = newItem;
                                    });
                                  },
                                  onIndexSelected: (itemIndex) {
                                    _stockItemIndex[index] = itemIndex;
                                  },
                                  isEnabled: true,
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
                                  itemLimit: _stockQuantity.isNotEmpty
                                      ? _stockQuantity[_stockItemIndex[index]]
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
                                ),
                              ),

                              // delete button
                              _quantityControllers.length > 1
                                  ? Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: IconButton.outlined(
                                        onPressed: () {
                                          _removeStockItem(index);
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

                  const SizedBox(height: 15),

                  MyOutlinedButton(
                    onPressed: _addStockItem,
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
                  ), */
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: MyStickyButton(
          onTap: () {
            if (formKey.currentState!.validate()) {
              addProduct(
                context,
                _nameController.text,
                /* int.parse(_numberOfGoodsController.text.replaceAll(' ', ''))
                    .toString(), */
                '0',
                _descriptionController.text,
                image,
                /* _stockItemSelected.map((value) {
                  return value!;
                }).toList(),
                _quantityControllers.map((value) {
                  return value.text.contains('.')
                      ? double.parse(
                          value.text.replaceAll(' ', ''),
                        ).toString()
                      : int.parse(
                          value.text.replaceAll(' ', ''),
                        ).toString();
                }).toList(),
                _stockUnitSelected.map((value) {
                  return value;
                }).toList(), */
                [''],
                [''],
                ['Kg'],
              );
              Navigator.pop(context);
              showSnackbar(context, Constants.addItemToast);
            }
          },
          text: Constants.addItem,
          backgroundColor: const [
            AppPallete.peach,
            AppPallete.pink,
          ],
        ),
      ),
    );
  }
}
