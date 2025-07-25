import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../view_models/auth_viewmodel.dart';
import '../../widgets/common/custom_card.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/my_custom_button.dart';
import 'home_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _surnameFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() => setState(() {}));
    _passwordFocusNode.addListener(() => setState(() {}));
    _nameFocusNode.addListener(() => setState(() {}));
    _surnameFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _nameFocusNode.dispose();
    _surnameFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submitRegisterForm() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();
    final surname = _surnameController.text.trim();

    if (email.isEmpty || password.isEmpty || name.isEmpty || surname.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tüm alanlar doldurulmalıdır.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    try {
      // --- DOĞRU YERİ ÇAĞIRIYORUZ ---
      await authViewModel.signUp(
        email: email,
        password: password,
        name: name,
        surname: surname,
      );
      // -----------------------------

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kayıt başarılı! Lütfen e-postanıza gönderilen doğrulama linkine tıklayın.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kayıt başarısız: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.backgroundColorLight,
              AppColors.backgroundColorDark,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: CustomCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Yeni Hesap Oluştur',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColorDark,
                    ),
                  ),
                  const SizedBox(height: 30),
                  CustomTextField(
                    controller: _nameController,
                    focusNode: _nameFocusNode,
                    labelText: 'Adınız',
                    hintText: 'Adınızı giriniz...',
                    prefixIcon: Icons.person_outline,
                    isFocused: _nameFocusNode.hasFocus,
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: _surnameController,
                    focusNode: _surnameFocusNode,
                    labelText: 'Soyadınız',
                    hintText: 'Soyadınızı giriniz...',
                    prefixIcon: Icons.person_outline,
                    isFocused: _surnameFocusNode.hasFocus,
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: _emailController,
                    focusNode: _emailFocusNode,
                    labelText: 'E-posta Adresi',
                    hintText: 'ornek@email.com',
                    prefixIcon: Icons.email,
                    isFocused: _emailFocusNode.hasFocus,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                    labelText: 'Şifre',
                    hintText: 'Güçlü bir şifre giriniz...',
                    prefixIcon: Icons.lock,
                    obscureText: true,
                    isFocused: _passwordFocusNode.hasFocus,
                  ),
                  const SizedBox(height: 30),
                  MyCustomButton(
                    onPressed: _submitRegisterForm,
                    buttonText: 'Kayıt Ol',
                  ),
                  const SizedBox(height: 15),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const HomePage()),
                      );
                    },
                    child: Text(
                      'Zaten bir hesabınız var mı? Giriş Yapın',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}