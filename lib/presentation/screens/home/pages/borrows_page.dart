import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:library_management/data/services/borrowing_service.dart';
import 'package:library_management/data/services/auth_service.dart';
import 'package:library_management/data/models/borrow_record_model.dart';
import 'package:library_management/utils/image_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BorrowsPage extends StatefulWidget {
  const BorrowsPage({Key? key}) : super(key: key);

  @override
  State<BorrowsPage> createState() => _BorrowsPageState();
}

class _BorrowsPageState extends State<BorrowsPage> with SingleTickerProviderStateMixin {
  final _borrowingService = BorrowingService();
  final _authService = AuthService();
  List<BorrowRecord> _currentBorrows = [];
  List<BorrowRecord> _historyBorrows = [];
  bool _loading = true;
  late TabController _tabController;
  Map<String, String?> _coverImageUrls = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadBorrows();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBorrows() async {
    setState(() => _loading = true);
    try {
      final user = _authService.currentUser;
      if (user == null) {
        setState(() {
          _currentBorrows = [];
          _historyBorrows = [];
          _loading = false;
        });
        return;
      }

      final allBorrows = await _borrowingService.getUserBorrowings(user.id);
      
      setState(() {
        _currentBorrows = allBorrows
            .where((b) => b.status == 'borrowed' || b.status == 'overdue')
            .toList();
        _historyBorrows = allBorrows
            .where((b) => b.status == 'returned')
            .toList();
      });

      // 加载封面图片
      await _loadCoverImages([..._currentBorrows, ..._historyBorrows]);
    } catch (e) {
      print('加载借阅记录失败: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadCoverImages(List<BorrowRecord> records) async {
    final urls = <String, String?>{};
    for (final record in records) {
      if (record.book?.coverImageUrl != null && 
          !_coverImageUrls.containsKey(record.bookId)) {
        final resolvedUrl = await ImageHelper.resolveCoverImageUrl(
          record.book!.coverImageUrl,
        );
        urls[record.bookId] = resolvedUrl;
      }
    }
    setState(() {
      _coverImageUrls.addAll(urls);
    });
  }

  Future<void> _handleReturn(String recordId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认归还'),
        content: const Text('确定要归还这本书吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确认'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final result = await _borrowingService.returnBook(recordId);
      if (!mounted) return;
      
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('归还成功！'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadBorrows();
      } else {
        throw Exception(result['error'] ?? '归还失败');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('归还失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  int _getDaysRemaining(String dueDate) {
    try {
      final due = DateTime.parse(dueDate);
      final now = DateTime.now();
      final diff = due.difference(now).inDays;
      return diff;
    } catch (e) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的借阅'),
        elevation: 0,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '当前借阅'),
            Tab(text: '历史记录'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildCurrentBorrows(),
                _buildBorrowHistory(),
              ],
            ),
    );
  }

  Widget _buildCurrentBorrows() {
    if (_currentBorrows.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              '暂无借阅中的图书',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _currentBorrows.length,
      itemBuilder: (context, index) {
        return _buildBorrowCard(_currentBorrows[index], isCurrent: true);
      },
    );
  }

  Widget _buildBorrowHistory() {
    if (_historyBorrows.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              '暂无借阅历史',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _historyBorrows.length,
      itemBuilder: (context, index) {
        return _buildBorrowCard(_historyBorrows[index], isCurrent: false);
      },
    );
  }

  Widget _buildBorrowCard(BorrowRecord record, {required bool isCurrent}) {
    final book = record.book;
    final coverUrl = _coverImageUrls[record.bookId] ?? book?.coverImageUrl;
    final daysRemaining = _getDaysRemaining(record.dueDate);
    final isOverdue = record.status == 'overdue' || daysRemaining < 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => context.push('/book/${record.bookId}'),
                  child: coverUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: CachedNetworkImage(
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
                          ),
                        )
                      : Container(
                          width: 50,
                          height: 70,
                          color: Colors.grey[300],
                          child: const Icon(Icons.book),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => context.push('/book/${record.bookId}'),
                        child: Text(
                          book?.title ?? '未知图书',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '作者: ${book?.author ?? '未知'}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '借阅日期',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                              Text(
                                record.borrowedAt.split('T')[0],
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                isCurrent ? '到期日期' : '归还日期',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                              Text(
                                isCurrent
                                    ? record.dueDate.split('T')[0]
                                    : record.returnedAt != null
                                        ? record.returnedAt!.split('T')[0]
                                        : '-',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isOverdue ? Colors.red : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (isCurrent) ...[
                        const SizedBox(height: 8),
                        Text(
                          isOverdue
                              ? '已逾期 ${-daysRemaining} 天'
                              : '剩余 $daysRemaining 天',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isOverdue ? Colors.red : Colors.green,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (isCurrent) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _handleReturn(record.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('归还'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
