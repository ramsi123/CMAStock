import 'package:cahaya_mulya_abadi/components/my_searchbar.dart';
import 'package:cahaya_mulya_abadi/components/order_tile.dart';
import 'package:cahaya_mulya_abadi/services/database/database_service.dart';
import 'package:cahaya_mulya_abadi/themes/app_pallete.dart';
import 'package:cahaya_mulya_abadi/utils/constants.dart';
import 'package:cahaya_mulya_abadi/utils/show_delete_approval.dart';
import 'package:cahaya_mulya_abadi/utils/show_snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'add_order_page.dart';
import 'detail_order_page.dart';

class AllOrderPage extends StatefulWidget {
  final String userRole;
  const AllOrderPage({
    super.key,
    required this.userRole,
  });

  @override
  State<AllOrderPage> createState() => _AllOrderPageState();
}

class _AllOrderPageState extends State<AllOrderPage> {
  // database service
  final databaseService = DatabaseService();

  // variables
  String searchedItem = '';
  Stream<QuerySnapshot<Object?>>? getOrder;

  // delete order
  void deleteOrder(
    BuildContext context,
    String docId,
  ) async {
    try {
      await databaseService.deleteOrder(docId);
    } catch (e) {
      if (context.mounted) {
        showSnackbar(context, e.toString());
      }
    }
  }

  @override
  void initState() {
    super.initState();

    // retrieve all order
    getOrder = databaseService.getOrder();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
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

              // list of item
              Expanded(
                child: StreamBuilder(
                  stream: getOrder,
                  builder: (context, snapshot) {
                    // error
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text('Error'),
                      );
                    }

                    // loading..
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final orderData = snapshot.data!.docs;

                    // no data
                    if (orderData.isEmpty) {
                      return Container(
                        alignment: Alignment.center,
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // animation
                              Lottie.asset('assets/empty-item.json'),

                              // text
                              const Text('No order'),
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
                          bottom: widget.userRole.contains('owner') ? 80 : 16,
                        ),
                        itemCount: orderData.length,
                        itemBuilder: (context, index) {
                          final data = orderData[index];

                          return OrderTile(
                            title: data['customerName'],
                            description: data['deskripsi'],
                            status: data['status'],
                            userRole: widget.userRole,
                            navigateToDetailOrderPage: (context) {
                              Navigator.push(
                                context,
                                DetailOrderPage.route(
                                  data.id,
                                  widget.userRole,
                                ),
                              ).then((value) {
                                setState(() {
                                  getOrder = databaseService.getOrder();
                                });
                              });
                            },
                            onPressedDelete: (context) {
                              showDeleteApproval(
                                context,
                                Constants.deleteOrderToast,
                                () {
                                  deleteOrder(context, data.id);

                                  // refresh data
                                  setState(() {
                                    getOrder = databaseService.getOrder();
                                  });
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
                          bottom: widget.userRole.contains('owner') ? 80 : 16,
                        ),
                        itemCount: orderData.length,
                        itemBuilder: (context, index) {
                          final data = orderData[index];

                          if (data['customerName']
                                  .toString()
                                  .toLowerCase()
                                  .contains(
                                    searchedItem.toLowerCase(),
                                  ) ||
                              data['deskripsi']
                                  .toString()
                                  .toLowerCase()
                                  .contains(
                                    searchedItem.toLowerCase(),
                                  )) {
                            return OrderTile(
                              title: data['customerName'],
                              description: data['deskripsi'],
                              status: data['status'],
                              userRole: widget.userRole,
                              navigateToDetailOrderPage: (context) {
                                Navigator.push(
                                  context,
                                  DetailOrderPage.route(
                                    data.id,
                                    widget.userRole,
                                  ),
                                ).then((value) {
                                  setState(() {
                                    getOrder = databaseService.getOrder();
                                  });
                                });
                              },
                              onPressedDelete: (context) {
                                showDeleteApproval(
                                  context,
                                  Constants.deleteOrderToast,
                                  () {
                                    deleteOrder(context, data.id);

                                    // refresh data
                                    setState(() {
                                      getOrder = databaseService.getOrder();
                                    });
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
                        AddOrderPage.route(widget.userRole),
                      ).then((value) {
                        // refresh data
                        setState(() {
                          getOrder = databaseService.getOrder();
                        });
                      });
                    },
                    backgroundColor: Colors.white,
                    foregroundColor: AppPallete.pink,
                    label: const Text('TAMBAH ORDER'),
                    icon: const Icon(Icons.add),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
