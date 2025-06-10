import 'dart:async';
import 'dart:ui';
import 'package:cahaya_mulya_abadi/error/server_exception.dart';
import 'package:cahaya_mulya_abadi/firebase_options.dart';
import 'package:cahaya_mulya_abadi/services/auth/auth_service.dart';
import 'package:cahaya_mulya_abadi/services/notifications/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

class BackgroundService {
  // instane of firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // get stock
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
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    iosConfiguration: IosConfiguration(),
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: false,
      autoStart: false,
      autoStartOnBoot: false,
    ),
  );
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }
  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // print instantly for the first time
  // initialize firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // fetch stock data
  calculateStockData();
  service.invoke('update');

  // periodic fetch data
  Timer.periodic(
    const Duration(hours: 6),
    (timer) async {
      if (service is AndroidServiceInstance) {
        if (await service.isForegroundService()) {
          service.setForegroundNotificationInfo(
            title: 'Cahaya Mulya Abadi',
            content: 'Notification Content',
          );
        }
      }

      // fetch stock data
      calculateStockData();
      service.invoke('update');
    },
  );
}

// fetch then calculate stock data
void calculateStockData() async {
  // database & auth service
  final backgroundService = BackgroundService();
  final authService = AuthService();

  // variables
  double quantity = 0;

  // stock name and quantity (kg) list availability
  final List<String> stockName = [];
  final List<double> stockQuantity = [];

  // selected stock
  final List<String> selectedStock = [];

  // fetch user profile
  Map<String, dynamic> userProfile = await authService.getUserProfile().first;

  // fetch stock data
  QuerySnapshot stockData = await backgroundService.getStock().first;

  for (var data in stockData.docs) {
    // store stock name
    stockName.add(data['namaBarang']);

    // convert to kg first, then store stock quantity
    if (data['unit'].toString().toLowerCase().contains('gram')) {
      quantity = double.parse(data['jumlahBarang']) / 1000;
    } else {
      quantity = double.parse(data['jumlahBarang']);
    }
    stockQuantity.add(quantity);
  }

  // calculate stock data
  // check the amount that user input
  double tempStockAmount = 0;
  if (userProfile['stockAlertUnit'].toString().toLowerCase().contains('gram')) {
    tempStockAmount = double.parse(userProfile['stockAlertAmount']) / 1000;
  } else {
    tempStockAmount = double.parse(userProfile['stockAlertAmount']);
  }

  // store selected stock
  int index = 0;
  for (var stock in stockName) {
    if (stockQuantity[index] <= tempStockAmount) {
      selectedStock.add(stock);
    }

    index++;
  }

  // show notification
  if (selectedStock.isNotEmpty) {
    NotificationService().showNotification(
      title: 'Kehabisan Stok',
      body: selectedStock.length > 1
          ? 'Stok ${selectedStock[0]} dan +${selectedStock.length - 1} lainnya sisa sedikit'
          : 'Stok ${selectedStock[0]} sisa sedikit',
      inboxLines: selectedStock,
    );
  }
}
