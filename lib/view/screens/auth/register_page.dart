// lib/view/screens/auth/register_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  final TextEditingController _phoneController = TextEditingController();

  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

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
    if (!mounted) return;

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();
    final surname = _surnameController.text.trim();

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
            content: Text('Kayıt başarılı! Yönlendiriliyorsunuz...'),
            backgroundColor: Colors.green,
          ),
        );

        // Yönlendirme işlemi
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
                (route) => false,
          );
        });
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kayıt başarısız: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bir hata oluştu: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'E-posta gereklidir';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Geçerli bir e-posta adresi girin';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre gereklidir';
    }
    if (value.length < 6) {
      return 'Şifre en az 6 karakter olmalıdır';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ad gereklidir';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Telefon numarası gereklidir';
    }
    if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
      return 'Geçerli bir telefon numarası girin (10 haneli)';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Image.asset('assets/logos/iris_primary_logo.png', height: 150),
                const SizedBox(height: 50),

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

                _buildTextField(
                  controller: _nameController,
                  labelText: 'Ad',
                  validator: _validateName,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _surnameController,
                  labelText: 'Soyad',
                  validator: _validateName,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _emailController,
                  labelText: 'E-posta',
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _phoneController,
                  labelText: 'Telefon Numarası',
                  keyboardType: TextInputType.phone,
                  prefixText: '+90 ',
                  validator: _validatePhone,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _passwordController,
                  labelText: 'Şifre',
                  obscureText: true,
                  validator: _validatePassword,
                ),
                const SizedBox(height: 40),

                ElevatedButton(
                  onPressed: _isLoading ? null : _submitRegisterForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: AppColors.textOnPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : Text(
                    'Kayıt Ol',
                    style: AppFonts.poppinsBold(
                      fontSize: 16,
                    ).copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Zaten hesabın var mı?', style: AppFonts.bodyMedium(color: AppColors.textSecondary)),
                    TextButton(
                      onPressed: () {
                        // Login sayfasına yönlendirme
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => const HomePage()),
                        );
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
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? prefixText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: AppFonts.bodySmall(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: AppFonts.bodyMedium(color: AppColors.textSecondary),
        prefixText: prefixText,
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
        errorStyle: AppFonts.bodySmall(color: Colors.red),
      ),
      validator: validator,
    );
  }
}