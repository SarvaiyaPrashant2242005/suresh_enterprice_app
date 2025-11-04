import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider_updated.dart';
import '../providers/customer_provider.dart';
import '../providers/category_provider.dart';
import '../providers/product_provider.dart';
import '../providers/gst_master_provider.dart';
import '../providers/user_provider.dart';
import '../screens/login_screen.dart';

class SidebarDrawer extends StatelessWidget {
  final Function(String) onSelect;
  final String currentSelection;

  const SidebarDrawer({
    Key? key, 
    required this.onSelect,
    this.currentSelection = 'Home',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    
    // Debug: Print auth data to console
    debugPrint('Auth Data: ${auth.authData}');
    
    // Try multiple paths to get userType
    final userType = auth.authData?['user']?['userType'] ?? 
                     auth.authData?['userType'] ?? 
                     'User';
    final userName = auth.authData?['user']?['name'] ?? 
                     auth.authData?['name'] ?? 
                     'User';
    final userEmail = auth.authData?['user']?['email'] ?? 
                      auth.authData?['email'] ?? 
                      'user@example.com';

    // Debug: Print userType
    debugPrint('User Type: $userType');
    debugPrint('Is Admin: ${userType == 'Admin'}');

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            accountName: Text(
              userName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            accountEmail: Text(userEmail),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                style: TextStyle(
                  fontSize: 40.0,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            otherAccountsPictures: [
              // Show user type badge
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  userType,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.home,
            title: 'Home',
            isSelected: currentSelection == 'Home',
            onTap: () {
              onSelect('Home');
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.category,
            title: 'Categories',
            isSelected: currentSelection == 'Categories',
            onTap: () {
              onSelect('Categories');
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.inventory,
            title: 'Products',
            isSelected: currentSelection == 'Products',
            onTap: () {
              onSelect('Products');
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.people,
            title: 'Customers',
            isSelected: currentSelection == 'Customers',
            onTap: () {
              // Trigger fetch before navigating with userType
              final auth = Provider.of<AuthProvider>(context, listen: false);
              final userType = auth.authData?['user']?['userType'] ?? 
                               auth.authData?['userType'];
              Provider.of<CustomerProvider>(context, listen: false)
                  .fetchCustomers(userType: userType);
              onSelect('Customers');
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.receipt,
            title: 'GST Master',
            isSelected: currentSelection == 'GST Master',
            onTap: () {
              onSelect('GST Master');
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.receipt_long,
            title: 'Invoices',
            isSelected: currentSelection == 'Invoices',
            onTap: () {
              onSelect('Invoices');
              Navigator.pop(context);
            },
          ),
          // Show Users menu for Admin OR temporarily for all users (for testing)
          // Remove the condition temporarily to see if it appears
          // if (userType == 'Admin' || userType == 'admin' || userType.toLowerCase() == 'admin')
          _buildDrawerItem(
            context: context,
            icon: Icons.people_alt,
            title: 'Users',
            isSelected: currentSelection == 'Users',
            onTap: () {
              onSelect('Users');
              Navigator.pop(context);
            },
          ),
          // Add a debug info item (remove after testing)
          if (userType != 'Admin')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Current User Type: $userType',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          const Divider(),
          _buildDrawerItem(
            context: context,
            icon: Icons.person,
            title: 'Profile',
            isSelected: currentSelection == 'Profile',
            onTap: () {
              onSelect('Profile');
              Navigator.pop(context);
            },
          ),
          const Divider(),
          _buildLogoutItem(
            context: context,
            icon: Icons.logout,
            title: 'Logout',
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Theme.of(context).primaryColor : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Theme.of(context).primaryColor : null,
        ),
      ),
      selected: isSelected,
      selectedTileColor: Theme.of(context).primaryColor.withOpacity(0.1),
      onTap: onTap,
    );
  }

  Widget _buildLogoutItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: const Icon(Icons.logout, color: Colors.red),
      title: const Text(
        'Logout',
        style: TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Row(
            children: [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 8),
              Text('Confirm Logout'),
            ],
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _performLogout(context);
    }
  }

  Future<void> _performLogout(BuildContext context) async {
    // Get the root navigator and scaffold messenger before any operations
    final navigatorState = Navigator.of(context, rootNavigator: true);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    // Close drawer
    Navigator.of(context).pop();
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext loadingContext) {
        return WillPopScope(
          onWillPop: () async => false,
          child: const Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Logging out...'),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    try {
      // Clear all provider states
      await _clearAllStates(context);
      
      // Perform logout
      final auth = Provider.of<AuthProvider>(context, listen: false);
      await auth.logout();
      
      // Small delay to ensure everything is cleared
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Navigate to login screen - remove all previous routes
      navigatorState.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      debugPrint('Logout error: $e');
      
      // Close loading dialog
      try {
        navigatorState.pop();
      } catch (_) {}
      
      // Show error message
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Logout failed: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () => _performLogout(context),
          ),
        ),
      );
    }
  }

  Future<void> _clearAllStates(BuildContext context) async {
    try {
      // Clear Category Provider
      try {
        final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
        // If you have a clear method: categoryProvider.clear();
      } catch (e) {
        debugPrint('Error clearing CategoryProvider: $e');
      }
      
      // Clear Product Provider
      try {
        final productProvider = Provider.of<ProductProvider>(context, listen: false);
        // If you have a clear method: productProvider.clear();
      } catch (e) {
        debugPrint('Error clearing ProductProvider: $e');
      }
      
      // Clear Customer Provider
      try {
        final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
        // If you have a clear method: customerProvider.clear();
      } catch (e) {
        debugPrint('Error clearing CustomerProvider: $e');
      }
      
      // Clear GST Master Provider
      try {
        final gstMasterProvider = Provider.of<GstMasterProvider>(context, listen: false);
        // If you have a clear method: gstMasterProvider.clear();
      } catch (e) {
        debugPrint('Error clearing GstMasterProvider: $e');
      }
      
      // Clear User Provider
      try {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.clear();
      } catch (e) {
        debugPrint('Error clearing UserProvider: $e');
      }
    } catch (e) {
      debugPrint('Error clearing provider states: $e');
    }
  }
}