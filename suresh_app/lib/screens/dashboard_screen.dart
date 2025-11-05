import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:suresh_app/screens/invoice_screen.dart';
import 'package:suresh_app/screens/user_screen.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  @override
  void initState() {
    super.initState();
    // Check authentication status
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthStatus();
    });
  }

  void _checkAuthStatus() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.authData == null || auth.token == null) {
      // User is not authenticated, navigate to login
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }
  
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
      case 'Invoices':
        return const InvoiceScreen();
      case 'Users':
        return const UsersScreen();                                                                                                                                                                          ();
      default:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.info_outline, size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Coming Soon: $_title',
                style: const TextStyle(fontSize: 24, color: Colors.grey),
              ),
            ],
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Handle back button press
        if (_title != 'Home') {
          setState(() {
            _title = 'Home';
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(_title),
          elevation: 2,
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
        ),
        drawer: SidebarDrawer(
          onSelect: _onSelect,
          currentSelection: _title,
        ),
        body: _getScreenForTitle(_title),
      ),
    );
  }
}