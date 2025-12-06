import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:library_management/data/services/home_service.dart';
import 'package:library_management/data/models/book_model.dart';
import 'package:library_management/utils/image_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomePage extends StatefulWidget {
  final VoidCallback? onSearchTap;
  
  const HomePage({Key? key, this.onSearchTap}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _homeService = HomeService();
  List<Book> _recommendedBooks = [];
  List<Book> _popularBooks = [];
  List<Book> _newBooks = [];
  List<String> _categories = [];
  String? _selectedCategory;
  List<Book> _categoryBooks = [];
  bool _loading = true;
  final PageController _carouselController = PageController();
  Map<String, String?> _coverImageUrls = {};

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  @override
  void dispose() {
    _carouselController.dispose();
    super.dispose();
  }

  Future<void> _loadHomeData() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _homeService.getRecommendedBooks(limit: 8),
        _homeService.getPopularBooks(limit: 4),
        _homeService.getNewBooks(limit: 10),
        _homeService.getCategories(),
      ]);

      setState(() {
        _recommendedBooks = results[0] as List<Book>;
        _popularBooks = results[1] as List<Book>;
        _newBooks = results[2] as List<Book>;
        _categories = results[3] as List<String>;
      });

      // 加载所有封面图片URL
      await _loadCoverImages();

      // 自动选择第一个分类
      if (_categories.isNotEmpty) {
        _selectedCategory = _categories[0];
        await _loadCategoryBooks(_categories[0]);
      }
    } catch (e) {
      print('加载首页数据失败: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadCategoryBooks(String category) async {
    try {
      final books = await _homeService.getBooksByCategory(category, limit: 20);
      setState(() {
        _categoryBooks = books;
      });
      // 加载分类图书的封面
      await _loadCoverImagesForBooks(books);
    } catch (e) {
      print('加载分类图书失败: $e');
    }
  }

  Future<void> _loadCoverImages() async {
    final allBooks = [
      ..._recommendedBooks,
      ..._popularBooks,
      ..._newBooks,
    ];
    await _loadCoverImagesForBooks(allBooks);
  }

  Future<void> _loadCoverImagesForBooks(List<Book> books) async {
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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('图书馆'),
        elevation: 0,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 搜索栏
            Padding(
              padding: const EdgeInsets.all(16),
              child: GestureDetector(
                onTap: widget.onSearchTap,
                child: AbsorbPointer(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '搜索书名或作者...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                ),
              ),
            ),

            // 精选推荐轮播
            if (_recommendedBooks.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Text(
                      '⭐ 精选推荐',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: PageView.builder(
                  controller: _carouselController,
                  itemCount: _recommendedBooks.length,
                  itemBuilder: (context, index) {
                    final book = _recommendedBooks[index];
                    return _buildCarouselItem(book);
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],

            // 人气排行榜
            if (_popularBooks.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.local_fire_department, color: Colors.orange, size: 20),
                        SizedBox(width: 4),
                        Text(
                          '🔥 人气排行榜',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ..._popularBooks.asMap().entries.map((entry) {
                      final index = entry.key;
                      final book = entry.value;
                      return _buildRankingItem(book, index + 1);
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // 新上架
            if (_newBooks.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.book, color: Colors.green, size: 20),
                        SizedBox(width: 4),
                        Text(
                          '📚 新上架',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 280,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _newBooks.length,
                        itemBuilder: (context, index) {
                          return SizedBox(
                            width: 120,
                            child: _buildNewBookCard(_newBooks[index]),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // 分类浏览
            if (_categories.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📖 分类浏览',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _categories.map((category) {
                        final isSelected = category == _selectedCategory;
                        return FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = category;
                            });
                            _loadCategoryBooks(category);
                          },
                          selectedColor: Colors.blue,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        );
                      }).toList(),
                    ),
                    if (_selectedCategory != null && _categoryBooks.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        '$_selectedCategory 分类图书',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _categoryBooks.length,
                        itemBuilder: (context, index) {
                          return _buildBookListItem(_categoryBooks[index]);
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCarouselItem(Book book) {
    final coverUrl = _coverImageUrls[book.id] ?? book.coverImageUrl;
    return GestureDetector(
      onTap: () => context.push('/book/${book.id}'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: coverUrl != null
                  ? ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: coverUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[300],
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.book, size: 64),
                        ),
                      ),
                    )
                  : Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                        color: Colors.grey,
                      ),
                      child: const Icon(Icons.book, size: 64, color: Colors.white),
                    ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      book.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      book.author,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (book.category != null && book.category!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        book.category!,
                        style: TextStyle(
                          color: Colors.blue[600],
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankingItem(Book book, int rank) {
    return GestureDetector(
      onTap: () => context.push('/book/${book.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: rank <= 3 ? Colors.orange : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: TextStyle(
                    color: rank <= 3 ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    book.author,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewBookCard(Book book) {
    final coverUrl = _coverImageUrls[book.id] ?? book.coverImageUrl;
    return GestureDetector(
      onTap: () => context.push('/book/${book.id}'),
      child: Card(
        margin: const EdgeInsets.only(right: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: coverUrl != null
                  ? CachedNetworkImage(
                      imageUrl: coverUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.book),
                      ),
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.book, size: 48),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.author,
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookListItem(Book book) {
    final coverUrl = _coverImageUrls[book.id] ?? book.coverImageUrl;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
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
        subtitle: Text(book.author),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => context.push('/book/${book.id}'),
      ),
    );
  }
}
