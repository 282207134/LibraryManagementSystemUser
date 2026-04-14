import 'package:flutter/material.dart';
import 'package:library_management/data/services/auth_service.dart';
import 'package:library_management/localization/app_localization.dart';
import 'package:library_management/presentation/screens/home/pages/admin_page.dart';
import 'package:library_management/presentation/screens/home/pages/books_page.dart';
import 'package:library_management/presentation/screens/home/pages/borrows_page.dart';
import 'package:library_management/presentation/screens/home/pages/home_page.dart';
import 'package:library_management/presentation/screens/home/pages/favorites_page.dart';
import 'package:library_management/presentation/screens/home/pages/profile_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  int _selectedIndex = 0;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    try {
      final profile = await _authService.getUserProfile();
      if (!mounted) return;
      setState(() {
        _isAdmin = (profile?['role'] as String?) == 'admin';
      });
    } catch (_) {}
  }

  List<Widget> get _pages {
    final pages = <Widget>[
      HomePage(onSearchTap: _switchToBooksPage),
      BooksPage(),
      BorrowsPage(),
      FavoritesPage(),
    ];

    if (_isAdmin) {
      pages.add(const AdminPage());
    }

    pages.add(const ProfilePage());
    return pages;
  }

  List<BottomNavigationBarItem> get _items {
    final items = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: '',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.library_books),
        label: '',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.bookmark),
        label: '',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.favorite),
        label: '',
      ),
    ];

    if (_isAdmin) {
      items.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.admin_panel_settings),
          label: '',
        ),
      );
    }

    items.add(
      const BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: '',
      ),
    );

    return items;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _switchToBooksPage() {
    setState(() {
      _selectedIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final labels = [
      AppLocalization.tr('nav_home'),
      AppLocalization.tr('nav_books'),
      AppLocalization.tr('nav_borrows'),
      AppLocalization.tr('nav_favorites'),
      if (_isAdmin) AppLocalization.tr('nav_admin'),
      AppLocalization.tr('nav_profile'),
    ];

    final items = _items
        .asMap()
        .entries
        .map(
          (entry) => BottomNavigationBarItem(
            icon: entry.value.icon,
            activeIcon: entry.value.activeIcon,
            label: labels[entry.key],
            tooltip: labels[entry.key],
            backgroundColor: entry.value.backgroundColor,
          ),
        )
        .toList();

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: items,
      ),
    );
  }
}
