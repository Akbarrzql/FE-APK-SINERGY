import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gabungyuk/core/common/color_value.dart';

class BottomNavigation extends StatefulWidget {
  final int currentIndex;

  const BottomNavigation({Key? key, this.currentIndex = 0}) : super(key: key);

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _currentIndex = 0;
  final List _pageStack = [];

  final _tabs = [
    // const HomePage(),
    // const TransactionPage(),
    // const BudgetPage(),
    // const ProfilePage(),
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
    // TODO: implement initState
    super.initState();
    _currentIndex = widget.currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return WillPopScope(
      onWillPop: () => _pagePop(context),
      child: Scaffold(
        body: _tabs[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: SvgPicture.asset('assets/icons/home.svg'),
              activeIcon: SvgPicture.asset(
                'assets/icons/home_active.svg',
                color: ColorValue.secondaryColor,
              ),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset('assets/icons/transaction.svg'),
              activeIcon: SvgPicture.asset(
                'assets/icons/transaction_active.svg',
                color: ColorValue.secondaryColor,
              ),
              label: 'Transaksi',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset('assets/icons/budget.svg'),
              activeIcon: SvgPicture.asset(
                'assets/icons/budget_active.svg',
                color: ColorValue.secondaryColor,
              ),
              label: 'Anggaran',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset('assets/icons/profile.svg'),
              activeIcon: SvgPicture.asset(
                'assets/icons/profile_active.svg',
                color: ColorValue.secondaryColor,
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