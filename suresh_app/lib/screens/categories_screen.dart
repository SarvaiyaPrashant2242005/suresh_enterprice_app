import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/category.dart';
import '../providers/category_provider.dart';
import '../providers/auth_provider_updated.dart';
import '../services/api_client.dart';
import '../widgets/loading_indicator.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late CategoryProvider _categoryProvider;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  Category? _editingCategory;

  @override
  void initState() {
    super.initState();
    _categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    int? companyId;
    String? userType;
    final ad = auth.authData;
    if (ad != null) {
      final dynamic c = ad['company_id'] ?? ad['companyId'] ?? (ad['user'] is Map ? (ad['user']['company_id'] ?? ad['user']['companyId']) : null);
      if (c is num) companyId = c.toInt();
      if (c is String) companyId = int.tryParse(c);
      // Get userType from authData
      userType = ad['userType'] ?? (ad['user'] is Map ? ad['user']['userType'] : null);
    }
    await _categoryProvider.fetchCategories(companyId: companyId, userType: userType);
  }

  void _showAddEditBottomSheet({Category? category}) {
    _editingCategory = category;
    if (category != null) {
      _nameController.text = category.name;
    } else {
      _nameController.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _CategoryFormSheet(
          formKey: _formKey,
          nameController: _nameController,
          category: category,
        );
      },
    );
  }

  Future<void> _confirmDelete(Category category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${category.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _categoryProvider.deleteCategory(category.id!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Categories'),
      // ),
      body: Consumer<CategoryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const LoadingIndicator();
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${provider.errorMessage}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadCategories,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No categories found'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showAddEditBottomSheet(),
                    child: const Text('Add Category'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadCategories,
            child: ListView.builder(
              itemCount: provider.categories.length,
              itemBuilder: (context, index) {
                final category = provider.categories[index];
                return ListTile(
                  title: Text(category.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showAddEditBottomSheet(category: category),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _confirmDelete(category),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditBottomSheet(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CategoryFormSheet extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final Category? category;

  const _CategoryFormSheet({
    required this.formKey,
    required this.nameController,
    required this.category,
  });

  @override
  State<_CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends State<_CategoryFormSheet> {
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black12)],
          ),
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 24,
            bottom: mediaQuery.viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Form(
              key: widget.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.category == null ? 'Add Category' : 'Edit Category',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: widget.nameController,
                    decoration: const InputDecoration(
                      labelText: 'Category Name',
                      hintText: 'Enter category name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter category name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                      onPressed: () async {
                        if (widget.formKey.currentState!.validate()) {
                          final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
                          final category = Category(
                            id: widget.category?.id,
                            name: widget.nameController.text,
                          );

                          if (widget.category == null) {
                            await categoryProvider.createCategory(category);
                          } else {
                            await categoryProvider.updateCategory(widget.category!.id!, category);
                          }

                          if (mounted) {
                            Navigator.of(context).pop();
                          }
                        }
                      },
                      child: Text(widget.category == null ? 'Add Category' : 'Update Category'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}