import 'dart:io';
import 'package:cahaya_mulya_abadi/components/mandatory_textfield.dart';
import 'package:cahaya_mulya_abadi/themes/app_pallete.dart';
import 'package:cahaya_mulya_abadi/utils/constants.dart';
import 'package:cahaya_mulya_abadi/utils/show_snackbar.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import '../../components/my_button.dart';
import '../../components/optional_textfield.dart';
import '../../services/database/database_service.dart';
import '../../utils/pick_image.dart';

class AddStockPage extends StatefulWidget {
  static route() =>
      MaterialPageRoute(builder: (context) => const AddStockPage());
  const AddStockPage({super.key});

  @override
  State<AddStockPage> createState() => _AddStockPageState();
}

class _AddStockPageState extends State<AddStockPage> {
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

  // add stock
  void addStock(
    BuildContext context,
    String name,
    String numberOfGoods,
    String unit,
    String description,
    File? image,
  ) async {
    try {
      await databaseService.addStock(
        name,
        numberOfGoods,
        unit,
        description,
        image,
      );
    } catch (e) {
      if (context.mounted) {
        showSnackbar(context, e.toString());
      }
    }
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Bahan'),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
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

                  const SizedBox(height: 15),

                  // number of goods
                  /* NumberOfGoodsTextfield(
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
                  isRawMaterial: true,
                ),

                const SizedBox(height: 15), */

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

                  // save stock
                  MyButton(
                    onTap: () {
                      if (formKey.currentState!.validate()) {
                        addStock(
                          context,
                          _nameController.text,
                          /* _numberOfGoodsController.text.contains('.')
                            ? double.parse(_numberOfGoodsController.text
                                    .replaceAll(' ', ''))
                                .toString()
                            : int.parse(_numberOfGoodsController.text
                                    .replaceAll(' ', ''))
                                .toString(), */
                          '0',
                          unit,
                          _descriptionController.text,
                          image,
                          //_noteController.text,
                        );
                        Navigator.pop(context);
                        showSnackbar(context, Constants.addItemToast);
                      }
                    },
                    text: 'Tambah Item',
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
    );
  }
}
