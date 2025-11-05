import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/product.dart';
import '../services/api_client.dart';
import '../utils/dialog_utils.dart';
import '../widgets/loading_overlay.dart';
import 'product_form_screen.dart';

class ProductsTabScreen extends StatefulWidget {
  const ProductsTabScreen({Key? key}) : super(key: key);

  @override
  _ProductsTabScreenState createState() => _ProductsTabScreenState();
}

class _ProductsTabScreenState extends State<ProductsTabScreen> {
  List<Product> _products = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<ApiClient>();
      final products = await api.getProducts();
      setState(() => _products = products);
    } catch (e) {
      DialogUtils.showError(context, e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteProduct(Product product) async {
    final confirmed = await DialogUtils.showConfirmDialog(
      context,
      'Delete Product',
      'Are you sure you want to delete ${product.name}?',
    );

    if (!confirmed) return;

    setState(() => _isLoading = true);
    try {
      final api = context.read<ApiClient>();
      await api.deleteProduct(product.id!);
      await _loadProducts();
      DialogUtils.showSuccess(context, 'Product deleted successfully');
    } catch (e) {
      DialogUtils.showError(context, e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductFormScreen(),
                  ),
                );
                if (result == true) {
                  await _loadProducts();
                }
              },
              child: Text('Add New Product'),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                return Card(
                  margin: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    title: Text(product.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Price: ₹${product.price.toStringAsFixed(2)}'),
                        if (product.categoryName != null)
                          Text('Category: ${product.categoryName}'),
                        
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductFormScreen(
                                  product: product,
                                ),
                              ),
                            );
                            if (result == true) {
                              await _loadProducts();
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          color: Colors.red,
                          onPressed: () => _deleteProduct(product),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

