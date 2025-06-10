import 'dart:async';
import 'package:cahaya_mulya_abadi/components/bottom_nav_bar.dart';
import 'package:cahaya_mulya_abadi/pages/dashboard/dashboard_page.dart';
import 'package:cahaya_mulya_abadi/pages/order/order_page.dart';
import 'package:cahaya_mulya_abadi/pages/packaging/packaging_page.dart';
import 'package:cahaya_mulya_abadi/pages/product/product_page.dart';
import 'package:cahaya_mulya_abadi/pages/profile/profile_page.dart';
import 'package:cahaya_mulya_abadi/pages/stock/stock_page.dart';
import 'package:cahaya_mulya_abadi/services/auth/auth_service.dart';
import 'package:cahaya_mulya_abadi/services/background/background_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  final String userRole;
  const HomePage({
    super.key,
    required this.userRole,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // auth & flutter background service
  final authService = AuthService();
  final service = FlutterBackgroundService();

  // this selected index is to control the bottom nav bar
  int _selectedIndex = 0;

  // pages
  List<Widget> _pages = [];

  // variables
  late StreamSubscription userSubscription;

  // this method will update our selected index when the user taps on the bottom
  // bar
  void navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // retrieve user profile
  void onRetrieveUserProfile(Map<String, dynamic> userProfile) {
    if (userProfile['notification']) {
      service.startService();
    } else {
      service.invoke('stopService');
    }
  }

  // initialize background service
  void initializeBackgroundService() async {
    // ask notification permission & initialize flutter_background_service
    await Permission.notification.isDenied.then(
      (value) {
        if (value) {
          Permission.notification.request();
        }
      },
    );
    await initializeService();
  }

  @override
  void initState() {
    super.initState();
    if (widget.userRole.contains('owner')) {
      _pages = [
        // dashboard page
        const DashboardPage(),

        // stock page
        StockPage(
          userRole: widget.userRole,
        ),

        // product page
        ProductPage(userRole: widget.userRole),

        // order page
        OrderPage(
          userRole: widget.userRole,
        ),

        // profile page
        ProfilePage(),
      ];
    } else {
      _pages = [
        // stock page
        StockPage(
          userRole: widget.userRole,
        ),

        // product page
        ProductPage(userRole: widget.userRole),

        // order page
        OrderPage(
          userRole: widget.userRole,
        ),

        // packaging page
        const PackagingPage(),

        // profile page
        ProfilePage(),
      ];
    }

    // retrieve user profile
    userSubscription =
        authService.getUserProfile().listen(onRetrieveUserProfile);

    // initialize background service
    initializeBackgroundService();
  }

  @override
  void dispose() {
    // dispose subscription to prevent memory leaks
    userSubscription.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavBar(
        userRole: widget.userRole,
        selectedIndex: _selectedIndex,
        onTabChange: (index) => navigateBottomBar(index),
      ),
      body: _pages[_selectedIndex],
    );
  }
}
