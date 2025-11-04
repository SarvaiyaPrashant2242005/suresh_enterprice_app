import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/gst_master.dart';
import '../providers/gst_master_provider.dart';
import '../widgets/loading_indicator.dart';
import 'gst_master_form.dart';

class GstMasterScreen extends StatefulWidget {
  const GstMasterScreen({Key? key}) : super(key: key);

  @override
  State<GstMasterScreen> createState() => _GstMasterScreenState();
}

class _GstMasterScreenState extends State<GstMasterScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GstMasterProvider>(context, listen: false).fetchGstMasters();
    });
  }

  void _showAddEditBottomSheet([GstMaster? gstMaster]) {
    GstMasterBottomSheet.show(context, gstMaster: gstMaster);
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
                    onPressed: () => _showAddEditBottomSheet(),
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
                    title: Text('GST Rate: ${gstMaster.gstRate.toStringAsFixed(2)}%'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CGST Rate: ${gstMaster.cgstRate.toStringAsFixed(2)}%'),
                        Text('SGST Rate: ${gstMaster.sgstRate.toStringAsFixed(2)}%'),
                        Text('IGST Rate: ${gstMaster.igstRate.toStringAsFixed(2)}%'),
                        Text(
                          'Status: ${gstMaster.isActive ? 'Active' : 'Inactive'}',
                          style: TextStyle(
                            color: gstMaster.isActive ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showAddEditBottomSheet(gstMaster),
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
                                        gstMasterProvider.deleteGstMaster(gstMaster.id!.toString());
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
        onPressed: () => _showAddEditBottomSheet(),
        child: const Icon(Icons.add),
      ),
    );
  }
}