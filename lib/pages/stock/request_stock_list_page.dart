import 'package:cahaya_mulya_abadi/components/my_searchbar.dart';
import 'package:cahaya_mulya_abadi/components/request_stock_tile.dart';
import 'package:cahaya_mulya_abadi/pages/stock/request_stock_detail_page.dart';
import 'package:cahaya_mulya_abadi/services/database/database_service.dart';
import 'package:cahaya_mulya_abadi/utils/constants.dart';
import 'package:cahaya_mulya_abadi/utils/show_delete_approval.dart';
import 'package:cahaya_mulya_abadi/utils/show_snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class RequestStockListPage extends StatefulWidget {
  const RequestStockListPage({super.key});

  @override
  State<RequestStockListPage> createState() => _RequestStockListPageState();
}

class _RequestStockListPageState extends State<RequestStockListPage> {
  // database service
  final databaseService = DatabaseService();

  // variables
  String searchedItem = '';
  Stream<QuerySnapshot<Object?>>? getStockRequest;

  // delete stock request
  void deleteStockRequest(
    BuildContext context,
    String docId,
  ) async {
    try {
      await databaseService.deleteStockRequest(docId);
    } catch (e) {
      if (context.mounted) {
        showSnackbar(context, e.toString());
      }
    }
  }

  @override
  void initState() {
    super.initState();

    // retrieve all stock request
    getStockRequest = databaseService.getStockRequest();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Center(
        child: Column(
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
                stream: getStockRequest,
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
                            const Text('Empty stock request'),
                          ],
                        ),
                      ),
                    );
                  }

                  // load complete
                  if (searchedItem.isEmpty) {
                    return ListView.builder(
                      padding: const EdgeInsets.only(
                        left: 5,
                        right: 5,
                        bottom: 16,
                      ),
                      itemCount: stockData.length,
                      itemBuilder: (context, index) {
                        final data = stockData[index];

                        return RequestStockTile(
                          title: data['namaBarang'],
                          amount: data['jumlahBarang'],
                          unit: data['unit'],
                          status: data['status'],
                          onTap: () {
                            Navigator.push(
                              context,
                              RequestStockDetailPage.route(data.id),
                            ).then((value) {
                              setState(() {
                                getStockRequest =
                                    databaseService.getStockRequest();
                              });
                            });
                          },
                          onPressedDelete: (context) {
                            showDeleteApproval(
                              context,
                              Constants.deleteStockRequestToast,
                              () {
                                // delete stock request
                                deleteStockRequest(
                                  context,
                                  data.id,
                                );

                                // refresh data
                                setState(() {
                                  getStockRequest =
                                      databaseService.getStockRequest();
                                });
                              },
                            );
                          },
                        );
                      },
                    );
                  } else {
                    return ListView.builder(
                      padding: const EdgeInsets.only(
                        left: 5,
                        right: 5,
                        bottom: 16,
                      ),
                      itemCount: stockData.length,
                      itemBuilder: (context, index) {
                        final data = stockData[index];

                        if (data['namaBarang']
                            .toString()
                            .toLowerCase()
                            .contains(
                              searchedItem.toLowerCase(),
                            )) {
                          return RequestStockTile(
                            title: data['namaBarang'],
                            amount: data['jumlahBarang'],
                            unit: data['unit'],
                            status: data['status'],
                            onTap: () {
                              Navigator.push(
                                context,
                                RequestStockDetailPage.route(data.id),
                              ).then((value) {
                                setState(() {
                                  getStockRequest =
                                      databaseService.getStockRequest();
                                });
                              });
                            },
                            onPressedDelete: (context) {
                              showDeleteApproval(
                                context,
                                Constants.deleteStockRequestToast,
                                () {
                                  // delete stock request
                                  deleteStockRequest(
                                    context,
                                    data.id,
                                  );

                                  // refresh data
                                  setState(() {
                                    getStockRequest =
                                        databaseService.getStockRequest();
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
      ),
    );
  }
}
