import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/fainzy_user_order.dart';
import '../providers/order_provider.dart';

class OrderActionButtons extends StatelessWidget {
  const OrderActionButtons({
    super.key,
    required this.order,
    required this.onActionTaken,
  });

  final FainzyUserOrder order;
  final void Function(String status) onActionTaken;

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final status = order.status ?? 'unknown';
    final orderId = order.id;
    
    if (orderId == null) {
      return const SizedBox.shrink();
    }

    final isUpdating = orderProvider.isOrderUpdating(orderId);
    final error = orderProvider.getOrderActionError(orderId);

    return Column(
      children: [
        if (error != null)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.red.shade300),
            ),
            child: Row(
              children: [
                Icon(Icons.error, color: Colors.red.shade700, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    error,
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: _buildActionButtons(context, status, isUpdating),
        ),
      ],
    );
  }

  List<Widget> _buildActionButtons(BuildContext context, String status, bool isUpdating) {
    if (isUpdating) {
      return [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.grey.shade600),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Updating...',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ];
    }

    switch (status) {
      case 'pending':
        return [
          Expanded(
            child: _ActionButton(
              label: 'Accept',
              color: Colors.green.shade700,
              onPressed: () => _showAcceptDialog(context),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ActionButton(
              label: 'Reject',
              color: Colors.red,
              onPressed: () => _showRejectDialog(context),
            ),
          ),
        ];

      case 'payment_processing':
        return [
          Expanded(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Awaiting Payment',
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please wait for payment confirmation before starting preparation',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (order.cancellationTime != null) ...[
                  const SizedBox(height: 4),
                  CancellationCountdownWidget(order: order),
                ],
              ],
            ),
          ),
        ];

      case 'order_processing':
        return [
          Expanded(
            child: _ActionButton(
              label: 'Mark Ready',
              color: Colors.green.shade600,
              onPressed: () => onActionTaken('ready'),
            ),
          ),
        ];

      case 'ready':
        return [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Ready for Pickup',
              style: TextStyle(
                color: Colors.green.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ];

      case 'enroute_pickup':
        return [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'En Route to Store',
              style: TextStyle(
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ];

      case 'robot_arrived_for_pickup':
        return [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.purple.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Robot Arrived',
              style: TextStyle(
                color: Colors.purple.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ];

      case 'enroute_delivery':
      case 'robot_arrived_for_delivery':
        return [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Delivering',
              style: TextStyle(
                color: Colors.green.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ];

      case 'completed':
        return [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Completed',
              style: TextStyle(
                color: Colors.green.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ];

      case 'rejected':
        return [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Rejected',
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ];

      case 'cancelled':
        return [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Cancelled',
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ];

      default:
        return [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status.toUpperCase(),
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ];
    }
  }

  void _showAcceptDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Accept Order'),
          content: Text('Accept order ${order.orderId ?? order.id}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onActionTaken('payment_processing');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
              ),
              child: const Text('Accept'),
            ),
          ],
        );
      },
    );
  }

  void _showRejectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reject Order'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Reject order ${order.orderId ?? order.id}?'),
              const SizedBox(height: 16),
              const Text(
                'If you reject this order, it will be cancelled and cannot be restarted.',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onActionTaken('rejected');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      elevation: 1,
      highlightElevation: 1,
      hoverElevation: 1,
      focusElevation: 1,
      onPressed: onPressed,
      color: color,
      height: 44,
      minWidth: 104,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Cancellation countdown widget for orders with cancellation time
class CancellationCountdownWidget extends StatefulWidget {
  const CancellationCountdownWidget({
    super.key,
    required this.order,
  });

  final FainzyUserOrder order;

  @override
  State<CancellationCountdownWidget> createState() => _CancellationCountdownWidgetState();
}

class _CancellationCountdownWidgetState extends State<CancellationCountdownWidget> {
  Timer? _timer;
  Duration _countDownDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    if (widget.order.cancellationTime != null) {
      _countDownDuration = widget.order.cancellationTime!.toLocal().difference(DateTime.now());
    }
    _startCountDown();
  }

  void _startCountDown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), _handleTimer);
  }

  void _handleTimer(Timer timer) {
    final secondsLeft = _countDownDuration.inSeconds > 0 ? _countDownDuration.inSeconds - 1 : 0;
    if (secondsLeft <= 0) {
      _stopCountDown();
    } else {
      setState(() {
        _countDownDuration = Duration(seconds: secondsLeft);
      });
    }
  }

  void _stopCountDown() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_countDownDuration.inSeconds <= 0) {
      return const SizedBox.shrink();
    }

    String strDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = strDigits(_countDownDuration.inMinutes.remainder(60));
    final seconds = strDigits(_countDownDuration.inSeconds.remainder(60));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Text(
        'Auto-cancel in $minutes:$seconds',
        style: TextStyle(
          color: Colors.orange.shade700,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}