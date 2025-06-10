import 'dart:io';
import 'package:cahaya_mulya_abadi/components/mandatory_textfield.dart';
import 'package:cahaya_mulya_abadi/components/my_button.dart';
import 'package:cahaya_mulya_abadi/components/optional_textfield.dart';
import 'package:cahaya_mulya_abadi/components/number_of_goods_textfield.dart';
import 'package:cahaya_mulya_abadi/themes/app_pallete.dart';
import 'package:cahaya_mulya_abadi/utils/show_snackbar.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import '../../services/database/database_service.dart';
import '../../utils/pick_image.dart';

class EditStockPage extends StatefulWidget {
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
        builder: (context) => EditStockPage(
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

  const EditStockPage({
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
  State<EditStockPage> createState() => _EditStockPageState();
}

class _EditStockPageState extends State<EditStockPage> {
  // database service
  final databaseService = DatabaseService();

  // controllers
  final _nameController = TextEditingController();
  final _numberOfGoodsController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _noteController = TextEditingController();

  // form key
  final formKey = GlobalKey<FormState>();

  // variables
  String unit = 'Kg';
  double prevAmount = 0;
  File? image;

  // select image
  void selectImage() async {
    final pickedImage = await pickImage();
    if (pickedImage != null) {
      setState(() {
        image = pickedImage;
      });
    }
  }

  // update stock
  void updateStock(
    BuildContext context,
    String docId,
    String name,
    String numberOfGoods,
    String unit,
    String description,
    File? image,
    String imageId,
    String imageUrl,
  ) async {
    try {
      await databaseService.updateStock(
        docId,
        name,
        numberOfGoods,
        unit,
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
    String totalAmount,
    String note,
  ) async {
    // calculate stock report
    String status = '';
    double finalAmount = 0;
    if (prevAmount < double.parse(totalAmount)) {
      status = 'Masuk';
      finalAmount = double.parse(totalAmount) - prevAmount;
    } else if (prevAmount > double.parse(totalAmount)) {
      status = 'Keluar';
      finalAmount = prevAmount - double.parse(totalAmount);
    } else {
      finalAmount = double.parse(totalAmount);
    }

    // add stock report
    if (finalAmount != double.parse(totalAmount)) {
      try {
        await databaseService.addStockReport(
          docId,
          status,
          finalAmount.toString(),
          totalAmount,
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
    _numberOfGoodsController.text = widget.numberOfGoods;
    unit = widget.unit;
    _descriptionController.text =
        widget.description.isNotEmpty ? widget.description : '';

    // initialize previous amount
    prevAmount = double.parse(widget.numberOfGoods);
  }

  @override
  void dispose() {
    // dispose controllers
    _nameController.dispose();
    _numberOfGoodsController.dispose();
    _descriptionController.dispose();
    _noteController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Bahan Baku'),
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
                            child: widget.imageUrl.isNotEmpty
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
                          ),

                    const SizedBox(height: 15),

                    // name
                    MandatoryTextfield(
                      controller: _nameController,
                      title: 'Nama Barang',
                      hintText: 'Masukkan nama barang',
                      obscureText: false,
                    ),

                    const SizedBox(height: 15),

                    // number of goods
                    NumberOfGoodsTextfield(
                      controller: _numberOfGoodsController,
                      title: 'Jumlah Barang',
                      hintText: 'Masukkan jumlah barang',
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
                      isEnabled: false,
                    ),

                    const SizedBox(height: 15),

                    // description
                    OptionalTextfield(
                      controller: _descriptionController,
                      title: 'Deskripsi Barang',
                      hintText: 'Masukkan deskripsi barang',
                      obscureText: false,
                    ),

                    /* const SizedBox(height: 15),

                    // note
                    OptionalTextfield(
                      controller: _noteController,
                      title: 'Note',
                      hintText: 'Masukkan keterangan',
                      obscureText: false,
                    ), */

                    const SizedBox(height: 25),

                    // save changes
                    MyButton(
                      onTap: () {
                        if (formKey.currentState!.validate()) {
                          updateStock(
                            context,
                            widget.docId,
                            _nameController.text,
                            _numberOfGoodsController.text.contains('.')
                                ? double.parse(_numberOfGoodsController.text
                                        .replaceAll(' ', ''))
                                    .toString()
                                : int.parse(_numberOfGoodsController.text
                                        .replaceAll(' ', ''))
                                    .toString(),
                            unit,
                            _descriptionController.text,
                            image,
                            widget.imageId,
                            widget.imageUrl,
                          );
                          addStockReport(
                            context,
                            widget.docId,
                            _numberOfGoodsController.text.contains('.')
                                ? double.parse(_numberOfGoodsController.text
                                        .replaceAll(' ', ''))
                                    .toString()
                                : int.parse(_numberOfGoodsController.text
                                        .replaceAll(' ', ''))
                                    .toString(),
                            _noteController.text,
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
