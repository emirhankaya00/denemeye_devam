import 'package:denemeye_devam/features/auth/screens/register_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:denemeye_devam/features/common/widgets/my_button.dart';
import 'package:denemeye_devam/features/common/widgets/custom_text_field.dart';
import 'package:denemeye_devam/core/app_colors.dart';
import 'package:denemeye_devam/features/common/widgets/custom_card.dart';
import 'package:denemeye_devam/viewmodels/auth_viewmodel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Controller'ların adını e-posta ile uyumlu hale getirelim
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() => setState(() {}));
    _passwordFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  // Giriş yapma mantığını ayrı bir fonksiyona taşıdık
  Future<void> _signIn() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Hata yönetimi için try-catch bloğu
    try {
      await authViewModel.signIn(email, password);
      // Başarılı giriş sonrası RootScreen zaten yönlendirmeyi yapacak.
      // Burada manuel yönlendirmeye gerek yok.
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Giriş başarısız: ${e.toString()}'),
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
                    'Hesabınıza Giriş Yapın',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColorDark,
                    ),
                  ),
                  const SizedBox(height: 30),
                  CustomTextField(
                    // Controller'ı email controller ile değiştirdik
                    controller: _emailController,
                    focusNode: _emailFocusNode,
                    // Label'ı E-posta olarak güncelledik
                    labelText: 'E-posta',
                    hintText: 'E-posta adresinizi giriniz...',
                    prefixIcon: Icons.email_outlined,
                    isFocused: _emailFocusNode.hasFocus,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                    labelText: 'Şifre',
                    hintText: 'Şifrenizi giriniz...',
                    prefixIcon: Icons.lock,
                    obscureText: true,
                    isFocused: _passwordFocusNode.hasFocus,
                  ),
                  const SizedBox(height: 30),
                  MyCustomButton(
                    // onPressed artık _signIn fonksiyonunu çağırıyor
                    onPressed: _signIn,
                    buttonText: 'Giriş Yap',
                  ),
                  const SizedBox(height: 20),

                  // Yönlendirme yapan kısım
                  TextButton(
                    onPressed: () {
                      // RegisterPage'e yönlendiriyoruz.
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const RegisterPage(),
                        ),
                      );
                    },
                    child: Text(
                      'Hesabınız yok mu? Kayıt Olun',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}