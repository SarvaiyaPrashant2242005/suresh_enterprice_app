import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/gst_master.dart';
import '../providers/gst_master_provider.dart';
import '../widgets/loading_button.dart';
import 'gst_master_form.dart';

class GstMasterList extends StatefulWidget {
  const GstMasterList({Key? key}) : super(key: key);

  @override
  _GstMasterListState createState() => _GstMasterListState();
}

class _GstMasterListState extends State<GstMasterList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GstMasterProvider>().fetchGstMasters();
    });
  }

  Future<void> _confirmDelete(BuildContext context, GstMaster gstMaster) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${gstMaster.hsnCode}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      final provider = context.read<GstMasterProvider>();
      try {
        await provider.deleteGstMaster(gstMaster.id.toString());
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('GST entry deleted successfully')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GST Master'),
      ),
      body: Consumer<GstMasterProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(provider.error!),
                  const SizedBox(height: 16),
                  LoadingButton(
                    onPressed: () => provider.fetchGstMasters(),
                    loading: false,
                    label: 'Retry',
                  ),
                ],
              ),
            );
          }

          if (provider.gstMasters.isEmpty) {
            return const Center(child: Text('No GST entries found'));
          }

          return ListView.builder(
            itemCount: provider.gstMasters.length,
            itemBuilder: (context, index) {
              final gstMaster = provider.gstMasters[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text('HSN Code: ${gstMaster.hsnCode}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('CGST: ${gstMaster.cgst}%'),
                      Text('SGST: ${gstMaster.sgst}%'),
                      Text('IGST: ${gstMaster.igst}%'),
                      if (gstMaster.description != null)
                        Text('Description: ${gstMaster.description}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => GstMasterBottomSheet(
                                gstMaster: gstMaster,
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _confirmDelete(context, gstMaster),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const GstMasterBottomSheet(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}