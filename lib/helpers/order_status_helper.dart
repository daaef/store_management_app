import 'package:flutter/material.dart';

/// Helper class for order status colors and display
class OrderStatusHelper {
  /// Get color for order status
  static Color getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'rejected':
        return Colors.grey;
      case 'order_processing':
        return Colors.blue;
      case 'ready':
        return Colors.teal;
      case 'picked_up':
        return Colors.indigo;
      case 'out_for_delivery':
        return Colors.purple;
      case 'near_delivery_location':
        return Colors.deepPurple;
      default:
        return Colors.blueGrey; // For active orders or unknown status
    }
  }

  /// Get display name for order status
  static String getStatusDisplayName(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'rejected':
        return 'Rejected';
      case 'order_processing':
        return 'Processing';
      case 'ready':
        return 'Ready';
      case 'picked_up':
        return 'Picked Up';
      case 'out_for_delivery':
        return 'Out for Delivery';
      case 'near_delivery_location':
        return 'Near Location';
      default:
        return status?.toUpperCase() ?? 'Unknown';
    }
  }

  /// Check if status is active (not pending, completed, cancelled, or rejected)
  static bool isActiveStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
      case 'completed':
      case 'cancelled':
      case 'rejected':
        return false;
      default:
        return true;
    }
  }
}
