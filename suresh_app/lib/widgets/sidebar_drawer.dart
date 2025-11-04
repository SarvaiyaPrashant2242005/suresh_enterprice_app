import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider_updated.dart';
import '../providers/customer_provider.dart';

class SidebarDrawer extends StatelessWidget {
  final Function(String) onSelect;

  const SidebarDrawer({Key? key, required this.onSelect}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final userType = auth.authData?['userType'] ?? 'User';
    final userName = auth.authData?['name'] ?? 'User';
    final userEmail = auth.authData?['email'] ?? 'user@example.com';

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(userName),
            accountEmail: Text(userEmail),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                style: const TextStyle(fontSize: 40.0),
              ),
            ),
          ),
          _buildDrawerItem(
            icon: Icons.home,
            title: 'Home',
            onTap: () => onSelect('Home'),
          ),
          _buildDrawerItem(
            icon: Icons.category,
            title: 'Categories',
            onTap: () => onSelect('Categories'),
          ),
          _buildDrawerItem(
            icon: Icons.inventory,
            title: 'Products',
            onTap: () => onSelect('Products'),
          ),
          _buildDrawerItem(
            icon: Icons.people,
            title: 'Customers',
            onTap: () {
              // Trigger fetch before navigating with userType
              final auth = Provider.of<AuthProvider>(context, listen: false);
              final userType = auth.authData?['user']?['userType'] ?? auth.authData?['userType'];
              Provider.of<CustomerProvider>(context, listen: false)
                  .fetchCustomers(userType: userType);
              onSelect('Customers');
            },
          ),
          _buildDrawerItem(
            icon: Icons.receipt,
            title: 'GST Master',
            onTap: () => onSelect('GST Master'),
          ),
          _buildDrawerItem(
            icon: Icons.receipt_long,
            title: 'Invoices',
            onTap: () => onSelect('Invoices'),
          ),
          _buildDrawerItem(
            icon: Icons.business,
            title: 'Users',
            onTap: () => onSelect('Users'),
          ),
          if (userType == 'Admin')
            _buildDrawerItem(
              icon: Icons.people_alt,
              title: 'Users',
              onTap: () => onSelect('Users'),
            ),
          const Divider(),
          _buildDrawerItem(
            icon: Icons.person,
            title: 'Profile',
            onTap: () => onSelect('Profile'),
          ),
          _buildDrawerItem(
            icon: Icons.logout,
            title: 'Logout',
            onTap: () {
              auth.logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }
}