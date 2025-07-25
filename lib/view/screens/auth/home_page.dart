import 'package:denemeye_devam/view/screens/auth/register_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart'; // AppFonts'u kullanmak için ekledik
import '../../view_models/auth_viewmodel.dart';
// Eski özel widget'lar artık kullanılmıyor.
// import '../../widgets/common/custom_card.dart';
// import '../../widgets/common/custom_text_field.dart';
// import '../../widgets/common/my_custom_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lütfen tüm alanları doldurun.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      await authViewModel.signIn(email, password);
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
    // 1. Scaffold'un arka plan rengi güncellendi
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Yeni tasarıma uygun logo
              Image.asset('assets/images/logo.png', height: 40),
              const SizedBox(height: 50),

              // Yeni tasarıma uygun başlık
              Text(
                'Seni yeniden görmek güzel',
                textAlign: TextAlign.start,
                style: AppFonts.poppinsBold(
                  // 2. Başlık rengi güncellendi
                  color: AppColors.textPrimary,
                  fontSize: 26,
                ),
              ),
              const SizedBox(height: 30),

              // Yeni tasarıma uygun TextField
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'E-posta',
                  labelStyle: AppFonts.bodyMedium(color: AppColors.textSecondary),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.borderColor),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primaryColor),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Yeni tasarıma uygun şifre alanı
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Şifre',
                  labelStyle: AppFonts.bodyMedium(color: AppColors.textSecondary),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.borderColor),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primaryColor),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () { /* TODO: Şifremi unuttum fonksiyonu */ },
                  child: Text(
                    'Şifremi unuttum',
                    // 3. TextButton rengi güncellendi
                    style: AppFonts.bodyMedium(color: AppColors.textButton),
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // Yeni tasarıma uygun buton
              ElevatedButton(
                onPressed: _signIn,
                style: ElevatedButton.styleFrom(
                  // 4. Buton renkleri güncellendi
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: AppColors.textOnPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Giriş yap', style: AppFonts.poppinsBold(fontSize: 16)),
              ),
              const SizedBox(height: 20),

              // Kayıt ol yönlendirmesi
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Hesabın yok mu?',
                    style: AppFonts.bodyMedium(color: AppColors.textSecondary),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const RegisterPage(),
                      ));
                    },
                    child: Text(
                      'Kayıt Ol',
                      // 5. Kayıt ol butonunun rengi güncellendi
                      style: AppFonts.poppinsBold(color: AppColors.textButton),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}