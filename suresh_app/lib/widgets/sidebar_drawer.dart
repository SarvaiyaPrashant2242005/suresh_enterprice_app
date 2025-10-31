import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../screens/login_screen.dart';

class SidebarDrawer extends StatelessWidget {
  const SidebarDrawer({super.key, required this.onSelect});

  final void Function(String title) onSelect;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().authData;
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(user?['name']?.toString() ?? 'Admin'),
              accountEmail: Text(user?['email']?.toString() ?? ''),
              currentAccountPicture: const CircleAvatar(child: Icon(Icons.person)),
            ),
            _drawerItem(context, Icons.category, 'Categories'),
            _drawerItem(context, Icons.shopping_bag, 'Products'),
            _drawerItem(context, Icons.group, 'Customers'),
            _drawerItem(context, Icons.receipt_long, 'GST Master'),
            _drawerItem(context, Icons.business, 'Company Profilee'),
            _drawerItem(context, Icons.description, 'Invoices'),
            _drawerItem(context, Icons.supervised_user_circle, 'Users'),
            _drawerItem(context, Icons.person, 'Profile'),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                await context.read<AuthProvider>().logout();
                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(BuildContext context, IconData icon, String title) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () => onSelect(title),
    );
  }
}


