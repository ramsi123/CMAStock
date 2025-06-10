import 'dart:io';
import 'package:cahaya_mulya_abadi/components/mandatory_textfield.dart';
import 'package:cahaya_mulya_abadi/components/my_button.dart';
import 'package:cahaya_mulya_abadi/components/number_of_goods_textfield.dart';
import 'package:cahaya_mulya_abadi/components/optional_textfield.dart';
import 'package:cahaya_mulya_abadi/services/database/database_service.dart';
import 'package:cahaya_mulya_abadi/themes/app_pallete.dart';
import 'package:cahaya_mulya_abadi/utils/show_snackbar.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

class EditStockStaffPage extends StatefulWidget {
  static route(
    String docId,
    String title,
    String description,
    String numberOfGoods,
    String unit,
    String imageId,
    String imageUrl,
  ) =>
      MaterialPageRoute(
        builder: (context) => EditStockStaffPage(
          docId: docId,
          title: title,
          description: description,
          numberOfGoods: numberOfGoods,
          unit: unit,
          imageId: imageId,
          imageUrl: imageUrl,
        ),
      );

  final String docId;
  final String title;
  final String description;
  final String numberOfGoods;
  final String unit;
  final String imageId;
  final String imageUrl;

  const EditStockStaffPage({
    super.key,
    required this.docId,
    required this.title,
    required this.description,
    required this.numberOfGoods,
    required this.unit,
    required this.imageId,
    required this.imageUrl,
  });

  @override
  State<EditStockStaffPage> createState() => _EditStockStaffPageState();
}

class _EditStockStaffPageState extends State<EditStockStaffPage> {
  // database service
  final databaseService = DatabaseService();

  // controllers
  final _nameController = TextEditingController();
  final _prevNumberOfGoodsController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _currentNumberOfGoodsController = TextEditingController();
  final _noteController = TextEditingController();
  int? selectedRadio;

  // form key
  final formKey = GlobalKey<FormState>();

  // variables
  String prevUnit = 'Kg';
  String currentUnit = 'Kg';
  double prevAmount = 0;
  File? image;

  // set selected radio
  void setSelectedRadio(int? value) {
    setState(() {
      selectedRadio = value;
    });
  }

  // calculate new qty
  double calculateStock(
    String numberOfGoods,
    String newNumberOfGoods,
    String prevUnit,
    String currentUnit,
    int? selectedRadio,
  ) {
    double prevAmount = double.parse(numberOfGoods);
    double currentAmount = double.parse(newNumberOfGoods);
    double finalAmount = 0;

    // convert to gram
    if (prevUnit.toLowerCase().contains('kg')) {
      prevAmount = prevAmount * 1000;
    }
    if (currentUnit.toLowerCase().contains('kg')) {
      currentAmount = currentAmount * 1000;
    }

    // add or subtract
    if (selectedRadio == 0) {
      finalAmount = prevAmount + currentAmount;
    } else {
      finalAmount = prevAmount - currentAmount;
    }

    // convert to kg
    if (prevUnit.toString().toLowerCase().contains('kg')) {
      finalAmount = finalAmount / 1000;
    }

    return finalAmount;
  }

  // update stock
  void updateStock(
    BuildContext context,
    String docId,
    String name,
    String numberOfGoods,
    String newNumberOfGoods,
    String prevUnit,
    String currentUnit,
    String description,
    File? image,
    String imageId,
    String imageUrl,
    int? selectedRadio,
  ) async {
    try {
      await databaseService.updateStock(
        docId,
        name,
        calculateStock(
          numberOfGoods,
          newNumberOfGoods,
          prevUnit,
          currentUnit,
          selectedRadio,
        ).toString(),
        prevUnit,
        description,
        image,
        imageId,
        imageUrl,
      );
    } catch (e) {
      if (context.mounted) {
        showSnackbar(context, e.toString());
      }
    }
  }

  // add stock report
  void addStockReport(
    BuildContext context,
    String docId,
    String prevAmount,
    String currentAmount,
    String prevUnit,
    String currentUnit,
    String note,
    int? selectedRadio,
  ) async {
    String status = '';
    if (selectedRadio == 0) {
      status = 'Masuk';
    } else {
      status = 'Keluar';
    }

    double convertedCurrentAmount = double.parse(currentAmount);
    // convert current amount to kg
    if (currentUnit.toLowerCase().contains('gram')) {
      convertedCurrentAmount = convertedCurrentAmount / 1000;
    }

    // add stock report
    if (double.parse(currentAmount) != 0) {
      try {
        await databaseService.addStockReport(
          docId,
          status,
          convertedCurrentAmount.toString(),
          calculateStock(
            prevAmount,
            currentAmount,
            prevUnit,
            currentUnit,
            selectedRadio,
          ).toString(),
          note,
        );
      } catch (e) {
        if (context.mounted) {
          showSnackbar(context, e.toString());
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();

    // initialize controllers
    _nameController.text = widget.title;
    _prevNumberOfGoodsController.text = widget.numberOfGoods;
    prevUnit = widget.unit;
    _descriptionController.text =
        widget.description.isNotEmpty ? widget.description : '';

    // initialize previous amount
    prevAmount = double.parse(widget.numberOfGoods);

    // initialize selected radio
    selectedRadio = 0;
  }

  @override
  void dispose() {
    // dispose controllers
    _nameController.dispose();
    _prevNumberOfGoodsController.dispose();
    _descriptionController.dispose();
    _currentNumberOfGoodsController.dispose();
    _noteController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Stok Bahan Baku'),
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios),
          ),
        ),
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    // picture
                    widget.imageUrl.isNotEmpty
                        ? Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                widget.imageUrl,
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
                      enabled: false,
                    ),

                    const SizedBox(height: 15),

                    // prev number of goods
                    NumberOfGoodsTextfield(
                      controller: _prevNumberOfGoodsController,
                      title: 'Jumlah Barang Saat Ini',
                      hintText: 'Masukkan jumlah barang',
                      unit: prevUnit,
                      onAmountChanged: (newValue) {},
                      onUnitChanged: (newUnit) {
                        setState(() {
                          prevUnit = newUnit;
                        });
                      },
                      prevAmount: 0,
                      prevAmountUnit: '',
                      currentAmountUnit: '',
                      isItemLimitOn: false,
                      stockStatus: 0,
                      isRawMaterial: true,
                      isEnabled: false,
                    ),

                    const SizedBox(height: 15),

                    // description
                    OptionalTextfield(
                      controller: _descriptionController,
                      title: 'Deskripsi Barang',
                      hintText: 'Masukkan deskripsi barang',
                      obscureText: false,
                      enabled: false,
                    ),

                    const SizedBox(height: 15),

                    // input new number of goods
                    NumberOfGoodsTextfield(
                      controller: _currentNumberOfGoodsController,
                      title: 'Jumlah Barang',
                      hintText: 'Masukkan jumlah barang',
                      unit: currentUnit,
                      onAmountChanged: (newValue) {},
                      onUnitChanged: (newUnit) {
                        setState(() {
                          currentUnit = newUnit;
                        });
                      },
                      prevAmount: prevAmount,
                      prevAmountUnit: prevUnit,
                      currentAmountUnit: currentUnit,
                      isItemLimitOn: true,
                      stockStatus: selectedRadio,
                      isRawMaterial: true,
                      isEnabled: true,
                    ),

                    const SizedBox(height: 15),

                    SingleChildScrollView(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // add stock radio button
                          Expanded(
                            child: RadioListTile(
                              value: 0,
                              groupValue: selectedRadio,
                              onChanged: (value) {
                                setSelectedRadio(value);
                              },
                              title: const Text('Tambah Barang'),
                              contentPadding: const EdgeInsets.all(0),
                              activeColor: AppPallete.pink,
                              fillColor: WidgetStateProperty.resolveWith<Color>(
                                (states) {
                                  if (states.contains(WidgetState.selected)) {
                                    return AppPallete.pink;
                                  }
                                  return Colors.grey;
                                },
                              ),
                            ),
                          ),

                          // subtract stock radio button
                          Expanded(
                            child: RadioListTile(
                              value: 1,
                              groupValue: selectedRadio,
                              onChanged: (value) {
                                setSelectedRadio(value);
                              },
                              title: const Text('Kurangi Barang'),
                              contentPadding: const EdgeInsets.all(0),
                              activeColor: AppPallete.pink,
                              fillColor: WidgetStateProperty.resolveWith<Color>(
                                (states) {
                                  if (states.contains(WidgetState.selected)) {
                                    return AppPallete.pink;
                                  }
                                  return Colors.grey;
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),

                    // note
                    OptionalTextfield(
                      controller: _noteController,
                      title: 'Catatan',
                      hintText: 'Masukkan catatan',
                      obscureText: false,
                    ),

                    const SizedBox(height: 25),

                    // save changes
                    MyButton(
                      onTap: () {
                        formKey.currentState!.validate();
                        if (formKey.currentState!.validate()) {
                          updateStock(
                            context,
                            widget.docId,
                            _nameController.text,
                            _prevNumberOfGoodsController.text.contains('.')
                                ? double.parse(_prevNumberOfGoodsController.text
                                        .replaceAll(' ', ''))
                                    .toString()
                                : int.parse(_prevNumberOfGoodsController.text
                                        .replaceAll(' ', ''))
                                    .toString(),
                            _currentNumberOfGoodsController.text.contains('.')
                                ? double.parse(_currentNumberOfGoodsController
                                        .text
                                        .replaceAll(' ', ''))
                                    .toString()
                                : int.parse(_currentNumberOfGoodsController.text
                                        .replaceAll(' ', ''))
                                    .toString(),
                            prevUnit,
                            currentUnit,
                            _descriptionController.text,
                            image,
                            widget.imageId,
                            widget.imageUrl,
                            selectedRadio,
                          );
                          addStockReport(
                            context,
                            widget.docId,
                            _prevNumberOfGoodsController.text.contains('.')
                                ? double.parse(_prevNumberOfGoodsController.text
                                        .replaceAll(' ', ''))
                                    .toString()
                                : int.parse(_prevNumberOfGoodsController.text
                                        .replaceAll(' ', ''))
                                    .toString(),
                            _currentNumberOfGoodsController.text.contains('.')
                                ? double.parse(_currentNumberOfGoodsController
                                        .text
                                        .replaceAll(' ', ''))
                                    .toString()
                                : int.parse(_currentNumberOfGoodsController.text
                                        .replaceAll(' ', ''))
                                    .toString(),
                            prevUnit,
                            currentUnit,
                            _noteController.text,
                            selectedRadio,
                          );
                          Navigator.pop(context);
                          showSnackbar(context, 'Update Barang Berhasil.');
                        }
                      },
                      text: 'Simpan',
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
