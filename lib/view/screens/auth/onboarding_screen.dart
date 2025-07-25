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
                imagePath: 'assets/images/iris_login_img.jpg',
                logoPath: 'assets/logos/iris_white_logo.png',
                title: 'İris\'e Hoş Geldin! Güzellik ve bakım rutinin artık parmaklarının ucunda.',
              ),
              OnboardingPage(
                imagePath: 'assets/images/iris_login_img_2.jpg',
                logoPath: 'assets/logos/iris_white_logo.png',
                title: 'Anında Randevu Oluştur Telefon trafiğine takılmadan, sadece birkaç dokunuşla yerini anında ayırt.',
              ),
              OnboardingPage(
                imagePath: 'assets/images/iris_login_img_3.jpg',
                logoPath: 'assets/logos/iris_white_logo.png',
                title: 'Takvimini Sen Yönet Uzmanını seç, uygun tarih ve saati görüntüle, randevunu kolayca planla.',
              ),
              OnboardingPage(
                imagePath: 'assets/images/iris_login_img_4.jpg',
                logoPath: 'assets/logos/iris_white_logo.png',
                title: 'Tüm Hizmetler Elinin Altında Servislerimizi ve uzmanlarımızı keşfetmeye başlamak için şimdi giriş yap veya kayıt ol.',
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

  const OnboardingPage({
    super.key,
    required this.imagePath,
    required this.logoPath,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    // Tanımlı kenar boşlukları ve alan yükseklikleri
    final double logoTopOffset = 40.0;
    final double textLeftOffset = 40.0; // Metnin soldan boşluğu
    final double textRightOffset = 40.0; // Metnin sağdan boşluğu
    final double textBottomOffset = 80.0; // Metnin alttan boşluğu

    // Hedef/varsayılan boyutlar
    final double targetLogoHeight = 150.0; // Logonun hedef yüksekliği
    final double targetTitleFontSize = 32.0; // Başlık fontunun hedef boyutu
    final double fixedTextContainerHeight = 200.0; // Metin için sabit yükseklik sınırı
    final double minGapBetweenLogoAndText = 20.0; // Logo ve metin arasındaki minimum boşluk

    // Logo, sabit metin yüksekliği ve aralarındaki minimum boşluğun toplam hedef yüksekliği
    final double requiredTotalContentHeight = targetLogoHeight + fixedTextContainerHeight + minGapBetweenLogoAndText;

    // İçerik için mevcut dikey alan (Logo üst boşluğundan buton alanına kadar)
    final double availableContentVerticalSpace = screenHeight - logoTopOffset - textBottomOffset;

    double actualLogoHeight = targetLogoHeight;
    double actualTitleFontSize = targetTitleFontSize;

    // Eğer gerekli toplam içerik yüksekliği, mevcut alandan fazlaysa, boyutları küçült
    if (requiredTotalContentHeight > availableContentVerticalSpace) {
      final double scaleFactor = availableContentVerticalSpace / requiredTotalContentHeight;

      actualLogoHeight = targetLogoHeight * scaleFactor;
      actualTitleFontSize = targetTitleFontSize * scaleFactor;

      // Minimum boyutları garanti altına al
      actualLogoHeight = actualLogoHeight.clamp(30.0, targetLogoHeight); // Logo min 30px
      actualTitleFontSize = actualTitleFontSize.clamp(20.0, targetTitleFontSize); // Font min 20px
    }

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
            color: Colors.black.withValues(alpha: 0.4), // Doğru kullanım
          ),
        ),
        // Logo - Üst sol köşeye konumlandırıldı (Boyutu dinamik)
        Positioned(
          top: logoTopOffset, // Üstten boşluk
          left: 0.0, // Logonun sol kenarı 0'dan başlasın
          child: Image.asset(
            logoPath,
            height: actualLogoHeight, // Dinamik yükseklik
          ),
        ),
        // Başlık metni - Altta konumlandırıldı (Boyutu dinamik ve sabit yükseklikte)
        Positioned(
          left: textLeftOffset, // Metnin soldan boşluğu 40.0
          right: textRightOffset, // Metnin sağdan boşluğu 40.0
          bottom: textBottomOffset, // Alttan boşluk
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Metin solda hizalı
            children: [
              SizedBox(
                height: fixedTextContainerHeight, // Metin için sabit yükseklik sınırı
                child: Text(
                  title,
                  style: AppFonts.poppinsBold(fontSize: 24, color: AppColors.textOnPrimary), // Dinamik font boyutu
                  maxLines: 5, // En fazla satır sayısı
                  overflow: TextOverflow.ellipsis, // Taşma durumunda üç nokta
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}