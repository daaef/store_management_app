import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../theme/colors/app_colors.dart';
import '../theme/text_styles/app_text_style.dart';
import '../widgets/custom_app_bar.dart';
import '../providers/order_provider.dart';
import '../models/fainzy_user_order.dart';
import '../widgets/order_item_widget.dart';

class EnhancedOrderManagementScreen extends StatefulWidget {
  const EnhancedOrderManagementScreen({super.key});

  static Route<dynamic> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const EnhancedOrderManagementScreen(),
    );
  }

  @override
  State<EnhancedOrderManagementScreen> createState() => _EnhancedOrderManagementScreenState();
}

class _EnhancedOrderManagementScreenState extends State<EnhancedOrderManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Enhanced Order Management',
        actions: [
          // Sound notification toggle
          Consumer<OrderProvider>(
            builder: (context, orderProvider, child) {
              return IconButton(
                onPressed: () {
                  orderProvider.setSoundNotifications(!orderProvider.soundNotificationsEnabled);
                },
                icon: Icon(
                  orderProvider.soundNotificationsEnabled 
                    ? Icons.volume_up 
                    : Icons.volume_off
                ),
                tooltip: orderProvider.soundNotificationsEnabled 
                  ? 'Disable order sound notifications' 
                  : 'Enable order sound notifications',
              );
            },
          ),
          IconButton(
            onPressed: () {
              context.read<OrderProvider>().refreshOrders();
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Orders',
          ),
        ],
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          // Fetch orders when first loading the screen
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (orderProvider.status == OrderStatus.initial) {
              orderProvider.fetchOrders();
            }
          });

          if (orderProvider.status == OrderStatus.loading) {
            return const Center(
              child: SpinKitWave(
                color: AppColors.primaryMain,
                size: 30,
              ),
            );
          }

          if (orderProvider.status == OrderStatus.error) {
            return _buildErrorView(
              orderProvider.error ?? 'An unknown error occurred',
              () => orderProvider.fetchOrders(),
            );
          }

          if (orderProvider.status == OrderStatus.success) {
            return Column(
              children: [
                // Search and Statistics Section
                _buildSearchAndStatsSection(orderProvider),
                
                // Enhanced Tab Section
                _buildTabSection(orderProvider),
                
                // Orders Content
                Expanded(
                  child: _buildOrdersTabView(orderProvider),
                ),
              ],
            );
          }

          return const Center(
            child: Text('No orders found'),
          );
        },
      ),
    );
  }

  Widget _buildErrorView(String error, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading orders',
              style: AppTextStyle.headline6,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: AppTextStyle.body2.copyWith(color: AppColors.errorColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryMain,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndStatsSection(OrderProvider orderProvider) {
    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search orders by ID, customer name...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
          const SizedBox(height: 16),
          
          // Statistics Cards
          Row(
            children: [
              _buildStatCard(
                'Total Orders',
                orderProvider.allOrders.length.toString(),
                Icons.receipt_long,
                AppColors.primaryMain,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                'Pending',
                orderProvider.pendingOrders.length.toString(),
                Icons.pending_actions,
                Colors.orange,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                'Active',
                orderProvider.activeOrders.length.toString(),
                Icons.local_shipping,
                Colors.blue,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                'Completed',
                orderProvider.pastOrders.where((o) => o.status == 'completed').length.toString(),
                Icons.check_circle,
                Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTextStyle.headline6.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: AppTextStyle.caption.copyWith(
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSection(OrderProvider orderProvider) {
    final pendingCount = orderProvider.pendingOrders.length;
    final activeCount = orderProvider.activeOrders.length;
    final completedCount = orderProvider.pastOrders.where((o) => o.status == 'completed').length;
    final cancelledCount = orderProvider.pastOrders.where((o) => o.status == 'cancelled').length;
    final rejectedCount = orderProvider.pastOrders.where((o) => o.status == 'rejected').length;
    final allCount = orderProvider.allOrders.length;

    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorWeight: 3,
        indicatorColor: AppColors.primaryMain,
        labelColor: AppColors.primaryMain,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: AppTextStyle.body2.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: AppTextStyle.body2.copyWith(fontWeight: FontWeight.w400),
        tabs: [
          Tab(text: 'All ($allCount)'),
          Tab(text: 'Pending ($pendingCount)'),
          Tab(text: 'Active ($activeCount)'),
          Tab(text: 'Completed ($completedCount)'),
          Tab(text: 'Cancelled ($cancelledCount)'),
          Tab(text: 'Rejected ($rejectedCount)'),
        ],
      ),
    );
  }

  Widget _buildOrdersTabView(OrderProvider orderProvider) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildOrdersList(_filterOrders(orderProvider.allOrders)),
        _buildOrdersList(_filterOrders(orderProvider.pendingOrders)),
        _buildOrdersList(_filterOrders(orderProvider.activeOrders)),
        _buildOrdersList(_filterOrders(orderProvider.pastOrders.where((o) => o.status == 'completed').toList())),
        _buildOrdersList(_filterOrders(orderProvider.pastOrders.where((o) => o.status == 'cancelled').toList())),
        _buildOrdersList(_filterOrders(orderProvider.pastOrders.where((o) => o.status == 'rejected').toList())),
      ],
    );
  }

  List<FainzyUserOrder> _filterOrders(List<FainzyUserOrder> orders) {
    if (_searchQuery.isEmpty) return orders;
    
    return orders.where((order) {
      final searchLower = _searchQuery.toLowerCase();
      return (order.orderId?.toLowerCase().contains(searchLower) ?? false) ||
             (order.user?.name?.toLowerCase().contains(searchLower) ?? false) ||
             (order.code?.toLowerCase().contains(searchLower) ?? false) ||
             (order.status?.toLowerCase().contains(searchLower) ?? false);
    }).toList();
  }

  Widget _buildOrdersList(List<FainzyUserOrder> orders) {
    // Sort orders by created date (newest first)
    final sortedOrders = List<FainzyUserOrder>.from(orders)
      ..sort((a, b) => (b.created ?? DateTime.now()).compareTo(a.created ?? DateTime.now()));

    if (sortedOrders.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<OrderProvider>().refreshOrders();
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sortedOrders.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemBuilder: (context, index) {
          final order = sortedOrders[index];
          return OrderItemWidget(
            key: ValueKey(order.id),
            order: order,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No orders found',
              style: AppTextStyle.headline6.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Orders will appear here when customers place them',
              style: AppTextStyle.body2.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
