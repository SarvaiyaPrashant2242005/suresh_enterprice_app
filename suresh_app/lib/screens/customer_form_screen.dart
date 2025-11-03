import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../mixins/form_validation_mixin.dart';
import '../model/customer.dart';
import '../services/api_client.dart';
import '../utils/dialog_utils.dart';
import '../utils/validators.dart';
import '../widgets/form_widgets.dart';
import '../widgets/loading_overlay.dart';

class CustomerFormScreen extends StatefulWidget {
  final Customer? customer;

  const CustomerFormScreen({Key? key, this.customer}) : super(key: key);

  @override
  _CustomerFormScreenState createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> with FormValidationMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _gstNumberController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer?.name);
    _emailController = TextEditingController(text: widget.customer?.email);
    _phoneController = TextEditingController(text: widget.customer?.phone);
    _addressController = TextEditingController(text: widget.customer?.address);
    _gstNumberController = TextEditingController(text: widget.customer?.gstNumber);
  }

  bool _validateForm() {
    if (!_formKey.currentState!.validate()) return false;

    return validateFields({
      'name': ValidationRule(
        value: _nameController.text,
        validator: Validators.isValidUserName,
        errorMessage: 'Please enter a valid name',
      ),
      'email': ValidationRule(
        value: _emailController.text,
        validator: Validators.isValidEmail,
        errorMessage: 'Please enter a valid email',
      ),
      'phone': ValidationRule(
        value: _phoneController.text,
        validator: Validators.isValidPhoneNumber,
        errorMessage: 'Please enter a valid phone number',
      ),
      'gstNumber': ValidationRule(
        value: _gstNumberController.text,
        validator: (value) => value?.isEmpty == true || Validators.isValidGstNumber(value),
        errorMessage: 'Please enter a valid GST number',
      ),
    });
  }

  Future<void> _handleSubmit() async {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);

    try {
      final customer = Customer(
        id: widget.customer?.id,
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        address: _addressController.text.isEmpty ? null : _addressController.text,
        gstNumber: _gstNumberController.text.isEmpty ? null : _gstNumberController.text,
      );

      final api = context.read<ApiClient>();
      if (widget.customer != null) {
        await api.updateCustomer(widget.customer!.id!, customer);
      } else {
        await api.createCustomer(customer);
      }

      DialogUtils.showSuccess(
        context,
        'Customer ${widget.customer != null ? 'updated' : 'created'} successfully',
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
          title: Text(widget.customer != null ? 'Edit Customer' : 'Create Customer'),
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
                        Validators.isValidUserName,
                        'Please enter a valid name',
                      ),
                    ),
                    SizedBox(height: 16),
                    CustomTextField(
                      label: 'Email *',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      errorText: errors['email'],
                      onChanged: (_) => validateField(
                        'email',
                        _emailController.text,
                        Validators.isValidEmail,
                        'Please enter a valid email',
                      ),
                    ),
                    SizedBox(height: 16),
                    CustomTextField(
                      label: 'Phone *',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      errorText: errors['phone'],
                      onChanged: (_) => validateField(
                        'phone',
                        _phoneController.text,
                        Validators.isValidPhoneNumber,
                        'Please enter a valid phone number',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                FormSection(
                  title: 'Additional Information',
                  children: [
                    CustomTextField(
                      label: 'GST Number',
                      controller: _gstNumberController,
                      errorText: errors['gstNumber'],
                      onChanged: (_) => validateField(
                        'gstNumber',
                        _gstNumberController.text,
                        (value) => value?.isEmpty == true || Validators.isValidGstNumber(value),
                        'Please enter a valid GST number',
                      ),
                    ),
                    SizedBox(height: 16),
                    CustomTextField(
                      label: 'Address',
                      controller: _addressController,
                      maxLines: 3,
                    ),
                  ],
                ),
                SizedBox(height: 24),
                LoadingButton(
                  isLoading: _isLoading,
                  onPressed: _handleSubmit,
                  text: widget.customer != null ? 'Update Customer' : 'Create Customer',
                  loadingText: widget.customer != null ? 'Updating...' : 'Creating...',
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
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _gstNumberController.dispose();
    super.dispose();
  }
}