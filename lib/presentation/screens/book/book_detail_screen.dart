import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:library_management/data/services/book_service.dart';
import 'package:library_management/data/services/borrowing_service.dart';
import 'package:library_management/data/services/auth_service.dart';
import 'package:library_management/data/services/review_service.dart';
import 'package:library_management/data/models/book_model.dart';
import 'package:library_management/data/models/review_model.dart';
import 'package:library_management/utils/image_helper.dart';
import 'package:library_management/presentation/widgets/star_rating.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:library_management/config/app_config.dart';

class BookDetailScreen extends StatefulWidget {
  final String bookId;
  
  const BookDetailScreen({Key? key, required this.bookId}) : super(key: key);

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  final _bookService = BookService();
  final _borrowingService = BorrowingService();
  final _authService = AuthService();
  final _reviewService = ReviewService();
  
  Book? _book;
  bool _loading = true;
  String? _error;
  String? _coverImageUrl;
  bool _isBorrowed = false;
  bool _isFavorite = false;
  bool _borrowing = false;

  // 评论相关状态
  List<Review> _reviews = [];
  Review? _userReview;
  BookRatingStats? _ratingStats;
  bool _reviewLoading = false;
  int _selectedRating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _showReviewForm = false;

  @override
  void initState() {
    super.initState();
    _loadBookDetail();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadBookDetail() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final book = await _bookService.getBookById(widget.bookId);
      if (book == null) {
        setState(() {
          _error = '图书不存在';
          _loading = false;
        });
        return;
      }

      setState(() => _book = book);

      // 加载封面图片
      if (book.coverImageUrl != null) {
        final resolvedUrl = await ImageHelper.resolveCoverImageUrl(book.coverImageUrl);
        setState(() => _coverImageUrl = resolvedUrl);
      }

      // 检查借阅和收藏状态
      final user = _authService.currentUser;
      if (user != null) {
        final borrowings = await _borrowingService.getCurrentBorrowings(user.id);
        _isBorrowed = borrowings.any((b) => b.bookId == widget.bookId);

        final favorites = await AppConfig.supabase
            .from('book_favorites')
            .select('id')
            .eq('user_id', user.id)
            .eq('book_id', widget.bookId)
            .maybeSingle();
        
        setState(() {
          _isFavorite = favorites != null;
        });

        // 加载用户的评论
        final review = await _reviewService.getUserReview(widget.bookId, user.id);
        if (review != null) {
          setState(() {
            _userReview = review;
            _selectedRating = review.rating;
            _commentController.text = review.comment ?? '';
          });
        }
      }

      // 加载所有评论和评分统计
      await _loadReviewsAndStats();
    } catch (e) {
      setState(() {
        _error = '加载图书详情失败: $e';
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadReviewsAndStats() async {
    setState(() => _reviewLoading = true);
    try {
      final results = await Future.wait([
        _reviewService.getReviews(widget.bookId),
        _reviewService.getBookRatingStats(widget.bookId),
      ]);

      setState(() {
        _reviews = results[0] as List<Review>;
        _ratingStats = results[1] as BookRatingStats;
      });
    } catch (e) {
      print('加载评论失败: $e');
    } finally {
      setState(() => _reviewLoading = false);
    }
  }

  Future<void> _handleBorrow() async {
    final user = _authService.currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先登录')),
      );
      context.go('/login');
      return;
    }

    if (_book == null) return;

    setState(() => _borrowing = true);
    try {
      final result = await _borrowingService.borrowBook(
        bookId: widget.bookId,
        userId: user.id,
        days: 30,
      );

      if (!mounted) return;
      
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('借阅成功！'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadBookDetail();
      } else {
        throw Exception(result['error'] ?? '借阅失败');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('借阅失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _borrowing = false);
      }
    }
  }

  Future<void> _toggleFavorite() async {
    final user = _authService.currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先登录')),
      );
      return;
    }

    try {
      if (_isFavorite) {
        await AppConfig.supabase
            .from('book_favorites')
            .delete()
            .eq('user_id', user.id)
            .eq('book_id', widget.bookId);
        if (mounted) {
          setState(() => _isFavorite = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('已取消收藏')),
          );
        }
      } else {
        await AppConfig.supabase
            .from('book_favorites')
            .insert({
              'user_id': user.id,
              'book_id': widget.bookId,
            });
        if (mounted) {
          setState(() => _isFavorite = true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('已添加收藏')),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('操作失败: $e')),
      );
    }
  }

  Future<void> _handleSubmitReview() async {
    final user = _authService.currentUser;
    if (user == null || _selectedRating == 0) return;

    setState(() => _reviewLoading = true);
    try {
      final review = await _reviewService.submitReview(
        widget.bookId,
        user.id,
        _selectedRating,
        _commentController.text.trim().isEmpty
            ? null
            : _commentController.text.trim(),
      );

      if (!mounted) return;
      
      if (review != null) {
        setState(() {
          _userReview = review;
          _showReviewForm = false;
        });
        await _loadReviewsAndStats();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('评论提交成功！')),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('提交评论失败: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _reviewLoading = false);
      }
    }
  }

  Future<void> _handleDeleteReview() async {
    if (_userReview == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这条评论吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final user = _authService.currentUser;
    if (user == null) return;

    setState(() => _reviewLoading = true);
    try {
      final success = await _reviewService.deleteReview(_userReview!.id, user.id);
      if (!mounted) return;
      
      if (success) {
        setState(() {
          _userReview = null;
          _selectedRating = 0;
          _commentController.clear();
        });
        await _loadReviewsAndStats();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('评论已删除')),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('删除评论失败: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _reviewLoading = false);
      }
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.year}/${date.month}/${date.day}';
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('图书详情')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _book == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('图书详情')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(_error ?? '图书不存在'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('返回'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('图书详情'),
        actions: [
          IconButton(
            icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
            color: _isFavorite ? Colors.red : null,
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 封面和基本信息
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 封面
                  Container(
                    width: 120,
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[300],
                    ),
                    child: _coverImageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: _coverImageUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) => const Icon(
                                Icons.book,
                                size: 64,
                              ),
                            ),
                          )
                        : const Icon(Icons.book, size: 64),
                  ),
                  const SizedBox(width: 16),
                  // 图书信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _book!.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '作者: ${_book!.author}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        if (_book!.category != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            '分类: ${_book!.category}',
                            style: TextStyle(color: Colors.blue[600], fontSize: 12),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Chip(
                              label: Text(
                                _book!.availableQuantity > 0 ? '可借' : '已借完',
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor: _book!.availableQuantity > 0
                                  ? Colors.green
                                  : Colors.red,
                              labelStyle: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '库存: ${_book!.quantity}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 操作按钮
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isBorrowed || _book!.availableQuantity == 0 || _borrowing
                          ? null
                          : _handleBorrow,
                      icon: _borrowing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.bookmark_add),
                      label: Text(_isBorrowed ? '已借阅' : '借阅'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 详细信息
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '详细信息',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_book!.isbn != null)
                    _buildInfoRow('ISBN', _book!.isbn!),
                  if (_book!.publisher != null && _book!.publisher!.isNotEmpty)
                    _buildInfoRow('出版社', _book!.publisher!),
                  if (_book!.publicationYear != null)
                    _buildInfoRow('出版年份', _book!.publicationYear.toString()),
                  _buildInfoRow('总数量', _book!.quantity.toString()),
                  _buildInfoRow('可借数量', _book!.availableQuantity.toString()),
                  if (_book!.description != null && _book!.description!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      '简介',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _book!.description!,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ],
              ),
            ),

            // 评论和评分区域
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '评论与评分',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 评分统计
                  if (_ratingStats != null && _ratingStats!.totalReviews > 0) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          StarRating(
                            rating: _ratingStats!.averageRating,
                            readonly: true,
                            showText: true,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '共 ${_ratingStats!.totalReviews} 条评论',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 用户评论
                  if (_authService.currentUser != null) ...[
                    if (_userReview != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  '我的评论',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextButton(
                                  onPressed: _handleDeleteReview,
                                  child: const Text(
                                    '删除',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                            StarRating(
                              rating: _userReview!.rating.toDouble(),
                              readonly: true,
                              size: 20,
                            ),
                            if (_userReview!.comment != null &&
                                _userReview!.comment!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(_userReview!.comment!),
                            ],
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _showReviewForm = true;
                                  _selectedRating = _userReview!.rating;
                                  _commentController.text = _userReview!.comment ?? '';
                                });
                              },
                              child: const Text('修改评论'),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _showReviewForm = !_showReviewForm;
                            if (!_showReviewForm) {
                              _selectedRating = 0;
                              _commentController.clear();
                            }
                          });
                        },
                        child: Text(_showReviewForm ? '取消评论' : '添加评论'),
                      ),
                    ],

                    // 评论表单
                    if (_showReviewForm) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '评分',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            StarRating(
                              rating: _selectedRating.toDouble(),
                              readonly: false,
                              onRatingChange: (rating) {
                                setState(() => _selectedRating = rating);
                              },
                              size: 32,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              '评论内容（可选）',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _commentController,
                              maxLines: 4,
                              decoration: const InputDecoration(
                                hintText: '分享你的阅读体验...',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _reviewLoading || _selectedRating == 0
                                        ? null
                                        : _handleSubmitReview,
                                    child: Text(_reviewLoading ? '提交中...' : '提交评论'),
                                  ),
                                ),
                                if (_userReview != null) ...[
                                  const SizedBox(width: 8),
                                  OutlinedButton(
                                    onPressed: () {
                                      setState(() {
                                        _showReviewForm = false;
                                        _selectedRating = _userReview!.rating;
                                        _commentController.text = _userReview!.comment ?? '';
                                      });
                                    },
                                    child: const Text('取消'),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                  ],

                  // 评论列表
                  const Text(
                    '所有评论',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_reviewLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_reviews.isEmpty)
                    const Text(
                      '暂无评论，快来第一个评论吧！',
                      style: TextStyle(color: Colors.grey),
                    )
                  else
                    ..._reviews.map((review) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    review.userFullName ??
                                        review.userEmail ??
                                        '匿名用户',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    review.createdAt != null
                                        ? _formatDate(review.createdAt!)
                                        : '-',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              StarRating(
                                rating: review.rating.toDouble(),
                                readonly: true,
                                size: 16,
                              ),
                              if (review.comment != null &&
                                  review.comment!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(review.comment!),
                              ],
                            ],
                          ),
                        )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
