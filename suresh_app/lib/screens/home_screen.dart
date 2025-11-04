import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider_updated.dart';
import '../providers/category_provider.dart';
import '../providers/product_provider.dart';
import '../services/storage_service.dart';
import '../widgets/loading_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storage = StorageService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
      final productProvider = Provider.of<ProductProvider>(context, listen: false);

      // Get company ID and user type
      int? companyId;
      String? userType;
      final authData = auth.authData;
      
      if (authData != null) {
        final dynamic c = authData['company_id'] ?? 
                         authData['companyId'] ?? 
                         (authData['user'] is Map ? 
                          (authData['user']['company_id'] ?? authData['user']['companyId']) : 
                          null);
        if (c is num) companyId = c.toInt();
        if (c is String) companyId = int.tryParse(c);
        userType = authData['userType'] ?? 
                   (authData['user'] is Map ? authData['user']['userType'] : null);
      }

      // Fetch categories and products
      await Future.wait([
        categoryProvider.fetchCategories(companyId: companyId, userType: userType),
        productProvider.fetchProducts(companyId: companyId, userType: userType),
      ]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading dashboard: $e'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final userName = auth.authData?['user']?['name'] ?? 
                     auth.authData?['name'] ?? 
                     'User';
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    if (_isLoading) {
      return const LoadingIndicator();
    }

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      color: Theme.of(context).primaryColor,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Clean Minimal Header
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: EdgeInsets.fromLTRB(
                isTablet ? 32 : 20,
                MediaQuery.of(context).padding.top + 20,
                isTablet ? 32 : 20,
                24,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getGreeting(),
                          style: TextStyle(
                            fontSize: isTablet ? 16 : 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userName,
                          style: TextStyle(
                            fontSize: isTablet ? 28 : 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[900],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_outline,
                      size: isTablet ? 28 : 24,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverPadding(
            padding: EdgeInsets.all(isTablet ? 24 : 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Statistics Section Header
                Padding(
                  padding: const EdgeInsets.only(bottom: 20, top: 8),
                  child: Text(
                    'Overview',
                    style: TextStyle(
                      fontSize: isTablet ? 22 : 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[900],
                      letterSpacing: -0.5,
                    ),
                  ),
                ),

                // Statistics Cards
                LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = isTablet ? 4 : 2;
                    final childAspectRatio = isTablet ? 1.3 : 1.1;
                    
                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: childAspectRatio,
                      children: [
                        Consumer<CategoryProvider>(
                          builder: (context, categoryProvider, _) => _CleanStatCard(
                            title: 'Categories',
                            count: categoryProvider.categories.length,
                            icon: Icons.category_outlined,
                            color: const Color(0xFF6366F1),
                            isLoading: categoryProvider.isLoading,
                          ),
                        ),
                        Consumer<ProductProvider>(
                          builder: (context, productProvider, _) => _CleanStatCard(
                            title: 'Products',
                            count: productProvider.products.length,
                            icon: Icons.inventory_2_outlined,
                            color: const Color(0xFF10B981),
                            isLoading: productProvider.isLoading,
                          ),
                        ),
                        _CleanStatCard(
                          title: 'Orders',
                          count: 0,
                          icon: Icons.shopping_bag_outlined,
                          color: const Color(0xFFF59E0B),
                          isLoading: false,
                        ),
                        _CleanStatCard(
                          title: 'Revenue',
                          count: 0,
                          icon: Icons.trending_up_rounded,
                          color: const Color(0xFFEC4899),
                          isLoading: false,
                          prefix: '₹',
                        ),
                      ],
                    );
                  },
                ),

                SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _CleanStatCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;
  final bool isLoading;
  final String? prefix;

  const _CleanStatCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    this.isLoading = false,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.12),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 24,
                      ),
                    ),
                    if (isLoading)
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${prefix ?? ''}$count',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}