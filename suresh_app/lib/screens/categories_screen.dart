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

  void _showAddEditDialog({Category? category}) {
    _editingCategory = category;
    if (category != null) {
      _nameController.text = category.name;
    } else {
      _nameController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(category == null ? 'Add Category' : 'Edit Category'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
             
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: _saveCategory,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveCategory() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final category = Category(
        id: _editingCategory?.id,
        name: name,
      );

      if (_editingCategory == null) {
        await _categoryProvider.createCategory(category);
      } else {
        await _categoryProvider.updateCategory(_editingCategory!.id!, category);
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    }
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
      appBar: AppBar(
        title: const Text('Categories'),
      ),
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
                    onPressed: () => _showAddEditDialog(),
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
                        onPressed: () => _showAddEditDialog(category: category),
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
        onPressed: () => _showAddEditDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}