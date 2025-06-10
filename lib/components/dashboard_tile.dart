import 'package:cahaya_mulya_abadi/themes/app_pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DashboardTile extends StatelessWidget {
  final String title;
  final String description;
  final String iconAsset;
  const DashboardTile({
    super.key,
    required this.title,
    required this.description,
    required this.iconAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [
            AppPallete.peach,
            AppPallete.pink,
          ],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // title
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 12),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(height: 2),

          // description
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              description,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(height: 20),

          // icon
          Align(
            alignment: Alignment.bottomRight,
            child: IconButton(
              onPressed: () {},
              icon: SvgPicture.asset(
                iconAsset,
                width: 25,
                height: 25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
