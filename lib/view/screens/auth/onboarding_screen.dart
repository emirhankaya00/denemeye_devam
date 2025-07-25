import 'package:flutter/material.dart';
import 'package:denemeye_devam/core/theme/app_colors.dart'; // Renkler için
import 'package:denemeye_devam/core/theme/app_fonts.dart';   // Fontlar için
import 'package:denemeye_devam/view/screens/auth/home_page.dart'; // Giriş sayfası için
import 'package:denemeye_devam/view/screens/auth/register_page.dart'; // Kayıt sayfası için

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Arka plan rengi
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            children: const [
              // Her bir tanıtım sayfası burada olacak
              OnboardingPage(
                imagePath: 'assets/images/iris_login_img.jpg', // Kendi görsellerinizle güncelleyin
                logoPath: 'assets/logos/iris_white_logo.png',         // Kendi logonuzla güncelleyin
                title: 'İris\'e Hoş Geldin!',
                description: 'Güzellik ve bakım rutinin artık parmaklarının ucunda.',
              ),
              OnboardingPage(
                imagePath: 'assets/images/iris_login_img_2.jpg',
                logoPath: 'assets/logos/iris_white_logo.png',
                title: 'Anında Randevu Oluştur',
                description: 'Telefon trafiğine takılmadan, sadece birkaç dokunuşla yerini anında ayırt.',
              ),
              OnboardingPage(
                imagePath: 'assets/images/iris_login_img_3.jpg',
                logoPath: 'assets/logos/iris_white_logo.png',
                title: 'Takvimini Sen Yönet',
                description: 'Uzmanını seç, uygun tarih ve saati görüntüle, randevunu kolayca planla.',
              ),
              OnboardingPage(
                imagePath: 'assets/images/onboarding_4.jpg',
                logoPath: 'assets/images/logo.png',
                title: 'Tüm Hizmetler Elinin Altında',
                description: 'Servislerimizi ve uzmanları keşfetmeye başlamak için şimdi giriş yap veya kayıt ol.',
              ),
            ],
          ),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Column(
              children: [
                // Sayfa indikatörleri
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) => buildDot(index, context)),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // Giriş Yap butonuna basıldığında HomePage'e yönlendir
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => const HomePage()),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textOnPrimary, // Beyaz metin
                          side: const BorderSide(color: AppColors.textOnPrimary), // Beyaz kenarlık
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          'Giriş Yap',
                          style: AppFonts.poppinsBold(fontSize: 16, color: AppColors.textOnPrimary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Kayıt Ol butonuna basıldığında RegisterPage'e yönlendir
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => const RegisterPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor, // Ana renk
                          foregroundColor: AppColors.textOnPrimary, // Beyaz metin
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          'Kayıt Ol',
                          style: AppFonts.poppinsBold(fontSize: 16, color: AppColors.textOnPrimary),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Sayfa indikatör noktalarını oluşturan helper metot
  Widget buildDot(int index, BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 5),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? AppColors.primaryColor : AppColors.textOnPrimary.withOpacity(0.5),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}

// Her bir tanıtım sayfası için özel widget
class OnboardingPage extends StatelessWidget {
  final String imagePath;
  final String logoPath;
  final String title;
  final String description;

  const OnboardingPage({
    super.key,
    required this.imagePath,
    required this.logoPath,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Arka Plan Resmi
        Positioned.fill(
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
          ),
        ),
        // Karartma efekti (Overlay)
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.4), // Resmin üzerine hafif karartma
          ),
        ),
        // İçerik (logo, başlık, açıklama)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 80.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end, // İçeriği alta hizala
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(logoPath, height: 40), // Logonuz
              const SizedBox(height: 20),
              Text(
                title,
                style: AppFonts.poppinsBold(fontSize: 32, color: AppColors.textOnPrimary), // Beyaz metin
              ),
              const SizedBox(height: 10),
              Text(
                description,
                style: AppFonts.bodyLarge(color: AppColors.textOnPrimary.withOpacity(0.8)), // Hafif şeffaf beyaz
              ),
              const SizedBox(height: 120), // Butonların yerini bırakmak için boşluk
            ],
          ),
        ),
      ],
    );
  }
}