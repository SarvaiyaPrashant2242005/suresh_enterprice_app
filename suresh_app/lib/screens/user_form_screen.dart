import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../mixins/form_validation_mixin.dart';
import '../model/user.dart';
import '../services/api_client.dart';
import '../utils/dialog_utils.dart';
import '../utils/validators.dart';
import '../widgets/form_widgets.dart';
import '../widgets/loading_overlay.dart';

class UserFormScreen extends StatefulWidget {
  final User? user;

  const UserFormScreen({Key? key, this.user}) : super(key: key);

  @override
  _UserFormScreenState createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> with FormValidationMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;
  bool _isLoading = false;
  String _selectedUserType = 'Customer User';
  String? _selectedCompanyId;
  bool _withGst = true;
  bool _withoutGst = false;
  List<Map<String, dynamic>> _companies = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.name);
    _emailController = TextEditingController(text: widget.user?.email);
    _phoneController = TextEditingController(text: widget.user?.phone);
    _passwordController = TextEditingController();

    if (widget.user != null) {
      _selectedUserType = widget.user?.userType ?? 'Customer User';
      _selectedCompanyId = widget.user?.companyId?.toString();
      _withGst = widget.user?.withGst ?? true;
      _withoutGst = widget.user?.withoutGst ?? false;
    }

    _loadCompanies();
  }

  Future<void> _loadCompanies() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<ApiClient>();
      final companies = await api.getCompanyProfiles();
      setState(() {
        _companies = companies.map((c) => {
          'id': c.id.toString(),
          'name': c.companyName,
        }).toList();
      });
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
    });
  }

  Future<void> _handleSubmit() async {
    if (!_validateForm()) return;
    if (!_withGst && !_withoutGst) {
      DialogUtils.showError(context, 'Please select either With GST or Without GST');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = User(
        id: widget.user?.id,
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        userType: _selectedUserType,
        companyId: _selectedCompanyId != null ? int.parse(_selectedCompanyId!) : null,
        password: _passwordController.text.isEmpty ? null : _passwordController.text,
        withGst: _withGst,
        withoutGst: _withoutGst,
      );

      final api = context.read<ApiClient>();
      if (widget.user != null) {
        await api.updateUser(widget.user!.id!, user);
      } else {
        await api.createUser(user);
      }

      DialogUtils.showSuccess(
        context,
        'User ${widget.user != null ? 'updated' : 'created'} successfully',
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
          title: Text(widget.user != null ? 'Edit User' : 'Create User'),
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
                    if (widget.user == null) ...[
                      SizedBox(height: 16),
                      CustomTextField(
                        label: 'Password *',
                        controller: _passwordController,
                        isPassword: true,
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 16),
                FormSection(
                  title: 'User Settings',
                  children: [
                    CustomDropdown<String>(
                      label: 'User Type',
                      value: _selectedUserType,
                      items: [
                        DropdownMenuItem(
                          value: 'Admin User',
                          child: Text('Admin User'),
                        ),
                        DropdownMenuItem(
                          value: 'Customer User',
                          child: Text('Customer User'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedUserType = value);
                        }
                      },
                    ),
                    SizedBox(height: 16),
                    CustomDropdown<String>(
                      label: 'Company',
                      value: _selectedCompanyId,
                      items: [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text('-- Select Company --'),
                        ),
                        ..._companies.map((company) => DropdownMenuItem(
                          value: company['id'],
                          child: Text(company['name']),
                        )),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedCompanyId = value);
                      },
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CheckboxListTile(
                            title: Text('With GST'),
                            value: _withGst,
                            onChanged: (value) {
                              setState(() => _withGst = value ?? false);
                            },
                          ),
                        ),
                        Expanded(
                          child: CheckboxListTile(
                            title: Text('Without GST'),
                            value: _withoutGst,
                            onChanged: (value) {
                              setState(() => _withoutGst = value ?? false);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 24),
                LoadingButton(
                  isLoading: _isLoading,
                  onPressed: _handleSubmit,
                  text: widget.user != null ? 'Update User' : 'Create User',
                  loadingText: widget.user != null ? 'Updating...' : 'Creating...',
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
    _passwordController.dispose();
    super.dispose();
  }
}