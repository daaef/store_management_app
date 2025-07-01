import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../theme/colors/app_colors.dart';
import '../theme/text_styles/app_text_style.dart';
import '../widgets/custom_app_bar.dart';
import '../providers/order_provider.dart';
import '../providers/auth_provider.dart';
import '../models/fainzy_user_order.dart';
import '../widgets/order_item_widget.dart';
import '../widgets/order_notification_widget.dart';

class OrderManagementScreen extends StatefulWidget {
  const OrderManagementScreen({super.key});

  static Route<dynamic> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const OrderManagementScreen(),
    );
  }

  @override
  State<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  int _columnCount = 3; // Default to 3 columns

  // ScrollControllers for each tab to avoid PrimaryScrollController conflicts
  late ScrollController _allOrdersController;
  late ScrollController _pendingOrdersController;
  late ScrollController _activeOrdersController;
  late ScrollController _completedOrdersController;
  late ScrollController _cancelledOrdersController;
  late ScrollController _rejectedOrdersController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    
    // Initialize scroll controllers
    _allOrdersController = ScrollController();
    _pendingOrdersController = ScrollController();
    _activeOrdersController = ScrollController();
    _completedOrdersController = ScrollController();
    _cancelledOrdersController = ScrollController();
    _rejectedOrdersController = ScrollController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    
    // Dispose scroll controllers
    _allOrdersController.dispose();
    _pendingOrdersController.dispose();
    _activeOrdersController.dispose();
    _completedOrdersController.dispose();
    _cancelledOrdersController.dispose();
    _rejectedOrdersController.dispose();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Order Management',
        actions: [
          // Connection status indicator
          Consumer<OrderProvider>(
            builder: (context, orderProvider, child) {
              return _buildConnectionStatusIndicator(orderProvider);
            },
          ),
          const SizedBox(width: 8),
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
            
            // Initialize WebSocket connection for real-time updates
            orderProvider.initializeWebsocketWithAuth(context);
            
            // Set up new order notification callback
            orderProvider.setNewOrderCallback((order) {
              _showNewOrderDialog(order);
            });
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
          // Header with connection status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order Management Dashboard',
                style: AppTextStyle.headline6.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.grey600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search by order ID, customer name, code, or status...',
                hintStyle: AppTextStyle.body2.copyWith(color: Colors.grey[600]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey[600]),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Statistics Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total',
                  orderProvider.allOrders.length.toString(),
                  Icons.shopping_cart,
                  AppColors.primaryMain,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Pending',
                  orderProvider.pendingOrders.length.toString(),
                  Icons.pending_actions,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Active',
                  orderProvider.activeOrders.length.toString(),
                  Icons.local_shipping,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Completed',
                  orderProvider.completedOrders.length.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Column Layout Toggle
          Row(
            children: [
              Text(
                'Layout:',
                style: AppTextStyle.body2.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey600,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildColumnToggle(2),
                    _buildColumnToggle(3),
                    _buildColumnToggle(4),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColumnToggle(int columns) {
    final isSelected = _columnCount == columns;
    return GestureDetector(
      onTap: () {
        setState(() {
          _columnCount = columns;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryMain : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          '$columns',
          style: AppTextStyle.body2.copyWith(
            color: isSelected ? Colors.white : AppColors.grey600,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 24,
            color: color,
          ),
          const SizedBox(height: 8),
          Text(
            count,
            style: AppTextStyle.headline5.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyle.caption.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSection(OrderProvider orderProvider) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: AppColors.primaryMain,
            indicatorWeight: 3,
            labelColor: AppColors.primaryMain,
            unselectedLabelColor: Colors.grey[600],
            labelStyle: AppTextStyle.body2.copyWith(fontWeight: FontWeight.w600),
            unselectedLabelStyle: AppTextStyle.body2,
            tabs: [
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('All'),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryMain.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        orderProvider.allOrders.length.toString(),
                        style: AppTextStyle.caption.copyWith(
                          color: AppColors.primaryMain,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Pending'),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        orderProvider.pendingOrders.length.toString(),
                        style: AppTextStyle.caption.copyWith(
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Active'),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        orderProvider.activeOrders.length.toString(),
                        style: AppTextStyle.caption.copyWith(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Completed'),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        orderProvider.completedOrders.length.toString(),
                        style: AppTextStyle.caption.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Cancelled'),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        orderProvider.cancelledOrders.length.toString(),
                        style: AppTextStyle.caption.copyWith(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Rejected'),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        orderProvider.rejectedOrders.length.toString(),
                        style: AppTextStyle.caption.copyWith(
                          color: Colors.grey[700]!,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }

  Widget _buildOrdersTabView(OrderProvider orderProvider) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildOrdersList(_filterOrders(orderProvider.allOrders), _allOrdersController),
        _buildOrdersList(_filterOrders(orderProvider.pendingOrders), _pendingOrdersController),
        _buildOrdersList(_filterOrders(orderProvider.activeOrders), _activeOrdersController),
        _buildOrdersList(_filterOrders(orderProvider.completedOrders), _completedOrdersController),
        _buildOrdersList(_filterOrders(orderProvider.cancelledOrders), _cancelledOrdersController),
        _buildOrdersList(_filterOrders(orderProvider.rejectedOrders), _rejectedOrdersController),
      ],
    );
  }

  List<FainzyUserOrder> _filterOrders(List<FainzyUserOrder> orders) {
    List<FainzyUserOrder> filteredOrders = orders;
    
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filteredOrders = orders.where((order) {
        final orderIdMatch = order.orderId?.toLowerCase().contains(query) ?? false;
        final customerNameMatch = order.user?.name?.toLowerCase().contains(query) ?? false;
        final orderCodeMatch = order.code?.toLowerCase().contains(query) ?? false;
        final statusMatch = order.status?.toLowerCase().contains(query) ?? false;

        return orderIdMatch || customerNameMatch || orderCodeMatch || statusMatch;
      }).toList();
    }
    
    // Ensure filtered orders are also sorted by creation date (latest first)
    filteredOrders.sort((a, b) {
      final dateA = a.created ?? DateTime.now();
      final dateB = b.created ?? DateTime.now();
      return dateB.compareTo(dateA); // Descending order (latest first)
    });
    
    return filteredOrders;
  }

  Widget _buildOrdersList(List<FainzyUserOrder> orders, ScrollController scrollController) {
    if (orders.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          await context.read<OrderProvider>().refreshOrders();
        },
        child: SingleChildScrollView(
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: _buildEmptyState(),
          ),
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<OrderProvider>().refreshOrders();
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Scrollbar(
          controller: scrollController,
          thumbVisibility: true,
          thickness: 8.0,
          radius: const Radius.circular(4.0),
          child: Padding(
            padding: const EdgeInsets.only(right: 16.0), // Add space between scrollbar and content
            child: MasonryGridView.builder(
              controller: scrollController,
              gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _columnCount,
              ),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              itemCount: orders.length,
              itemBuilder: (context, index) {
                return OrderItemWidget(
                  key: ValueKey(orders[index].id),
                  order: orders[index],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
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
            _searchQuery.isNotEmpty
                ? 'Try adjusting your search terms'
                : 'Orders will appear here when available',
            style: AppTextStyle.body2.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStatusIndicator(OrderProvider orderProvider) {
    Color statusColor;
    String statusText;
    IconData statusIcon;
    bool showShimmer = false;
    bool showReconnectButton = false;

    // Determine status based on connection state
    final status = orderProvider.connectionStatus.toLowerCase();
    
    if (status.contains('connecting') || status.contains('initializing')) {
      statusColor = Colors.amber;
      statusText = 'Connecting...';
      statusIcon = Icons.wifi_tethering;
      showShimmer = true;
    } else if (status.contains('reconnecting')) {
      statusColor = Colors.orange;
      statusText = 'Reconnecting...';
      statusIcon = Icons.refresh;
      showShimmer = true;
    } else if (orderProvider.isWebsocketConnected && status.contains('connected')) {
      statusColor = Colors.green;
      statusText = 'Live';
      statusIcon = Icons.wifi;
    } else if (status.contains('failed') || status.contains('error')) {
      statusColor = Colors.red;
      statusText = 'Failed';
      statusIcon = Icons.error;
      showReconnectButton = true;
    } else if (status.contains('max retries')) {
      statusColor = Colors.red;
      statusText = 'Offline';
      statusIcon = Icons.cloud_off;
      showReconnectButton = true;
    } else {
      statusColor = Colors.grey;
      statusText = 'Disconnected';
      statusIcon = Icons.wifi_off;
      showReconnectButton = true;
    }

    Widget indicator = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            color: statusColor,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (showReconnectButton) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _handleReconnect(orderProvider),
              child: Icon(
                Icons.refresh,
                color: statusColor,
                size: 14,
              ),
            ),
          ],
        ],
      ),
    );

    // Add shimmer animation for connecting state
    if (showShimmer) {
      return AnimatedBuilder(
        animation: ModalRoute.of(context)?.animation ?? kAlwaysCompleteAnimation,
        builder: (context, child) {
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.3, end: 1.0),
            duration: const Duration(milliseconds: 1000),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: indicator,
              );
            },
          );
        },
      );
    }

    return indicator;
  }

  void _handleReconnect(OrderProvider orderProvider) {
    // Get store ID from auth provider and force reconnect
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isLoggedIn && authProvider.storeID.isNotEmpty) {
      orderProvider.reconnectWebsocket(authProvider.storeID);
      
      // Show feedback to user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reconnecting to live updates...'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  /// Show dialog when a new order arrives
  void _showNewOrderDialog(FainzyUserOrder order) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return OrderNotificationWidget(
          order: order,
          onAccept: () {
            Navigator.of(context).pop();
            if (order.id != null) {
              context.read<OrderProvider>().acceptOrder(order.id!);
            }
          },
          onReject: () {
            Navigator.of(context).pop();
            if (order.id != null) {
              context.read<OrderProvider>().rejectOrder(order.id!);
            }
          },
          onMarkReady: () {
            Navigator.of(context).pop();
            if (order.id != null) {
              context.read<OrderProvider>().markOrderReady(order.id!);
            }
          },
          onViewDetails: () {
            Navigator.of(context).pop();
            if (order.id != null) {
              Navigator.pushNamed(
                context,
                '/order-details',
                arguments: order.id,
              );
            }
          },
        );
      },
    );
  }
}
