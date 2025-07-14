import 'package:flutter/material.dart';
import 'package:denemeye_devam/features/common/widgets/my_button.dart';
import 'package:denemeye_devam/features/common/widgets/custom_text_field.dart';
import 'package:denemeye_devam/core/app_colors.dart';
import 'package:denemeye_devam/features/common/widgets/custom_card.dart';
import 'package:denemeye_devam/screens/root_screen.dart'; // <-- RootScreen'i buraya import ettik!
// import 'package:denemeye_devam/screens/dashboard_screen.dart'; // DashboardScreen import'ına artık burada ihtiyacımız yoktu, kaldırdık.


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _usernameFocusNode.addListener(() => setState(() {}));
    _passwordFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
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
                    controller: _usernameController,
                    focusNode: _usernameFocusNode,
                    labelText: 'Kullanıcı Adı',
                    hintText: 'Kullanıcı adınızı giriniz...',
                    prefixIcon: Icons.person,
                    isFocused: _usernameFocusNode.hasFocus,
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
                    onPressed: () {
                      // Kullanıcı adı ve şifre kontrolü burada yapılabilir
                      // Şimdilik direkt geçiş yapıyoruz.

                      debugPrint('Kullanıcı Adı: ${_usernameController.text}');
                      debugPrint('Şifre: ${_passwordController.text}');

                      // SnackBar gösterimi devam edebilir
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Giriş Denemesi: K.Adı: ${_usernameController.text}, Şifre: ${_passwordController.text}'),
                        ),
                      );

                      // DashboardScreen yerine RootScreen'a geçiş yapıyoruz!
                      // pushReplacement kullanarak, kullanıcının login sonrası geri tuşuyla geri dönmesini engelledik.
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RootScreen(), // <-- İşte burada RootScreen'e gidiyoruz!
                        ),
                      );
                    },
                    buttonText: 'Giriş Yap',
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