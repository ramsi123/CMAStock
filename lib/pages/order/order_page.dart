import 'package:cahaya_mulya_abadi/components/tab_item.dart';
import 'package:cahaya_mulya_abadi/pages/order/active_order_page.dart';
import 'package:cahaya_mulya_abadi/pages/order/all_order_page.dart';
import 'package:cahaya_mulya_abadi/themes/app_pallete.dart';
import 'package:flutter/material.dart';

class OrderPage extends StatelessWidget {
  final String userRole;
  const OrderPage({
    super.key,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Order'),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(40),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              child: Container(
                height: 40,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                  color: Theme.of(context).colorScheme.surface,
                ),
                child: TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: AppPallete.lightPeach,
                    border: Border.all(
                      color: AppPallete.pink,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                  ),
                  labelColor: AppPallete.pink,
                  unselectedLabelColor: Colors.black54,
                  tabs: const [
                    TabItem(title: 'Active Order'),
                    TabItem(title: 'All Order'),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              // active order
              ActiveOrderPage(
                userRole: userRole,
              ),

              // all order
              AllOrderPage(
                userRole: userRole,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
