import 'package:cahaya_mulya_abadi/themes/app_pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../utils/constants.dart';

class ItemTile extends StatelessWidget {
  final String title;
  final String description;
  final String numberOfGoods;
  final String unit;
  final String imageUrl;
  final String userRole;
  final Function(BuildContext)? onPressedEdit;
  final Function(BuildContext)? onPressedDelete;
  const ItemTile({
    super.key,
    required this.title,
    required this.description,
    required this.numberOfGoods,
    required this.unit,
    required this.imageUrl,
    required this.userRole,
    required this.onPressedEdit,
    required this.onPressedDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
      child: Slidable(
        endActionPane: ActionPane(
          extentRatio: userRole.contains('owner') ? 0.35 : 0.25,
          motion: const StretchMotion(),
          children: userRole.contains('owner')
              ? [
                  // edit
                  SlidableAction(
                    onPressed: onPressedEdit,
                    icon: Icons.edit_outlined,
                    label: Constants.edit,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    padding: const EdgeInsets.all(0),
                  ),

                  // delete
                  SlidableAction(
                    onPressed: onPressedDelete,
                    icon: Icons.delete_outline,
                    label: Constants.delete,
                    foregroundColor: AppPallete.redDanger,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    padding: const EdgeInsets.all(0),
                  ),
                ]
              : [
                  // edit
                  SlidableAction(
                    onPressed: onPressedEdit,
                    icon: Icons.edit_outlined,
                    label: Constants.edit,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    padding: const EdgeInsets.all(0),
                  ),
                ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // picture, title, and description
              Flexible(
                child: Row(
                  children: [
                    // picture
                    Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        color: AppPallete.grey,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: imageUrl.isNotEmpty
                          ? FadeInImage.assetNetwork(
                              placeholder: 'assets/loading.gif',
                              image: imageUrl,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              padding: const EdgeInsets.all(10),
                              child: Image.asset('assets/box.png'),
                            ),
                    ),

                    const SizedBox(width: 10),

                    // title and description
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // title
                          Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),

                          // description
                          Text(
                            description,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 25),

              // number of goods and unit
              Padding(
                padding: const EdgeInsets.only(right: 18),
                child: Row(
                  children: [
                    // number of goods
                    Text(
                      numberOfGoods,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(width: 5),

                    // unit
                    Text(
                      unit,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
