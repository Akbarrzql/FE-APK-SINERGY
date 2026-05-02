import 'package:flutter/material.dart';
import 'package:gabungyuk/feature/auth/login/login_screen.dart';

import '../../../../core/gen/assets.gen.dart';
import '../../../../core/gen/fonts.gen.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<_OnboardingItem> _items = [
    _OnboardingItem(
      assetPath: Assets.image.png.kolaborasiOnboarding.path,
      title: 'Kolaborasi',
      description:
      'Kerja sama antar individu atau kelompok\nuntuk mencapai tujuan bersama dengan\nsumber daya yang berbeda.',
    ),
    _OnboardingItem(
      assetPath: Assets.image.png.mentorOnboarding.path,
      title: 'Mentor',
      description:
      'Seseorang yang membimbing serta\nmembantu mereka mengembangkan\nketerampilan dan potensi.',
    ),
    _OnboardingItem(
      assetPath: Assets.image.png.rekomendasiOnboarding.path,
      title: 'Rekomendasi',
      description:
      'Suatu rekomendasi tertentu yang\nmenunjukkan dan menampilkan keahlian\nyang anda miliki.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentIndex < _items.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // TODO: Arahkan ke halaman berikutnya / login / home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen()
        ),
      );
    }
  }

  void _previousPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipToLast() {
    _pageController.animateToPage(
      _items.length - 1,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF2F80ED);
    const Color lightBlue = Color(0xFFA9CBFF);
    const Color textBlue = Color(0xFF8BB8FF);
    const Color titleColor = Color(0xFF111111);
    const Color backgroundColor = Color(0xFFF8F8F8);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _items.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        const SizedBox(height: 42),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 240,
                                child: Image.asset(
                                  item.assetPath,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: 42),
                              Text(
                                item.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: FontFamily.poppins,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: titleColor,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                item.description,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: FontFamily.poppins,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: textBlue,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 34),
              child: Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _buildLeftButton(
                        currentIndex: _currentIndex,
                        onSkip: _skipToLast,
                        onBack: _previousPage,
                      ),
                    ),
                  ),
                  _PageIndicator(
                    currentIndex: _currentIndex,
                    total: _items.length,
                    activeColor: primaryBlue,
                    inactiveColor: lightBlue,
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _nextPage,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(70, 32),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          _currentIndex == _items.length - 1
                              ? 'Selesai'
                              : 'Lanjut',
                          style: const TextStyle(
                            fontFamily: FontFamily.poppins,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: primaryBlue,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeftButton({
    required int currentIndex,
    required VoidCallback onSkip,
    required VoidCallback onBack,
  }) {
    const Color primaryBlue = Color(0xFF2F80ED);
    const Color disabledBlue = Color(0xFFA9CBFF);

    final bool isFirstPage = currentIndex == 0;

    return TextButton(
      onPressed: isFirstPage ? onSkip : onBack,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: const Size(70, 32),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        isFirstPage ? 'Skip' : 'Kembali',
        style: TextStyle(
          fontFamily: FontFamily.poppins,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isFirstPage ? disabledBlue : disabledBlue,
        ),
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  final int currentIndex;
  final int total;
  final Color activeColor;
  final Color inactiveColor;

  const _PageIndicator({
    required this.currentIndex,
    required this.total,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        total,
            (index) {
          final bool isActive = index == currentIndex;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 5),
            height: 14,
            width: 14,
            decoration: BoxDecoration(
              color: isActive ? activeColor : inactiveColor,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        },
      ),
    );
  }
}

class _OnboardingItem {
  final String assetPath;
  final String title;
  final String description;

  const _OnboardingItem({
    required this.assetPath,
    required this.title,
    required this.description,
  });
}