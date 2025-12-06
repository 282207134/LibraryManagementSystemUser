import 'package:flutter/material.dart';
import 'package:library_management/data/services/book_service.dart';
import 'package:library_management/data/services/auth_service.dart';
import 'package:library_management/data/models/book_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:library_management/config/app_config.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final _bookService = BookService();
  final _authService = AuthService();
  List<Book> _favoriteBooks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _loading = true);
    try {
      final user = _authService.currentUser;
      if (user == null) {
        setState(() {
          _favoriteBooks = [];
          _loading = false;
        });
        return;
      }

      // 获取收藏的图书ID
      final response = await AppConfig.supabase
          .from('book_favorites')
          .select('book_id')
          .eq('user_id', user.id);

      if (response.isEmpty) {
        setState(() {
          _favoriteBooks = [];
          _loading = false;
        });
        return;
      }

      final bookIds = (response as List)
          .map((item) => item['book_id'] as String)
          .toList();

      // 获取图书详情
      final books = <Book>[];
      for (final bookId in bookIds) {
        final book = await _bookService.getBookById(bookId);
        if (book != null) {
          books.add(book);
        }
      }

      setState(() {
        _favoriteBooks = books;
        _loading = false;
      });
    } catch (e) {
      print('加载收藏失败: $e');
      setState(() {
        _favoriteBooks = [];
        _loading = false;
      });
    }
  }

  Future<void> _removeFavorite(String bookId) async {
    try {
      final user = _authService.currentUser;
      if (user == null) return;

      await AppConfig.supabase
          .from('book_favorites')
          .delete()
          .eq('user_id', user.id)
          .eq('book_id', bookId);

      _loadFavorites();
    } catch (e) {
      print('取消收藏失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的收藏'),
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _favoriteBooks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        '暂无收藏',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _favoriteBooks.length,
                  itemBuilder: (context, index) {
                    final book = _favoriteBooks[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: book.coverImageUrl != null
                            ? Image.network(
                                book.coverImageUrl!,
                                width: 50,
                                height: 70,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 50,
                                    height: 70,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.book),
                                  );
                                },
                              )
                            : Container(
                                width: 50,
                                height: 70,
                                color: Colors.grey[300],
                                child: const Icon(Icons.book),
                              ),
                        title: Text(book.title),
                        subtitle: Text(book.author),
                        trailing: IconButton(
                          icon: const Icon(Icons.favorite, color: Colors.red),
                          onPressed: () => _removeFavorite(book.id),
                        ),
                        onTap: () {
                          // TODO: 导航到图书详情页
                        },
                      ),
                    );
                  },
                ),
    );
  }
}

