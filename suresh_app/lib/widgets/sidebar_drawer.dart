import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:suresh_app/screens/user_screen.dart';
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

    final userType = auth.authData?['user']?['userType'] ??
        auth.authData?['userType'] ??
        'User';
    final userName =
        auth.authData?['user']?['name'] ?? auth.authData?['name'] ?? 'User';
    final userEmail = auth.authData?['user']?['email'] ??
        auth.authData?['email'] ??
        'user@example.com';

    final theme = Theme.of(context);

    return Drawer(
      backgroundColor: Colors.grey[100], // soft background
      child: Column(
        children: [
          // Header Section
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF009688), Color(0xFF26A69A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            accountName: Text(
              userName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            accountEmail: Text(
              userEmail,
              style: const TextStyle(fontSize: 13),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                style: const TextStyle(
                  fontSize: 36.0,
                  color: Color(0xFF009688),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          ),

          // Scrollable List Items
          Expanded(
            child: ListView(
              children: [
                _buildDrawerItem(
                  context: context,
                  icon: Icons.home_rounded,
                  title: 'Home',
                  isSelected: currentSelection == 'Home',
                  onTap: () {
                    onSelect('Home');
                    Navigator.pop(context);
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.category_outlined,
                  title: 'Categories',
                  isSelected: currentSelection == 'Categories',
                  onTap: () {
                    onSelect('Categories');
                    Navigator.pop(context);
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.inventory_2_outlined,
                  title: 'Products',
                  isSelected: currentSelection == 'Products',
                  onTap: () {
                    onSelect('Products');
                    Navigator.pop(context);
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.people_outline,
                  title: 'Customers',
                  isSelected: currentSelection == 'Customers',
                  onTap: () {
                    final auth =
                        Provider.of<AuthProvider>(context, listen: false);
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
                  icon: Icons.receipt_long,
                  title: 'GST Master',
                  isSelected: currentSelection == 'GST Master',
                  onTap: () {
                    onSelect('GST Master');
                    Navigator.pop(context);
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.receipt,
                  title: 'Invoices',
                  isSelected: currentSelection == 'Invoices',
                  onTap: () {
                    onSelect('Invoices');
                    Navigator.pop(context);
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.people_alt_rounded,
                  title: 'Users',
                  isSelected: currentSelection == 'Users',
                  onTap: () {
                    onSelect('Users');
                    Navigator.pop(context);
                    
                  },
                ),
               
                _buildDrawerItem(
                  context: context,
                  icon: Icons.person_outline,
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
    final selectedColor = const Color(0xFF009688);
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? selectedColor : Colors.grey[700],
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? selectedColor : Colors.grey[800],
          fontSize: 15,
        ),
      ),
      selected: isSelected,
      selectedTileColor: selectedColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      leading: const Icon(Icons.logout, color: Colors.redAccent),
      title: const Text(
        'Logout',
        style: TextStyle(
          color: Colors.redAccent,
          fontWeight: FontWeight.w600,
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
              Icon(Icons.logout, color: Colors.redAccent),
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
                backgroundColor: Colors.redAccent,
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
    final navigatorState = Navigator.of(context, rootNavigator: true);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    Navigator.of(context).pop();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return const Center(
          child: Card(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Color(0xFF009688)),
                  SizedBox(height: 16),
                  Text('Logging out...'),
                ],
              ),
            ),
          ),
        );
      },
    );

    try {
      await _clearAllStates(context);

      final auth = Provider.of<AuthProvider>(context, listen: false);
      await auth.logout();
      await Future.delayed(const Duration(milliseconds: 400));

      navigatorState.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      debugPrint('Logout error: $e');
      try {
        navigatorState.pop();
      } catch (_) {}
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Logout failed: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _clearAllStates(BuildContext context) async {
    try {
      Provider.of<UserProvider>(context, listen: false).clear();
    } catch (e) {
      debugPrint('Error clearing providers: $e');
    }
  }
}