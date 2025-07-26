// lib/view/screens/auth/home_page.dart
import 'package:denemeye_devam/view/screens/auth/register_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../../view_models/auth_viewmodel.dart';
import '../root_screen.dart'; // RootScreen'i import ettik
import 'package:supabase_flutter/supabase_flutter.dart'; // AuthException için import ettik


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false; // Yükleme durumu için eklendi

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true; // Butona basıldığında yüklemeyi başlat
    });

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
      setState(() {
        _isLoading = false; // Hata durumunda yüklemeyi durdur
      });
      return;
    }

    try {
      await authViewModel.signIn(email, password);

      // BAŞARILI GİRİŞ SONRASI YÖNLENDİRME BURAYA EKLENDİ
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Giriş başarılı!'),
            backgroundColor: Colors.green,
          ),
        );
        // Kullanıcıyı RootScreen'e yönlendir ve önceki tüm rotaları temizle
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const RootScreen()),
              (route) => false,
        );
      }
    } on AuthException catch (e) { // Supabase'e özgü hata yakalama
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Giriş başarısız: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) { // Diğer genel hatalar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bilinmeyen bir hata oluştu.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // İşlem bittiğinde yüklemeyi durdur
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Image.asset('assets/logos/iris_primary_logo.png', height: 150),
              const SizedBox(height: 50),

              Text(
                'Seni yeniden görmek güzel!',
                textAlign: TextAlign.start,
                style: AppFonts.poppinsBold(
                  color: AppColors.textPrimary,
                  fontSize: 26,
                ),
              ),
              const SizedBox(height: 30),

              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: AppFonts.bodySmall(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'E-posta',
                  labelStyle: AppFonts.bodyMedium(color: AppColors.textSecondary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _passwordController,
                obscureText: true,
                style: AppFonts.bodySmall(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Şifre',
                  labelStyle: AppFonts.bodyMedium(color: AppColors.textSecondary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                ),
              ),
              const SizedBox(height: 15),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () { /* TODO: Şifremi unuttum fonksiyonu */ },
                  child: Text(
                    'Şifremi Unuttum',
                    style: AppFonts.bodyMedium(color: AppColors.textButton),
                  ),
                ),
              ),
              const SizedBox(height: 25),

              ElevatedButton(
                onPressed: _isLoading ? null : _signIn, // Yüklenirken butonu devre dışı bırak
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: AppColors.textOnPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                // --- DEĞİŞİKLİK BURADA ---
                    : Text(
                  'Giriş Yap',
                  style: AppFonts.poppinsBold(
                    fontSize: 16,
                    color: AppColors.textOnPrimary, // Rengi beyaz olarak belirttik
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'Veya şununla giriş yap',
                textAlign: TextAlign.center,
                style: AppFonts.bodyMedium(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),

              OutlinedButton(
                onPressed: () { /* TODO: Google ile giriş fonksiyonu */ },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.borderColor),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/logos/google_logo.png', height: 24),
                    const SizedBox(width: 10),
                    Text('Google', style: AppFonts.poppinsBold(fontSize: 16)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

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