import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/gst_master.dart';
import '../providers/gst_master_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/loading_button.dart';
import '../mixins/form_validation_mixin.dart';

class GstMasterForm extends StatefulWidget {
  final GstMaster? gstMaster;

  const GstMasterForm({Key? key, this.gstMaster}) : super(key: key);

  @override
  _GstMasterFormState createState() => _GstMasterFormState();
}

class _GstMasterFormState extends State<GstMasterForm> with FormValidationMixin {
  final _formKey = GlobalKey<FormState>();
  final _hsnCodeController = TextEditingController();
  final _cgstController = TextEditingController();
  final _sgstController = TextEditingController();
  final _igstController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.gstMaster != null) {
      _hsnCodeController.text = widget.gstMaster!.hsnCode;
      _cgstController.text = widget.gstMaster!.cgst.toString();
      _sgstController.text = widget.gstMaster!.sgst.toString();
      _igstController.text = widget.gstMaster!.igst.toString();
      _descriptionController.text = widget.gstMaster?.description ?? '';
    }
  }

  @override
  void dispose() {
    _hsnCodeController.dispose();
    _cgstController.dispose();
    _sgstController.dispose();
    _igstController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitForm(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<GstMasterProvider>();
      
      final gstMaster = GstMaster(
        id: widget.gstMaster?.id,
        hsnCode: _hsnCodeController.text,
        cgst: double.parse(_cgstController.text),
        sgst: double.parse(_sgstController.text),
        igst: double.parse(_igstController.text),
        description: _descriptionController.text.isNotEmpty 
            ? _descriptionController.text 
            : null,
      );

      try {
        if (widget.gstMaster != null) {
          await provider.updateGstMaster(widget.gstMaster!.id!, gstMaster);
        } else {
          await provider.addGstMaster(gstMaster);
        }

        if (!mounted) return;
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  String? _validateTaxRate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a tax rate';
    }
    
    final double? rate = double.tryParse(value);
    if (rate == null) {
      return 'Please enter a valid number';
    }
    
    if (rate < 0 || rate > 100) {
      return 'Tax rate must be between 0 and 100';
    }
    
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.gstMaster != null;
    final provider = context.watch<GstMasterProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit GST Master' : 'Add GST Master'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            CustomTextField(
              controller: _hsnCodeController,
              label: 'HSN Code',
              validator: (value) => validateRequired(value, 'HSN Code'),
              maxLength: 8,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _cgstController,
              label: 'CGST Rate (%)',
              validator: _validateTaxRate,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _sgstController,
              label: 'SGST Rate (%)',
              validator: _validateTaxRate,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _igstController,
              label: 'IGST Rate (%)',
              validator: _validateTaxRate,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _descriptionController,
              label: 'Description',
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            LoadingButton(
              onPressed: () => _submitForm(context),
              loading: provider.isLoading,
              label: isEditing ? 'Update' : 'Save',
            ),
          ],
        ),
      ),
    );
  }
}