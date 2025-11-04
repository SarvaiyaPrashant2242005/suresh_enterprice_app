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
          // Modern App Bar Header
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              padding: EdgeInsets.fromLTRB(
                isTablet ? 32 : 20,
                MediaQuery.of(context).padding.top + 20,
                isTablet ? 32 : 20,
                32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getGreeting(),
                              style: TextStyle(
                                fontSize: isTablet ? 18 : 16,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              userName,
                              style: TextStyle(
                                fontSize: isTablet ? 32 : 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person,
                          size: isTablet ? 32 : 28,
                          color: Colors.white,
                        ),
                      ),
                    ],
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
                  padding: const EdgeInsets.only(bottom: 16, top: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Overview',
                        style: TextStyle(
                          fontSize: isTablet ? 24 : 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
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
                          builder: (context, categoryProvider, _) => _ModernStatCard(
                            title: 'Categories',
                            count: categoryProvider.categories.length,
                            icon: Icons.category_rounded,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                            ),
                            isLoading: categoryProvider.isLoading,
                          ),
                        ),
                        Consumer<ProductProvider>(
                          builder: (context, productProvider, _) => _ModernStatCard(
                            title: 'Products',
                            count: productProvider.products.length,
                            icon: Icons.inventory_2_rounded,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
                            ),
                            isLoading: productProvider.isLoading,
                          ),
                        ),
                        _ModernStatCard(
                          title: 'Orders',
                          count: 0,
                          icon: Icons.shopping_cart_rounded,
                          gradient: const LinearGradient(
                            colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
                          ),
                          isLoading: false,
                        ),
                        _ModernStatCard(
                          title: 'Revenue',
                          count: 0,
                          icon: Icons.attach_money_rounded,
                          gradient: const LinearGradient(
                            colors: [Color(0xFFfa709a), Color(0xFFfee140)],
                          ),
                          isLoading: false,
                          prefix: '\₹',
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

class _ModernStatCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Gradient gradient;
  final bool isLoading;
  final String? prefix;

  const _ModernStatCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.gradient,
    this.isLoading = false,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(10),
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
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    if (isLoading)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${prefix ?? ''}$count',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
