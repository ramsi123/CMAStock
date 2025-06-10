import 'package:cahaya_mulya_abadi/components/tab_item.dart';
import 'package:cahaya_mulya_abadi/pages/stock/add_stock_page.dart';
import 'package:cahaya_mulya_abadi/pages/stock/add_request_stock_page.dart';
import 'package:cahaya_mulya_abadi/themes/app_pallete.dart';
import 'package:flutter/material.dart';

class AddStockAndRequestPage extends StatelessWidget {
  static route() =>
      MaterialPageRoute(builder: (context) => const AddStockAndRequestPage());
  const AddStockAndRequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tambah Bahan'),
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios),
          ),
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
                    TabItem(title: 'Tambah Barang'),
                    TabItem(title: 'Request Barang'),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            // tambah barang
            AddStockPage(),

            // request barang
            AddRequestStockPage(),
          ],
        ),
      ),
    );
  }
}
