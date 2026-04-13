import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:library_management/config/app_config.dart';
import 'package:library_management/data/models/book_model.dart';
import 'package:library_management/data/services/book_service.dart';
import 'package:library_management/localization/app_localization.dart';
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
        SnackBar(content: Text('${AppLocalization.tr('loading')}: $e')),
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
        title: Text(isEdit ? AppLocalization.tr('edit_book') : AppLocalization.tr('add_book')),
        content: SizedBox(
          width: 420,
          child: StatefulBuilder(
            builder: (context, setDialogState) => SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildField(titleController, '${AppLocalization.tr('books')}*'),
                  const SizedBox(height: 10),
                  _buildField(authorController, '${AppLocalization.tr('author')}*'),
                  const SizedBox(height: 10),
                  _buildField(isbnController, 'ISBN'),
                  const SizedBox(height: 10),
                  _buildField(publisherController, AppLocalization.tr('publisher')),
                  const SizedBox(height: 10),
                  _buildField(yearController, AppLocalization.tr('publication_year'), keyboardType: TextInputType.number),
                  const SizedBox(height: 10),
                  _buildField(categoryController, AppLocalization.tr('category')),
                  const SizedBox(height: 10),
                  _buildField(descriptionController, AppLocalization.tr('description'), maxLines: 3),
                  const SizedBox(height: 10),
                  _buildField(
                    quantityController,
                    '${AppLocalization.tr('quantity')}*',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  _buildField(
                    availableController,
                    '${AppLocalization.tr('available_quantity')}*',
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
                          label: Text(AppLocalization.tr('camera_upload')),
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
                          label: Text(AppLocalization.tr('gallery_upload')),
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
                          child: Text(AppLocalization.tr('loading')),
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
            child: Text(AppLocalization.tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(isEdit ? AppLocalization.tr('save') : AppLocalization.tr('add_book')),
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
        SnackBar(content: Text(AppLocalization.tr('confirm'))),
      );
      return;
    }
    if (quantity < 0 || available < 0 || available > quantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalization.tr('available_quantity'))),
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
        SnackBar(content: Text(isEdit ? AppLocalization.tr('update') : AppLocalization.tr('add_book'))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${isEdit ? AppLocalization.tr('update') : AppLocalization.tr('add_book')}: $e')),
      );
    }
  }

  Future<void> _deleteBook(Book book) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalization.tr('delete')),
        content: Text('${AppLocalization.tr('confirm')} "${book.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalization.tr('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalization.tr('delete')),
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
        SnackBar(content: Text(AppLocalization.tr('delete'))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocalization.tr('operation_failed')}: $e')),
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
        SnackBar(content: Text('${AppLocalization.tr('upload_failed')}: $e')),
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
        title: Text(AppLocalization.tr('admin')),
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
                hintText: AppLocalization.tr('search_book_author'),
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
                    ? Center(child: Text(AppLocalization.tr('books')))
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
        label: Text(AppLocalization.tr('add_book')),
      ),
    );
  }
}
