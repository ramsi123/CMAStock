import 'package:flutter/material.dart';

class MyDropdownButton extends StatefulWidget {
  final List<String> dropdownItem;
  final String? item;
  final String title;
  final String hint;
  final Function(String?)? onChanged;
  final Function(int) onIndexSelected;
  final bool isEnabled;
  final bool? isValidatorEnabled;
  const MyDropdownButton({
    super.key,
    required this.dropdownItem,
    required this.item,
    required this.title,
    required this.hint,
    required this.onChanged,
    required this.onIndexSelected,
    required this.isEnabled,
    this.isValidatorEnabled,
  });

  @override
  State<MyDropdownButton> createState() => _MyDropdownButtonState();
}

class _MyDropdownButtonState extends State<MyDropdownButton> {
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

        // dropdown button
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            border: Border.all(
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1.5),
          child: DropdownButtonFormField(
            items: widget.dropdownItem.map((value) {
              return DropdownMenuItem(
                value: value,
                child: Text(value),
              );
            }).toList(),
            icon: const Icon(Icons.keyboard_arrow_down),
            value: widget.item,
            hint: Text(widget.hint),
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.primary,
              overflow: TextOverflow.ellipsis,
            ),
            isExpanded: true,
            onChanged: widget.isEnabled
                ? (String? newValue) {
                    widget.onChanged!(newValue);
                    widget.onIndexSelected(
                        widget.dropdownItem.indexOf(newValue!));
                  }
                : null,
            validator: (value) {
              // check if validator enabled or not
              if (widget.isValidatorEnabled != null) {
                if (widget.isValidatorEnabled == false) {
                  return null;
                }
              }

              if (value == null) {
                return 'Item Perlu Dipilih!';
              }

              return null;
            },
          ),
        ),
      ],
    );
  }
}
