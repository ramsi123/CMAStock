import 'package:cahaya_mulya_abadi/themes/app_pallete.dart';
import 'package:cahaya_mulya_abadi/utils/show_snackbar.dart';
import 'package:flutter/material.dart';
import '../../components/my_button.dart';
import '../../components/optional_textfield.dart';
import '../../services/auth/auth_service.dart';

class LoginPage extends StatefulWidget {
  static route() => MaterialPageRoute(builder: (context) => const LoginPage());
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // email and pw controllers
  final _emailController = TextEditingController();
  final _pwController = TextEditingController();

  // login method
  void login(BuildContext context) async {
    // auth service
    final authService = AuthService();

    // try login
    try {
      await authService.signInWithEmailPassword(
        _emailController.text,
        _pwController.text,
      );
    } catch (e) {
      if (context.mounted) {
        showSnackbar(context, e.toString());
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _pwController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // logo
                    ClipRRect(
                      child: Image.asset('assets/cma-stock-logo.png'),
                    ),

                    const SizedBox(height: 35),

                    // email textfield
                    OptionalTextfield(
                      controller: _emailController,
                      title: 'Email',
                      hintText: 'Masukkan Email Anda',
                      obscureText: false,
                    ),

                    const SizedBox(height: 10),

                    // password textfield
                    OptionalTextfield(
                      controller: _pwController,
                      title: 'Password',
                      hintText: 'Masukkan Password Anda',
                      obscureText: true,
                    ),

                    const SizedBox(height: 25),

                    // login button
                    MyButton(
                      onTap: () => login(context),
                      text: "Login",
                      backgroundColor: const [
                        AppPallete.peach,
                        AppPallete.pink,
                      ],
                    ),

                    const SizedBox(height: 25),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
