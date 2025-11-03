import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../mixins/form_validation_mixin.dart';
import '../model/category.dart';
import '../model/product.dart';
import '../services/api_client.dart';
import '../utils/dialog_utils.dart';
import '../utils/validators.dart';
import '../widgets/form_widgets.dart';
import '../widgets/loading_overlay.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;

  const ProductFormScreen({Key? key, this.product}) : super(key: key);

  @override
  _ProductFormScreenState createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> with FormValidationMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _hsnCodeController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  String? _selectedCategoryId;
  List<Category> _categories = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name);
    _hsnCodeController = TextEditingController(text: widget.product?.hsnCode);
    _descriptionController = TextEditingController(text: widget.product?.description);
    _priceController = TextEditingController(
      text: widget.product?.price?.toStringAsFixed(2),
    );
    _selectedCategoryId = widget.product?.categoryId?.toString();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<ApiClient>();
      final categories = await api.getCategories();
      setState(() => _categories = categories);
    } catch (e) {
      DialogUtils.showError(context, e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  bool _validateForm() {
    if (!_formKey.currentState!.validate()) return false;

    return validateFields({
      'name': ValidationRule(
        value: _nameController.text,
        validator: Validators.isNotEmpty,
        errorMessage: 'Product name is required',
      ),
      'hsnCode': ValidationRule(
        value: _hsnCodeController.text,
        // validators.dart defines isValidHsnCode
        validator: Validators.isValidHsnCode,
        errorMessage: 'Invalid HSN code',
      ),
      'price': ValidationRule(
        value: _priceController.text,
        validator: Validators.isValidPrice,
        errorMessage: 'Invalid price',
      ),
      'category': ValidationRule(
        value: _selectedCategoryId,
        validator: Validators.isNotEmpty,
        errorMessage: 'Category is required',
      ),
    });
  }

  Future<void> _handleSubmit() async {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);

    try {
      final product = Product(
        id: widget.product?.id,
        name: _nameController.text,
        hsnCode: _hsnCodeController.text,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        price: double.parse(_priceController.text),
        categoryId: int.parse(_selectedCategoryId!),
      );

      final api = context.read<ApiClient>();
      if (widget.product != null) {
        await api.updateProduct(widget.product!.id!, product);
      } else {
        await api.createProduct(product);
      }

      DialogUtils.showSuccess(
        context,
        'Product ${widget.product != null ? 'updated' : 'created'} successfully',
      );
      Navigator.pop(context, true);
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
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.product != null ? 'Edit Product' : 'Create Product'),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FormSection(
                  title: 'Basic Information',
                  children: [
                    CustomTextField(
                      label: 'Name *',
                      controller: _nameController,
                      errorText: errors['name'],
                      onChanged: (_) => validateField(
                        'name',
                        _nameController.text,
                        Validators.isNotEmpty,
                        'Product name is required',
                      ),
                    ),
                    SizedBox(height: 16),
                    CustomDropdown<String>(
                      label: 'Category',
                      value: _selectedCategoryId,
                      errorText: errors['category'],
                      items: [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text('-- Select Category --'),
                        ),
                        ..._categories.map((category) => DropdownMenuItem(
                          value: category.id.toString(),
                          child: Text(category.name),
                        )),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedCategoryId = value);
                        validateField(
                          'category',
                          value,
                          Validators.isNotEmpty,
                          'Category is required',
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 16),
                FormSection(
                  title: 'Product Details',
                  children: [
                    CustomTextField(
                      label: 'HSN Code *',
                      controller: _hsnCodeController,
                      errorText: errors['hsnCode'],
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onChanged: (_) => validateField(
                        'hsnCode',
                        _hsnCodeController.text,
                        Validators.isValidHsnCode,
                        'Invalid HSN code',
                      ),
                    ),
                    SizedBox(height: 16),
                    CustomTextField(
                      label: 'Price *',
                      controller: _priceController,
                      errorText: errors['price'],
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      onChanged: (_) => validateField(
                        'price',
                        _priceController.text,
                        Validators.isValidPrice,
                        'Invalid price',
                      ),
                    ),
                    SizedBox(height: 16),
                    CustomTextField(
                      label: 'Description',
                      controller: _descriptionController,
                      maxLines: 3,
                    ),
                  ],
                ),
                SizedBox(height: 24),
                LoadingButton(
                  isLoading: _isLoading,
                  onPressed: _handleSubmit,
                  text: widget.product != null ? 'Update Product' : 'Create Product',
                  loadingText: widget.product != null ? 'Updating...' : 'Creating...',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hsnCodeController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}