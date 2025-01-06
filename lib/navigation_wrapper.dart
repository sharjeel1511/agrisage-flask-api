import 'package:flutter/material.dart';
import 'home_page.dart';
import 'history_page.dart';
import 'profile_page.dart';

class NavigationWrapper extends StatefulWidget {
  const NavigationWrapper({Key? key}) : super(key: key);

  @override
  State<NavigationWrapper> createState() => _NavigationWrapperState();
}

class _NavigationWrapperState extends State<NavigationWrapper> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const HistoryPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    print('Building NavigationWrapper');
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() => _selectedIndex = index);
          },
          height: 65,
          backgroundColor: Colors.white,
          elevation: 0,
          indicatorColor: const Color(0xFF2ECC71).withOpacity(0.1),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          animationDuration: const Duration(milliseconds: 500),
          destinations: [
            NavigationDestination(
              icon: Icon(
                Icons.home_outlined,
                color: _selectedIndex == 0
                    ? const Color(0xFF2ECC71)
                    : const Color(0xFF94A3B8),
              ),
              selectedIcon: const Icon(Icons.home, color: Color(0xFF2ECC71)),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.history_outlined,
                color: _selectedIndex == 1
                    ? const Color(0xFF2ECC71)
                    : const Color(0xFF94A3B8),
              ),
              selectedIcon: const Icon(Icons.history, color: Color(0xFF2ECC71)),
              label: 'History',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.person_outline,
                color: _selectedIndex == 2
                    ? const Color(0xFF2ECC71)
                    : const Color(0xFF94A3B8),
              ),
              selectedIcon: const Icon(Icons.person, color: Color(0xFF2ECC71)),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
