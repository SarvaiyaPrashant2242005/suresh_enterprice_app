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
  late final TextEditingController _gstRateController;
  late final TextEditingController _cgstController;
  late final TextEditingController _sgstController;
  late final TextEditingController _igstController;
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _gstRateController = TextEditingController(
      text: widget.gstMaster?.gstRate?.toString() ?? '',
    );
    _cgstController = TextEditingController(
      text: widget.gstMaster?.cgstRate?.toString() ?? '',
    );
    _sgstController = TextEditingController(
      text: widget.gstMaster?.sgstRate?.toString() ?? '',
    );
    _igstController = TextEditingController(
      text: widget.gstMaster?.igstRate?.toString() ?? '',
    );
    _isActive = widget.gstMaster?.isActive ?? true;
  }

  bool _validateForm() {
    if (!_formKey.currentState!.validate()) return false;

    return validateFields({
      'gstRate': ValidationRule(
        value: _gstRateController.text,
        validator: Validators.isValidPrice,
        errorMessage: 'Please enter a valid GST rate',
      ),
      'cgstRate': ValidationRule(
        value: _cgstController.text,
        validator: Validators.isValidPrice,
        errorMessage: 'Please enter a valid CGST rate',
      ),
      'sgstRate': ValidationRule(
        value: _sgstController.text,
        validator: Validators.isValidPrice,
        errorMessage: 'Please enter a valid SGST rate',
      ),
      'igstRate': ValidationRule(
        value: _igstController.text,
        validator: Validators.isValidPrice,
        errorMessage: 'Please enter a valid IGST rate',
      ),
    });
  }

  Future<void> _handleSubmit() async {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);

    try {
      final gstMaster = GstMaster(
        id: widget.gstMaster?.id,
        gstRate: double.parse(_gstRateController.text),
        cgstRate: double.parse(_cgstController.text),
        sgstRate: double.parse(_sgstController.text),
        igstRate: double.parse(_igstController.text),
        isActive: _isActive,
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
                      label: 'GST Rate (%) *',
                      controller: _gstRateController,
                      errorText: errors['gstRate'],
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => validateField(
                        'gstRate',
                        _gstRateController.text,
                        Validators.isValidPrice,
                        'Please enter a valid GST rate',
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: 'CGST Rate (%) *',
                            controller: _cgstController,
                            errorText: errors['cgstRate'],
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            onChanged: (_) => validateField(
                              'cgstRate',
                              _cgstController.text,
                              Validators.isValidPrice,
                              'Please enter a valid CGST rate',
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: CustomTextField(
                            label: 'SGST Rate (%) *',
                            controller: _sgstController,
                            errorText: errors['sgstRate'],
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            onChanged: (_) => validateField(
                              'sgstRate',
                              _sgstController.text,
                              Validators.isValidPrice,
                              'Please enter a valid SGST rate',
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    CustomTextField(
                      label: 'IGST Rate (%) *',
                      controller: _igstController,
                      errorText: errors['igstRate'],
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => validateField(
                        'igstRate',
                        _igstController.text,
                        Validators.isValidPrice,
                        'Please enter a valid IGST rate',
                      ),
                    ),
                    SizedBox(height: 16),
                    CheckboxListTile(
                      title: const Text('Active'),
                      value: _isActive,
                      onChanged: (value) {
                        setState(() {
                          _isActive = value ?? true;
                        });
                      },
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
    _gstRateController.dispose();
    _cgstController.dispose();
    _sgstController.dispose();
    _igstController.dispose();
    super.dispose();
  }
}