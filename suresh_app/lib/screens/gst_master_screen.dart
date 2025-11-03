import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/gst_master.dart';
import '../utils/validators.dart';
import '../providers/gst_master_provider.dart';
import '../widgets/loading_indicator.dart';

class GstMasterScreen extends StatefulWidget {
  const GstMasterScreen({Key? key}) : super(key: key);

  @override
  State<GstMasterScreen> createState() => _GstMasterScreenState();
}

class _GstMasterScreenState extends State<GstMasterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hsnController = TextEditingController();
  final _cgstController = TextEditingController();
  final _sgstController = TextEditingController();
  final _igstController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GstMasterProvider>(context, listen: false).fetchGstMasters();
    });
  }

  @override
  void dispose() {
    _hsnController.dispose();
    _cgstController.dispose();
    _sgstController.dispose();
    _igstController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _hsnController.clear();
    _cgstController.clear();
    _sgstController.clear();
    _igstController.clear();
    _descriptionController.clear();
  }

  void _showAddEditDialog(BuildContext context, [GstMaster? gstMaster]) {
    if (gstMaster != null) {
      _hsnController.text = gstMaster.hsnCode;
      _cgstController.text = gstMaster.cgst.toString();
      _sgstController.text = gstMaster.sgst.toString();
      _igstController.text = gstMaster.igst.toString();
      _descriptionController.text = gstMaster.description ?? '';
    } else {
      _resetForm();
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(gstMaster == null ? 'Add GST Master' : 'Edit GST Master'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _hsnController,
                  decoration: const InputDecoration(labelText: 'HSN Code'),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter HSN Code';
                    if (!Validators.isValidHsnCode(value)) return 'Invalid HSN Code';
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _cgstController,
                        decoration: const InputDecoration(labelText: 'CGST (%)'),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter CGST';
                          if (double.tryParse(value) == null) return 'Enter valid number';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _sgstController,
                        decoration: const InputDecoration(labelText: 'SGST (%)'),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter SGST';
                          if (double.tryParse(value) == null) return 'Enter valid number';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _igstController,
                  decoration: const InputDecoration(labelText: 'IGST (%)'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter IGST';
                    if (double.tryParse(value) == null) return 'Enter valid number';
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final gstData = GstMaster(
                  id: gstMaster?.id,
                  hsnCode: _hsnController.text,
                  cgst: double.parse(_cgstController.text),
                  sgst: double.parse(_sgstController.text),
                  igst: double.parse(_igstController.text),
                  description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
                );

                if (gstMaster == null) {
                  Provider.of<GstMasterProvider>(context, listen: false)
                      .addGstMaster(gstData);
                } else {
                  Provider.of<GstMasterProvider>(context, listen: false)
                      .updateGstMaster(gstMaster.id!, gstData);
                }

                Navigator.of(ctx).pop();
              }
            },
            child: Text(gstMaster == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<GstMasterProvider>(
        builder: (ctx, gstMasterProvider, child) {
          if (gstMasterProvider.isLoading) {
            return const LoadingIndicator();
          }

          if (gstMasterProvider.errorMessage != null && gstMasterProvider.errorMessage!.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${gstMasterProvider.errorMessage}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => gstMasterProvider.fetchGstMasters(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (gstMasterProvider.gstMasters.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No GST rates found'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showAddEditDialog(context),
                    child: const Text('Add GST Rate'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => gstMasterProvider.fetchGstMasters(),
            child: ListView.builder(
              itemCount: gstMasterProvider.gstMasters.length,
              itemBuilder: (ctx, index) {
                final gstMaster = gstMasterProvider.gstMasters[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  child: ListTile(
                    title: Text(gstMaster.hsnCode),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CGST: ${gstMaster.cgst}%'),
                        Text('SGST: ${gstMaster.sgst}%'),
                        Text('IGST: ${gstMaster.igst}%'),
                        if (gstMaster.description != null && 
                            gstMaster.description!.isNotEmpty)
                          Text('Description: ${gstMaster.description}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showAddEditDialog(context, gstMaster),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Delete GST Rate'),
                                content: const Text(
                                  'Are you sure you want to delete this GST rate?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      if (gstMaster.id != null) {
                                        gstMasterProvider.deleteGstMaster(gstMaster.id.toString());
                                      }
                                      Navigator.of(ctx).pop();
                                    },
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}