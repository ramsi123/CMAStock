import 'package:cahaya_mulya_abadi/themes/app_pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// ignore: must_be_immutable
class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  Function(int)? onTabChange;
  final String userRole;
  BottomNavBar({
    super.key,
    required this.userRole,
    required this.selectedIndex,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    return userRole.contains('owner')
        ? BottomNavigationBar(
            items: [
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'assets/home.svg',
                  width: 30,
                  height: 30,
                ),
                activeIcon: SvgPicture.asset(
                  'assets/home_selected.svg',
                  width: 30,
                  height: 30,
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'assets/stock.svg',
                  width: 30,
                  height: 30,
                ),
                activeIcon: SvgPicture.asset(
                  'assets/stock_selected.svg',
                  width: 30,
                  height: 30,
                ),
                label: 'Stock',
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'assets/product.svg',
                  width: 30,
                  height: 30,
                ),
                activeIcon: SvgPicture.asset(
                  'assets/product_selected.svg',
                  width: 30,
                  height: 30,
                ),
                label: 'Product',
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'assets/order.svg',
                  width: 30,
                  height: 30,
                ),
                activeIcon: SvgPicture.asset(
                  'assets/order_selected.svg',
                  width: 30,
                  height: 30,
                ),
                label: 'Order',
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'assets/profile.svg',
                  width: 30,
                  height: 30,
                ),
                activeIcon: SvgPicture.asset(
                  'assets/profile_selected.svg',
                  width: 30,
                  height: 30,
                ),
                label: 'Profile',
              ),
            ],
            currentIndex: selectedIndex,
            onTap: onTabChange,
            selectedItemColor: AppPallete.pink,
            unselectedItemColor: Theme.of(context).colorScheme.primary,
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            elevation: 2,
          )
        : BottomNavigationBar(
            items: [
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'assets/stock.svg',
                  width: 30,
                  height: 30,
                ),
                activeIcon: SvgPicture.asset(
                  'assets/stock_selected.svg',
                  width: 30,
                  height: 30,
                ),
                label: 'Stock',
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'assets/product.svg',
                  width: 30,
                  height: 30,
                ),
                activeIcon: SvgPicture.asset(
                  'assets/product_selected.svg',
                  width: 30,
                  height: 30,
                ),
                label: 'Product',
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'assets/order.svg',
                  width: 30,
                  height: 30,
                ),
                activeIcon: SvgPicture.asset(
                  'assets/order_selected.svg',
                  width: 30,
                  height: 30,
                ),
                label: 'Order',
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'assets/stock.svg',
                  width: 30,
                  height: 30,
                ),
                activeIcon: SvgPicture.asset(
                  'assets/stock_selected.svg',
                  width: 30,
                  height: 30,
                ),
                label: 'Packaging',
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'assets/profile.svg',
                  width: 30,
                  height: 30,
                ),
                activeIcon: SvgPicture.asset(
                  'assets/profile_selected.svg',
                  width: 30,
                  height: 30,
                ),
                label: 'Profile',
              ),
            ],
            currentIndex: selectedIndex,
            onTap: onTabChange,
            selectedItemColor: AppPallete.pink,
            unselectedItemColor: Theme.of(context).colorScheme.primary,
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            elevation: 2,
          );
    /* return GNav(
      color: Colors.grey[400],
      tabBackgroundColor: Theme.of(context).colorScheme.secondary,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      tabBorderRadius: 16,
      gap: 8,
      padding: const EdgeInsets.all(20),
      onTabChange: (value) => onTabChange!(value),
      tabs: const [
        GButton(
          /* gap: 10,
          iconActiveColor: Colors.purple,
          //iconColor: Colors.black,
          textColor: Colors.purple,
          backgroundColor: Colors.purple.withOpacity(.2),
          iconSize: 24,
          //padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12), */
          icon: Icons.inventory_2_outlined,
          text: "Stock",
        ),
        GButton(
          /* gap: 10,
          iconActiveColor: Colors.purple,
          //iconColor: Colors.black,
          textColor: Colors.purple,
          backgroundColor: Colors.purple.withOpacity(.2),
          iconSize: 24,
          //padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12), */
          icon: Icons.shopping_bag_outlined,
          text: "Product",
        ),
        GButton(
          /* gap: 10,
          iconActiveColor: Colors.purple,
          //iconColor: Colors.black,
          textColor: Colors.purple,
          backgroundColor: Colors.purple.withOpacity(.2),
          iconSize: 24,
          //padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12), */
          icon: Icons.shopping_cart_outlined,
          text: "Order",
        ),
        GButton(
          /* gap: 10,
          iconActiveColor: Colors.purple,
          //iconColor: Colors.black,
          textColor: Colors.purple,
          backgroundColor: Colors.purple.withOpacity(.2),
          iconSize: 24,
          //padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12), */
          icon: Icons.person_outline,
          text: "Profile",
        ),
      ],
    ); */
  }
}
