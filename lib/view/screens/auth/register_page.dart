import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../../view_models/auth_viewmodel.dart';
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
  // Tasarıma uygun olarak telefon numarası alanı da ekleyelim.
  final TextEditingController _phoneController = TextEditingController();


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submitRegisterForm() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();
    final surname = _surnameController.text.trim();
    final phone = _phoneController.text.trim();


    if (email.isEmpty || password.isEmpty || name.isEmpty || surname.isEmpty || phone.isEmpty) {
      if(mounted) {
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
      await authViewModel.signUp(
        email: email,
        password: password,
        name: name,
        surname: surname,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kayıt başarılı! Giriş yapabilirsiniz.'),
            backgroundColor: Colors.green,
          ),
        );
        // Kullanıcıyı doğrudan giriş sayfasına yönlendir.
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomePage()),
              (route) => false,
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
    // 1. Scaffold arka plan rengi güncellendi.
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Yeni tasarıma uygun logo
              Image.asset('assets/images/logo.png', height: 40),
              const SizedBox(height: 50),

              // Başlıklar güncellendi
              Text(
                'Kayıt Ol',
                style: AppFonts.poppinsBold(fontSize: 26, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'Sana özel fırsatları ve randevu takibini kolaylaştırmak için hemen kayıt ol.',
                style: AppFonts.bodyMedium(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 30),

              // TextField'lar yeni tasarıma uyarlandı
              _buildTextField(controller: _nameController, labelText: 'Ad'),
              const SizedBox(height: 20),
              _buildTextField(controller: _surnameController, labelText: 'Soyad'),
              const SizedBox(height: 20),
              _buildTextField(controller: _emailController, labelText: 'E-posta', keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 20),
              _buildTextField(controller: _phoneController, labelText: 'Telefon Numarası', keyboardType: TextInputType.phone),
              const SizedBox(height: 20),
              _buildTextField(controller: _passwordController, labelText: 'Şifre', obscureText: true),
              const SizedBox(height: 40),

              // Buton yeni tasarıma uyarlandı
              ElevatedButton(
                onPressed: _submitRegisterForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: AppColors.textOnPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Kayıt Ol', style: AppFonts.poppinsBold(fontSize: 16)),
              ),
              const SizedBox(height: 20),

              // Giriş yap yönlendirmesi güncellendi
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Zaten hesabın var mı?', style: AppFonts.bodyMedium(color: AppColors.textSecondary)),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Bir önceki sayfaya (giriş) dön
                    },
                    child: Text(
                      'Giriş Yap',
                      style: AppFonts.poppinsBold(color: AppColors.textButton),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // Standartlaşmış TextField oluşturucu
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: AppFonts.bodyMedium(color: AppColors.textSecondary),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.borderColor),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primaryColor),
        ),
      ),
    );
  }
}