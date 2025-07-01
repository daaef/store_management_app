import 'package:flutter/material.dart';
import '../models/fainzy_user_order.dart';

class OrderNotificationWidget extends StatelessWidget {
  final FainzyUserOrder? order;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onMarkReady;
  final VoidCallback? onViewDetails;
  final VoidCallback? onDismiss;
  
  const OrderNotificationWidget({
    super.key,
    this.order,
    this.onAccept,
    this.onReject,
    this.onMarkReady,
    this.onViewDetails,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.notifications),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      order != null 
                          ? 'New Order #${order!.orderId ?? order!.id}' 
                          : 'New order notifications will appear here',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (onDismiss != null)
                    IconButton(
                      onPressed: onDismiss,
                      icon: const Icon(Icons.close),
                    ),
                ],
              ),
              if (order != null) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (onAccept != null)
                      ElevatedButton(
                        onPressed: onAccept,
                        child: const Text('Accept'),
                      ),
                    const SizedBox(width: 8),
                    if (onReject != null)
                      ElevatedButton(
                        onPressed: onReject,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Reject'),
                      ),
                    const SizedBox(width: 8),
                    if (onMarkReady != null)
                      ElevatedButton(
                        onPressed: onMarkReady,
                        child: const Text('Mark Ready'),
                      ),
                    const SizedBox(width: 8),
                    if (onViewDetails != null)
                      ElevatedButton(
                        onPressed: onViewDetails,
                        child: const Text('View Details'),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
