import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:library_management/data/services/book_service.dart';
import 'package:library_management/data/models/book_model.dart';
import 'package:library_management/utils/image_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BooksPage extends StatefulWidget {
  const BooksPage({Key? key}) : super(key: key);

  @override
  State<BooksPage> createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  final _bookService = BookService();
  List<Book> _books = [];
  bool _loading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  Map<String, String?> _coverImageUrls = {};

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBooks({String? search}) async {
    setState(() => _loading = true);
    try {
      final books = await _bookService.getBooks(
        page: 1,
        pageSize: 50,
        search: search,
      );
      setState(() {
        _books = books;
      });
      // 加载封面图片
      await _loadCoverImages(books);
    } catch (e) {
      print('加载图书失败: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadCoverImages(List<Book> books) async {
    final urls = <String, String?>{};
    for (final book in books) {
      if (book.coverImageUrl != null && !_coverImageUrls.containsKey(book.id)) {
        final resolvedUrl = await ImageHelper.resolveCoverImageUrl(book.coverImageUrl);
        urls[book.id] = resolvedUrl;
      }
    }
    setState(() {
      _coverImageUrls.addAll(urls);
    });
  }

  void _handleSearch(String query) {
    setState(() => _searchQuery = query);
    _loadBooks(search: query.isEmpty ? null : query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('图书浏览'),
        elevation: 0,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索书名或作者...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _handleSearch('');
                        },
                      )
                    : null,
              ),
              onSubmitted: _handleSearch,
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _books.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.book_outlined, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty ? '暂无图书' : '未找到相关图书',
                              style: TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _books.length,
                        itemBuilder: (context, index) {
                          return _buildBookListItem(_books[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookListItem(Book book) {
    final coverUrl = _coverImageUrls[book.id] ?? book.coverImageUrl;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: coverUrl != null
            ? CachedNetworkImage(
                imageUrl: coverUrl,
                width: 50,
                height: 70,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 50,
                  height: 70,
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 50,
                  height: 70,
                  color: Colors.grey[300],
                  child: const Icon(Icons.book),
                ),
              )
            : Container(
                width: 50,
                height: 70,
                color: Colors.grey[300],
                child: const Icon(Icons.book),
              ),
        title: Text(book.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(book.author),
            const SizedBox(height: 4),
            Row(
              children: [
                if (book.category != null)
                  Chip(
                    label: Text(
                      book.category!,
                      style: const TextStyle(fontSize: 10),
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: EdgeInsets.zero,
                  ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(
                    book.availableQuantity > 0 ? '可借' : '已借完',
                    style: const TextStyle(fontSize: 10, color: Colors.white),
                  ),
                  backgroundColor: book.availableQuantity > 0 ? Colors.green : Colors.red,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => context.push('/book/${book.id}'),
      ),
    );
  }
}
