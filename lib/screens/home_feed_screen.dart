import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/store_provider.dart';
import '../providers/order_provider.dart';
import '../providers/menu_provider.dart';
import '../providers/navigation_provider.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StoreProvider>().refreshData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await context.read<StoreProvider>().refreshData();
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with breadcrumb style
                _buildDashboardHeader(),
                const SizedBox(height: 32),

                // KPI Cards Row
                _buildKPICards(),
                const SizedBox(height: 32),

                // Main Content Grid
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column - Charts and Analytics
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          _buildRevenueChart(),
                          const SizedBox(height: 24),
                          _buildOrdersChart(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    
                    // Right Column - Quick Actions and Recent Activity
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          _buildQuickActions(),
                          const SizedBox(height: 24),
                          _buildRecentActivity(),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardHeader() {
    return Consumer<StoreProvider>(
      builder: (context, storeProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Breadcrumb
            Row(
              children: [
                const Icon(Icons.dashboard, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Dashboard',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Main Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      storeProvider.storeName,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    // Store Status
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: storeProvider.isOpen ?  Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            storeProvider.isOpen ? Icons.store: Icons.store_outlined ,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            storeProvider.isOpen ? 'Open' : 'Closed',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Refresh Button
                    IconButton(
                      onPressed: () {
                        // TODO: Refresh data
                      },
                      icon: const Icon(Icons.refresh),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildKPICards() {
    return Consumer3<StoreProvider, OrderProvider, MenuProvider>(
      builder: (context, storeProvider, orderProvider, menuProvider, child) {
        return Row(
          children: [
            Expanded(
              child: _buildKPICard(
                title: 'Total Revenue',
                value: storeProvider.formattedTotalRevenue,
                subtitle: 'This month',
                icon: Icons.trending_up,
                color: Colors.green,
                trend: '+12.5%',
                isPositive: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildKPICard(
                title: 'Total Orders',
                value: '${storeProvider.totalOrders}',
                subtitle: 'All time',
                icon: Icons.receipt_long,
                color: Colors.blue,
                trend: '${storeProvider.pendingOrders} pending',
                isPositive: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildKPICard(
                title: 'Menu Items',
                value: '${menuProvider.menuItems.length}',
                subtitle: 'Active items',
                icon: Icons.restaurant_menu,
                color: Colors.orange,
                trend: 'Ready to order',
                isPositive: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildKPICard(
                title: 'Avg Order Value',
                value: storeProvider.formattedAverageOrderValue,
                subtitle: 'Per order',
                icon: Icons.attach_money,
                color: Colors.purple,
                trend: '${storeProvider.completionRate.toStringAsFixed(1)}% completed',
                isPositive: storeProvider.completionRate > 80,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildKPICard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String trend,
    required bool isPositive,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
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
              /* Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPositive 
                      ? Colors.green.withOpacity(0.1) 
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive ? Icons.trending_up : Icons.trending_down,
                      size: 12,
                      color: isPositive ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      trend,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isPositive ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ), */
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueChart() {
    return Consumer<StoreProvider>(
      builder: (context, storeProvider, child) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Revenue Overview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Total: ${storeProvider.formattedTotalRevenue}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Revenue breakdown
              Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.green.withOpacity(0.3),
                      Colors.green.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.trending_up, size: 48, color: Colors.green),
                    const SizedBox(height: 12),
                    Text(
                      storeProvider.formattedTotalRevenue,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'From ${storeProvider.completedOrders} completed orders',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Avg: ${storeProvider.formattedAverageOrderValue} per order',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrdersChart() {
    return Consumer<StoreProvider>(
      builder: (context, storeProvider, child) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Order Distribution',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    '${storeProvider.totalOrders} total',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              Column(
                children: [
                  _buildOrderStatusRow(
                    'Completed',
                    storeProvider.completedOrders,
                    Colors.green,
                    storeProvider.totalOrders,
                  ),
                  const SizedBox(height: 12),
                  _buildOrderStatusRow(
                    'Pending',
                    storeProvider.pendingOrders,
                    Colors.orange,
                    storeProvider.totalOrders,
                  ),
                  const SizedBox(height: 12),
                  _buildOrderStatusRow(
                    'In Progress',
                    storeProvider.totalOrders - storeProvider.completedOrders - storeProvider.pendingOrders,
                    Colors.blue,
                    storeProvider.totalOrders,
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              // Summary stats
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatColumn(
                      'Completion Rate',
                      '${storeProvider.completionRate.toStringAsFixed(1)}%',
                      Colors.green,
                    ),
                    Container(width: 1, height: 30, color: Colors.grey[300]),
                    _buildStatColumn(
                      'Pending Rate',
                      '${storeProvider.pendingRate.toStringAsFixed(1)}%',
                      Colors.orange,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderStatusRow(String status, int count, Color color, int total) {
    final percentage = total > 0 ? (count / total * 100).round() : 0;
    
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            status,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          '$count',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '$percentage%',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Consumer<StoreProvider>(
      builder: (context, storeProvider, child) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              
              // Store Status Toggle
              _buildStoreStatusToggle(storeProvider),
              const SizedBox(height: 12),
              
              _buildQuickActionButton(
                icon: Icons.add_box,
                title: 'Add Menu Item',
                color: Colors.blue,
                onTap: () {
                  // Navigate to add menu item (menu tab)
                  final navProvider = Provider.of<NavigationProvider>(context, listen: false);
                  navProvider.onPageChanged(2); // Menu tab
                },
              ),
              const SizedBox(height: 12),
              _buildQuickActionButton(
                icon: Icons.inventory,
                title: 'View Orders',
                color: Colors.orange,
                onTap: () {
                  // Navigate to orders tab
                  final navProvider = Provider.of<NavigationProvider>(context, listen: false);
                  navProvider.onPageChanged(1); // Orders tab
                },
              ),
              const SizedBox(height: 12),
              _buildQuickActionButton(
                icon: Icons.settings,
                title: 'Store Settings',
                color: Colors.purple,
                onTap: () {
                  // Navigate to profile/settings tab
                  final navProvider = Provider.of<NavigationProvider>(context, listen: false);
                  navProvider.onPageChanged(3); // Profile tab
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: color,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Consumer<StoreProvider>(
      builder: (context, storeProvider, child) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              
              if (storeProvider.completedOrders > 0) ...[
                _buildActivityItem(
                  icon: Icons.check_circle,
                  title: '${storeProvider.completedOrders} orders completed',
                  subtitle: 'Revenue: ${storeProvider.formattedTotalRevenue}',
                  color: Colors.green,
                ),
                const SizedBox(height: 16),
              ],
              
              if (storeProvider.pendingOrders > 0) ...[
                _buildActivityItem(
                  icon: Icons.pending,
                  title: '${storeProvider.pendingOrders} pending orders',
                  subtitle: 'Require attention',
                  color: Colors.orange,
                ),
                const SizedBox(height: 16),
              ],
              
              _buildActivityItem(
                icon: storeProvider.isOpen ? Icons.store : Icons.store_mall_directory_outlined,
                title: storeProvider.isOpen ? 'Store is open' : 'Store is closed',
                subtitle: storeProvider.isOpen ? 'Ready for orders' : 'Not accepting orders',
                color: storeProvider.isOpen ? Colors.green : Colors.red,
              ),
              const SizedBox(height: 16),
              
              _buildActivityItem(
                icon: Icons.analytics,
                title: 'Completion rate: ${storeProvider.completionRate.toStringAsFixed(1)}%',
                subtitle: 'Based on ${storeProvider.totalOrders} total orders',
                color: storeProvider.completionRate > 80 ? Colors.green : Colors.orange,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStoreStatusToggle(StoreProvider storeProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: storeProvider.isOpen ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: storeProvider.isOpen ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: storeProvider.isOpen ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              storeProvider.isOpen ? Icons.store : Icons.store_mall_directory_outlined,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Store Status',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  storeProvider.isOpen ? 'Open for Business' : 'Currently Closed',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: storeProvider.isOpen ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: storeProvider.isOpen,
            onChanged: (value) {
              storeProvider.toggleStoreStatus();
            },
            activeColor: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
