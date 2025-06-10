import 'dart:io';
import 'package:cahaya_mulya_abadi/error/server_exception.dart';
import 'package:cahaya_mulya_abadi/utils/constants.dart';
import 'package:cahaya_mulya_abadi/utils/generate_code.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class DatabaseService {
  // instane of firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // instance of supabase
  final _supabase = Supabase.instance.client;

  // upload image
  Future<String> uploadImage({
    required File image,
    required String itemId,
  }) async {
    try {
      await _supabase.storage.from(Constants.itemImagesStorage).upload(
            itemId,
            image,
          );

      return _supabase.storage
          .from(Constants.itemImagesStorage)
          .getPublicUrl(itemId);
    } on StorageException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // delete image
  Future<List<FileObject>> deleteImage({
    required String imageId,
  }) async {
    try {
      return await _supabase.storage
          .from(Constants.itemImagesStorage)
          .remove([imageId]);
    } on StorageException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // retrieve stock
  /* why we don't use the first function that return a list of map?
  because in our app we have update function. in order to edit data in
  firestore, we need to have access to "document id". the way to obtain that
  is through QuerySnapshot. that is the reason why we need QuerySnapshot as
  a return.*/
  /* Stream<List<Map<String, dynamic>>> getStock() {
    return _firestore
        .collection('bahan_baku')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  } */
  Stream<QuerySnapshot> getStock() {
    try {
      return _firestore
          .collection('bahan_baku')
          .orderBy('timestamp', descending: true)
          .snapshots();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // add stock
  Future<void> addStock(
    String name,
    String numberOfGoods,
    String unit,
    String description,
    File? image,
  ) async {
    final itemId = const Uuid().v1();

    // add stock
    try {
      String imageId = '';
      String imageUrl = '';

      // get current value, then create next material id
      final listOfStock = await getStock().first;
      int currentValue = getCurrentValue(listOfStock, 'materialId');
      String materialId = generateCode('M', currentValue);

      // upload image data
      if (image != null) {
        imageId = itemId;
        imageUrl = await uploadImage(image: image, itemId: itemId);
      }

      // stock data
      final stock = {
        'materialId': materialId,
        'namaBarang': name,
        'jumlahBarang': numberOfGoods,
        'unit': unit,
        'deskripsiBarang': description.isEmpty ? '' : description,
        'imageId': imageId,
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('bahan_baku').doc(itemId).set(stock);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // update stock
  Future<void> updateStock(
    String docId,
    String name,
    String numberOfGoods,
    String unit,
    String description,
    File? image,
    String imageId,
    String imageUrl,
  ) async {
    try {
      // image data
      final newUid = const Uuid().v1();
      String newImageId = '';
      String newImageUrl = '';

      if (image != null) {
        if (imageId.isNotEmpty) {
          await deleteImage(imageId: imageId);
        }

        newImageId = newUid;
        newImageUrl = await uploadImage(
          image: image,
          itemId: newUid,
        );
      } else {
        if (imageId.isNotEmpty || imageUrl.isNotEmpty) {
          newImageId = imageId;
          newImageUrl = imageUrl;
        }
      }

      // stock data
      final newStock = {
        'namaBarang': name,
        'jumlahBarang': numberOfGoods,
        'unit': unit,
        'deskripsiBarang': description.isEmpty ? '' : description,
        'imageId': newImageId,
        'imageUrl': newImageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('bahan_baku').doc(docId).update(newStock);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // edit quantity stock
  Future<void> editQuantityStock(
    String docId,
    String numberOfGoods,
  ) async {
    try {
      // stock data
      final newStock = {
        'jumlahBarang': numberOfGoods,
      };

      await _firestore.collection('bahan_baku').doc(docId).update(newStock);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // delete stock
  Future<void> deleteStock(
    String docId,
    String imageId,
  ) async {
    try {
      await deleteImage(imageId: imageId);
      return _firestore.collection('bahan_baku').doc(docId).delete();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // add stock request
  Future<void> addStockRequest(
    String name,
    String numberOfGoods,
    String unit,
    String description,
  ) async {
    try {
      final stock = {
        'namaBarang': name,
        'jumlahBarang': numberOfGoods,
        'unit': unit,
        'deskripsiBarang': description.isEmpty ? '' : description,
        'status': 'Waiting',
        'timestamp': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('request_bahan_baku').add(stock);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // delete stock request
  Future<void> deleteStockRequest(
    String docId,
  ) async {
    try {
      return _firestore.collection('request_bahan_baku').doc(docId).delete();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // give permission to stock request
  Future<void> givePermissionStockRequest(
    String docId,
    String status,
  ) async {
    try {
      // new stock request
      final newStockRequest = {
        'status': status,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('request_bahan_baku')
          .doc(docId)
          .update(newStockRequest);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // retrieve all stock request
  Stream<QuerySnapshot> getStockRequest() {
    try {
      return _firestore
          .collection('request_bahan_baku')
          .orderBy('timestamp', descending: true)
          .snapshots();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // retrieve detail stock request
  Stream<Map<String, dynamic>> getDetailStockRequest(String docId) {
    try {
      return _firestore
          .collection('request_bahan_baku')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .where((doc) => doc.id == docId)
            .map((doc) => doc.data())
            .single;
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // add stock report
  Future<void> addStockReport(
    String docId,
    String status,
    String amount,
    String totalAmount,
    String note,
  ) async {
    try {
      // stock data
      final stockReport = {
        'status': status,
        'jumlah': amount,
        'sisa': totalAmount,
        'note': note,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('bahan_baku')
          .doc(docId)
          .collection('laporan')
          .add(stockReport);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // retrieve product
  Stream<QuerySnapshot> getProduct() {
    try {
      return _firestore
          .collection('barang_produksi')
          .orderBy('timestamp', descending: true)
          .snapshots();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // retrieve detail product
  Stream<Map<String, dynamic>> getDetailProduct(String docId) {
    try {
      return _firestore
          .collection('barang_produksi')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .where((doc) => doc.id == docId)
            .map((doc) => doc.data())
            .single;
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // add product
  Future<void> addProduct(
    String name,
    String numberOfGoods,
    String description,
    File? image,
    List<String> item,
    List<String> itemQuantity,
    List<String> itemUnit,
  ) async {
    try {
      final itemId = const Uuid().v1();
      String imageId = '';
      String imageUrl = '';

      // get current value, then create next product id
      final listOfProduct = await getProduct().first;
      int currentValue = getCurrentValue(listOfProduct, 'productId');
      String productId = generateCode('P', currentValue);

      // upload image data
      if (image != null) {
        imageId = itemId;
        imageUrl = await uploadImage(image: image, itemId: itemId);
      }

      // product data
      final product = {
        'productId': productId,
        'namaBarang': name,
        'jumlahBarang': numberOfGoods,
        'deskripsiBarang': description.isEmpty ? '' : description,
        'imageId': imageId,
        'imageUrl': imageUrl,
        'materialName': item,
        'materialQuantity': itemQuantity,
        'materialUnit': itemUnit,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('barang_produksi').doc(itemId).set(product);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // update product
  Future<void> updateProduct(
    String docId,
    String name,
    String numberOfGoods,
    String description,
    File? image,
    String imageId,
    String imageUrl,
    List<String> item,
    List<String> itemQuantity,
    List<String> itemUnit,
  ) async {
    try {
      // image data
      final newUid = const Uuid().v1();
      String newImageId = '';
      String newImageUrl = '';

      if (image != null) {
        if (imageId.isNotEmpty) {
          await deleteImage(imageId: imageId);
        }

        newImageId = newUid;
        newImageUrl = await uploadImage(
          image: image,
          itemId: newUid,
        );
      } else {
        if (imageId.isNotEmpty || imageUrl.isNotEmpty) {
          newImageId = imageId;
          newImageUrl = imageUrl;
        }
      }

      // product data
      final newProduct = {
        'namaBarang': name,
        'jumlahBarang': numberOfGoods,
        'deskripsiBarang': description.isEmpty ? '' : description,
        'imageId': newImageId,
        'imageUrl': newImageUrl,
        'materialName': item,
        'materialQuantity': itemQuantity,
        'materialUnit': itemUnit,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('barang_produksi')
          .doc(docId)
          .update(newProduct);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // update product quantity
  Future<void> editProductQuantity(
    String docId,
    String numberOfGoods,
  ) async {
    try {
      // product data
      final newProduct = {
        'jumlahBarang': numberOfGoods,
      };

      await _firestore
          .collection('barang_produksi')
          .doc(docId)
          .update(newProduct);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // delete product
  Future<void> deleteProduct(
    String docId,
    String imageId,
  ) async {
    try {
      await deleteImage(imageId: imageId);
      return _firestore.collection('barang_produksi').doc(docId).delete();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // retrieve packaging
  Stream<QuerySnapshot> getPackaging() {
    try {
      return _firestore
          .collection('packaging')
          .orderBy('timestamp', descending: false)
          .snapshots();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // retrieve detail packaging
  Stream<Map<String, dynamic>> getDetailPackaging(String docId) {
    try {
      return _firestore.collection('packaging').snapshots().map((snapshot) {
        return snapshot.docs
            .where((doc) => doc.id == docId)
            .map((doc) => doc.data())
            .single;
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // finished packaging
  Future<void> finishedPackaging(
    String docId,
    String status,
  ) async {
    try {
      // new packaging status
      final newPackaging = {
        'status': status,
      };

      await _firestore.collection('packaging').doc(docId).update(newPackaging);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // add order
  Future<void> addOrder(
    String customerName,
    String address,
    String description,
    List<String> item,
    List<String> itemQuantity,
    String totalOrderQty,
  ) async {
    try {
      // get current value, then create next order id
      final listOfOrder = await getOrder().first;
      int currentValue = getCurrentValue(listOfOrder, 'orderId');
      String orderId = generateCode('O', currentValue);

      // order data
      final order = {
        'orderId': orderId,
        'customerName': customerName,
        'alamat': address.isEmpty ? '' : address,
        'deskripsi': description.isEmpty ? '' : description,
        'orderItemName': item,
        'orderItemQuantity': itemQuantity,
        'orderLeftovers': totalOrderQty,
        'status': 'Not Yet',
        'timestamp': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('pesanan').add(order);
    } catch (e) {
      ServerException(e.toString());
    }
  }

  // update order
  Future<void> updateOrder(
    String docId,
    String customerName,
    String address,
    String description,
    List<String> item,
    List<String> itemQuantity,
    String totalOrderQty,
  ) async {
    try {
      // new order data
      final newOrder = {
        'customerName': customerName,
        'alamat': address.isEmpty ? '' : address,
        'deskripsi': description.isEmpty ? '' : description,
        'orderItemName': item,
        'orderItemQuantity': itemQuantity,
        'orderLeftovers': totalOrderQty,
      };

      await _firestore.collection('pesanan').doc(docId).update(newOrder);
    } catch (e) {
      ServerException(e.toString());
    }
  }

  // delete order
  Future<void> deleteOrder(
    String docId,
  ) async {
    try {
      await _firestore.collection('pesanan').doc(docId).delete();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // retrieve all order
  Stream<QuerySnapshot> getOrder() {
    try {
      return _firestore
          .collection('pesanan')
          .orderBy('timestamp', descending: false)
          .snapshots();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // retrieve detail order
  Stream<Map<String, dynamic>> getDetailOrder(String docId) {
    try {
      return _firestore.collection('pesanan').snapshots().map((snapshot) {
        return snapshot.docs
            .where((doc) => doc.id == docId)
            .map((doc) => doc.data())
            .single;
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // retrieve outstanding
  Stream<QuerySnapshot> getOutstanding(String docId) {
    try {
      return _firestore
          .collection('pesanan')
          .doc(docId)
          .collection('outstanding')
          .orderBy('timestamp', descending: true)
          .snapshots();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // save edit profile
  Future<void> saveEditProfile(
    String docId,
    String name,
    File? image,
    String imageId,
    String imageUrl,
  ) async {
    // image data
    final newUid = const Uuid().v1();
    String newImageId = '';
    String newImageUrl = '';

    if (image != null) {
      if (imageId.isNotEmpty) {
        await deleteImage(imageId: imageId);
      }

      newImageId = newUid;
      newImageUrl = await uploadImage(
        image: image,
        itemId: newUid,
      );
    } else {
      if (imageId.isNotEmpty || imageUrl.isNotEmpty) {
        newImageId = imageId;
        newImageUrl = imageUrl;
      }
    }

    // new user data
    final newUser = {
      'name': name,
      'imageId': newImageId,
      'imageUrl': newImageUrl,
    };

    await _firestore.collection('Users').doc(docId).update(newUser);
  }

  // update notification state
  Future<void> updateNotification(
    String docId,
    bool isNotificationOn,
  ) async {
    // new user data
    final newUser = {
      'notification': isNotificationOn,
    };

    await _firestore.collection('Users').doc(docId).update(newUser);
  }

  // save stock alert changes
  Future<void> saveStockAlert(
    String docId,
    String stockAlertAmount,
    String stockAlertUnit,
  ) async {
    // new stock alert data
    final newStockAlert = {
      'stockAlertAmount': stockAlertAmount,
      'stockAlertUnit': stockAlertUnit,
    };

    await _firestore.collection('Users').doc(docId).update(newStockAlert);
  }
}
