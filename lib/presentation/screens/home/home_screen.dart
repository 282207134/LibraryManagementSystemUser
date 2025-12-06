import 'package:flutter/material.dart';
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
  int _selectedIndex = 0;

  List<Widget> get _pages => [
    HomePage(onSearchTap: _switchToBooksPage),
    BooksPage(),
    BorrowsPage(),
    FavoritesPage(),
    ProfilePage(),
  ];

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
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: '图书浏览',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: '我的借阅',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: '我的收藏',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '个人中心',
          ),
        ],
      ),
    );
  }
}
