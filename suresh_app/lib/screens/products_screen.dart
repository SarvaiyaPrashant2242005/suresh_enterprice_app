import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/product.dart';
import '../model/category.dart';
import '../providers/product_provider.dart';
import '../providers/category_provider.dart';
import '../providers/auth_provider_updated.dart';
import '../widgets/loading_indicator.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  late ProductProvider _productProvider;
  late CategoryProvider _categoryProvider;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _hsnController = TextEditingController();
  final _uomController = TextEditingController();
  bool _isActive = true;
  int? _selectedCategoryId;
  Product? _editingProduct;
  int? _companyId;

  @override
  void initState() {
    super.initState();
    _productProvider = Provider.of<ProductProvider>(context, listen: false);
    _categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    _loadData();
  }

  Future<void> _loadData() async {
    // get company id from auth provider so we can filter and include it on create
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _companyId = auth.authData?['user']?['companyId'] as int?;
    // Get userType from authData
    final userType = auth.authData?['user']?['userType'] ?? auth.authData?['userType'];
    await _productProvider.fetchProducts(companyId: _companyId, userType: userType);
      if (_categoryProvider.categories.isEmpty) {
        await _categoryProvider.fetchCategories(companyId: _companyId, userType: userType);
    }
  }

  void _showAddEditBottomSheet({Product? product}) {
    _editingProduct = product;
    if (product != null) {
      _nameController.text = product.name;
      _descriptionController.text = product.description ?? '';
      _priceController.text = product.price.toString();
      _selectedCategoryId = product.categoryId;
      _hsnController.text = product.hsnCode ?? '';
      _uomController.text = product.uom ?? '';
      _isActive = product.isActive ?? true;
    } else {
      _nameController.clear();
      _descriptionController.clear();
      _priceController.clear();
      _selectedCategoryId = null;
      _hsnController.clear();
      _uomController.clear();
      _isActive = true;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _ProductFormSheet(
          formKey: _formKey,
          nameController: _nameController,
          descriptionController: _descriptionController,
          priceController: _priceController,
          hsnController: _hsnController,
          uomController: _uomController,
          selectedCategoryId: _selectedCategoryId,
          isActive: _isActive,
          product: product,
          categories: _categoryProvider.categories,
          companyId: _companyId,
        );
      },
    );
  }

  Future<void> _confirmDelete(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${product.name}?'),
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
      await _productProvider.deleteProduct(product.id!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _hsnController.dispose();
    _uomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
      ),
      body: Consumer<ProductProvider>(
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
                    onPressed: _loadData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No products found'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showAddEditBottomSheet(),
                    child: const Text('Add Product'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadData,
            child: ListView.builder(
              itemCount: provider.products.length,
              itemBuilder: (context, index) {
                final product = provider.products[index];
                return ListTile(
                  title: Text(product.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (product.description != null) Text(product.description!),
                      Text('Price: ₹${product.price.toStringAsFixed(2)}'),
                      if (product.categoryName != null) Text('Category: ${product.categoryName}'),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showAddEditBottomSheet(product: product),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _confirmDelete(product),
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

class _ProductFormSheet extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController priceController;
  final TextEditingController hsnController;
  final TextEditingController uomController;
  final int? selectedCategoryId;
  final bool isActive;
  final Product? product;
  final List<Category> categories;
  final int? companyId;

  const _ProductFormSheet({
    required this.formKey,
    required this.nameController,
    required this.descriptionController,
    required this.priceController,
    required this.hsnController,
    required this.uomController,
    required this.selectedCategoryId,
    required this.isActive,
    required this.product,
    required this.categories,
    required this.companyId,
  });

  @override
  State<_ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends State<_ProductFormSheet> {
  int? _selectedCategoryId;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.selectedCategoryId;
    _isActive = widget.isActive;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 600;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        widget.product == null ? 'Add Product' : 'Edit Product',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        runSpacing: 16,
                        spacing: 16,
                        children: [
                          SizedBox(
                            width: isWide ? (constraints.maxWidth / 2) - 24 : double.infinity,
                            child: TextFormField(
                              controller: widget.nameController,
                              decoration: const InputDecoration(
                                labelText: 'Product Name',
                                hintText: 'Enter product name',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter product name';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(
                            width: isWide ? (constraints.maxWidth / 2) - 24 : double.infinity,
                            child: TextFormField(
                              controller: widget.descriptionController,
                              decoration: const InputDecoration(
                                labelText: 'Description',
                                hintText: 'Enter description',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 2,
                            ),
                          ),
                          SizedBox(
                            width: isWide ? (constraints.maxWidth / 2) - 24 : double.infinity,
                            child: TextFormField(
                              controller: widget.hsnController,
                              decoration: const InputDecoration(
                                labelText: 'HSN Code',
                                hintText: 'Enter HSN code',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: isWide ? (constraints.maxWidth / 2) - 24 : double.infinity,
                            child: TextFormField(
                              controller: widget.uomController,
                              decoration: const InputDecoration(
                                labelText: 'UOM',
                                hintText: 'Unit of measurement',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: isWide ? (constraints.maxWidth / 2) - 24 : double.infinity,
                            child: TextFormField(
                              controller: widget.priceController,
                              decoration: const InputDecoration(
                                labelText: 'Price',
                                hintText: '0.00',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter price';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Please enter a valid number';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(
                            width: isWide ? (constraints.maxWidth / 2) - 24 : double.infinity,
                            child: DropdownButtonFormField<int>(
                              value: _selectedCategoryId,
                              decoration: const InputDecoration(
                                labelText: 'Category',
                                border: OutlineInputBorder(),
                              ),
                              items: widget.categories.map((category) {
                                return DropdownMenuItem<int>(
                                  value: category.id,
                                  child: Text(category.name),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategoryId = value;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select a category';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(
                            width: isWide ? (constraints.maxWidth / 2) - 24 : double.infinity,
                            child: Row(
                              children: [
                                Switch(
                                  value: _isActive,
                                  onChanged: (val) {
                                    setState(() {
                                      _isActive = val;
                                    });
                                  },
                                ),
                                const SizedBox(width: 8),
                                const Text('Active'),
                              ],
                            ),
                          ),
                        ],
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
                              final productProvider = Provider.of<ProductProvider>(context, listen: false);
                              final product = Product(
                                id: widget.product?.id,
                                name: widget.nameController.text,
                                description: widget.descriptionController.text.isEmpty ? null : widget.descriptionController.text,
                                price: double.parse(widget.priceController.text),
                                categoryId: _selectedCategoryId,
                                hsnCode: widget.hsnController.text.isEmpty ? null : widget.hsnController.text,
                                uom: widget.uomController.text.isEmpty ? null : widget.uomController.text,
                                isActive: _isActive,
                                companyId: widget.companyId,
                              );

                              if (widget.product == null) {
                                await productProvider.createProduct(product);
                              } else {
                                await productProvider.updateProduct(widget.product!.id!, product);
                              }

                              if (mounted) {
                                Navigator.of(context).pop();
                              }
                            }
                          },
                          child: Text(widget.product == null ? 'Add Product' : 'Update Product'),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}