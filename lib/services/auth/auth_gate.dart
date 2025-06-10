import 'package:cahaya_mulya_abadi/pages/home/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../pages/auth/login_page.dart';
import 'auth_service.dart';

class AuthGate extends StatelessWidget {
  // auth service
  final authService = AuthService();

  AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, authSnapshot) {
          return StreamBuilder(
            stream: authService.getUserProfile(),
            builder: (context, roleSnapshot) {
              if (authSnapshot.hasData && roleSnapshot.hasData) {
                final data = roleSnapshot.data!;
                return HomePage(
                  userRole: data['role'].toString().toLowerCase(),
                );
              } else {
                return const LoginPage();
              }
            },
          );

          /* return FutureBuilder(
            future: authService.getUserRole3(),
            builder: (context, roleSnapshot) {
              if (authSnapshot.hasData && roleSnapshot.hasData) {
                final data = roleSnapshot.data!.data()!;
                developer.log(data['role'], name: 'MyTag');
                return const HomePage();
              } else {
                return LoginPage();
              }
            },
          ); */

          /* return StreamBuilder(
            stream: authService.getUserRole4(),
            builder: (context, roleSnapshot) {
              if (authSnapshot.hasData && roleSnapshot.hasData) {
                Map<String, dynamic> data =
                    roleSnapshot.data!.data() as Map<String, dynamic>;
                developer.log(data['role'], name: 'MyTag');
                return const HomePage();
              } else {
                return LoginPage();
              }
            },
          ); */

          /* if (authSnapshot.hasData) {
            return const HomePage();
          } else {
            return LoginPage();
          } */
        },
      ),
    );
  }
}
