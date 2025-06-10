import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'document_snapshot_matcher.dart';
import 'models/order.dart';
import 'models/outstanding.dart';
import 'models/product.dart';
import 'models/stock.dart';
import 'models/stock_report.dart';
import 'models/stock_request.dart';
import 'models/user.dart';
import 'query_snapshot_matcher.dart';

const stockUid = 'abc';
const productUid = 'def';

void main() async {
  // stock
  group(
    'stock',
    () {
      const expectedStockDumpAfterSet = '''{
  "bahan_baku": {
    "abc": {
      "materialId": "M001",
      "namaBarang": "Bahan baku 1",
      "jumlahBarang": "10",
      "unit": "Kg",
      "deskripsiBarang": "Deskripsi bahan baku 1",
      "imageId": "301",
      "imageUrl": "https://301",
      "timestamp": "February 26, 2025 at 6:00:18AM UTC+7"
    }
  }
}''';

      const expectedStockDumpAfterDelete = '''{
  "bahan_baku": {}
}''';

      // retrieve stock
      test(
        'retrieve stock',
        () async {
          final instance = FakeFirebaseFirestore();
          await instance.collection('bahan_baku').doc(stockUid).set(
                Stock(
                  materialId: 'M001',
                  namaBarang: 'Bahan baku 1',
                  jumlahBarang: '10',
                  unit: 'Kg',
                  deskripsiBarang: 'Deskripsi bahan baku 1',
                  imageId: '301',
                  imageUrl: 'https://301',
                  timestamp: 'February 26, 2025 at 6:00:18AM UTC+7',
                ).toMap(),
              );
          expect(
              instance.collection('bahan_baku').snapshots(),
              emits(QuerySnapshotMatcher([
                DocumentSnapshotMatcher(
                  stockUid,
                  {
                    'materialId': 'M001',
                    'namaBarang': 'Bahan baku 1',
                    'jumlahBarang': '10',
                    'unit': 'Kg',
                    'deskripsiBarang': 'Deskripsi bahan baku 1',
                    'imageId': '301',
                    'imageUrl': 'https://301',
                    'timestamp': 'February 26, 2025 at 6:00:18AM UTC+7',
                  },
                  // you can use the above method or below, both works fine
                  // with snapshot. other than snapshot is not working.
                  /* Stock(
                      materialId: 'M001',
                      namaBarang: 'Bahan baku 1',
                      jumlahBarang: '10',
                      unit: 'Kg',
                      deskripsiBarang: 'Deskripsi bahan baku 1',
                      imageId: '301',
                      imageUrl: 'https://301',
                      timestamp: 'February 26, 2025 at 6:00:18AM UTC+7',
                    ).toMap() */
                )
              ])));
        },
      );

      // add stock
      test(
        'add stock',
        () async {
          final instance = FakeFirebaseFirestore();
          await instance.collection('bahan_baku').doc(stockUid).set(
                Stock(
                  materialId: 'M001',
                  namaBarang: 'Bahan baku 1',
                  jumlahBarang: '10',
                  unit: 'Kg',
                  deskripsiBarang: 'Deskripsi bahan baku 1',
                  imageId: '301',
                  imageUrl: 'https://301',
                  timestamp: 'February 26, 2025 at 6:00:18AM UTC+7',
                ).toMap(),
              );
          expect(instance.dump(), equals(expectedStockDumpAfterSet));
        },
      );

      // update stock
      test(
        'update stock',
        () async {
          final instance = FakeFirebaseFirestore();
          final doc = instance.collection('bahan_baku').doc(stockUid);
          await doc.set(
            Stock(
              materialId: 'M001',
              namaBarang: 'Bahan baku 1',
              jumlahBarang: '10',
              unit: 'Kg',
              deskripsiBarang: 'Deskripsi bahan baku 1',
              imageId: '301',
              imageUrl: 'https://301',
              timestamp: 'February 26, 2025 at 6:00:18AM UTC+7',
            ).toMap(),
          );
          await doc.update(
            Stock(
              materialId: 'M001',
              namaBarang: 'Bahan baku 2',
              jumlahBarang: '10',
              unit: 'Kg',
              deskripsiBarang: 'Deskripsi bahan baku 1',
              imageId: '301',
              imageUrl: 'https://301',
              timestamp: 'February 26, 2025 at 6:00:18AM UTC+7',
            ).toMap(),
          );
          expect((await doc.get()).get('namaBarang'), equals('Bahan baku 2'));
        },
      );

      // edit quantity stock
      test(
        'edit quantity stock',
        () async {
          final instance = FakeFirebaseFirestore();
          final doc = instance.collection('bahan_baku').doc(stockUid);
          await doc.set(
            Stock(
              materialId: 'M001',
              namaBarang: 'Bahan baku 1',
              jumlahBarang: '10',
              unit: 'Kg',
              deskripsiBarang: 'Deskripsi bahan baku 1',
              imageId: '301',
              imageUrl: 'https://301',
              timestamp: 'February 26, 2025 at 6:00:18AM UTC+7',
            ).toMap(),
          );
          await doc.update(
            Stock(
              materialId: 'M001',
              namaBarang: 'Bahan baku 1',
              jumlahBarang: '20',
              unit: 'Kg',
              deskripsiBarang: 'Deskripsi bahan baku 1',
              imageId: '301',
              imageUrl: 'https://301',
              timestamp: 'February 26, 2025 at 6:00:18AM UTC+7',
            ).toMap(),
          );
          expect((await doc.get()).get('jumlahBarang'), equals('20'));
        },
      );

      // delete stock
      test(
        'delete stock',
        () async {
          final instance = FakeFirebaseFirestore();
          final doc = instance.collection('bahan_baku').doc(stockUid);
          await doc.set(
            Stock(
              materialId: 'M001',
              namaBarang: 'Bahan baku 1',
              jumlahBarang: '10',
              unit: 'Kg',
              deskripsiBarang: 'Deskripsi bahan baku 1',
              imageId: '301',
              imageUrl: 'https://301',
              timestamp: 'February 26, 2025 at 6:00:18AM UTC+7',
            ).toMap(),
          );
          await doc.delete();
          expect(instance.dump(), equals(expectedStockDumpAfterDelete));
        },
      );

      // add stock report
      test(
        'add stock report',
        () async {
          final instance = FakeFirebaseFirestore();
          await instance.collection('bahan_baku').doc(stockUid).set(
                Stock(
                  materialId: 'M001',
                  namaBarang: 'Bahan baku 1',
                  jumlahBarang: '10',
                  unit: 'Kg',
                  deskripsiBarang: 'Deskripsi bahan baku 1',
                  imageId: '301',
                  imageUrl: 'https://301',
                  timestamp: 'February 26, 2025 at 6:00:18AM UTC+7',
                ).toMap(),
              );
          final stockReport = await instance
              .collection('bahan_baku')
              .doc(stockUid)
              .collection('laporan')
              .add(
                StockReport(
                  status: 'Masuk',
                  jumlah: '10',
                  sisa: '10',
                  note: 'Barang masuk',
                  timestamp: 'February 26, 2025 at 6:02:18AM UTC+7',
                ).toMap(),
              );
          expect(instance.dump(), equals('''{
  "bahan_baku": {
    "abc": {
      "laporan": {
        "${stockReport.id}": {
          "status": "Masuk",
          "jumlah": "10",
          "sisa": "10",
          "note": "Barang masuk",
          "timestamp": "February 26, 2025 at 6:02:18AM UTC+7"
        }
      },
      "materialId": "M001",
      "namaBarang": "Bahan baku 1",
      "jumlahBarang": "10",
      "unit": "Kg",
      "deskripsiBarang": "Deskripsi bahan baku 1",
      "imageId": "301",
      "imageUrl": "https://301",
      "timestamp": "February 26, 2025 at 6:00:18AM UTC+7"
    }
  }
}'''));
        },
      );
    },
  );

  // stock request
  group(
    'stock request',
    () {
      const expectedStockRequestDumpAfterDelete = '''{
  "request_bahan_baku": {}
}''';

      // add stock request
      test(
        'add stock request',
        () async {
          final instance = FakeFirebaseFirestore();
          final doc1 = await instance.collection('request_bahan_baku').add(
                StockRequest(
                  namaBarang: 'Bahan plastik 1',
                  jumlahBarang: '10',
                  unit: 'Kg',
                  deskripsiBarang: 'Ini bahan plastik 1',
                  status: 'Waiting',
                  timestamp: 'February 26, 2025 at 6:00:18AM UTC+7',
                ).toMap(),
              );
          expect(doc1.id.length, greaterThanOrEqualTo(20));
          expect(instance.dump(), equals('''{
  "request_bahan_baku": {
    "${doc1.id}": {
      "namaBarang": "Bahan plastik 1",
      "jumlahBarang": "10",
      "unit": "Kg",
      "deskripsiBarang": "Ini bahan plastik 1",
      "status": "Waiting",
      "timestamp": "February 26, 2025 at 6:00:18AM UTC+7"
    }
  }
}'''));
          final doc2 = await instance.collection('request_bahan_baku').add(
                StockRequest(
                  namaBarang: 'Bahan plastik 2',
                  jumlahBarang: '200',
                  unit: 'Gram',
                  deskripsiBarang: 'Ini bahan plastik 2',
                  status: 'Waiting',
                  timestamp: 'February 26, 2025 at 6:00:18AM UTC+7',
                ).toMap(),
              );
          expect(instance.dump(), equals('''{
  "request_bahan_baku": {
    "${doc1.id}": {
      "namaBarang": "Bahan plastik 1",
      "jumlahBarang": "10",
      "unit": "Kg",
      "deskripsiBarang": "Ini bahan plastik 1",
      "status": "Waiting",
      "timestamp": "February 26, 2025 at 6:00:18AM UTC+7"
    },
    "${doc2.id}": {
      "namaBarang": "Bahan plastik 2",
      "jumlahBarang": "200",
      "unit": "Gram",
      "deskripsiBarang": "Ini bahan plastik 2",
      "status": "Waiting",
      "timestamp": "February 26, 2025 at 6:00:18AM UTC+7"
    }
  }
}'''));
        },
      );

      // delete stock request
      test(
        'delete stock request',
        () async {
          final instance = FakeFirebaseFirestore();
          final stockRequest =
              await instance.collection('request_bahan_baku').add(
                    StockRequest(
                      namaBarang: 'Bahan plastik 1',
                      jumlahBarang: '10',
                      unit: 'Kg',
                      deskripsiBarang: 'Ini bahan plastik 1',
                      status: 'Waiting',
                      timestamp: 'February 26, 2025 at 6:00:18AM UTC+7',
                    ).toMap(),
                  );
          await instance
              .collection('request_bahan_baku')
              .doc(stockRequest.id)
              .delete();
          expect(instance.dump(), equals(expectedStockRequestDumpAfterDelete));
        },
      );

      // give permission to stock request
      test(
        'give permission to stock request',
        () async {
          final instance = FakeFirebaseFirestore();
          final stockRequest =
              await instance.collection('request_bahan_baku').add(
                    StockRequest(
                      namaBarang: 'Bahan plastik 1',
                      jumlahBarang: '10',
                      unit: 'Kg',
                      deskripsiBarang: 'Ini bahan plastik 1',
                      status: 'Waiting',
                      timestamp: 'February 26, 2025 at 6:00:18AM UTC+7',
                    ).toMap(),
                  );
          final doc =
              instance.collection('request_bahan_baku').doc(stockRequest.id);
          await doc.update(
            StockRequest(
              namaBarang: 'Bahan plastik 1',
              jumlahBarang: '10',
              unit: 'Kg',
              deskripsiBarang: 'Ini bahan plastik 1',
              status: 'Approve',
              timestamp: 'February 26, 2025 at 6:00:18AM UTC+7',
            ).toMap(),
          );
          expect((await doc.get()).get('status'), equals('Approve'));
        },
      );

      // retrieve all stock request
      test(
        'retrieve all stock request',
        () async {
          final instance = FakeFirebaseFirestore();
          final doc = await instance.collection('request_bahan_baku').add(
                StockRequest(
                  namaBarang: 'Bahan plastik 1',
                  jumlahBarang: '10',
                  unit: 'Kg',
                  deskripsiBarang: 'Ini bahan plastik 1',
                  status: 'Waiting',
                  timestamp: 'February 26, 2025 at 6:00:18AM UTC+7',
                ).toMap(),
              );
          expect(
              instance.collection('request_bahan_baku').snapshots(),
              emits(QuerySnapshotMatcher([
                DocumentSnapshotMatcher(
                  doc.id,
                  StockRequest(
                    namaBarang: "Bahan plastik 1",
                    jumlahBarang: "10",
                    unit: "Kg",
                    deskripsiBarang: "Ini bahan plastik 1",
                    status: "Waiting",
                    timestamp: "February 26, 2025 at 6:00:18AM UTC+7",
                  ).toMap(),
                )
              ])));
        },
      );

      // retrieve detail stock request
      test(
        'retrieve detail stock request',
        () async {
          final instance = FakeFirebaseFirestore();
          final stockRequest =
              await instance.collection('request_bahan_baku').add(
                    StockRequest(
                      namaBarang: 'Bahan plastik 1',
                      jumlahBarang: '10',
                      unit: 'Kg',
                      deskripsiBarang: 'Ini bahan plastik 1',
                      status: 'Waiting',
                      timestamp: 'February 26, 2025 at 6:00:18AM UTC+7',
                    ).toMap(),
                  );
          expect(
              instance.collection('request_bahan_baku').snapshots(),
              emits(QuerySnapshotMatcher([
                DocumentSnapshotMatcher(
                  stockRequest.id,
                  StockRequest(
                    namaBarang: "Bahan plastik 1",
                    jumlahBarang: "10",
                    unit: "Kg",
                    deskripsiBarang: "Ini bahan plastik 1",
                    status: "Waiting",
                    timestamp: "February 26, 2025 at 6:00:18AM UTC+7",
                  ).toMap(),
                )
              ])));
        },
      );
    },
  );

  // product
  group(
    'product',
    () {
      const expectedProductDumpAfterSet = '''{
  "barang_produksi": {
    "def": {
      "productId": "P001",
      "namaBarang": "Botol Tube 100ml",
      "jumlahBarang": "500",
      "deskripsiBarang": "Ini botol tube 100ml",
      "imageId": "301",
      "imageUrl": "https://301",
      "materialName": [
        "Polietilena Tereftalat"
      ],
      "materialQuantity": [
        "10"
      ],
      "materialUnit": [
        "Gram"
      ],
      "timestamp": "February 26, 2025 at 6:00:18AM UTC+7"
    }
  }
}''';

      const expectedProductDumpAfterDelete = '''{
  "barang_produksi": {}
}''';

      // retrieve product
      test(
        'retrieve product',
        () async {
          final instance = FakeFirebaseFirestore();
          await instance.collection('barang_produksi').doc(productUid).set(
                Product(
                  productId: 'P001',
                  namaBarang: 'Botol Tube 100ml',
                  jumlahBarang: '500',
                  deskripsiBarang: 'Ini botol tube 100ml',
                  imageId: '301',
                  imageUrl: 'https://301',
                  materialName: ['Polietilena Tereftalat'],
                  materialQuantity: ['10'],
                  materialUnit: ['Gram'],
                  timestamp: 'February 26, 2025 at 6:00:18AM UTC+7',
                ).toMap(),
              );
          expect(
              instance.collection('barang_produksi').snapshots(),
              emits(QuerySnapshotMatcher([
                DocumentSnapshotMatcher(
                  productUid,
                  Product(
                    productId: 'P001',
                    namaBarang: 'Botol Tube 100ml',
                    jumlahBarang: '500',
                    deskripsiBarang: 'Ini botol tube 100ml',
                    imageId: '301',
                    imageUrl: 'https://301',
                    materialName: ['Polietilena Tereftalat'],
                    materialQuantity: ['10'],
                    materialUnit: ['Gram'],
                    timestamp: 'February 26, 2025 at 6:00:18AM UTC+7',
                  ).toMap(),
                )
              ])));
        },
      );

      // add product
      test(
        'add product',
        () async {
          final instance = FakeFirebaseFirestore();
          await instance.collection('barang_produksi').doc(productUid).set(
                Product(
                  productId: 'P001',
                  namaBarang: 'Botol Tube 100ml',
                  jumlahBarang: '500',
                  deskripsiBarang: 'Ini botol tube 100ml',
                  imageId: '301',
                  imageUrl: 'https://301',
                  materialName: ['Polietilena Tereftalat'],
                  materialQuantity: ['10'],
                  materialUnit: ['Gram'],
                  timestamp: 'February 26, 2025 at 6:00:18AM UTC+7',
                ).toMap(),
              );
          expect(instance.dump(), equals(expectedProductDumpAfterSet));
        },
      );

      // update product
      test(
        'update product',
        () async {
          final instance = FakeFirebaseFirestore();
          final doc = instance.collection('barang_produksi').doc(productUid);
          await doc.set(
            Product(
              productId: 'P001',
              namaBarang: 'Botol Tube 100ml',
              jumlahBarang: '500',
              deskripsiBarang: 'Ini botol tube 100ml',
              imageId: '301',
              imageUrl: 'https://301',
              materialName: ['Polietilena Tereftalat'],
              materialQuantity: ['10'],
              materialUnit: ['Gram'],
              timestamp: 'February 26, 2025 at 6:00:18AM UTC+7',
            ).toMap(),
          );
          await doc.update(
            Product(
              productId: 'P001',
              namaBarang: 'Botol Tube 100ml',
              jumlahBarang: '900',
              deskripsiBarang: 'Ini botol tube 100ml',
              imageId: '301',
              imageUrl: 'https://301',
              materialName: ['Polietilena Tereftalat'],
              materialQuantity: ['10'],
              materialUnit: ['Gram'],
              timestamp: 'February 26, 2025 at 6:00:18AM UTC+7',
            ).toMap(),
          );
          expect((await doc.get()).get('jumlahBarang'), equals('900'));
        },
      );

      // delete product
      test(
        'delete product',
        () async {
          final instance = FakeFirebaseFirestore();
          final doc = instance.collection('barang_produksi').doc(productUid);
          await doc.set(
            Product(
              productId: 'P001',
              namaBarang: 'Botol Tube 100ml',
              jumlahBarang: '500',
              deskripsiBarang: 'Ini botol tube 100ml',
              imageId: '301',
              imageUrl: 'https://301',
              materialName: ['Polietilena Tereftalat'],
              materialQuantity: ['10'],
              materialUnit: ['Gram'],
              timestamp: 'February 26, 2025 at 6:00:18AM UTC+7',
            ).toMap(),
          );
          await doc.delete();
          expect(instance.dump(), equals(expectedProductDumpAfterDelete));
        },
      );
    },
  );

  // order
  group(
    'order',
    () {
      const expectedOrderDumpAfterDelete = '''{
  "pesanan": {}
}''';

      // retrieve order
      test(
        'retrieve order',
        () async {
          final instance = FakeFirebaseFirestore();
          final order = await instance.collection('pesanan').add(
                Order(
                  customerName: 'Mitra Cahaya Bulan 1',
                  deskripsi: 'Ini deskripsi dari mitra cahaya bulan',
                  orderItemName: ['Botol Tube 100ml', 'Botol Tube 500ml'],
                  orderItemQuantity: ['150', '350'],
                  orderLeftovers: '500',
                  status: 'Process',
                  timestamp: 'February 26, 2025 at 6:00:18AM UTC+7',
                ).toMap(),
              );
          expect(
              instance.collection('pesanan').snapshots(),
              emits(QuerySnapshotMatcher([
                DocumentSnapshotMatcher(
                  order.id,
                  Order(
                    customerName: 'Mitra Cahaya Bulan 1',
                    deskripsi: 'Ini deskripsi dari mitra cahaya bulan',
                    orderItemName: ['Botol Tube 100ml', 'Botol Tube 500ml'],
                    orderItemQuantity: ['150', '350'],
                    orderLeftovers: '500',
                    status: 'Process',
                    timestamp: 'February 26, 2025 at 6:00:18AM UTC+7',
                  ).toMap(),
                )
              ])));
        },
      );

      // add order
      test(
        'add order',
        () async {
          final instance = FakeFirebaseFirestore();
          final order = await instance.collection('pesanan').add(
                Order(
                  customerName: 'Mitra Cahaya Bulan 1',
                  deskripsi: 'Ini deskripsi dari mitra cahaya bulan',
                  orderItemName: ['Botol Tube 100ml', 'Botol Tube 500ml'],
                  orderItemQuantity: ['150', '350'],
                  orderLeftovers: '500',
                  status: 'Process',
                  timestamp: 'February 26, 2025 at 6:00:18AM UTC+7',
                ).toMap(),
              );
          expect(order.id.length, greaterThanOrEqualTo(20));
          expect(instance.dump(), equals('''{
  "pesanan": {
    "${order.id}": {
      "customerName": "Mitra Cahaya Bulan 1",
      "deskripsi": "Ini deskripsi dari mitra cahaya bulan",
      "orderItemName": [
        "Botol Tube 100ml",
        "Botol Tube 500ml"
      ],
      "orderItemQuantity": [
        "150",
        "350"
      ],
      "orderLeftovers": "500",
      "status": "Process",
      "timestamp": "February 26, 2025 at 6:00:18AM UTC+7"
    }
  }
}'''));
        },
      );

      // update order
      test(
        'update order',
        () async {
          final instance = FakeFirebaseFirestore();
          final order = await instance.collection('pesanan').add(
                Order(
                  customerName: 'Mitra Cahaya Bulan 1',
                  deskripsi: 'Ini deskripsi dari mitra cahaya bulan',
                  orderItemName: ['Botol Tube 100ml', 'Botol Tube 500ml'],
                  orderItemQuantity: ['150', '350'],
                  orderLeftovers: '500',
                  status: 'Process',
                  timestamp: 'February 26, 2025 at 6:00:18AM UTC+7',
                ).toMap(),
              );
          await instance.collection('pesanan').doc(order.id).update(
                Order(
                  customerName: 'Mitra Cahaya Bulan 1',
                  deskripsi: 'Ini deskripsi dari mitra cahaya bulan',
                  orderItemName: ['Botol Tube 100ml', 'Botol Tube 500ml'],
                  orderItemQuantity: ['150', '350'],
                  orderLeftovers: '500',
                  status: 'Done',
                  timestamp: 'February 26, 2025 at 6:00:18AM UTC+7',
                ).toMap(),
              );
          expect(
            (await instance.collection('pesanan').doc(order.id).get())
                .get('status'),
            equals('Done'),
          );
        },
      );

      // delete order
      test(
        'delete order',
        () async {
          final instance = FakeFirebaseFirestore();
          final order = await instance.collection('pesanan').add(
                Order(
                  customerName: 'Mitra Cahaya Bulan 1',
                  deskripsi: 'Ini deskripsi dari mitra cahaya bulan',
                  orderItemName: ['Botol Tube 100ml', 'Botol Tube 500ml'],
                  orderItemQuantity: ['150', '350'],
                  orderLeftovers: '500',
                  status: 'Process',
                  timestamp: 'February 26, 2025 at 6:00:18AM UTC+7',
                ).toMap(),
              );
          await instance.collection('pesanan').doc(order.id).delete();
          expect(instance.dump(), equals(expectedOrderDumpAfterDelete));
        },
      );

      // retrieve outstanding
      test(
        'retrieve outstanding',
        () async {
          final instance = FakeFirebaseFirestore();
          final order = await instance.collection('pesanan').add(
                Order(
                  customerName: 'Mitra Cahaya Bulan 1',
                  deskripsi: 'Ini deskripsi dari mitra cahaya bulan',
                  orderItemName: ['Botol Tube 100ml', 'Botol Tube 500ml'],
                  orderItemQuantity: ['150', '350'],
                  orderLeftovers: '500',
                  status: 'Process',
                  timestamp: 'February 26, 2025 at 6:00:18AM UTC+7',
                ).toMap(),
              );
          final outstanding = await instance
              .collection('pesanan')
              .doc(order.id)
              .collection('outstanding')
              .add(
                Outstanding(
                  product: 'Botol Tube 100ml',
                  jumlah: '100',
                  note: 'pengiriman batch 2',
                  timestamp: 'February 26, 2025 at 6:02:18AM UTC+7',
                ).toMap(),
              );
          expect(instance.dump(), equals('''{
  "pesanan": {
    "${order.id}": {
      "outstanding": {
        "${outstanding.id}": {
          "product": "Botol Tube 100ml",
          "jumlah": "100",
          "note": "pengiriman batch 2",
          "timestamp": "February 26, 2025 at 6:02:18AM UTC+7"
        }
      },
      "customerName": "Mitra Cahaya Bulan 1",
      "deskripsi": "Ini deskripsi dari mitra cahaya bulan",
      "orderItemName": [
        "Botol Tube 100ml",
        "Botol Tube 500ml"
      ],
      "orderItemQuantity": [
        "150",
        "350"
      ],
      "orderLeftovers": "500",
      "status": "Process",
      "timestamp": "February 26, 2025 at 6:00:18AM UTC+7"
    }
  }
}'''));
        },
      );
    },
  );

  // profile & notification
  group(
    'profile & notification',
    () {
      // save edit profile
      test(
        'save edit profile',
        () async {
          final instance = FakeFirebaseFirestore();
          final user = await instance.collection('Users').add(
                User(
                  name: 'Andi',
                  email: 'andi123@gmail.com',
                  imageId: '301',
                  imageUrl: 'https://301',
                  role: 'Staff',
                  notification: true,
                  stockAlertAmount: '2',
                  stockAlertUnit: 'Kg',
                ).toMap(),
              );
          await instance.collection('Users').doc(user.id).update(
                User(
                  name: 'Andi Firman',
                  email: 'andi123@gmail.com',
                  imageId: '301',
                  imageUrl: 'https://301',
                  role: 'Staff',
                  notification: true,
                  stockAlertAmount: '2',
                  stockAlertUnit: 'Kg',
                ).toMap(),
              );
          expect(
            (await instance.collection('Users').doc(user.id).get()).get('name'),
            equals('Andi Firman'),
          );
        },
      );

      // update notification state
      test(
        'update notification state',
        () async {
          final instance = FakeFirebaseFirestore();
          final user = await instance.collection('Users').add(
                User(
                  name: 'Andi',
                  email: 'andi123@gmail.com',
                  imageId: '301',
                  imageUrl: 'https://301',
                  role: 'Staff',
                  notification: true,
                  stockAlertAmount: '2',
                  stockAlertUnit: 'Kg',
                ).toMap(),
              );
          await instance.collection('Users').doc(user.id).update(
                User(
                  name: 'Andi',
                  email: 'andi123@gmail.com',
                  imageId: '301',
                  imageUrl: 'https://301',
                  role: 'Staff',
                  notification: false,
                  stockAlertAmount: '2',
                  stockAlertUnit: 'Kg',
                ).toMap(),
              );
          expect(
            (await instance.collection('Users').doc(user.id).get())
                .get('notification'),
            equals(false),
          );
        },
      );

      // save stock alert changes
      test(
        'save stock alert changes',
        () async {
          final instance = FakeFirebaseFirestore();
          final user = await instance.collection('Users').add(
                User(
                  name: 'Andi',
                  email: 'andi123@gmail.com',
                  imageId: '301',
                  imageUrl: 'https://301',
                  role: 'Staff',
                  notification: true,
                  stockAlertAmount: '2',
                  stockAlertUnit: 'Kg',
                ).toMap(),
              );
          await instance.collection('Users').doc(user.id).update(
                User(
                  name: 'Andi',
                  email: 'andi123@gmail.com',
                  imageId: '301',
                  imageUrl: 'https://301',
                  role: 'Staff',
                  notification: true,
                  stockAlertAmount: '500',
                  stockAlertUnit: 'Gram',
                ).toMap(),
              );
          expect(
            (await instance.collection('Users').doc(user.id).get())
                .get('stockAlertAmount'),
            equals('500'),
          );
          expect(
            (await instance.collection('Users').doc(user.id).get())
                .get('stockAlertUnit'),
            equals('Gram'),
          );
        },
      );
    },
  );
}
