import 'package:cahaya_mulya_abadi/components/mandatory_textfield.dart';
import 'package:cahaya_mulya_abadi/themes/app_pallete.dart';
import 'package:cahaya_mulya_abadi/utils/constants.dart';
import 'package:cahaya_mulya_abadi/utils/show_snackbar.dart';
import 'package:flutter/material.dart';
import '../../components/my_button.dart';
import '../../components/optional_textfield.dart';
import '../../components/number_of_goods_textfield.dart';
import '../../services/database/database_service.dart';

class AddRequestStockPage extends StatefulWidget {
  static route() =>
      MaterialPageRoute(builder: (context) => const AddRequestStockPage());
  const AddRequestStockPage({super.key});

  @override
  State<AddRequestStockPage> createState() => _AddRequestStockPageState();
}

class _AddRequestStockPageState extends State<AddRequestStockPage> {
  // database service
  final databaseService = DatabaseService();

  // controllers
  final _nameController = TextEditingController();
  final _numberOfGoodsController = TextEditingController();
  final _descriptionController = TextEditingController();

  // form key
  final formKey = GlobalKey<FormState>();

  // variables
  String unit = 'Kg';

  // add stock request
  void addStockRequest(
    BuildContext context,
    String name,
    String numberOfGoods,
    String unit,
    String description,
  ) async {
    try {
      await databaseService.addStockRequest(
        name,
        numberOfGoods,
        unit,
        description,
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

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Bahan'),
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
                    isEnabled: true,
                  ),

                  const SizedBox(height: 15),

                  // description
                  OptionalTextfield(
                    controller: _descriptionController,
                    title: 'Deskripsi Barang',
                    hintText: 'Masukkan deskripsi barang',
                    obscureText: false,
                  ),

                  const SizedBox(height: 25),

                  // save stock request
                  MyButton(
                    onTap: () {
                      if (formKey.currentState!.validate()) {
                        addStockRequest(
                          context,
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
                        );
                        Navigator.pop(context);
                        showSnackbar(context, Constants.addStockRequestToast);
                      }
                    },
                    text: 'Request Barang',
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
