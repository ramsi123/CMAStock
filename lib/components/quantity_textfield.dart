import 'package:cahaya_mulya_abadi/themes/app_pallete.dart';
import 'package:flutter/material.dart';

class QuantityTextfield extends StatefulWidget {
  final TextEditingController controller;
  final String title;
  final String hintText;
  final String unit;
  final Function(String)? onUnitChanged;
  final bool isRawMaterial;
  final num itemLimit;
  final String itemLimitUnit;
  final bool isItemLimitOn;
  final int productAmount;
  final bool? enabled;
  final bool? isValidatorEnabled;
  final FocusNode? focusNode;
  const QuantityTextfield({
    super.key,
    required this.controller,
    required this.title,
    required this.hintText,
    required this.unit,
    required this.onUnitChanged,
    required this.isRawMaterial,
    required this.itemLimit,
    required this.itemLimitUnit,
    required this.isItemLimitOn,
    required this.productAmount,
    this.enabled,
    this.isValidatorEnabled,
    this.focusNode,
  });

  @override
  State<QuantityTextfield> createState() => _QuantityTextfieldState();
}

class _QuantityTextfieldState extends State<QuantityTextfield> {
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
            suffixIcon: widget.isRawMaterial
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
          style: const TextStyle(
            fontSize: 14,
            overflow: TextOverflow.ellipsis,
          ),
          validator: (value) {
            // check if validator enabled or not
            if (widget.isValidatorEnabled != null) {
              if (widget.isValidatorEnabled == false) {
                return null;
              }
            }

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

            double convertedItemQuantity = 0;
            double convertedItemLimit = 0;
            String tempUnit = 'Kg';

            // convert selected item & order limit to kg if its raw material
            if (value.isNotEmpty && widget.isRawMaterial) {
              // selected item quantity
              if (widget.unit.toLowerCase().contains('gram')) {
                convertedItemQuantity = double.parse(value) / 1000;
              } else {
                convertedItemQuantity = double.parse(value);
              }

              // item limit
              if (widget.itemLimitUnit.toLowerCase().contains('gram')) {
                convertedItemLimit = widget.itemLimit.toDouble() / 1000;
              } else {
                convertedItemLimit = widget.itemLimit.toDouble();
              }

              // if item limit is less than 1 kg, change format to Gram
              if (convertedItemLimit < 1) {
                convertedItemQuantity = convertedItemQuantity * 1000;
                convertedItemLimit = convertedItemLimit * 1000;
                tempUnit = 'Gram';
              }

              // multiply the quantity of product with the amount of material
              convertedItemQuantity =
                  convertedItemQuantity * widget.productAmount;
            }

            // return error if input more than limit
            if (widget.isRawMaterial) {
              if (widget.isItemLimitOn &&
                  convertedItemQuantity > convertedItemLimit) {
                return 'Max $convertedItemLimit $tempUnit';
              }
            } else {
              if (widget.isItemLimitOn && int.parse(value) > widget.itemLimit) {
                return 'Max ${widget.itemLimit} stock';
              }
            }

            return null;
          },
          keyboardType: TextInputType.number,
          maxLines: 1,
          enabled: widget.enabled,
        ),
      ],
    );
  }
}
