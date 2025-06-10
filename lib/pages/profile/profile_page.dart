import 'package:cahaya_mulya_abadi/pages/profile/edit_profile_page.dart';
import 'package:cahaya_mulya_abadi/pages/profile/stock_alert_page.dart';
import 'package:cahaya_mulya_abadi/themes/app_pallete.dart';
import 'package:cahaya_mulya_abadi/utils/constants.dart';
import 'package:cahaya_mulya_abadi/utils/show_snackbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../services/auth/auth_service.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  // auth service
  final authService = AuthService();

  // logout
  void logout(BuildContext context) async {
    await authService.signout();

    if (context.mounted) {
      showSnackbar(context, 'Logout Berhasil.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            child: StreamBuilder(
                stream: authService.getUserProfile(),
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

                  final userProfile = snapshot.data!;

                  // load complete
                  return Column(
                    children: [
                      // profile picture
                      SizedBox(
                        height: 105,
                        width: 105,
                        child: userProfile['imageUrl'].toString().isNotEmpty
                            ? ClipOval(
                                child: FadeInImage.assetNetwork(
                                  placeholder: 'assets/loading.gif',
                                  image: userProfile['imageUrl'],
                                  width: 105,
                                  height: 105,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : ClipOval(
                                child: Image.asset(
                                  'assets/profile-picture.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),

                      const SizedBox(height: 10),

                      // name
                      Text(
                        userProfile['name'].toString().isNotEmpty
                            ? userProfile['name']
                            : '...',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      // role
                      Text(
                        userProfile['role'],
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // edit profile
                      ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            EditProfilePage.route(
                              userProfile['uid'],
                              userProfile['imageId'],
                              userProfile['imageUrl'],
                              userProfile['name'],
                              userProfile['email'],
                            ),
                          );
                        },
                        title: const Text(
                          Constants.editProfile,
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        leading: const Icon(
                          Icons.person_outline_rounded,
                          color: Colors.black,
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.black,
                          size: 20,
                        ),
                        tileColor: Theme.of(context).colorScheme.tertiary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // stock alert
                      ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            StockAlertPage.route(
                              userProfile['uid'],
                              userProfile['stockAlertAmount'],
                              userProfile['stockAlertUnit'],
                            ),
                          );
                        },
                        title: const Text(
                          Constants.alertBahanBaku,
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        leading: const Icon(
                          CupertinoIcons.bell,
                          color: Colors.black,
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.black,
                          size: 20,
                        ),
                        tileColor: Theme.of(context).colorScheme.tertiary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // log out
                      ListTile(
                        onTap: () => logout(context),
                        title: const Text(
                          Constants.logOut,
                          style: TextStyle(
                            color: AppPallete.red,
                          ),
                        ),
                        leading: const Icon(
                          Icons.logout_outlined,
                          color: AppPallete.red,
                        ),
                        tileColor: Theme.of(context).colorScheme.tertiary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ],
                  );
                }),
          ),
        ),
      ),
    );
  }
}
