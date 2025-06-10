import 'package:cahaya_mulya_abadi/components/item_tile.dart';
import 'package:cahaya_mulya_abadi/components/my_searchbar.dart';
import 'package:cahaya_mulya_abadi/pages/stock/add_request_stock_page.dart';
import 'package:cahaya_mulya_abadi/pages/stock/add_stock_page.dart';
import 'package:cahaya_mulya_abadi/pages/stock/edit_stock_staff_page.dart';
import 'package:cahaya_mulya_abadi/services/database/database_service.dart';
import 'package:cahaya_mulya_abadi/themes/app_pallete.dart';
import 'package:cahaya_mulya_abadi/utils/constants.dart';
import 'package:cahaya_mulya_abadi/utils/show_delete_approval.dart';
import 'package:cahaya_mulya_abadi/utils/show_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'edit_stock_page.dart';

class StockListPage extends StatefulWidget {
  final String userRole;
  const StockListPage({
    super.key,
    required this.userRole,
  });

  @override
  State<StockListPage> createState() => _StockListPageState();
}

class _StockListPageState extends State<StockListPage> {
  // database service
  final databaseService = DatabaseService();

  // variables
  String searchedItem = '';

  // delete stock
  void deleteStock(
    BuildContext context,
    String docId,
    String imageId,
  ) async {
    try {
      await databaseService.deleteStock(docId, imageId);
    } catch (e) {
      if (context.mounted) {
        showSnackbar(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Center(
        child: Stack(
          children: [
            // main content
            Column(
              children: [
                const SizedBox(height: 16),

                // search bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: MySearchbar(
                    hintText: 'Search',
                    onChanged: (value) {
                      setState(() {
                        searchedItem = value;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 5),

                // list of item
                Expanded(
                  child: StreamBuilder(
                    stream: databaseService.getStock(),
                    builder: (context, snapshot) {
                      // error
                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      }

                      // loading..
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      //final stockData = snapshot.data ?? [];
                      final stockData = snapshot.data!.docs;

                      // no data
                      if (stockData.isEmpty) {
                        return Container(
                          alignment: Alignment.center,
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // animation
                                Lottie.asset('assets/empty-item.json'),

                                // text
                                const Text('Empty stock'),
                              ],
                            ),
                          ),
                        );
                      }

                      // load complete
                      if (searchedItem.isEmpty) {
                        return ListView.builder(
                          padding: EdgeInsets.only(
                            left: 5,
                            right: 5,
                            bottom: widget.userRole.contains('owner') ? 16 : 80,
                          ),
                          itemCount: stockData.length,
                          itemBuilder: (context, index) {
                            final data = stockData[index];

                            return ItemTile(
                              title: data['namaBarang'],
                              description: data['deskripsiBarang'],
                              numberOfGoods: data['jumlahBarang'],
                              unit: data['unit'],
                              imageUrl: data['imageUrl'],
                              userRole: widget.userRole,
                              onPressedEdit: (context) {
                                if (widget.userRole.contains('owner')) {
                                  Navigator.push(
                                    context,
                                    EditStockPage.route(
                                      data.id,
                                      data['namaBarang'],
                                      data['deskripsiBarang'],
                                      data['jumlahBarang'],
                                      data['unit'],
                                      data['imageId'],
                                      data['imageUrl'],
                                    ),
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    EditStockStaffPage.route(
                                      data.id,
                                      data['namaBarang'],
                                      data['deskripsiBarang'],
                                      data['jumlahBarang'],
                                      data['unit'],
                                      data['imageId'],
                                      data['imageUrl'],
                                    ),
                                  );
                                }
                              },
                              onPressedDelete: (context) {
                                showDeleteApproval(
                                  context,
                                  Constants.deleteStockToast,
                                  () {
                                    deleteStock(
                                      context,
                                      data.id,
                                      data['imageId'],
                                    );
                                  },
                                );
                              },
                            );
                          },
                        );
                      } else {
                        return ListView.builder(
                          padding: EdgeInsets.only(
                            left: 5,
                            right: 5,
                            bottom: widget.userRole.contains('owner') ? 16 : 80,
                          ),
                          itemCount: stockData.length,
                          itemBuilder: (context, index) {
                            final data = stockData[index];

                            if (data['namaBarang']
                                    .toString()
                                    .toLowerCase()
                                    .contains(
                                      searchedItem.toLowerCase(),
                                    ) ||
                                data['deskripsiBarang']
                                    .toString()
                                    .toLowerCase()
                                    .contains(
                                      searchedItem.toLowerCase(),
                                    )) {
                              return ItemTile(
                                title: data['namaBarang'],
                                description: data['deskripsiBarang'],
                                numberOfGoods: data['jumlahBarang'],
                                unit: data['unit'],
                                imageUrl: data['imageUrl'],
                                userRole: widget.userRole,
                                onPressedEdit: (context) {
                                  if (widget.userRole.contains('owner')) {
                                    Navigator.push(
                                      context,
                                      EditStockPage.route(
                                        data.id,
                                        data['namaBarang'],
                                        data['deskripsiBarang'],
                                        data['jumlahBarang'],
                                        data['unit'],
                                        data['imageId'],
                                        data['imageUrl'],
                                      ),
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      EditStockStaffPage.route(
                                        data.id,
                                        data['namaBarang'],
                                        data['deskripsiBarang'],
                                        data['jumlahBarang'],
                                        data['unit'],
                                        data['imageId'],
                                        data['imageUrl'],
                                      ),
                                    );
                                  }
                                },
                                onPressedDelete: (context) {
                                  showDeleteApproval(
                                    context,
                                    Constants.deleteStockToast,
                                    () {
                                      deleteStock(
                                        context,
                                        data.id,
                                        data['imageId'],
                                      );
                                    },
                                  );
                                },
                              );
                            }

                            return Container();
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            ),

            // fab
            widget.userRole.contains('owner')
                ? Positioned(
                    bottom: 16.0,
                    right: 16.0,
                    child: FloatingActionButton.extended(
                      onPressed: () {
                        Navigator.push(
                          context,
                          AddStockPage.route(),
                        );
                      },
                      backgroundColor: Colors.white,
                      foregroundColor: AppPallete.pink,
                      label: const Text('TAMBAH BAHAN'),
                      icon: const Icon(Icons.add),
                    ),
                  )
                : Positioned(
                    bottom: 16.0,
                    right: 16.0,
                    child: FloatingActionButton.extended(
                      onPressed: () {
                        Navigator.push(
                          context,
                          AddRequestStockPage.route(),
                        );
                      },
                      backgroundColor: Colors.white,
                      foregroundColor: AppPallete.pink,
                      label: const Text('REQUEST BAHAN'),
                      icon: const Icon(Icons.add),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
