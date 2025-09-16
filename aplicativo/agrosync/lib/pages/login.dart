import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:agrosync/features/shared/widgets/CustomButton.dart';
import 'package:agrosync/features/shared/widgets/CustomTextField.dart';
import 'home_page.dart';
import 'package:agrosync/features/users/apresentation/signup.dart';
import 'package:agrosync/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:agrosync/models/toast.dart';
import 'package:agrosync/core/services/translation_service.dart';
import 'package:agrosync/core/services/guest_auth_service.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isSigning = false;
  bool _showPassword = false; // Adicione esta linha
  final FirebaseAuthService _auth = FirebaseAuthService();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() async {
    setState(() {
      _isSigning = true;
    });

    String email = _emailController.text;
    String password = _passwordController.text;

    User? user = await _auth.signInWithEmailAndPassword(email, password);

    setState(() {
      _isSigning = false;
    });

    if (user != null) {
      showToast(message: TranslationService.t('LOGIN_SUCCESS'));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
    } else {
      showToast(message: TranslationService.t('LOGIN_ERROR'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Permite que o conteúdo suba com o teclado
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              _buildLogo(),
              const SizedBox(height: 20),
              const SizedBox(height: 0),
              CustomTextField(controller: _emailController, label: TranslationService.t('EMAIL'), obscureText: false),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _passwordController,
                label: TranslationService.t('PASSWORD'),
                obscureText: !_showPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _showPassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _showPassword = !_showPassword;
                    });
                  },
                ),
              ),
              const SizedBox(height: 40),
              CustomButton(label: TranslationService.t('LOGIN'), onPressed: () => _signIn(), primary: true),
              const SizedBox(height: 20),
              CustomButton(label: TranslationService.t('SIGN_UP'), onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpScreen()));
              }),
              const SizedBox(height: 20),
              CustomButton(label: TranslationService.t('CONTINUE_AS_GUEST'), onPressed: () async {
                setState(() { _isSigning = true; });
                try {
                  // Offline-capable guest: no network calls
                  await Future.delayed(const Duration(milliseconds: 50));
                  // Persist guest flag so the app can work without internet
                  await GuestAuthService.signInAsGuest();
                  if (mounted) {
                    showToast(message: TranslationService.t('GUEST_SUCCESS'));
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
                  }
                } catch (e) {
                  showToast(message: TranslationService.t('GUEST_ERROR'));
                } finally {
                  if (mounted) setState(() { _isSigning = false; });
                }
              }, primary: false),
              const SizedBox(height: 20),
              _buildSponsors(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
  return SizedBox(
    height: 300,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Image.asset(
          'assets/images/agro_sync_verde.png',
          height: 300, 
          fit: BoxFit.contain,
        ),
      ],
    ),
  );
}

  Widget _buildSponsors() {
  return SizedBox(
    height: 100,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Image.asset(
          'assets/images/embrapa.png',
          height: 50, 
          fit: BoxFit.contain,
        ),
        Image.asset(
          'assets/images/univali.png',
          height: 50, 
          fit: BoxFit.contain,
        ),
        Image.asset(
          'assets/images/fapesc.png',
          height: 50, 
          fit: BoxFit.contain,
        ),
        Image.asset(
          'assets/images/cnpq.png',
          height: 50, 
          fit: BoxFit.contain,
        ),
      ],
    ),
  );
}

}
