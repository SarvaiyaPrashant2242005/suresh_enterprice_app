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

  // Show as bottom sheet
  static Future<bool?> showAsBottomSheet(
    BuildContext context, {
    Customer? customer,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CustomerFormScreen(customer: customer),
    );
  }

  @override
  _CustomerFormScreenState createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen>
    with FormValidationMixin, SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _gstNumberController;
  late final TextEditingController _stateCodeController;
  late final TextEditingController _billingAddressController;
  late final TextEditingController _shippingAddressController;
  late final TextEditingController _openingBalanceController;
  late final TextEditingController _openingDateController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isLoading = false;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer?.customerName);
    _emailController = TextEditingController(text: widget.customer?.emailAddress);
    _phoneController = TextEditingController(text: widget.customer?.contactNumber);
    _addressController = TextEditingController(text: widget.customer?.address);
    _gstNumberController = TextEditingController(text: widget.customer?.gstNumber);
    _stateCodeController = TextEditingController();
    _billingAddressController = TextEditingController();
    _shippingAddressController = TextEditingController();
    _openingBalanceController = TextEditingController(text: '0.00');
    _openingDateController = TextEditingController();

    // Animation setup
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _animationController.forward();
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
        validator: (value) =>
            value?.isEmpty == true || Validators.isValidGstNumber(value),
        errorMessage: 'Please enter a valid GST number',
      ),
    });
  }

  Future<void> _handleSubmit() async {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);

    try {
      // Parse opening balance to double, default to 0.0 if empty or invalid
      double openingBalance = 0.0;
      if (_openingBalanceController.text.isNotEmpty) {
        openingBalance = double.tryParse(_openingBalanceController.text) ?? 0.0;
      }

      // Parse opening date string to DateTime
      DateTime? openingDate;
      if (_openingDateController.text.isNotEmpty) {
        final parts = _openingDateController.text.split('-');
        if (parts.length == 3) {
          try {
            openingDate = DateTime(
              int.parse(parts[2]), // year
              int.parse(parts[1]), // month
              int.parse(parts[0]), // day
            );
          } catch (e) {
            // Handle invalid date silently
          }
        }
      }

      final customer = Customer(
        id: widget.customer?.id,
        customerName: _nameController.text,
        emailAddress: _emailController.text,
        contactNumber: _phoneController.text,
        address: _addressController.text.isEmpty ? null : _addressController.text,
        gstNumber: _gstNumberController.text.isEmpty ? null : _gstNumberController.text,
        stateCode: _stateCodeController.text.isEmpty ? null : _stateCodeController.text,
        billingAddress: _billingAddressController.text.isEmpty ? null : _billingAddressController.text,
        shippingAddress: _shippingAddressController.text.isEmpty ? null : _shippingAddressController.text,
        openingBalance: openingBalance,
        openingDate: openingDate,
        isActive: _isActive,
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

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _openingDateController.text =
            '${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final keyboardHeight = mediaQuery.viewInsets.bottom;
    final screenHeight = mediaQuery.size.height;
    final availableHeight = screenHeight - keyboardHeight - 100;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black26,
        ),
        child: GestureDetector(
          onTap: () {}, // Prevent dismissal when tapping inside
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: availableHeight,
                    maxWidth: 800,
                  ),
                  margin: EdgeInsets.only(
                    bottom: keyboardHeight,
                    left: mediaQuery.size.width > 800 ? (mediaQuery.size.width - 800) / 2 : 0,
                    right: mediaQuery.size.width > 800 ? (mediaQuery.size.width - 800) / 2 : 0,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: LoadingOverlay(
                    isLoading: _isLoading,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Handle bar
                        Container(
                          margin: EdgeInsets.only(top: 12),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        // Header
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.customer != null
                                      ? 'Edit Customer'
                                      : 'Add Customer',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.close),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                        ),
                        Divider(height: 1),
                        // Form content
                        Flexible(
                          child: Form(
                            key: _formKey,
                            child: SingleChildScrollView(
                              padding: EdgeInsets.all(16),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final isWideScreen = constraints.maxWidth > 600;
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      FormSection(
                                        title: 'Basic Information',
                                        children: [
                                          if (isWideScreen)
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: CustomTextField(
                                                    label: 'Customer Name *',
                                                    controller: _nameController,
                                                    errorText: errors['name'],
                                                    onChanged: (_) => validateField(
                                                      'name',
                                                      _nameController.text,
                                                      Validators.isValidUserName,
                                                      'Please enter a valid name',
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 16),
                                                Expanded(
                                                  child: CustomTextField(
                                                    label: 'GST Number',
                                                    controller: _gstNumberController,
                                                    errorText: errors['gstNumber'],
                                                    onChanged: (_) => validateField(
                                                      'gstNumber',
                                                      _gstNumberController.text,
                                                      (value) =>
                                                          value?.isEmpty == true ||
                                                          Validators.isValidGstNumber(value),
                                                      'Please enter a valid GST number',
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          else ...[
                                            CustomTextField(
                                              label: 'Customer Name *',
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
                                              label: 'GST Number',
                                              controller: _gstNumberController,
                                              errorText: errors['gstNumber'],
                                              onChanged: (_) => validateField(
                                                'gstNumber',
                                                _gstNumberController.text,
                                                (value) =>
                                                    value?.isEmpty == true ||
                                                    Validators.isValidGstNumber(value),
                                                'Please enter a valid GST number',
                                              ),
                                            ),
                                          ],
                                          SizedBox(height: 16),
                                          if (isWideScreen)
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: CustomTextField(
                                                    label: 'State Code',
                                                    controller: _stateCodeController,
                                                  ),
                                                ),
                                                SizedBox(width: 16),
                                                Expanded(
                                                  child: CustomTextField(
                                                    label: 'Contact Number *',
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
                                                ),
                                              ],
                                            )
                                          else ...[
                                            CustomTextField(
                                              label: 'State Code',
                                              controller: _stateCodeController,
                                            ),
                                            SizedBox(height: 16),
                                            CustomTextField(
                                              label: 'Contact Number *',
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
                                          SizedBox(height: 16),
                                          if (isWideScreen)
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: CustomTextField(
                                                    label: 'Email Address *',
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
                                                ),
                                                SizedBox(width: 16),
                                                Expanded(
                                                  child: CustomTextField(
                                                    label: 'Billing Address',
                                                    controller: _billingAddressController,
                                                  ),
                                                ),
                                              ],
                                            )
                                          else ...[
                                            CustomTextField(
                                              label: 'Email Address *',
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
                                              label: 'Billing Address',
                                              controller: _billingAddressController,
                                            ),
                                          ],
                                        ],
                                      ),
                                      SizedBox(height: 16),
                                      FormSection(
                                        title: 'Additional Information',
                                        children: [
                                          if (isWideScreen)
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: CustomTextField(
                                                    label: 'Shipping Address',
                                                    controller: _shippingAddressController,
                                                  ),
                                                ),
                                                SizedBox(width: 16),
                                                Expanded(
                                                  child: CustomTextField(
                                                    label: 'Opening Balance',
                                                    controller: _openingBalanceController,
                                                    keyboardType: TextInputType.numberWithOptions(
                                                        decimal: true),
                                                  ),
                                                ),
                                              ],
                                            )
                                          else ...[
                                            CustomTextField(
                                              label: 'Shipping Address',
                                              controller: _shippingAddressController,
                                            ),
                                            SizedBox(height: 16),
                                            CustomTextField(
                                              label: 'Opening Balance',
                                              controller: _openingBalanceController,
                                              keyboardType:
                                                  TextInputType.numberWithOptions(decimal: true),
                                            ),
                                          ],
                                          SizedBox(height: 16),
                                          GestureDetector(
                                            onTap: _selectDate,
                                            child: AbsorbPointer(
                                              child: CustomTextField(
                                                label: 'Opening Date',
                                                controller: _openingDateController,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 16),
                                          Row(
                                            children: [
                                              Checkbox(
                                                value: _isActive,
                                                onChanged: (value) {
                                                  setState(() {
                                                    _isActive = value ?? true;
                                                  });
                                                },
                                              ),
                                              Text(
                                                'Active',
                                                style: Theme.of(context).textTheme.bodyLarge,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 24),
                                      LoadingButton(
                                        isLoading: _isLoading,
                                        onPressed: _handleSubmit,
                                        text: widget.customer != null
                                            ? 'Update Customer'
                                            : 'Add Customer',
                                        loadingText: widget.customer != null
                                            ? 'Updating...'
                                            : 'Creating...',
                                      ),
                                      SizedBox(height: 16),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _gstNumberController.dispose();
    _stateCodeController.dispose();
    _billingAddressController.dispose();
    _shippingAddressController.dispose();
    _openingBalanceController.dispose();
    _openingDateController.dispose();
    super.dispose();
  }
}