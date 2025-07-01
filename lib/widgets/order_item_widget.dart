import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../theme/colors/app_colors.dart';
import '../theme/text_styles/app_text_style.dart';
import '../models/fainzy_user_order.dart';
import '../models/location.dart';
import '../providers/order_provider.dart';
import '../helpers/currency_formatter.dart';
import '../helpers/order_status_helper.dart';
import '../helpers/date_formatter.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:shimmer/shimmer.dart';
import '../services/currency_service.dart';

class OrderItemWidget extends StatelessWidget {
  const OrderItemWidget({
    super.key,
    required this.order,
  });

  final FainzyUserOrder order;

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        final isUpdating = orderProvider.isUpdating && 
                          orderProvider.selectedOrder?.id == order.id;
        
        if (isUpdating) {
          return _buildShimmerCard();
        }
        
        return _buildOrderCard(context, orderProvider);
      },
    );
  }

  Widget _buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Card(
        elevation: 2,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Order header shimmer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 18,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    height: 18,
                    width: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Customer name shimmer
              Container(
                height: 14,
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 4),
              
              // Time shimmer
              Container(
                height: 12,
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 12),
              
              // Menu items shimmer
              Container(
                height: 14,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                height: 14,
                width: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 12),
              
              // Action buttons shimmer
              Container(
                height: 36,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderProvider orderProvider) {
    final statusColor = OrderStatusHelper.getStatusColor(order.status);
    final statusDisplayName = OrderStatusHelper.getStatusDisplayName(order.status);
    
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: statusColor, width: 2),
      ),
      child: InkWell(
        onTap: () {
          _navigateToOrderDetails(context, order.id);
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                statusColor.withOpacity(0.05),
                statusColor.withOpacity(0.02),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Order ID
                Text(
                  'Order ID: ${order.orderId ?? 'N/A'}',
                  style: AppTextStyle.headline6.copyWith(
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Customer Name
                if (order.user?.name != null) ...[
                  Row(
                    children: [
                      Icon(Icons.person, size: 16, color: AppColors.grey600),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          order.user!.name!,
                          style: AppTextStyle.body2.copyWith(
                            color: AppColors.grey600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],
                
                // Customer Phone
                if (order.user?.phone != null) ...[
                  Row(
                    children: [
                      Icon(Icons.phone, size: 16, color: AppColors.grey600),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          order.user!.phone!,
                          style: AppTextStyle.body2.copyWith(
                            color: AppColors.grey600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],
                
                // Order Time
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: AppColors.grey600),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.created != null
                                ? timeago.format(order.created!)
                                : 'Unknown time',
                            style: AppTextStyle.body2.copyWith(
                              color: AppColors.grey600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (order.created != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              DateFormatter.formatNormal(order.created!),
                              style: AppTextStyle.caption.copyWith(
                                color: AppColors.grey400,
                              ),
                            ),
                            Text(
                              DateFormatter.formatKanji(order.created!),
                              style: AppTextStyle.caption.copyWith(
                                color: AppColors.grey400,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                
                // Total Price
                Row(
                  children: [
                    FutureBuilder<String>(
                      future: CurrencyService.getCurrentCurrency(),
                      builder: (context, snapshot) {
                        return CurrencyService.getCurrencyIcon(
                          currencyCode: snapshot.data,
                          size: 16,
                          color: AppColors.grey600,
                        );
                      },
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        order.totalPrice != null 
                            ? CurrencyFormatter.format(order.totalPrice!, currencyCode: 'JPY')
                            : '¥0',
                        style: AppTextStyle.body1.copyWith(
                          color: AppColors.primaryMain,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Menu Items
                if (order.menu != null && order.menu!.isNotEmpty) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.restaurant_menu, size: 16, color: AppColors.grey600),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _formatMenuItemsCount(order.menu!),
                          style: AppTextStyle.body2.copyWith(
                            color: AppColors.grey600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                
                // Delivery Address
                if (order.deliveryLocation != null) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on, size: 16, color: AppColors.grey600),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _formatAddress(order.deliveryLocation!),
                          style: AppTextStyle.body2.copyWith(
                            color: AppColors.grey600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                
                // Order Code
               /*  if (order.code != null) ...[
                  Row(
                    children: [
                      Icon(Icons.qr_code, size: 16, color: AppColors.grey600),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Code: ${order.code}',
                          style: AppTextStyle.body2.copyWith(
                            color: AppColors.grey600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                 */
                // Status at the bottom - prominent text without background
                Text(
                  statusDisplayName.toUpperCase(),
                  style: AppTextStyle.headline6.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                // Add action buttons for actionable statuses
                if (_shouldShowActionButtons(order.status)) ...[
                  const SizedBox(height: 12),
                  _buildInlineActionButtons(context, order),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatAddress(Location location) {
    final parts = <String>[];
    
    if (location.addressDetails != null && location.addressDetails!.isNotEmpty) {
      parts.add(location.addressDetails!);
    }
    if (location.city != null && location.city!.isNotEmpty) {
      parts.add(location.city!);
    }
    if (location.state != null && location.state!.isNotEmpty) {
      parts.add(location.state!);
    }
    if (location.country != null && location.country!.isNotEmpty) {
      parts.add(location.country!);
    }
    
    return parts.isNotEmpty ? parts.join(', ') : 'No address provided';
  }

  void _navigateToOrderDetails(BuildContext context, int? orderId) {
    if (orderId != null) {
      Navigator.pushNamed(
        context,
        '/order-details',
        arguments: orderId,
      );
    }
  }

  bool _shouldShowActionButtons(String? status) {
    // Show action buttons for orders that need merchant interaction
    return status == 'pending' || 
           status == 'order_processing';
  }

  Widget _buildInlineActionButtons(BuildContext context, FainzyUserOrder order) {
    final orderProvider = context.watch<OrderProvider>();
    final orderId = order.id;
    
    if (orderId == null) return const SizedBox.shrink();
    
    final isUpdating = orderProvider.isOrderUpdating(orderId);
    final status = order.status ?? 'unknown';

    return Row(
      children: [
        if (status == 'pending') ...[
          Expanded(
            child: _buildActionButton(
              context: context,
              label: 'Accept',
              color: Colors.green,
              isLoading: isUpdating,
              onPressed: () async {
                await orderProvider.acceptOrder(orderId);
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildActionButton(
              context: context,
              label: 'Reject',
              color: Colors.red,
              isLoading: isUpdating,
              onPressed: () async {
                final confirmed = await _showConfirmationDialog(
                  context,
                  'Reject Order',
                  'Are you sure you want to reject this order?',
                );
                if (confirmed) {
                  await orderProvider.rejectOrder(orderId);
                }
              },
            ),
          ),
        ] else if (status == 'order_processing') ...[
          Expanded(
            child: _buildActionButton(
              context: context,
              label: 'Mark Ready',
              color: Colors.blue,
              isLoading: isUpdating,
              onPressed: () async {
                await orderProvider.markOrderReady(orderId);
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required Color color,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 32,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                label,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  Future<bool> _showConfirmationDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Calculate and format the total count of menu items in the order
  String _formatMenuItemsCount(List menu) {
    int totalCount = 0;
    int totalSides = 0;
    
    for (final item in menu) {
      int quantity = 1; // Default quantity if not specified
      
      // Handle different menu item types
      if (item is Map<String, dynamic>) {
        quantity = item['quantity'] as int? ?? 1;
        
        // Count sides
        final sides = item['sides'] as List<dynamic>? ?? [];
        totalSides += sides.length;
      } else if (item.quantity != null) {
        quantity = item.quantity!;
        
        // Count sides from model
        if (item.sides != null) {
          totalSides += (item.sides!.length as int);
        }
      }
      
      totalCount += quantity;
    }
    
    // Format the count string
    String itemText = totalCount == 1 
        ? '1x menu item' 
        : '${totalCount}x menu items';
    
    if (totalSides > 0) {
      String sidesText = totalSides == 1 
          ? '1 side' 
          : '$totalSides sides';
      return '$itemText ($sidesText)';
    }
    
    return itemText;
  }
}