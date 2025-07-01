import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as dev;
import '../providers/store_provider.dart';
import '../providers/order_provider.dart';
import '../providers/navigation_provider.dart';
import '../models/fainzy_user_order.dart';
import '../models/fainzy_user.dart';

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
      _loadAndValidateData();
    });
  }

  /// Load data and validate accuracy
  Future<void> _loadAndValidateData() async {
    try {
      // Load store and order data
      await context.read<StoreProvider>().refreshData();
      await context.read<OrderProvider>().fetchOrders();
      
      // Also refresh top customers if needed
      await context.read<StoreProvider>().refreshTopCustomers();
      
      // Validate data accuracy after loading
      _validateDataAccuracy();
    } catch (e) {
      dev.log('❌ Error loading home feed data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Validate the accuracy of displayed data and log any discrepancies
  void _validateDataAccuracy() {
    final storeProvider = context.read<StoreProvider>();
    final orderProvider = context.read<OrderProvider>();
    
    dev.log('🔍 Validating home page data accuracy...');
    
    // Validate store information
    _validateStoreData(storeProvider);
    
    // Validate order statistics
    _validateOrderStatistics(storeProvider, orderProvider);
    
    // Validate calculations
    _validateCalculations(storeProvider);
    
    // Validate order distribution
    _validateOrderDistribution(
      storeProvider.totalOrders, 
      storeProvider.completedOrders, 
      storeProvider.pendingOrders, 
      storeProvider.activeOrders,
    );
    
    dev.log('✅ Data validation complete');
  }

  /// Validate store information accuracy
  void _validateStoreData(StoreProvider storeProvider) {
    final errors = <String>[];
    
    // Check store name
    if (storeProvider.storeName.isEmpty || storeProvider.storeName == 'My Store') {
      errors.add('Store name is missing or using default value: "${storeProvider.storeName}"');
    }
    
    // Check store address
    final address = _getFormattedAddress(storeProvider);
    if (address.isEmpty || address == 'Address not set') {
      errors.add('Store address is missing or incomplete');
    }
    
    // Check store rating
    if (storeProvider.storeRating <= 0 || storeProvider.storeRating > 5) {
      errors.add('Invalid store rating: ${storeProvider.storeRating} (should be 0-5)');
    }
    
    // Check currency
    if (storeProvider.currency.isEmpty) {
      errors.add('Store currency is not set');
    }
    
    // Log store data errors
    if (errors.isNotEmpty) {
      dev.log('⚠️ Store data validation errors:');
      for (final error in errors) {
        dev.log('  - $error');
      }
    } else {
      dev.log('✅ Store data validation passed');
    }
  }

  /// Validate order statistics accuracy
  void _validateOrderStatistics(StoreProvider storeProvider, OrderProvider orderProvider) {
    final errors = <String>[];
    final stats = storeProvider.orderStatistics;
    
    if (stats == null) {
      errors.add('Order statistics are null - using fallback data');
    } else {
      // Check for negative values
      if (stats.totalOrders != null && stats.totalOrders! < 0) {
        errors.add('Total orders is negative: ${stats.totalOrders}');
      }
      
      if (stats.totalPendingOrders != null && stats.totalPendingOrders! < 0) {
        errors.add('Pending orders is negative: ${stats.totalPendingOrders}');
      }
      
      if (stats.totalCompletedOrders != null && stats.totalCompletedOrders! < 0) {
        errors.add('Completed orders is negative: ${stats.totalCompletedOrders}');
      }
      
      if (stats.totalRevenue != null && stats.totalRevenue! < 0) {
        errors.add('Total revenue is negative: ${stats.totalRevenue}');
      }
      
      // Check logical consistency
      final statsTotal = stats.totalOrders ?? 0;
      final statsPending = stats.totalPendingOrders ?? 0;
      final statsCompleted = stats.totalCompletedOrders ?? 0;
      final statsActive = storeProvider.activeOrders;
      
      if (statsPending + statsCompleted + statsActive != statsTotal) {
        errors.add('Statistics don\'t add up: pending($statsPending) + completed($statsCompleted) + active($statsActive) ≠ total($statsTotal)');
      }
      
      // Compare with OrderProvider data if available
      final orderProviderOrders = orderProvider.allOrders;
      if (orderProviderOrders.isNotEmpty) {
        final providerTotal = orderProviderOrders.length;
        final providerCompleted = orderProvider.completedOrders.length;
        final providerPending = orderProvider.pendingOrders.length;
        final providerActive = orderProvider.activeOrders.length;
        
        // Check for significant discrepancies
        final totalDiff = (statsTotal - providerTotal).abs();
        final completedDiff = (statsCompleted - providerCompleted).abs();
        final pendingDiff = (statsPending - providerPending).abs();
        
        if (totalDiff > 10) { // Allow some difference for pagination/timing
          errors.add('Large discrepancy in total orders: Statistics($statsTotal) vs OrderProvider($providerTotal)');
        }
        
        if (completedDiff > 5) {
          errors.add('Large discrepancy in completed orders: Statistics($statsCompleted) vs OrderProvider($providerCompleted)');
        }
        
        if (pendingDiff > 5) {
          errors.add('Large discrepancy in pending orders: Statistics($statsPending) vs OrderProvider($providerPending)');
        }
        
        dev.log('📊 Data comparison: Stats(T:$statsTotal,C:$statsCompleted,P:$statsPending) vs Orders(T:$providerTotal,C:$providerCompleted,P:$providerPending,A:$providerActive)');
      }
    }
    
    // Log order statistics errors
    if (errors.isNotEmpty) {
      dev.log('⚠️ Order statistics validation errors:');
      for (final error in errors) {
        dev.log('  - $error');
      }
    } else {
      dev.log('✅ Order statistics validation passed');
    }
  }

  /// Validate calculation accuracy
  void _validateCalculations(StoreProvider storeProvider) {
    final errors = <String>[];
    
    // Validate completion rate calculation
    final completionRate = storeProvider.completionRate;
    if (completionRate < 0 || completionRate > 100) {
      errors.add('Invalid completion rate: ${completionRate}% (should be 0-100%)');
    }
    
    // Validate pending rate calculation
    final pendingRate = storeProvider.pendingRate;
    if (pendingRate < 0 || pendingRate > 100) {
      errors.add('Invalid pending rate: ${pendingRate}% (should be 0-100%)');
    }
    
    // Validate percentage sum (should be <= 100% when considering active orders)
    final totalPercentage = completionRate + pendingRate;
    if (totalPercentage > 100.1) { // Allow small floating point errors
      errors.add('Completion rate (${completionRate}%) + pending rate (${pendingRate}%) > 100%');
    }
    
    // Validate average order value
    final avgOrderValue = storeProvider.averageOrderValue;
    final totalRevenue = storeProvider.totalRevenue;
    final totalOrders = storeProvider.totalOrders;
    
    if (totalOrders > 0 && totalRevenue > 0) {
      final expectedAvg = totalRevenue / totalOrders;
      if ((avgOrderValue - expectedAvg).abs() > 0.01) { // Allow small floating point differences
        errors.add('Average order value mismatch: calculated($avgOrderValue) vs expected($expectedAvg)');
      }
    }
    
    // Log calculation errors
    if (errors.isNotEmpty) {
      dev.log('⚠️ Calculation validation errors:');
      for (final error in errors) {
        dev.log('  - $error');
      }
    } else {
      dev.log('✅ Calculation validation passed');
    }
  }

  /// Validate order distribution data
  void _validateOrderDistribution(int totalOrders, int completedOrders, int pendingOrders, int activeOrders) {
    final errors = <String>[];
    
    // Check for negative values
    if (totalOrders < 0) errors.add('Total orders is negative: $totalOrders');
    if (completedOrders < 0) errors.add('Completed orders is negative: $completedOrders');
    if (pendingOrders < 0) errors.add('Pending orders is negative: $pendingOrders');
    if (activeOrders < 0) errors.add('Active orders is negative: $activeOrders');
    
    // Check if sum matches total
    final sum = completedOrders + pendingOrders + activeOrders;
    if (sum != totalOrders) {
      errors.add('Order distribution doesn\'t add up: $completedOrders + $pendingOrders + $activeOrders = $sum ≠ $totalOrders');
    }
    
    // Check for logical consistency
    if (totalOrders > 0 && completedOrders == 0 && pendingOrders == 0 && activeOrders == 0) {
      errors.add('Total orders > 0 but all categories are 0');
    }
    
    // Log order distribution errors
    if (errors.isNotEmpty) {
      dev.log('⚠️ Order distribution validation errors:');
      for (final error in errors) {
        dev.log('  - $error');
      }
      
      // Show error to user if data is severely inconsistent
      // if (sum != totalOrders && mounted) {
      //   WidgetsBinding.instance.addPostFrameCallback((_) {
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       SnackBar(
      //         content: const Row(
      //           children: [
      //             Icon(Icons.warning, color: Colors.white),
      //             SizedBox(width: 8),
      //             Expanded(child: Text('Order data inconsistency detected. Refreshing...')),
      //           ],
      //         ),
      //         backgroundColor: Colors.orange,
      //         action: SnackBarAction(
      //           label: 'Refresh',
      //           textColor: Colors.white,
      //           onPressed: () => _loadAndValidateData(),
      //         ),
      //       ),
      //     );
      //   });
      // }
    }
  }

  /// Validate customer data accuracy
  void _validateCustomerData(Map<String, List<FainzyUserOrder>> customerOrders, OrderProvider orderProvider) {
    final errors = <String>[];
    
    // Check for anonymous customers
    final anonymousCustomers = customerOrders['Anonymous Customer']?.length ?? 0;
    if (anonymousCustomers > 0) {
      errors.add('Found $anonymousCustomers orders with missing customer names');
    }
    
    // Check for duplicate customer names (potential data quality issue)
    final customerNames = customerOrders.keys.toList();
    final duplicateNames = customerNames.where((name) => 
      customerNames.where((n) => n.toLowerCase() == name.toLowerCase()).length > 1).toSet();
    
    if (duplicateNames.isNotEmpty) {
      errors.add('Potential duplicate customer names found: ${duplicateNames.join(', ')}');
    }
    
    // Validate total order count consistency
    final totalCustomerOrders = customerOrders.values.expand((orders) => orders).length;
    final providerCompletedOrders = context.read<OrderProvider>().completedOrders.length;
    
    if (totalCustomerOrders != providerCompletedOrders) {
      errors.add('Customer order count mismatch: aggregated($totalCustomerOrders) vs provider($providerCompletedOrders)');
    }
    
    // Log customer data errors
    if (errors.isNotEmpty) {
      dev.log('⚠️ Customer data validation errors:');
      for (final error in errors) {
        dev.log('  - $error');
      }
    } else {
      dev.log('✅ Customer data validation passed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await _loadAndValidateData();
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
                          _buildTopCustomers(),
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
        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade600,
                Colors.blue.shade800,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              // Left side - Store Avatar and Info
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Store avatar/image
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.2),
                            border: Border.all(color: Colors.white, width: 2),
                            image: storeProvider.storeImageUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(storeProvider.storeImageUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: storeProvider.storeImageUrl == null
                              ? const Icon(
                                  Icons.store,
                                  color: Colors.white,
                                  size: 32,
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        
                        // Store name and basic info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                storeProvider.storeName,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                storeProvider.storeBranch,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Store details in a better layout
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        // Address
                        _buildInfoChip(
                          icon: Icons.location_on,
                          text: _getFormattedAddress(storeProvider),
                          backgroundColor: Colors.white.withOpacity(0.15),
                        ),
                        
                        // Phone number if available
                        if (storeProvider.storePhoneNumber != null && storeProvider.storePhoneNumber!.isNotEmpty)
                          _buildInfoChip(
                            icon: Icons.phone,
                            text: storeProvider.storePhoneNumber!,
                            backgroundColor: Colors.white.withOpacity(0.15),
                          ),
                        
                        // Rating
                        _buildInfoChip(
                          icon: Icons.star,
                          text: '${storeProvider.storeRating.toStringAsFixed(1)} (${storeProvider.totalReviews} reviews)',
                          backgroundColor: Colors.amber.withOpacity(0.8),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Right side - Status Toggle
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Icon(
                      storeProvider.isOpen ? Icons.store : Icons.store_mall_directory_outlined,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Store Status',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      storeProvider.isOpen ? 'OPEN' : 'CLOSED',
                      style: TextStyle(
                        color: storeProvider.isOpen ? Colors.green.shade200 : Colors.red.shade200,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Switch(
                      value: storeProvider.isOpen,
                      onChanged: (value) {
                        storeProvider.toggleStoreStatus();
                      },
                      activeColor: Colors.white,
                      activeTrackColor: Colors.green.shade400,
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: Colors.red.shade400,
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

  Widget _buildInfoChip({
    required IconData icon,
    required String text,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.white.withOpacity(0.9),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _getFormattedAddress(StoreProvider storeProvider) {
    // Check multiple sources for address information to handle API variations
    String address = '';
    
    // Try location.addressDetails first
    if (storeProvider.storeData?.location?.addressDetails != null && 
        storeProvider.storeData!.location!.addressDetails!.isNotEmpty) {
      address = storeProvider.storeData!.location!.addressDetails!;
    }
    // Try address.addressDetails as fallback
    else if (storeProvider.storeData?.address?.addressDetails != null && 
             storeProvider.storeData!.address!.addressDetails!.isNotEmpty) {
      address = storeProvider.storeData!.address!.addressDetails!;
    }
    // Build from components if full address not available
    else {
      List<String> addressParts = [];
      
      // Try to get from location first
      if (storeProvider.storeData?.location != null) {
        final location = storeProvider.storeData!.location!;
        if (location.city != null && location.city!.isNotEmpty) {
          addressParts.add(location.city!);
        }
        if (location.state != null && location.state!.isNotEmpty) {
          addressParts.add(location.state!);
        }
        if (location.country != null && location.country!.isNotEmpty) {
          addressParts.add(location.country!);
        }
      }
      // Fallback to address object
      else if (storeProvider.storeData?.address != null) {
        final addressData = storeProvider.storeData!.address!;
        if (addressData.city.isNotEmpty) {
          addressParts.add(addressData.city);
        }
        if (addressData.state.isNotEmpty) {
          addressParts.add(addressData.state);
        }
        if (addressData.country.isNotEmpty) {
          addressParts.add(addressData.country);
        }
      }
      
      address = addressParts.isNotEmpty ? addressParts.join(', ') : 'Address not set';
    }
    
    return address;
  }

  Widget _buildKPICards() {
    return Consumer2<StoreProvider, OrderProvider>(
      builder: (context, storeProvider, orderProvider, child) {
        // Check data status and log any issues
        if (storeProvider.dataStatus == DataStatus.error) {
          dev.log('⚠️ StoreProvider is in error state: ${storeProvider.error}');
        }
        
        // Use real-time order data from OrderProvider when available
        final hasOrderData = orderProvider.allOrders.isNotEmpty;
        final totalOrders = hasOrderData ? orderProvider.allOrders.length : storeProvider.totalOrders;
        final pendingOrders = hasOrderData ? orderProvider.pendingOrders.length : storeProvider.pendingOrders;
        final activeOrders = hasOrderData ? orderProvider.activeOrders.length : storeProvider.activeOrders;
        final completedOrders = hasOrderData ? orderProvider.completedOrders.length : storeProvider.completedOrders;
        
        // Log data source being used
        if (hasOrderData) {
          dev.log('📊 Using real-time order data: Total=$totalOrders, Pending=$pendingOrders, Active=$activeOrders, Completed=$completedOrders');
        } else {
          dev.log('📊 Using statistics data: Total=$totalOrders, Pending=$pendingOrders, Active=$activeOrders, Completed=$completedOrders');
        }
        
        // Validate KPI data before displaying
        _validateKPIDataWithOrderProvider(storeProvider, orderProvider, totalOrders, pendingOrders, activeOrders, completedOrders);
        
        return Row(
          children: [
            Expanded(
              child: _buildKPICard(
                title: 'Total Revenue',
                value: storeProvider.formattedTotalRevenue,
                subtitle: 'This month',
                icon: Icons.trending_up,
                color: Colors.green,
                trend: 'Revenue from $totalOrders orders',
                isPositive: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildKPICard(
                title: 'Total Orders',
                value: '$totalOrders',
                subtitle: hasOrderData ? 'Real-time data' : 'All time',
                icon: Icons.receipt_long,
                color: Colors.blue,
                trend: '$pendingOrders pending',
                isPositive: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildKPICard(
                title: 'Active Orders',
                value: '$activeOrders',
                subtitle: 'In progress',
                icon: Icons.local_shipping,
                color: Colors.orange,
                trend: 'Being processed',
                isPositive: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildKPICard(
                title: 'Completed',
                value: '$completedOrders',
                subtitle: 'Delivered orders',
                icon: Icons.check_circle,
                color: Colors.purple,
                trend: hasOrderData && totalOrders > 0 
                    ? '${(completedOrders / totalOrders * 100).toStringAsFixed(1)}% completion rate'
                    : '${storeProvider.completionRate.toStringAsFixed(1)}% completion rate',
                isPositive: (hasOrderData && totalOrders > 0 
                    ? (completedOrders / totalOrders * 100) 
                    : storeProvider.completionRate) > 80.0,
              ),
            ),
          ],
        );
      },
    );
  }

  /// Validate KPI data accuracy with OrderProvider data
  void _validateKPIDataWithOrderProvider(StoreProvider storeProvider, OrderProvider orderProvider, 
      int totalOrders, int pendingOrders, int activeOrders, int completedOrders) {
    final errors = <String>[];
    
    // Check if revenue formatting is correct
    final revenue = storeProvider.totalRevenue;
    final formattedRevenue = storeProvider.formattedTotalRevenue;
    
    if (revenue > 0 && formattedRevenue.isEmpty) {
      errors.add('Revenue formatting failed: revenue=$revenue, formatted="$formattedRevenue"');
    }
    
    // Check for impossible values
    if (activeOrders < 0) {
      errors.add('Active orders cannot be negative: $activeOrders');
    }
    
    // Cross-validate between OrderProvider and StoreProvider data
    final statsTotal = storeProvider.totalOrders;
    final statsCompleted = storeProvider.completedOrders;
    final statsPending = storeProvider.pendingOrders;
    
    if (orderProvider.allOrders.isNotEmpty) {
      // Compare order counts from different sources
      if ((totalOrders - statsTotal).abs() > 5) { // Allow small differences
        errors.add('Large discrepancy in total orders: OrderProvider($totalOrders) vs StoreProvider($statsTotal)');
      }
      
      if ((completedOrders - statsCompleted).abs() > 5) {
        errors.add('Large discrepancy in completed orders: OrderProvider($completedOrders) vs StoreProvider($statsCompleted)');
      }
      
      if ((pendingOrders - statsPending).abs() > 5) {
        errors.add('Large discrepancy in pending orders: OrderProvider($pendingOrders) vs StoreProvider($statsPending)');
      }
      
      // Check that order counts add up correctly
      if (totalOrders != (pendingOrders + activeOrders + completedOrders)) {
        errors.add('Order counts don\'t add up: $pendingOrders + $activeOrders + $completedOrders ≠ $totalOrders');
      }
    }
    
    // Check completion rate logic
    if (totalOrders > 0) {
      final calculatedCompletionRate = (completedOrders / totalOrders) * 100;
      if (calculatedCompletionRate == 0 && completedOrders > 0) {
        errors.add('Completion rate calculation error: $completedOrders completed orders but rate is 0%');
      }
    }
    
    // Log KPI validation errors
    // if (errors.isNotEmpty) {
    //   dev.log('⚠️ KPI data validation errors:');
    //   for (final error in errors) {
    //     dev.log('  - $error');
    //   }
      
    //   // Show user notification for significant discrepancies
    //   if (errors.any((error) => error.contains('Large discrepancy'))) {
    //     WidgetsBinding.instance.addPostFrameCallback((_) {
    //       if (mounted) {
    //         ScaffoldMessenger.of(context).showSnackBar(
    //           SnackBar(
    //             content: const Row(
    //               children: [
    //                 Icon(Icons.sync_problem, color: Colors.white),
    //                 SizedBox(width: 8),
    //                 Expanded(child: Text('Data sources out of sync. Using real-time data.')),
    //               ],
    //             ),
    //             backgroundColor: Colors.blue,
    //             action: SnackBarAction(
    //               label: 'Refresh',
    //               textColor: Colors.white,
    //               onPressed: () => _loadAndValidateData(),
    //             ),
    //           ),
    //         );
    //       }
    //     });
    //   }
    // } else {
    //   dev.log('✅ KPI data validation passed');
    // }
  }

  /// Validate KPI data accuracy (legacy method for backward compatibility)
  void _validateKPIData(StoreProvider storeProvider) {
    final errors = <String>[];
    
    // Check if revenue formatting is correct
    final revenue = storeProvider.totalRevenue;
    final formattedRevenue = storeProvider.formattedTotalRevenue;
    
    if (revenue > 0 && formattedRevenue.isEmpty) {
      errors.add('Revenue formatting failed: revenue=$revenue, formatted="$formattedRevenue"');
    }
    
    // Check for impossible values
    if (storeProvider.activeOrders < 0) {
      errors.add('Active orders cannot be negative: ${storeProvider.activeOrders}');
    }
    
    // Check completion rate logic
    final completionRate = storeProvider.completionRate;
    if (storeProvider.totalOrders > 0 && completionRate == 0 && storeProvider.completedOrders > 0) {
      errors.add('Completion rate is 0% but completed orders exist: ${storeProvider.completedOrders}');
    }
    
    // Log KPI validation errors
    if (errors.isNotEmpty) {
      dev.log('⚠️ KPI data validation errors:');
      for (final error in errors) {
        dev.log('  - $error');
      }
    }
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

  Widget _buildTopCustomers() {
    return Consumer2<StoreProvider, OrderProvider>(
      builder: (context, storeProvider, orderProvider, child) {
        // Use StoreProvider's top customers if available, otherwise fall back to OrderProvider calculation
        final useStoreProviderData = storeProvider.topCustomers.isNotEmpty;
        
        List<Widget> customerWidgets = [];
        int customerCount = 0;
        
        if (useStoreProviderData) {
          // Use API top customers data
          final topCustomers = storeProvider.topCustomers.take(5).toList();
          customerCount = storeProvider.topCustomers.length;
          
          for (int i = 0; i < topCustomers.length; i++) {
            final customer = topCustomers[i];
            final isTop = i == 0;
            
            customerWidgets.add(
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildCustomerRowFromUser(
                  customer,
                  isTop,
                ),
              ),
            );
          }
          
          dev.log('🏆 Using StoreProvider top customers: ${topCustomers.length} customers');
        } else {
          // Fallback to OrderProvider calculation
          final customerOrders = <String, List<FainzyUserOrder>>{};
          for (final order in orderProvider.completedOrders) {
            final customerName = order.user?.name ?? 'Anonymous Customer';
            customerOrders.putIfAbsent(customerName, () => []).add(order);
          }

          // Validate customer data
          _validateCustomerData(customerOrders, orderProvider);

          // Sort customers by number of orders
          final topCustomers = customerOrders.entries.toList()
            ..sort((a, b) => b.value.length.compareTo(a.value.length));
          
          customerCount = customerOrders.length;
          
          for (int i = 0; i < topCustomers.take(5).length; i++) {
            final entry = topCustomers[i];
            final customerName = entry.key;
            final orders = entry.value;
            final totalSpent = orders.fold<double>(
              0.0, 
              (sum, order) => sum + (order.totalPrice ?? 0.0),
            );
            final isTop = i == 0;
            
            customerWidgets.add(
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildCustomerRowFromOrders(
                  customerName, 
                  orders.length, 
                  totalSpent,
                  isTop,
                ),
              ),
            );
          }
          
          dev.log('📊 Using OrderProvider fallback: ${topCustomers.length} customers');
        }

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
                    'Top Customers',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: useStoreProviderData ? Colors.green.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (useStoreProviderData)
                          const Icon(Icons.analytics, size: 14, color: Colors.green)
                        else
                          const Icon(Icons.analytics, size: 14, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text(
                          useStoreProviderData 
                              ? '${customerCount}'
                              : '${customerCount}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: useStoreProviderData ? Colors.green : Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              if (customerWidgets.isEmpty)
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 48, color: Colors.grey),
                      SizedBox(height: 12),
                      Text(
                        'No customers yet',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Complete some orders to see your top customers',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...customerWidgets,
            ],
          ),
        );
      },
    );
  }

  Widget _buildCustomerRowFromUser(FainzyUser customer, bool isTop) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isTop ? Colors.green.withOpacity(0.05) : Colors.grey.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isTop ? Colors.green.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isTop ? Colors.green : Colors.grey,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              isTop ? Icons.star : Icons.person,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          
          // Customer info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.fullName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  customer.email ?? customer.phoneNumber ?? 'No contact info',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          // Top badge
          if (isTop)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'TOP',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCustomerRowFromOrders(String name, int orderCount, double totalSpent, bool isTop) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isTop ? Colors.blue.withOpacity(0.05) : Colors.grey.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isTop ? Colors.blue.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isTop ? Colors.blue : Colors.grey,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              isTop ? Icons.star : Icons.person,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          
          // Customer info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$orderCount orders • ¥${totalSpent.floor()}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          // Top badge
          if (isTop)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'TOP',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOrdersChart() {
    return Consumer2<StoreProvider, OrderProvider>(
      builder: (context, storeProvider, orderProvider, child) {
        // Use real-time order data from OrderProvider when available
        final hasOrderData = orderProvider.allOrders.isNotEmpty;
        final totalOrders = hasOrderData ? orderProvider.allOrders.length : storeProvider.totalOrders;
        final completedOrders = hasOrderData ? orderProvider.completedOrders.length : storeProvider.completedOrders;
        final pendingOrders = hasOrderData ? orderProvider.pendingOrders.length : storeProvider.pendingOrders;
        final activeOrders = hasOrderData ? orderProvider.activeOrders.length : storeProvider.activeOrders;
        
        // Log data source being used
        dev.log('📊 Order chart using ${hasOrderData ? "real-time" : "statistics"} data: Total=$totalOrders, Completed=$completedOrders, Pending=$pendingOrders, Active=$activeOrders');
        
        // Validate order distribution data
        _validateOrderDistribution(totalOrders, completedOrders, pendingOrders, activeOrders);
        
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
                  Row(
                    children: [
                      Text(
                        '$totalOrders total',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (hasOrderData)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Live',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      else if (totalOrders == 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'No data',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              if (totalOrders > 0) ...[
                Column(
                  children: [
                    _buildOrderStatusRow(
                      'Completed',
                      completedOrders,
                      Colors.green,
                      totalOrders,
                    ),
                    const SizedBox(height: 12),
                    _buildOrderStatusRow(
                      'Pending',
                      pendingOrders,
                      Colors.orange,
                      totalOrders,
                    ),
                    const SizedBox(height: 12),
                    _buildOrderStatusRow(
                      'Active',
                      activeOrders,
                      Colors.blue,
                      totalOrders,
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
                        '${(completedOrders / totalOrders * 100).toStringAsFixed(1)}%',
                        Colors.green,
                      ),
                      Container(width: 1, height: 30, color: Colors.grey[300]),
                      _buildStatColumn(
                        'Pending Rate',
                        '${(pendingOrders / totalOrders * 100).toStringAsFixed(1)}%',
                        Colors.orange,
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // No orders state
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
                        SizedBox(height: 12),
                        Text(
                          'No orders yet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          'Order distribution will appear here once you receive orders',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
    
    return Consumer2<StoreProvider, OrderProvider>(
      builder: (context, storeProvider, orderProvider, child) {
        // Get recent orders (last 5)
        final recentOrders = orderProvider.allOrders
            .where((order) => order.created != null)
            .toList()
          ..sort((a, b) => b.created!.compareTo(a.created!));

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
              
              if (recentOrders.isNotEmpty) ...[
                // Recent orders activity
                ...recentOrders.take(3).map((order) {
                  String activityText;
                  Color activityColor;
                  IconData activityIcon;
                  
                  switch (order.status?.toLowerCase()) {
                    case 'completed':
                      activityText = 'Order #${order.code ?? order.id} completed';
                      activityColor = Colors.green;
                      activityIcon = Icons.check_circle;
                      break;
                    case 'pending':
                      activityText = 'New order #${order.code ?? order.id} received';
                      activityColor = Colors.orange;
                      activityIcon = Icons.pending;
                      break;
                    case 'cancelled':
                      activityText = 'Order #${order.code ?? order.id} cancelled';
                      activityColor = Colors.red;
                      activityIcon = Icons.cancel;
                      break;
                    case 'rejected':
                      activityText = 'Order #${order.code ?? order.id} rejected';
                      activityColor = Colors.red;
                      activityIcon = Icons.cancel;
                      break;
                    case 'refunded':
                      activityText = 'Order #${order.code ?? order.id} refunded';
                      activityColor = Colors.red;
                      activityIcon = Icons.cancel;
                      break;
                    default:
                      activityText = 'Order ${order.orderId ?? order.id} in progress';
                      activityColor = Colors.blue;
                      activityIcon = Icons.local_shipping;
                  }
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildActivityItem(
                      icon: activityIcon,
                      title: activityText,
                      subtitle: _buildOrderSubtitle(order),
                      color: activityColor,
                    ),
                  );
                }).toList(),
                const SizedBox(height: 8),
              ],
              
              if (orderProvider.completedOrders.isNotEmpty) ...[
                _buildActivityItem(
                  icon: Icons.analytics,
                  title: '${orderProvider.completedOrders.length} orders completed',
                  subtitle: 'Total revenue generated',
                  color: Colors.green,
                ),
                const SizedBox(height: 16),
              ],
              
              if (orderProvider.pendingOrders.isNotEmpty) ...[
                _buildActivityItem(
                  icon: Icons.pending_actions,
                  title: '${orderProvider.pendingOrders.length} orders awaiting action',
                  subtitle: 'Require immediate attention',
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
              
              if (recentOrders.isEmpty) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.inbox_outlined, size: 40, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        'No recent activity',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        'Order activity will appear here',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  String _formatActivityTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
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

  /// Build subtitle for order activity showing menu item count and customer info
  String _buildOrderSubtitle(FainzyUserOrder order) {
    // Calculate total menu items count
    int totalMenuItems = 0;
    if (order.menu != null && order.menu!.isNotEmpty) {
      for (final menuItem in order.menu!) {
        totalMenuItems += menuItem.quantity ?? 1;
      }
    }
    
    // Build subtitle with item count and customer info
    String itemCountText = totalMenuItems == 1 
        ? '1 menu item' 
        : '$totalMenuItems menu items';
    
    String customerInfo = order.user?.name != null 
        ? 'Customer: ${order.user!.name}' 
        : _formatActivityTime(order.created!);
    
    return '$itemCountText • $customerInfo';
  }
}
