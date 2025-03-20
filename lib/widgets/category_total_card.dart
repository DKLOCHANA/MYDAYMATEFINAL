import 'package:flutter/material.dart';
import 'package:mydaymate/core/theme/app_colors.dart';
import 'package:mydaymate/core/utils/devices.dart';

class CategoryTotalCard extends StatelessWidget {
  final Color avatarColor;
  final IconData icon;
  final String categoryName;
  final double amount;
  final bool isExpense;

  const CategoryTotalCard({
    super.key,
    required this.avatarColor,
    required this.icon,
    required this.categoryName,
    required this.amount,
    this.isExpense = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.all(DeviceLayout.spacing(16)),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: avatarColor,
            child: Icon(icon, color: Colors.white),
          ),
          SizedBox(width: DeviceLayout.spacing(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  categoryName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: 4),
                Text(
                  'Tap to view details',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Rs ${amount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isExpense ? AppColors.error : AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
