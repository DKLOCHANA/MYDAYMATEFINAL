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

  const CategoryCard({
    super.key,
    required this.avatarColor,
    required this.icon,
    required this.categoryName,
    required this.amount,
    required this.date,
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
              Text(categoryName, style: Theme.of(context).textTheme.bodyLarge),
              const Spacer(),
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
          SizedBox(height: DeviceLayout.spacing(8)),
        ],
      ),
    );
  }
}
