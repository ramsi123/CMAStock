import 'package:cahaya_mulya_abadi/themes/app_pallete.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class NumberOfGoodsTextfield extends StatefulWidget {
  final TextEditingController controller;
  final String title;
  final String hintText;
  final String unit;
  final Function(String)? onAmountChanged;
  final Function(String)? onUnitChanged;
  final num prevAmount;
  final String prevAmountUnit;
  final String currentAmountUnit;
  final bool isItemLimitOn;
  final int? stockStatus;
  final bool isRawMaterial;
  final bool isEnabled;
  final FocusNode? focusNode;

  const NumberOfGoodsTextfield({
    super.key,
    required this.controller,
    required this.title,
    required this.hintText,
    required this.unit,
    required this.onAmountChanged,
    required this.onUnitChanged,
    required this.prevAmount,
    required this.prevAmountUnit,
    required this.currentAmountUnit,
    required this.isItemLimitOn,
    required this.stockStatus,
    required this.isRawMaterial,
    required this.isEnabled,
    this.focusNode,
  });

  @override
  State<NumberOfGoodsTextfield> createState() => _NumberOfGoodsTextfieldState();
}

class _NumberOfGoodsTextfieldState extends State<NumberOfGoodsTextfield> {
  String unit = '';

  @override
  void initState() {
    super.initState();
    unit = widget.unit;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // title
        Text(
          widget.title,
        ),

        const SizedBox(height: 5),

        // textfield
        TextFormField(
          controller: widget.controller,
          onChanged: widget.onAmountChanged,
          focusNode: widget.focusNode,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: AppPallete.grey,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: AppPallete.grey,
              ),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.secondary,
            hintText: widget.hintText,
            hintStyle: TextStyle(
              color: AppPallete.grey,
            ),
            suffixText: widget.isRawMaterial
                ? widget.isEnabled
                    ? null
                    : unit
                : unit,
            suffixIcon: widget.isRawMaterial && widget.isEnabled
                ? DropdownButton(
                    items: const [
                      DropdownMenuItem(
                        value: 'Kg',
                        child: Text('Kg'),
                      ),
                      DropdownMenuItem(
                        value: 'Gram',
                        child: Text('Gram'),
                      ),
                    ],
                    value: unit,
                    onChanged: (value) {
                      setState(() {
                        unit = value ?? 'Kg';
                      });
                      widget.onUnitChanged!(value ?? 'Kg');
                    },
                  )
                : null,
          ),
          validator: (value) {
            // check user input before calculate
            if (widget.isRawMaterial) {
              if (value!.isEmpty) {
                return '${widget.title} Perlu Diisi!';
              } else if (value.contains(',')) {
                return 'Gunakan titik untuk bilangan desimal!';
              } else if (value.contains('-')) {
                return 'Hanya menerima input angka!';
              }
            } else {
              if (value!.isEmpty) {
                return '${widget.title} Perlu Diisi!';
              } else if (value.contains(',') ||
                  value.contains('.') ||
                  value.contains('-')) {
                return 'Hanya menerima input angka!';
              }
            }

            // calculate only if item limit is true
            double convertedPrevAmount = 0;
            double convertedCurrentAmount = 0;

            if (value.isNotEmpty && widget.isItemLimitOn) {
              convertedCurrentAmount = double.parse(value);

              // convert to gram
              if (widget.prevAmountUnit.toLowerCase().contains('kg')) {
                convertedPrevAmount = widget.prevAmount * 1000;
              }
              if (widget.currentAmountUnit.toLowerCase().contains('kg')) {
                convertedCurrentAmount = convertedCurrentAmount * 1000;
              }
            }

            // return error if convertedCurrentAmount > convertedPrevAmount
            if (widget.isRawMaterial) {
              if (widget.isItemLimitOn &&
                  widget.stockStatus == 1 &&
                  convertedCurrentAmount > convertedPrevAmount) {
                return 'Sisa ${widget.prevAmount} ${widget.prevAmountUnit}';
              }
            }

            return null;
          },
          keyboardType: TextInputType.number,
          maxLines: null,
          enabled: widget.isEnabled,
        ),
      ],
    );
  }
}
