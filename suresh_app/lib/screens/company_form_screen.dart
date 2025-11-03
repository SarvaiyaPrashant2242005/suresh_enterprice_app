import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../mixins/form_validation_mixin.dart';
import '../model/company_profile.dart';
import '../services/api_client.dart';
import '../utils/dialog_utils.dart';
import '../utils/validators.dart';
import '../widgets/form_widgets.dart';
import '../widgets/loading_overlay.dart';

class CompanyFormScreen extends StatefulWidget {
  final CompanyProfile? company;

  const CompanyFormScreen({Key? key, this.company}) : super(key: key);

  @override
  _CompanyFormScreenState createState() => _CompanyFormScreenState();
}

class _CompanyFormScreenState extends State<CompanyFormScreen> with FormValidationMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _gstNumberController;
  File? _logoFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.company?.companyName);
    _emailController = TextEditingController(text: widget.company?.email);
    _phoneController = TextEditingController(text: widget.company?.phone);
    _addressController = TextEditingController(text: widget.company?.address);
    _gstNumberController = TextEditingController(text: widget.company?.gstNumber);
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
      );
      
      if (pickedFile != null) {
        setState(() {
          _logoFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      DialogUtils.showError(context, 'Failed to pick image: $e');
    }
  }

  bool _validateForm() {
    if (!_formKey.currentState!.validate()) return false;

    return validateFields({
      'name': ValidationRule(
        value: _nameController.text,
        validator: Validators.isNotEmpty,
        errorMessage: 'Company name is required',
      ),
      'email': ValidationRule(
        value: _emailController.text,
        validator: (value) => value?.isEmpty == true || Validators.isValidEmail(value),
        errorMessage: 'Please enter a valid email',
      ),
      'phone': ValidationRule(
        value: _phoneController.text,
        validator: (value) => value?.isEmpty == true || Validators.isValidPhoneNumber(value),
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
      final company = CompanyProfile(
        id: widget.company?.id,
        companyName: _nameController.text,
        email: _emailController.text.isEmpty ? null : _emailController.text,
        phone: _phoneController.text.isEmpty ? null : _phoneController.text,
        address: _addressController.text.isEmpty ? null : _addressController.text,
        gstNumber: _gstNumberController.text.isEmpty ? null : _gstNumberController.text,
      );

      final api = context.read<ApiClient>();
      if (widget.company != null) {
        await api.updateCompanyProfile(widget.company!.id!, company, _logoFile);
      } else {
        await api.createCompanyProfile(company, _logoFile);
      }

      DialogUtils.showSuccess(
        context,
        'Company ${widget.company != null ? 'updated' : 'created'} successfully',
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
          title: Text(widget.company != null ? 'Edit Company' : 'Create Company'),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FormSection(
                  title: 'Company Logo',
                  children: [
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: _logoFile != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(
                                      _logoFile!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : widget.company?.companyLogo != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          widget.company!.companyLogo!,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Icon(
                                        Icons.business,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                          ),
                          FloatingActionButton.small(
                            onPressed: _pickImage,
                            child: Icon(Icons.edit),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                FormSection(
                  title: 'Basic Information',
                  children: [
                    CustomTextField(
                      label: 'Company Name *',
                      controller: _nameController,
                      errorText: errors['name'],
                      onChanged: (_) => validateField(
                        'name',
                        _nameController.text,
                        Validators.isNotEmpty,
                        'Company name is required',
                      ),
                    ),
                    SizedBox(height: 16),
                    CustomTextField(
                      label: 'Email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      errorText: errors['email'],
                      onChanged: (_) => validateField(
                        'email',
                        _emailController.text,
                        (value) => value?.isEmpty == true || Validators.isValidEmail(value),
                        'Please enter a valid email',
                      ),
                    ),
                    SizedBox(height: 16),
                    CustomTextField(
                      label: 'Phone',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      errorText: errors['phone'],
                      onChanged: (_) => validateField(
                        'phone',
                        _phoneController.text,
                        (value) => value?.isEmpty == true || Validators.isValidPhoneNumber(value),
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
                  text: widget.company != null ? 'Update Company' : 'Create Company',
                  loadingText: widget.company != null ? 'Updating...' : 'Creating...',
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