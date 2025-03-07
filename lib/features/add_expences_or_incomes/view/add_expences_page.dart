import 'package:flutter/material.dart';
import '../../../widgets/custom_appbar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/devices.dart';

class AddExpencesPage extends StatelessWidget {
  const AddExpencesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final categoryItems = [
      {
        'name': 'Food',
        'icon': Icons.fastfood_rounded,
        'color': Colors.orange,
      },
      {
        'name': 'Travel',
        'icon': Icons.directions_car,
        'color': Colors.blue,
      },
      {
        'name': 'Medicine',
        'icon': Icons.medical_services,
        'color': Colors.red,
      },
      {
        'name': 'Others',
        'icon': Icons.more_horiz,
        'color': Colors.purple,
      },
    ];

    String? selectedCategory;

    return Scaffold(
      appBar: const CustomAppbar(title: 'Add Expense'),
      body: Padding(
        padding: EdgeInsets.all(DeviceLayout.spacing(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount Input Container
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(DeviceLayout.spacing(20)),
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Amount', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  Center(
                    child: IntrinsicWidth(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            'Rs ',
                            style: Theme.of(context)
                                .textTheme
                                .headlineLarge
                                ?.copyWith(
                                  color: AppColors.primary,
                                ),
                          ),
                          Expanded(
                            child: TextField(
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              style: Theme.of(context).textTheme.headlineLarge,
                              decoration: const InputDecoration(
                                hintText: '0',
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: DeviceLayout.spacing(20)),

            // Category Container
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: DeviceLayout.spacing(16),
                vertical: DeviceLayout.spacing(8),
              ),
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  borderRadius: BorderRadius.circular(15),
                  value: selectedCategory,
                  isExpanded: true,
                  hint: Row(
                    children: [
                      Text('Category',
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                  items: categoryItems.map((category) {
                    return DropdownMenuItem<String>(
                      value: category['name'] as String,
                      child: Row(
                        children: [
                          Icon(
                            category['icon'] as IconData,
                            color: category['color'] as Color,
                          ),
                          SizedBox(width: DeviceLayout.spacing(8)),
                          Text(category['name'] as String),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      selectedCategory = newValue;
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: DeviceLayout.spacing(20)),

            // Note Container

            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: DeviceLayout.spacing(16),
                vertical: DeviceLayout.spacing(8),
              ),
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Add note',
                  hintStyle: Theme.of(context).textTheme.bodyMedium,
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(height: DeviceLayout.spacing(20)),

            // Date Container

            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: DeviceLayout.spacing(16),
                vertical: DeviceLayout.spacing(8),
              ),
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: 'Select date',
                        hintStyle: Theme.of(context).textTheme.bodyMedium,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.calendar_month_outlined,
                        color: AppColors.primary),
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        // Handle date selection
                      }
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: DeviceLayout.spacing(20)),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: DeviceLayout.spacing(16),
                vertical: DeviceLayout.spacing(10),
              ),
              decoration: BoxDecoration(
                color: AppColors.captureReceipt,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt_outlined, color: AppColors.primary),
                  SizedBox(width: DeviceLayout.spacing(10)),
                  Text("Capture Receipt",
                      style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            ),

            Spacer(),
            ElevatedButton(onPressed: () {}, child: Text('Add Expense')),
            SizedBox(height: DeviceLayout.spacing(20)),
          ],
        ),
      ),
    );
  }
}
