import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:gap/gap.dart';
import '../theme/colors/app_colors.dart';
import '../theme/text_styles/app_text_style.dart';
import '../widgets/custom_app_bar.dart';
import '../providers/order_provider.dart';
import '../widgets/order_action_buttons.dart'; // Updated to use new enhanced version
import '../widgets/preparation_time_slider.dart'; // Add preparation time slider
import '../helpers/currency_formatter.dart';
import 'package:timeago/timeago.dart' as timeago;

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key, required this.orderId});

  final int orderId;

  static Route<dynamic> route(int orderId) {
    return MaterialPageRoute<void>(
      builder: (_) => OrderDetailsScreen(orderId: orderId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _OrderDetailsView(orderId: orderId);
  }
}

class _OrderDetailsView extends StatelessWidget {
  const _OrderDetailsView({required this.orderId});

  final int orderId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Order Details',
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          // Fetch order when first loading the screen
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (orderProvider.selectedOrder?.id != orderId) {
              orderProvider.fetchOrderById(orderId: orderId);
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error loading order',
                    style: AppTextStyle.headline6,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    orderProvider.error ?? 'An unknown error occurred',
                    style: AppTextStyle.body2.copyWith(color: AppColors.errorColor),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => orderProvider.fetchOrderById(orderId: orderId),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final order = orderProvider.selectedOrder;
          if (order == null) {
            return const Center(
              child: Text('Order not found'),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header section with order status and key info
                _buildOrderHeader(order),
                
                // Main content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Action buttons section
                      _buildActionSection(order, orderProvider),
                      const Gap(32),
                      
                      // Order summary cards
                      _buildOrderSummary(order),
                      const Gap(32),
                      
                      // Customer information
                      _buildCustomerInfo(order),
                      const Gap(32),
                      
                      // Order items
                      _buildOrderItems(order),
                      const Gap(32),
                      
                      // Delivery information
                      if (order.deliveryLocation != null)
                        _buildDeliveryInfo(order),
                      
                      const Gap(24),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, {bool fullWidth = false}) {
    return Container(
      width: fullWidth ? double.infinity : null,
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyle.caption.copyWith(
                color: AppColors.grey400,
              ),
            ),
            const Gap(8),
            Text(
              value,
              style: AppTextStyle.body1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(dynamic item) {
    final menuName = item.menu?.name ?? 'Unknown Item';
    final quantity = item.quantity ?? 0;
    final menuPrice = item.menu?.price;
    final price = menuPrice != null 
        ? CurrencyFormatter.format(menuPrice, currencyCode: 'JPY')
        : '¥0';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  menuName,
                  style: AppTextStyle.subTitle1,
                ),
                const Gap(4),
                Text(
                  'Quantity: $quantity',
                  style: AppTextStyle.body2.copyWith(
                    color: AppColors.grey400,
                  ),
                ),
              ],
            ),
          ),
          Text(
            price,
            style: AppTextStyle.subTitle1.copyWith(
              color: AppColors.primaryMain,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusDisplayText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'payment_processing':
        return 'Payment Processing';
      case 'processing':
        return 'Processing';
      case 'ready':
        return 'Ready';
      case 'enroute':
        return 'En Route';
      case 'completed':
        return 'Completed';
      case 'rejected':
        return 'Rejected';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status.toUpperCase();
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'payment_processing':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'ready':
        return Colors.green;
      case 'enroute':
        return Colors.indigo;
      case 'completed':
        return Colors.green.shade700;
      case 'rejected':
      case 'cancelled':
        return Colors.red;
      default:
        return AppColors.grey400;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'payment_processing':
        return Icons.payment;
      case 'processing':
        return Icons.kitchen;
      case 'ready':
        return Icons.check_circle;
      case 'enroute':
        return Icons.delivery_dining;
      case 'completed':
        return Icons.check_circle_outline;
      case 'rejected':
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  List<Color> _getHeaderColors(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return [
          Colors.orange.shade600,
          Colors.orange.shade400,
        ];
      case 'payment_processing':
        return [
          Colors.amber.shade700,
          Colors.amber.shade500,
        ];
      case 'processing':
        return [
          Colors.blue.shade600,
          Colors.blue.shade400,
        ];
      case 'ready':
        return [
          Colors.green.shade600,
          Colors.green.shade400,
        ];
      case 'enroute':
        return [
          Colors.indigo.shade600,
          Colors.indigo.shade400,
        ];
      case 'completed':
        return [
          Colors.green.shade800,
          Colors.green.shade600,
        ];
      case 'rejected':
      case 'cancelled':
        return [
          Colors.red.shade600,
          Colors.red.shade400,
        ];
      default:
        return [
          AppColors.grey400,
          AppColors.grey200,
        ];
    }
  }

  Widget _buildOrderHeader(dynamic order) {
    final status = order.status ?? 'unknown';
    final statusColor = _getStatusColor(status);
    final statusIcon = _getStatusIcon(status);
    final statusText = _getStatusDisplayText(status);
    
    final orderTotal = order.totalPrice != null 
        ? CurrencyFormatter.format(order.totalPrice!, currencyCode: 'JPY')
        : '¥0';

    // Get header colors based on status
    final headerColors = _getHeaderColors(status);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: headerColors,
        ),
        boxShadow: [
          BoxShadow(
            color: headerColors.first.withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.receipt_long,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const Gap(16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${order.id}',
                          style: AppTextStyle.headline5.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          order.created != null 
                              ? timeago.format(order.created!)
                              : 'Unknown time',
                          style: AppTextStyle.body2.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    orderTotal,
                    style: AppTextStyle.headline6.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Gap(20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      statusIcon,
                      color: Colors.white,
                      size: 20,
                    ),
                    const Gap(8),
                    Text(
                      statusText,
                      style: AppTextStyle.subTitle2.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionSection(dynamic order, OrderProvider orderProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions',
          style: AppTextStyle.headline6.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap(16),
        OrderActionButtons(
          order: order,
          onActionTaken: (status) async {
            await orderProvider.updateOrderStatus(
              orderId: order.id!,
              status: status,
            );
          },
        ),
        const Gap(16),
        // Add preparation time slider for applicable orders
        PreparationTimeSlider(
          order: order,
          onTimeChanged: (minutes) async {
            if (order.id != null) {
              await orderProvider.updatePreparationTime(
                orderId: order.id!,
                preparationTimeMinutes: minutes,
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildOrderSummary(dynamic order) {
    final itemsCount = order.menu?.length ?? 0;
    final totalAmount = order.totalPrice != null 
        ? CurrencyFormatter.format(order.totalPrice!, currencyCode: 'JPY')
        : '¥0';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order Summary',
          style: AppTextStyle.headline6.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap(16),
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                'Items',
                '$itemsCount items',
              ),
            ),
            const Gap(16),
            Expanded(
              child: _buildInfoCard(
                'Total Amount',
                totalAmount,
              ),
            ),
          ],
        ),
        const Gap(16),
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                'Order ID',
                order.orderId ?? 'N/A',
              ),
            ),
            const Gap(16),
            Expanded(
              child: _buildInfoCard(
                'Order Code',
                order.code ?? 'N/A',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomerInfo(dynamic order) {
    final customer = order.user;
    final customerName = customer?.name ?? 'Unknown Customer';
    final customerPhone = customer?.phone ?? 'Not provided';
    final customerEmail = customer?.email ?? 'Not provided';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Customer Information',
          style: AppTextStyle.headline6.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap(16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryMain.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.person,
                      color: AppColors.primaryMain,
                      size: 20,
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customerName,
                          style: AppTextStyle.subTitle1.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          'Customer',
                          style: AppTextStyle.caption.copyWith(
                            color: AppColors.grey400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Gap(16),
              _buildContactRow(Icons.phone, 'Phone', customerPhone),
              const Gap(8),
              _buildContactRow(Icons.email, 'Email', customerEmail),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.grey400,
        ),
        const Gap(8),
        Text(
          '$label: ',
          style: AppTextStyle.body2.copyWith(
            color: AppColors.grey400,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyle.body2,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItems(dynamic order) {
    final orderItems = order.menu ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Order Items',
              style: AppTextStyle.headline6.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryMain.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${orderItems.length}',
                style: AppTextStyle.caption.copyWith(
                  color: AppColors.primaryMain,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const Gap(16),
        if (orderItems.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 48,
                  color: AppColors.grey400,
                ),
                const Gap(12),
                Text(
                  'No items in this order',
                  style: AppTextStyle.body1.copyWith(
                    color: AppColors.grey400,
                  ),
                ),
              ],
            ),
          )
        else
          ...orderItems.map<Widget>((item) => _buildMenuItem(item)).toList(),
      ],
    );
  }

  Widget _buildDeliveryInfo(dynamic order) {
    final deliveryLocation = order.deliveryLocation;
    
    // Build address from available location properties
    String address = 'Not specified';
    if (deliveryLocation != null) {
      final addressParts = <String>[];
      
      if (deliveryLocation.addressDetails != null && deliveryLocation.addressDetails!.isNotEmpty) {
        addressParts.add(deliveryLocation.addressDetails!);
      }
      if (deliveryLocation.city != null && deliveryLocation.city!.isNotEmpty) {
        addressParts.add(deliveryLocation.city!);
      }
      if (deliveryLocation.state != null && deliveryLocation.state!.isNotEmpty) {
        addressParts.add(deliveryLocation.state!);
      }
      if (deliveryLocation.country != null && deliveryLocation.country!.isNotEmpty) {
        addressParts.add(deliveryLocation.country!);
      }
      
      if (addressParts.isNotEmpty) {
        address = addressParts.join(', ');
      }
    }
    
    final instructions = 'No special instructions'; // Property doesn't exist in model
    final estimatedTime = order.estimatedEta; // This is a double, not a DateTime

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Delivery Information',
          style: AppTextStyle.headline6.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap(16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.location_on,
                      color: Colors.green,
                      size: 20,
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Delivery Address',
                          style: AppTextStyle.subTitle2.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          address,
                          style: AppTextStyle.body2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Gap(16),
              if (estimatedTime != null) ...[
                _buildDeliveryRow(
                  Icons.schedule,
                  'Estimated ETA',
                  '${estimatedTime.toStringAsFixed(0)} minutes',
                ),
                const Gap(8),
              ],
              _buildDeliveryRow(
                Icons.note_alt,
                'Instructions',
                instructions,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.grey400,
        ),
        const Gap(8),
        Text(
          '$label: ',
          style: AppTextStyle.body2.copyWith(
            color: AppColors.grey400,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyle.body2,
          ),
        ),
      ],
    );
  }

}