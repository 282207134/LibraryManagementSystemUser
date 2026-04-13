import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:library_management/config/app_config.dart';
import 'package:library_management/data/models/book_model.dart';
import 'package:library_management/data/services/book_service.dart';
import 'package:library_management/utils/image_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final _bookService = BookService();
  final _picker = ImagePicker();
  final _searchController = TextEditingController();
  List<Book> _books = [];
  bool _loading = true;
  String _searchTerm = '';

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

  Future<void> _loadBooks() async {
    setState(() => _loading = true);
    try {
      final books = await _bookService.getBooks(
        page: 1,
        pageSize: 100,
        search: _searchTerm.isEmpty ? null : _searchTerm,
      );
      if (!mounted) return;
      setState(() => _books = books);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载图书失败: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _onSearch(String value) {
    setState(() => _searchTerm = value.trim());
    _loadBooks();
  }

  Future<void> _showBookDialog({Book? book}) async {
    final isEdit = book != null;
    final titleController = TextEditingController(text: book?.title ?? '');
    final authorController = TextEditingController(text: book?.author ?? '');
    final isbnController = TextEditingController(text: book?.isbn ?? '');
    final publisherController = TextEditingController(text: book?.publisher ?? '');
    final yearController = TextEditingController(
      text: book?.publicationYear?.toString() ?? '',
    );
    final categoryController = TextEditingController(text: book?.category ?? '');
    final descriptionController = TextEditingController(text: book?.description ?? '');
    final quantityController = TextEditingController(
      text: (book?.quantity ?? 1).toString(),
    );
    final availableController = TextEditingController(
      text: (book?.availableQuantity ?? 1).toString(),
    );
    String? uploadedCoverPath = book?.coverImageUrl;
    String? uploadedCoverPreview = book?.coverImageUrl;
    bool uploading = false;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? '编辑图书' : '添加图书'),
        content: SizedBox(
          width: 420,
          child: StatefulBuilder(
            builder: (context, setDialogState) => SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildField(titleController, '书名*'),
                  const SizedBox(height: 10),
                  _buildField(authorController, '作者*'),
                  const SizedBox(height: 10),
                  _buildField(isbnController, 'ISBN'),
                  const SizedBox(height: 10),
                  _buildField(publisherController, '出版社'),
                  const SizedBox(height: 10),
                  _buildField(yearController, '出版年份', keyboardType: TextInputType.number),
                  const SizedBox(height: 10),
                  _buildField(categoryController, '分类'),
                  const SizedBox(height: 10),
                  _buildField(descriptionController, '简介', maxLines: 3),
                  const SizedBox(height: 10),
                  _buildField(
                    quantityController,
                    '库存数量*',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  _buildField(
                    availableController,
                    '可借数量*',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: uploading
                              ? null
                              : () async {
                                  final picked = await _picker.pickImage(
                                    source: ImageSource.camera,
                                    imageQuality: 85,
                                  );
                                  if (picked == null) return;
                                  setDialogState(() => uploading = true);
                                  try {
                                    final result = await _uploadCover(picked);
                                    if (result != null) {
                                      setDialogState(() {
                                        uploadedCoverPath = result.$1;
                                        uploadedCoverPreview = result.$2;
                                      });
                                    }
                                  } finally {
                                    setDialogState(() => uploading = false);
                                  }
                                },
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('拍照上传'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: uploading
                              ? null
                              : () async {
                                  final picked = await _picker.pickImage(
                                    source: ImageSource.gallery,
                                    imageQuality: 85,
                                  );
                                  if (picked == null) return;
                                  setDialogState(() => uploading = true);
                                  try {
                                    final result = await _uploadCover(picked);
                                    if (result != null) {
                                      setDialogState(() {
                                        uploadedCoverPath = result.$1;
                                        uploadedCoverPreview = result.$2;
                                      });
                                    }
                                  } finally {
                                    setDialogState(() => uploading = false);
                                  }
                                },
                          icon: const Icon(Icons.photo_library),
                          label: const Text('相册上传'),
                        ),
                      ),
                    ],
                  ),
                  if (uploading) ...[
                    const SizedBox(height: 8),
                    const LinearProgressIndicator(),
                  ],
                  if (uploadedCoverPreview != null && uploadedCoverPreview!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        uploadedCoverPreview!,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 120,
                          alignment: Alignment.center,
                          color: Colors.grey.shade200,
                          child: const Text('封面预览加载失败'),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(isEdit ? '保存' : '添加'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final title = titleController.text.trim();
    final author = authorController.text.trim();
    final quantity = int.tryParse(quantityController.text.trim());
    final available = int.tryParse(availableController.text.trim());
    final publicationYear = int.tryParse(yearController.text.trim());

    if (title.isEmpty || author.isEmpty || quantity == null || available == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写完整必填信息')),
      );
      return;
    }
    if (quantity < 0 || available < 0 || available > quantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('数量不合法：可借数量不能大于库存')),
      );
      return;
    }

    try {
      if (isEdit) {
        await _bookService.updateBook(
          id: book.id,
          title: title,
          author: author,
          isbn: isbnController.text,
          publisher: publisherController.text,
          publicationYear: publicationYear,
          category: categoryController.text,
          description: descriptionController.text,
          quantity: quantity,
          availableQuantity: available,
          coverImageUrl: uploadedCoverPath,
        );
      } else {
        await _bookService.createBook(
          title: title,
          author: author,
          isbn: isbnController.text,
          publisher: publisherController.text,
          publicationYear: publicationYear,
          category: categoryController.text,
          description: descriptionController.text,
          quantity: quantity,
          coverImageUrl: uploadedCoverPath,
        );
      }

      await _loadBooks();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isEdit ? '图书更新成功' : '图书添加成功')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${isEdit ? '更新' : '添加'}失败: $e')),
      );
    }
  }

  Future<void> _deleteBook(Book book) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除图书'),
        content: Text('确定删除《${book.title}》吗？'),
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
    if (confirm != true) return;

    try {
      await _bookService.deleteBook(book.id);
      await _loadBooks();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('图书删除成功')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('删除失败: $e')),
      );
    }
  }

  Widget _buildField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Future<(String, String)?> _uploadCover(XFile picked) async {
    try {
      final bytes = await picked.readAsBytes();
      final ext = _safeExt(picked.name);
      final objectPath = 'covers/${DateTime.now().millisecondsSinceEpoch}-$ext';
      await AppConfig.supabase.storage.from('book-covers').uploadBinary(
            objectPath,
            bytes,
            fileOptions: FileOptions(
              contentType: _contentType(ext),
              upsert: true,
            ),
          );

      final previewUrl = await ImageHelper.resolveCoverImageUrl(objectPath) ?? objectPath;
      return (objectPath, previewUrl);
    } catch (e) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('上传封面失败: $e')),
      );
      return null;
    }
  }

  String _safeExt(String fileName) {
    final index = fileName.lastIndexOf('.');
    if (index == -1 || index == fileName.length - 1) return 'jpg';
    return fileName.substring(index + 1).toLowerCase();
  }

  String _contentType(String ext) {
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      default:
        return 'image/jpeg';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('管理界面'),
        elevation: 0,
        backgroundColor: isDark ? colorScheme.surface : null,
        foregroundColor: isDark ? colorScheme.onSurface : null,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onSubmitted: _onSearch,
              decoration: InputDecoration(
                hintText: '搜索书名或作者...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchTerm.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearch('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _books.isEmpty
                    ? const Center(child: Text('暂无图书'))
                    : RefreshIndicator(
                        onRefresh: _loadBooks,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          itemCount: _books.length,
                          itemBuilder: (context, index) {
                            final book = _books[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                title: Text(book.title),
                                subtitle: Text(
                                  '${book.author}  ·  库存 ${book.quantity} / 可借 ${book.availableQuantity}',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () => _showBookDialog(book: book),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline),
                                      onPressed: () => _deleteBook(book),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showBookDialog(),
        icon: const Icon(Icons.add),
        label: const Text('添加图书'),
      ),
    );
  }
}
