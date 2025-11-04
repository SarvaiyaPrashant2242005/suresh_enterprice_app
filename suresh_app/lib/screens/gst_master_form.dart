import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/gst_master.dart';
import '../providers/gst_master_provider.dart';
import '../widgets/loading_indicator.dart';

// Bottom Sheet Form Widget
class GstMasterBottomSheet extends StatefulWidget {
  final GstMaster? gstMaster;

  const GstMasterBottomSheet({Key? key, this.gstMaster}) : super(key: key);

  static void show(BuildContext context, {GstMaster? gstMaster}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GstMasterBottomSheet(gstMaster: gstMaster),
    );
  }

  @override
  State<GstMasterBottomSheet> createState() => _GstMasterBottomSheetState();
}

class _GstMasterBottomSheetState extends State<GstMasterBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _gstRateController = TextEditingController();
  final _sgstController = TextEditingController();
  final _cgstController = TextEditingController();
  final _igstController = TextEditingController();
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.gstMaster != null) {
      final totalGst = widget.gstMaster!.cgst + widget.gstMaster!.sgst;
      _gstRateController.text = totalGst.toString();
      _sgstController.text = widget.gstMaster!.sgst.toString();
      _cgstController.text = widget.gstMaster!.cgst.toString();
      _igstController.text = widget.gstMaster!.igst.toString();
    }
  }

  @override
  void dispose() {
    _gstRateController.dispose();
    _sgstController.dispose();
    _cgstController.dispose();
    _igstController.dispose();
    super.dispose();
  }

  String? _validateTaxRate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Required';
    }
    final double? rate = double.tryParse(value);
    if (rate == null) {
      return 'Invalid number';
    }
    if (rate < 0 || rate > 100) {
      return 'Must be 0-100';
    }
    return null;
  }

  Future<void> _submitForm(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<GstMasterProvider>();

      final gstMaster = GstMaster(
        id: widget.gstMaster?.id,
        hsnCode: '', // Empty since HSN is removed
        cgst: double.parse(_cgstController.text),
        sgst: double.parse(_sgstController.text),
        igst: double.parse(_igstController.text),
        description: null,
      );

      try {
        if (widget.gstMaster != null && widget.gstMaster!.id != null) {
          await provider.updateGstMaster(widget.gstMaster!.id!, gstMaster);
        } else {
          await provider.addGstMaster(gstMaster);
        }

        if (!mounted) return;
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.gstMaster != null
                ? 'GST Rate updated successfully'
                : 'GST Rate added successfully'),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.gstMaster != null;
    final provider = context.watch<GstMasterProvider>();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEditing ? 'Edit GST Rate' : 'Add GST Rate',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // GST Rate Fields in a Row
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _gstRateController,
                          decoration: const InputDecoration(
                            labelText: 'GST Rate (%)',
                            hintText: 'e.g., 18',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: _validateTaxRate,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _sgstController,
                          decoration: const InputDecoration(
                            labelText: 'SGST Rate (%)',
                            hintText: 'e.g., 9',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: _validateTaxRate,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _cgstController,
                          decoration: const InputDecoration(
                            labelText: 'CGST Rate (%)',
                            hintText: 'e.g., 9',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: _validateTaxRate,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _igstController,
                          decoration: const InputDecoration(
                            labelText: 'IGST Rate (%)',
                            hintText: 'e.g., 18',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: _validateTaxRate,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Active Checkbox
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
                      const Text(
                        'Active',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: provider.isLoading
                          ? null
                          : () => _submitForm(context),
                      child: provider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Save GST',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}           