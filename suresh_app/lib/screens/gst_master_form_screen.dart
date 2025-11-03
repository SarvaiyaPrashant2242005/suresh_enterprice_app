import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../mixins/form_validation_mixin.dart';
import '../model/gst_master.dart';
import '../services/api_client.dart';
import '../utils/dialog_utils.dart';
import '../utils/validators.dart';
import '../widgets/form_widgets.dart';
import '../widgets/loading_overlay.dart';

class GstMasterFormScreen extends StatefulWidget {
  final GstMaster? gstMaster;

  const GstMasterFormScreen({Key? key, this.gstMaster}) : super(key: key);

  @override
  _GstMasterFormScreenState createState() => _GstMasterFormScreenState();
}

class _GstMasterFormScreenState extends State<GstMasterFormScreen> with FormValidationMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _cgstController;
  late final TextEditingController _sgstController;
  late final TextEditingController _igstController;
  late final TextEditingController _hsnCodeController;
  late final TextEditingController _descriptionController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _cgstController = TextEditingController(
      text: widget.gstMaster?.cgst?.toString() ?? '',
    );
    _sgstController = TextEditingController(
      text: widget.gstMaster?.sgst?.toString() ?? '',
    );
    _igstController = TextEditingController(
      text: widget.gstMaster?.igst?.toString() ?? '',
    );
    _hsnCodeController = TextEditingController(
      text: widget.gstMaster?.hsnCode ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.gstMaster?.description ?? '',
    );
  }

  bool _validateForm() {
    if (!_formKey.currentState!.validate()) return false;

    return validateFields({
      'hsnCode': ValidationRule(
        value: _hsnCodeController.text,
        validator: Validators.isValidHsnCode,
        errorMessage: 'Please enter a valid HSN code',
      ),
      'cgst': ValidationRule(
        value: _cgstController.text,
        validator: Validators.isValidPrice,
        errorMessage: 'Please enter a valid CGST percentage',
      ),
      'sgst': ValidationRule(
        value: _sgstController.text,
        validator: Validators.isValidPrice,
        errorMessage: 'Please enter a valid SGST percentage',
      ),
      'igst': ValidationRule(
        value: _igstController.text,
        validator: Validators.isValidPrice,
        errorMessage: 'Please enter a valid IGST percentage',
      ),
    });
  }

  Future<void> _handleSubmit() async {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);

    try {
      final gstMaster = GstMaster(
        id: widget.gstMaster?.id,
        hsnCode: _hsnCodeController.text,
        cgst: double.parse(_cgstController.text),
        sgst: double.parse(_sgstController.text),
        igst: double.parse(_igstController.text),
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
      );

      final api = context.read<ApiClient>();
      if (widget.gstMaster != null) {
        await api.updateGstMaster(widget.gstMaster!.id!, gstMaster);
      } else {
        await api.createGstMaster(gstMaster);
      }

      DialogUtils.showSuccess(
        context,
        'GST Master ${widget.gstMaster != null ? 'updated' : 'created'} successfully',
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
          title: Text(widget.gstMaster != null ? 'Edit GST Master' : 'Create GST Master'),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FormSection(
                  title: 'GST Details',
                  children: [
                    CustomTextField(
                      label: 'HSN Code *',
                      controller: _hsnCodeController,
                      errorText: errors['hsnCode'],
                      keyboardType: TextInputType.number,
                      onChanged: (_) => validateField(
                        'hsnCode',
                        _hsnCodeController.text,
                        Validators.isValidHsnCode,
                        'Please enter a valid HSN code',
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: 'CGST % *',
                            controller: _cgstController,
                            errorText: errors['cgst'],
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            onChanged: (_) => validateField(
                              'cgst',
                              _cgstController.text,
                              Validators.isValidPrice,
                              'Please enter a valid percentage',
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: CustomTextField(
                            label: 'SGST % *',
                            controller: _sgstController,
                            errorText: errors['sgst'],
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            onChanged: (_) => validateField(
                              'sgst',
                              _sgstController.text,
                              Validators.isValidPrice,
                              'Please enter a valid percentage',
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    CustomTextField(
                      label: 'IGST % *',
                      controller: _igstController,
                      errorText: errors['igst'],
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => validateField(
                        'igst',
                        _igstController.text,
                        Validators.isValidPrice,
                        'Please enter a valid percentage',
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
                  text: widget.gstMaster != null ? 'Update GST Master' : 'Create GST Master',
                  loadingText: widget.gstMaster != null ? 'Updating...' : 'Creating...',
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
    _cgstController.dispose();
    _sgstController.dispose();
    _igstController.dispose();
    _hsnCodeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}