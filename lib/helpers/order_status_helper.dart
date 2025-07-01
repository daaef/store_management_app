import 'package:flutter/material.dart';

/// Helper class for order status colors and display
class OrderStatusHelper {
  /// Get color for order status
  static Color getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'payment_processing':
        return Colors.red;
      case 'order_processing':
        return Colors.blue;
      case 'ready':
        return Colors.green;
      case 'enroute_pickup':
        return Colors.amber;
      case 'robot_arrived_for_pickup':
        return Colors.purple;
      case 'enroute_delivery':
      case 'robot_arrived_for_delivery':
        return Colors.teal;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'rejected':
        return Colors.red;
      case 'refunded':
        return Colors.orange;
      default:
        return Colors.blueGrey; // For unknown status
    }
  }

  /// Get display name for order status
  static String getStatusDisplayName(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'payment_processing':
        return 'Awaiting Payment';
      case 'order_processing':
        return 'Processing';
      case 'ready':
        return 'Ready for Pickup';
      case 'enroute_pickup':
        return 'Robot En Route to Store';
      case 'robot_arrived_for_pickup':
        return 'Robot Arrived';
      case 'enroute_delivery':
        return 'Delivering';
      case 'robot_arrived_for_delivery':
        return 'Delivering';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'rejected':
        return 'Rejected';
      case 'refunded':
        return 'Refunded';
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
      case 'refunded':
        return false;
      case 'payment_processing':
      case 'order_processing':
      case 'ready':
      case 'enroute_pickup':
      case 'robot_arrived_for_pickup':
      case 'enroute_delivery':
      case 'robot_arrived_for_delivery':
        return true;
      default:
        return true;
    }
  }
}
