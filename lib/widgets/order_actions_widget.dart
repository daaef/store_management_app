import 'package:flutter/material.dart';
import '../theme/colors/app_colors.dart';
import '../theme/text_styles/app_text_style.dart';
import '../models/fainzy_user_order.dart';

// Legacy OrderActionButtons - kept for backwards compatibility
class LegacyOrderActionButtons extends StatelessWidget {
  const LegacyOrderActionButtons({
    super.key,
    required this.status,
    required this.onActionTaken,
    required this.order,
  });

  final FainzyUserOrder order;
  final String status;
  final void Function(String status) onActionTaken;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (status == 'pending') ...[
          Expanded(
            child: MaterialButton(
              elevation: 1,
              highlightElevation: 1,
              hoverElevation: 1,
              focusElevation: 1,
              onPressed: () {
                onActionTaken.call('payment_processing');
              },
              color: Colors.green.shade700,
              height: 44,
              minWidth: 104,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Accept',
                style: AppTextStyle.subTitle2.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: MaterialButton(
              elevation: 1,
              highlightElevation: 1,
              hoverElevation: 1,
              focusElevation: 1,
              onPressed: () {
                _showConfirmationDialog(
                  context,
                  title: 'Confirm Reject Order',
                  message: 'If you reject this order, the order will be cancelled and can no longer be restarted.',
                  buttonText: 'Reject',
                  onConfirm: () {
                    onActionTaken.call('rejected');
                  },
                );
              },
              color: Colors.red,
              height: 44,
              minWidth: 104,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Reject',
                style: AppTextStyle.subTitle2.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ] else if (status == 'payment_processing') ...[
          Expanded(
            child: Text(
              'Please do not begin order preparation until payment is made, i.e., until you see the green Ready button.',
              style: AppTextStyle.caption.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                'Awaiting Payment',
                style: AppTextStyle.body2.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ] else if (status == 'order_processing') ...[
          Expanded(
            child: MaterialButton(
              elevation: 1,
              highlightElevation: 1,
              hoverElevation: 1,
              focusElevation: 1,
              onPressed: () {
                onActionTaken.call('ready');
              },
              color: Colors.green.shade600,
              height: 44,
              minWidth: 104,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Ready',
                style: AppTextStyle.subTitle2.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ] else if (status == 'ready') ...[
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                'Ready',
                style: AppTextStyle.body2.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ] else if (status == 'picked_up') ...[
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                'Picked Up',
                style: AppTextStyle.body2.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ] else if (status == 'out_for_delivery' ||
            status == 'near_delivery_location') ...[
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                'Delivering',
                style: AppTextStyle.body2.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ] else if (status == 'rejected') ...[
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                'Rejected',
                style: AppTextStyle.body2.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ] else if (status == 'cancelled') ...[
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                'Cancelled',
                style: AppTextStyle.body2.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ] else if (status == 'completed') ...[
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                'Completed',
                style: AppTextStyle.body2.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ] else ...[
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                status.toUpperCase(),
                style: AppTextStyle.body2.copyWith(
                  color: Colors.grey,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String buttonText,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(buttonText),
            ),
          ],
        );
      },
    );
  }
}
