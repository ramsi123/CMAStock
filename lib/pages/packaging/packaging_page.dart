import 'package:cahaya_mulya_abadi/components/my_searchbar.dart';
import 'package:cahaya_mulya_abadi/components/packaging_tile.dart';
import 'package:cahaya_mulya_abadi/pages/packaging/packaging_detail_page.dart';
import 'package:cahaya_mulya_abadi/services/database/database_service.dart';
import 'package:cahaya_mulya_abadi/services/notifications/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class PackagingPage extends StatefulWidget {
  const PackagingPage({super.key});

  @override
  State<PackagingPage> createState() => _PackagingPageState();
}

class _PackagingPageState extends State<PackagingPage> {
  // database service
  final databaseService = DatabaseService();

  // variables
  String searchedItem = '';
  Stream<QuerySnapshot<Object?>>? getPackagingRequest;

  // show notification
  void showNotification(List<QueryDocumentSnapshot<Object?>> packagingData) {
    List<String> namaBarang = [];
    for (var i in packagingData) {
      final data = i;
      if (data['status'].toString().toLowerCase().contains('waiting')) {
        namaBarang.add(data['namaBarang']);
      }
    }

    NotificationService().showNotification(
      title: 'Ada Barang yang Perlu Dikemas!',
      body: namaBarang.length > 1
          ? '${namaBarang.first} dan +${namaBarang.length - 1} lainnya'
          : namaBarang.first,
      inboxLines: namaBarang,
    );
  }

  @override
  void initState() {
    super.initState();

    // retrieve all packaging request
    getPackagingRequest = databaseService.getPackaging();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Packaging'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
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
                  stream: getPackagingRequest,
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

                    final packagingData = snapshot.data!.docs;

                    // no data
                    if (packagingData.isEmpty) {
                      return Container(
                        alignment: Alignment.center,
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // animation
                              Lottie.asset('assets/empty-item.json'),

                              // text
                              const Text('Empty packaging request'),
                            ],
                          ),
                        ),
                      );
                    }

                    // show notification
                    showNotification(packagingData);

                    // load complete
                    if (searchedItem.isEmpty) {
                      return ListView.builder(
                        padding: const EdgeInsets.only(
                          left: 5,
                          right: 5,
                          bottom: 16,
                        ),
                        itemCount: packagingData.length,
                        itemBuilder: (context, index) {
                          final data = packagingData[index];

                          return PackagingTile(
                            title: data['namaBarang'],
                            amount: data['jumlahRequest'],
                            status: data['status'],
                            onTap: () {
                              Navigator.push(
                                context,
                                PackagingDetailPage.route(
                                  data.id,
                                  data['docId'],
                                ),
                              ).then((value) {
                                setState(() {
                                  getPackagingRequest =
                                      databaseService.getPackaging();
                                });
                              });
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
                        itemCount: packagingData.length,
                        itemBuilder: (context, index) {
                          final data = packagingData[index];

                          if (data['namaBarang']
                              .toString()
                              .toLowerCase()
                              .contains(
                                searchedItem.toLowerCase(),
                              )) {
                            return PackagingTile(
                              title: data['namaBarang'],
                              amount: data['jumlahRequest'],
                              status: data['status'],
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PackagingDetailPage.route(
                                    data.id,
                                    data['docId'],
                                  ),
                                ).then((value) {
                                  setState(() {
                                    getPackagingRequest =
                                        databaseService.getPackaging();
                                  });
                                });
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
      ),
    );
  }
}
