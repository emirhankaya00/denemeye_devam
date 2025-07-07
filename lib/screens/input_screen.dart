import 'package:flutter/material.dart';
import 'package:denemeye_devam/app_colors.dart'; // Renkler için AppColors kullanıyorsan
import '../widgets/custom_text_field.dart'; // Yeni oluşturacağımız CustomTextField'ı import et

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // TextField'ların focus durumlarını takip etmek için FocusNode'lar
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Focus değiştiğinde rebuild etmemiz için listener ekleyelim
    _nameFocusNode.addListener(() => setState(() {}));
    _emailFocusNode.addListener(() => setState(() {}));
    _passwordFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giriş Alanları Sayfası'),
        backgroundColor: AppColors.primaryColor, // Başlık çubuğu rengi
        foregroundColor: Colors.white, // Başlık yazısı rengi
      ),
      body: Container(
        // Arka plan gradient veya düz renk olarak ayarlanabilir
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.backgroundColorLight, // Senin arka plan renklerin
              AppColors.backgroundColorDark,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView( // Klavye açıldığında taşmayı önlemek için
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 15, // Hafif bir gölge efekti
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20), // Köşeleri daha oval yap
              ),
              color: AppColors.cardColor, // Kart rengi, saydamlık verebiliriz
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // İçeriğe göre boyutlan
                  children: [
                    Text(
                      'Hoş Geldiniz!',
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
                      labelText: 'Adınız Soyadınız',
                      hintText: 'Tam adınızı giriniz...',
                      prefixIcon: Icons.person,
                      isFocused: _nameFocusNode.hasFocus, // Focus bilgisini gönderiyoruz
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      labelText: 'E-posta Adresiniz',
                      hintText: 'ornek@email.com',
                      prefixIcon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      isFocused: _emailFocusNode.hasFocus,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _passwordController,
                      focusNode: _passwordFocusNode,
                      labelText: 'Şifreniz',
                      hintText: 'Güçlü bir şifre giriniz...',
                      prefixIcon: Icons.lock,
                      obscureText: true, // Şifreyi gizle
                      isFocused: _passwordFocusNode.hasFocus,
                    ),
                    const SizedBox(height: 30),
                    // Burada CustomButton'ını kullanabilirsin, eğer istersen
                    ElevatedButton(
                      onPressed: () {
                        // Giriş işlemi burada yapılacak
                        print('Ad: ${_nameController.text}');
                        print('Email: ${_emailController.text}');
                        print('Şifre: ${_passwordController.text}');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Giriş Denemesi Yapıldı!')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 8,
                      ),
                      child: const Text(
                        'Giriş Yap',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
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