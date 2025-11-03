import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../widgets/sidebar_drawer.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _title = 'Dashboard';

  void _onSelect(String title) {
    setState(() {
      _title = title;
    });
    Navigator.of(context).pop();
  }

  Widget _getScreenForTitle(String title) {
    switch (title) {
      case 'Profile':
        return const ProfileScreen();
      case 'Categories':
        return const CategoriesScreen();
      case 'Products':
        return const ProductsScreen();
      case 'Customers':
        return const CustomersScreen();
      case 'GST Master':
        return const GSTMasterScreen();
      case 'Company Profile':
        return const CompanyProfileScreen();
      case 'Invoices':
        return const InvoicesScreen();
      case 'Users':
        return const UsersScreen();
      default:
        return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      drawer: SidebarDrawer(onSelect: _onSelect),
      body: _getScreenForTitle(_title),
    );
  }
}

// Home Screen (Default Dashboard)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();
    final user = auth.authData;
    final userType = user?['userType'] as String? ?? 'Unknown';
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Welcome to Suresh Enterprise',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text(
            'User Type: $userType',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// Categories Screen
class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Categories Screen - Coming Soon'),
    );
  }
}

// Products Screen
class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Products Screen - Coming Soon'),
    );
  }
}

// Customers Screen
class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Customers Screen - Coming Soon'),
    );
  }
}

// GST Master Screen
class GSTMasterScreen extends StatelessWidget {
  const GSTMasterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('GST Master Screen - Coming Soon'),
    );
  }
}

// Company Profile Screen
class CompanyProfileScreen extends StatelessWidget {
  const CompanyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Company Profile Screen - Coming Soon'),
    );
  }
}

// Invoices Screen
class InvoicesScreen extends StatelessWidget {
  const InvoicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Invoices Screen - Coming Soon'),
    );
  }
}

// Users Screen
class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Users Screen - Coming Soon'),
    );
  }
}