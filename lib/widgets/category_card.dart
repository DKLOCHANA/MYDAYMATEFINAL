import 'package:flutter/material.dart';
import 'package:mydaymate/core/theme/app_colors.dart';
import 'package:mydaymate/core/utils/devices.dart';

class CategoryCard extends StatelessWidget {
  final Color avatarColor;
  final IconData icon;
  final String categoryName;
  final double amount;
  final String date;
  final bool isExpense;
  final String? subtitle;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.avatarColor,
    required this.icon,
    required this.categoryName,
    required this.amount,
    required this.date,
    this.isExpense = true,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.all(DeviceLayout.spacing(16)),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundColor: avatarColor,
                  child: Icon(icon, color: Colors.white),
                ),
                SizedBox(width: DeviceLayout.spacing(8)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(categoryName,
                          style: Theme.of(context).textTheme.bodyLarge),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isExpense ? "- " : "+ "}Rs ${amount.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color:
                                isExpense ? AppColors.error : AppColors.primary,
                          ),
                    ),
                    Text(
                      date,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            if (onTap != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.receipt, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      'Receipt available',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
