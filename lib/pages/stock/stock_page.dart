import 'package:cahaya_mulya_abadi/components/tab_item.dart';
import 'package:cahaya_mulya_abadi/pages/stock/request_stock_list_page.dart';
import 'package:cahaya_mulya_abadi/pages/stock/stock_list_page.dart';
import 'package:cahaya_mulya_abadi/themes/app_pallete.dart';
import 'package:flutter/material.dart';

class StockPage extends StatefulWidget {
  final String userRole;
  const StockPage({
    super.key,
    required this.userRole,
  });

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: const Text('Stock'),
          centerTitle: true,
          bottom: widget.userRole.contains('owner')
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(40),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                    child: Container(
                      height: 40,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(16)),
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
                          borderRadius:
                              const BorderRadius.all(Radius.circular(16)),
                        ),
                        labelColor: AppPallete.pink,
                        unselectedLabelColor: Colors.black54,
                        tabs: const [
                          TabItem(title: 'List Bahan Baku'),
                          TabItem(title: 'Request Barang'),
                        ],
                      ),
                    ),
                  ),
                )
              : null,
        ),
        body: SafeArea(
          child: widget.userRole.contains('owner')
              ? TabBarView(
                  children: [
                    // stock list page
                    StockListPage(userRole: widget.userRole),

                    // request list page
                    const RequestStockListPage(),
                  ],
                )
              : StockListPage(userRole: widget.userRole),
        ),
      ),
    );
  }
}
