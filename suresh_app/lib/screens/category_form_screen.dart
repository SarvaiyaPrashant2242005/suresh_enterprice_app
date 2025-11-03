import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../mixins/form_validation_mixin.dart';
import '../model/category.dart';
import '../services/api_client.dart';
import '../utils/dialog_utils.dart';
import '../utils/validators.dart';
import '../widgets/form_widgets.dart';
import '../widgets/loading_overlay.dart';

class CategoryFormScreen extends StatefulWidget {
  final Category? category;

  const CategoryFormScreen({Key? key, this.category}) : super(key: key);

  @override
  _CategoryFormScreenState createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> with FormValidationMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name);
  }

  bool _validateForm() {
    if (!_formKey.currentState!.validate()) return false;

    return validateFields({
      'name': ValidationRule(
        value: _nameController.text,
        validator: Validators.isNotEmpty,
        errorMessage: 'Category name is required',
      ),
    });
  }

  Future<void> _handleSubmit() async {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);

    try {
      final category = Category(
        id: widget.category?.id,
        name: _nameController.text,
      );

      final api = context.read<ApiClient>();
      if (widget.category != null) {
        await api.updateCategory(widget.category!.id!, category);
      } else {
        await api.createCategory(category);
      }

      DialogUtils.showSuccess(
        context,
        'Category ${widget.category != null ? 'updated' : 'created'} successfully',
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
          title: Text(widget.category != null ? 'Edit Category' : 'Create Category'),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FormSection(
                  title: 'Category Details',
                  children: [
                    CustomTextField(
                      label: 'Name *',
                      controller: _nameController,
                      errorText: errors['name'],
                      onChanged: (_) => validateField(
                        'name',
                        _nameController.text,
                        Validators.isNotEmpty,
                        'Category name is required',
                      ),
                    ),
                    SizedBox(height: 16),
                    
                  ],
                ),
                SizedBox(height: 24),
                LoadingButton(
                  isLoading: _isLoading,
                  onPressed: _handleSubmit,
                  text: widget.category != null ? 'Update Category' : 'Create Category',
                  loadingText: widget.category != null ? 'Updating...' : 'Creating...',
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
    _descriptionController.dispose();
    super.dispose();
  }
}