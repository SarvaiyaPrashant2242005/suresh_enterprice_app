import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider_updated.dart';
import '../widgets/sidebar_drawer.dart';
import 'profile_screen.dart';
import 'categories_screen.dart';
import 'products_screen.dart';
import 'customers_screen.dart';
import 'gst_master_screen.dart';
import 'home_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _title = 'Home';
  
  void _onSelect(String title) {
    setState(() {
      _title = title;
    });
  }

  Widget _getScreenForTitle(String title) {
    switch (title) {
      case 'Home':
        return const HomeScreen();
      case 'Profile':
        return const ProfileScreen();
      case 'Categories':
        return const CategoriesScreen();
      case 'Products':
        return const ProductsScreen();
      case 'Customers':
        return const CustomersScreen();
      case 'GST Master':
        return const GstMasterScreen();
      default:
        return Center(
          child: Text(
            'Coming Soon: $_title',
            style: const TextStyle(fontSize: 24),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final userType = auth.authData?['user']?['userType'] ?? 'User';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
      ),
      drawer: SidebarDrawer(onSelect: _onSelect),
      body: _getScreenForTitle(_title),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final userName = auth.authData?['user']?['name'] ?? 'User';
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.dashboard,
            size: 100,
            color: Colors.blue,
          ),
          const SizedBox(height: 20),
          Text(
            'Welcome, $userName!',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Select an option from the sidebar to get started',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}