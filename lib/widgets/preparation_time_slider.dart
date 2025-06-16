import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/fainzy_user_order.dart';
import '../providers/order_provider.dart';

class PreparationTimeSlider extends StatefulWidget {
  const PreparationTimeSlider({
    super.key,
    required this.order,
    this.onTimeChanged,
  });

  final FainzyUserOrder order;
  final void Function(int minutes)? onTimeChanged;

  @override
  State<PreparationTimeSlider> createState() => _PreparationTimeSliderState();
}

class _PreparationTimeSliderState extends State<PreparationTimeSlider> {
  double _preparationTime = 15.0; // Default 15 minutes
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    // Initialize with existing preparation time if available
    if (widget.order.estimatedEta != null) {
      _preparationTime = widget.order.estimatedEta!.clamp(5.0, 120.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderId = widget.order.id;
    
    if (orderId == null) {
      return const SizedBox.shrink();
    }

    // Only show for orders that are in preparation or can be prepared
    final status = widget.order.status;
    if (status != 'order_processing' && status != 'payment_processing' && status != 'pending') {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: Colors.orange.shade700,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Preparation Time',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                const Spacer(),
                if (_isUpdating)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.orange.shade700),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  '5 min',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.orange.shade600,
                      inactiveTrackColor: Colors.orange.shade200,
                      thumbColor: Colors.orange.shade700,
                      overlayColor: Colors.orange.shade100,
                      valueIndicatorColor: Colors.orange.shade700,
                      valueIndicatorTextStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: Slider(
                      value: _preparationTime,
                      min: 5.0,
                      max: 120.0,
                      divisions: 23, // 5-minute increments
                      label: '${_preparationTime.round()} min',
                      onChanged: _isUpdating ? null : (value) {
                        setState(() {
                          _preparationTime = value;
                        });
                      },
                      onChangeEnd: (value) {
                        _updatePreparationTime();
                      },
                    ),
                  ),
                ),
                Text(
                  '2 hrs',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orange.shade300),
                ),
                child: Text(
                  'Estimated: ${_preparationTime.round()} minutes',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            if (status == 'payment_processing') ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade700,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Preparation time will be communicated to customer once payment is confirmed',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isUpdating ? null : () => _setQuickTime(15),
                    icon: const Icon(Icons.flash_on, size: 16),
                    label: const Text('15 min'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange.shade700,
                      side: BorderSide(color: Colors.orange.shade300),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isUpdating ? null : () => _setQuickTime(30),
                    icon: const Icon(Icons.schedule, size: 16),
                    label: const Text('30 min'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange.shade700,
                      side: BorderSide(color: Colors.orange.shade300),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isUpdating ? null : () => _setQuickTime(45),
                    icon: const Icon(Icons.schedule_outlined, size: 16),
                    label: const Text('45 min'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange.shade700,
                      side: BorderSide(color: Colors.orange.shade300),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _setQuickTime(int minutes) {
    setState(() {
      _preparationTime = minutes.toDouble();
    });
    _updatePreparationTime();
  }

  void _updatePreparationTime() async {
    if (_isUpdating) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      final orderProvider = context.read<OrderProvider>();
      final success = await orderProvider.updatePreparationTime(
        orderId: widget.order.id!,
        preparationTimeMinutes: _preparationTime.round(),
      );

      if (success) {
        widget.onTimeChanged?.call(_preparationTime.round());
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Preparation time updated to ${_preparationTime.round()} minutes'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update preparation time'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating preparation time: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }
}

/// Simple preparation time display widget for completed orders
class PreparationTimeDisplay extends StatelessWidget {
  const PreparationTimeDisplay({
    super.key,
    required this.order,
  });

  final FainzyUserOrder order;

  @override
  Widget build(BuildContext context) {
    final estimatedEta = order.estimatedEta;
    if (estimatedEta == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.access_time,
            size: 14,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 4),
          Text(
            '${estimatedEta.round()} min prep',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}