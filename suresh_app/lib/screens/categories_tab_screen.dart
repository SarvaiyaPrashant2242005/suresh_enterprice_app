import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/category.dart';
import '../providers/category_provider.dart';
import '../providers/auth_provider_updated.dart';
import '../utils/dialog_utils.dart';
import '../widgets/loading_overlay.dart';
import 'category_form_screen.dart';

class CategoriesTabScreen extends StatefulWidget {
  const CategoriesTabScreen({Key? key}) : super(key: key);

  @override
  _CategoriesTabScreenState createState() => _CategoriesTabScreenState();
}

class _CategoriesTabScreenState extends State<CategoriesTabScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch categories on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final userType = auth.authData?['user']?['userType'] ?? auth.authData?['userType'];
      Provider.of<CategoryProvider>(context, listen: false).fetchCategories(userType: userType);
    });
  }

  Future<void> _refreshCategories(BuildContext context) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userType = auth.authData?['user']?['userType'] ?? auth.authData?['userType'];
    await Provider.of<CategoryProvider>(context, listen: false).fetchCategories(userType: userType);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, provider, child) {
        return LoadingOverlay(
          isLoading: provider.isLoading,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoryFormScreen(),
                      ),
                    );
                    if (result == true) {
                      await _refreshCategories(context);
                    }
                  },
                  child: Text('Add New Category'),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => _refreshCategories(context),
                  child: ListView.builder(
                    itemCount: provider.categories.length,
                    itemBuilder: (context, index) {
                      final category = provider.categories[index];
                      return Card(
                        margin: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          title: Text(category.name),
                        
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CategoryFormScreen(
                                        category: category,
                                      ),
                                    ),
                                  );
                                  if (result == true) {
                                    await _refreshCategories(context);
                                  }
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                color: Colors.red,
                                onPressed: () async {
                                  final confirmed = await DialogUtils.showConfirmDialog(
                                    context,
                                    'Delete Category',
                                    'Are you sure you want to delete \\${category.name}?',
                                  );
                                  if (!confirmed) return;
                                  final deleted = await provider.deleteCategory(category.id!);
                                  if (deleted) {
                                    DialogUtils.showSuccess(context, 'Category deleted successfully');
                                  } else if (provider.errorMessage != null) {
                                    DialogUtils.showError(context, provider.errorMessage!);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}