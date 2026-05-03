import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/services.dart';
import 'package:gabungyuk/core/common/color_value.dart';
import 'package:gabungyuk/core/common/shared_code.dart';
import 'package:gabungyuk/feature/home/home_screen.dart';
import 'package:gabungyuk/feature/auth/login/login_screen.dart';
import 'package:gabungyuk/feature/profile/presentation/screens/profile_screen.dart';

import '../../feature/task/task_screen.dart';
import '../gen/assets.gen.dart';

class BottomNavigation extends StatefulWidget {
  final int currentIndex;

  const BottomNavigation({Key? key, this.currentIndex = 0}) : super(key: key);

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation>
    with WidgetsBindingObserver {
  int _currentIndex = 0;
  final List _pageStack = [];
  final SharedCode _sharedCode = SharedCode();

  final _tabs = [
    const HomeScreen(),
    const TeskScreen(),
    const ProfileScreen(),
  ];

  void _pagePush(int i) {
    if (_pageStack.isEmpty) {
      _pageStack.add(_currentIndex);
    }
    if (i == _currentIndex) {
      return;
    }
    if (!_pageStack.contains(_currentIndex)) {
      _pageStack.add(_currentIndex);
    }

    setState(() {
      _currentIndex = i;
    });
  }

  Future<void> _checkExpiredSession() async {
    final isExpired = await _sharedCode.isAuthSessionExpired();
    if (!mounted || !isExpired) {
      return;
    }

    await _sharedCode.clearAuthSession();
    if (!mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<bool> _pagePop(BuildContext context) {
    if (_pageStack.isEmpty) {
      return Future<bool>.value(true);
    } else {
      int t = _pageStack.removeLast();
      setState(() {
        _currentIndex = (_currentIndex != t) ? t : _pageStack.removeLast();
      });
      return Future<bool>.value(false);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentIndex = widget.currentIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkExpiredSession();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkExpiredSession();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }

        final shouldExit = await _pagePop(context);
        if (shouldExit) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: _tabs[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: SvgPicture.asset(Assets.image.svg.homeTask.path),
              activeIcon: SvgPicture.asset(
                Assets.image.svg.homeTask.path,
                colorFilter: const ColorFilter.mode(
                  ColorValue.primaryColor,
                  BlendMode.srcIn,
                ),
              ),
              label: 'Kolaborasi',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(Assets.image.svg.taskIcon.path),
              activeIcon: SvgPicture.asset(
                Assets.image.svg.taskIcon.path,
                colorFilter: const ColorFilter.mode(
                  ColorValue.primaryColor,
                  BlendMode.srcIn,
                ),
              ),
              label: 'Tugas',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(Assets.image.svg.profileIcon.path),
              activeIcon: SvgPicture.asset(
                Assets.image.svg.profileIcon.path,
                colorFilter: const ColorFilter.mode(
                  ColorValue.primaryColor,
                  BlendMode.srcIn,
                ),
              ),
              label: 'Profil',
            ),
          ],
          currentIndex: _currentIndex,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: ColorValue.primaryColor,
          unselectedItemColor: ColorValue.greyColor,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          selectedLabelStyle: textTheme.bodyMedium,
          unselectedLabelStyle: textTheme.bodyMedium,
          showUnselectedLabels: true,
          showSelectedLabels: true,
          elevation: 5,
          onTap: (index) {
            _pagePush(index);
          },
        ),
      ),
    );
  }
}