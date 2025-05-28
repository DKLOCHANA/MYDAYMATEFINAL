import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mydaymate/core/theme/app_colors.dart';
import 'package:mydaymate/features/grocery/controller/grocery_controller.dart';
import 'package:mydaymate/features/grocery/model/grocery_item.dart';
import '../../../core/utils/devices.dart';

class GroceryPage extends GetView<GroceryController> {
  const GroceryPage({super.key});

  // Build dialog for adding/editing items
  Widget _buildItemDialog(
      {required BuildContext context,
      required String title,
      required VoidCallback onSave,
      String? itemId}) {
    // Add itemId parameter to identify if editing
    final theme = Theme.of(context);
    final isEditing = itemId != null; // Check if we're editing an existing item

    return AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller.nameController,
              decoration: const InputDecoration(
                labelText: 'Item Name',
                hintText: 'Enter item name',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: controller.quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      hintText: '1',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: Obx(() => DropdownButtonFormField<String>(
                        value: controller.selectedUnit.value,
                        decoration: const InputDecoration(
                          labelText: 'Unit',
                        ),
                        items: controller.units.map((unit) {
                          return DropdownMenuItem(
                            value: unit,
                            child: Text(unit),
                          );
                        }).toList(),
                        onChanged: (value) {
                          controller.selectedUnit.value = value!;
                        },
                      )),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() => DropdownButtonFormField<String>(
                  value: controller.selectedCategory.value,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                  ),
                  items: controller.categories
                      .where((category) => category.name != 'All')
                      .map((category) {
                    return DropdownMenuItem<String>(
                      value: category.name,
                      child: Row(
                        children: [
                          Icon(category.icon,
                              size: 20, color: theme.primaryColor),
                          const SizedBox(width: 8),
                          Text(category.name),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    controller.selectedCategory.value = value!;
                  },
                )),
            const SizedBox(height: 16),
            Obx(() => CheckboxListTile(
                  title: const Text('Needs Restock'),
                  value: controller.needsRestock.value,
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (value) {
                    controller.needsRestock.value = value!;
                  },
                )),
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Only show delete option when editing
            if (isEditing) ...[
              TextButton(
                onPressed: () {
                  // Close dialog and delete item
                  Get.back();
                  controller.deleteItem(itemId!);

                  // Show confirmation snackbar
                  Get.snackbar(
                    'Item Deleted',
                    '${controller.nameController.text} has been removed from your grocery list',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: theme.colorScheme.error.withOpacity(0.1),
                    colorText: theme.colorScheme.error,
                    duration: const Duration(seconds: 2),
                  );
                },
                child: const Text('Delete Item',
                    style: TextStyle(color: Colors.red)),
              ),
            ],
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
          ],
        ),
        ElevatedButton(
          onPressed: onSave,
          child: const Text('Save'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    DeviceLayout.init(context);
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final secondaryColor = theme.colorScheme.secondary;

    // Get screen size for responsiveness
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grocery List'),
        actions: [
          // Add "What Can I Cook?" button in the app bar
          TextButton.icon(
            onPressed: () => Get.toNamed('/what-can-i-cook'),
            icon: Icon(Icons.restaurant_menu, color: theme.primaryColor),
            label: Text(
              'What Can I Cook?',
              style: TextStyle(color: theme.primaryColor),
            ),
          ),
        ],
      ),
      body: Container(
        // Gradient background like financial planner
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.grey.shade50,
              Colors.grey.shade100.withOpacity(0.5),
            ],
            stops: const [0.0, 0.7, 1.0],
          ),
        ),
        child: Obx(() {
          // Filter items based on selected category
          List<GroceryItem> filteredItems = controller
                      .selectedViewCategory.value ==
                  'All'
              ? controller.items
              : controller.items
                  .where((item) =>
                      item.category == controller.selectedViewCategory.value)
                  .toList();

          // Get items that need restocking
          List<GroceryItem> restockItems =
              controller.items.where((item) => item.needsRestock).toList();

          return Padding(
            padding: EdgeInsets.symmetric(
              vertical: DeviceLayout.spacing(isSmallScreen ? 8 : 10),
              horizontal: DeviceLayout.spacing(isSmallScreen ? 16 : 20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // RESTOCK SECTION AS SUMMARY with financial planner gradient styling
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.topRight,
                      radius: 1.8,
                      colors: [
                        primaryColor.withOpacity(0.8),
                        primaryColor,
                        primaryColor.withOpacity(0.7),
                      ],
                      stops: const [0.0, 0.4, 1.0],
                    ),
                    borderRadius:
                        BorderRadius.circular(DeviceLayout.spacing(16)),
                    boxShadow: [
                      BoxShadow(
                        color: secondaryColor.withOpacity(0.2),
                        blurRadius: DeviceLayout.spacing(12),
                        offset: Offset(0, DeviceLayout.spacing(4)),
                        spreadRadius: DeviceLayout.spacing(2),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(
                        DeviceLayout.spacing(isSmallScreen ? 16 : 20)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart,
                              color: Colors.white.withOpacity(0.9),
                              size: DeviceLayout.fontSize(
                                  isSmallScreen ? 16 : 18),
                            ),
                            SizedBox(width: DeviceLayout.spacing(6)),
                            Text(
                              'Need to Restock',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: DeviceLayout.fontSize(
                                    isSmallScreen ? 16 : 18),
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: DeviceLayout.spacing(8)),
                        Text(
                          '${restockItems.length} ${restockItems.length == 1 ? 'Item' : 'Items'}',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontSize:
                                DeviceLayout.fontSize(isSmallScreen ? 28 : 34),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.1),
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: DeviceLayout.spacing(16)),

                        // Show restock items directly in the summary section
                        if (restockItems.isNotEmpty) ...[
                          SizedBox(height: DeviceLayout.spacing(16)),
                          Container(
                            height: isSmallScreen ? 90 : 100,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(
                                  DeviceLayout.spacing(12)),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1.5,
                              ),
                            ),
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: restockItems.length,
                              padding: EdgeInsets.symmetric(
                                  horizontal: DeviceLayout.spacing(8),
                                  vertical: DeviceLayout.spacing(
                                      isSmallScreen ? 8 : 10)),
                              itemBuilder: (context, index) {
                                final item = restockItems[index];
                                return Padding(
                                  padding: EdgeInsets.only(
                                    right: DeviceLayout.spacing(
                                        isSmallScreen ? 8 : 10),
                                  ),
                                  child: GestureDetector(
                                    onTap: () => _editItem(context, item),
                                    child: Stack(
                                      children: [
                                        // Container for the item with financial planner styling
                                        Container(
                                          width: isSmallScreen
                                              ? 90
                                              : 100, // Smaller width
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(
                                                DeviceLayout.spacing(10)),
                                            border: Border.all(
                                              color:
                                                  Colors.white.withOpacity(0.3),
                                              width: 1.5,
                                            ),
                                          ),
                                          padding: EdgeInsets.all(
                                              DeviceLayout.spacing(8)),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                item.name,
                                                textAlign: TextAlign.center,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  decoration: item.isPurchased
                                                      ? TextDecoration
                                                          .lineThrough
                                                      : null,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      DeviceLayout.fontSize(
                                                          isSmallScreen
                                                              ? 12
                                                              : 13),
                                                  color: Colors.white,
                                                ),
                                              ),
                                              SizedBox(
                                                  height:
                                                      DeviceLayout.spacing(2)),
                                              Text(
                                                '${item.quantity} ${item.unit}',
                                                style: TextStyle(
                                                  fontSize:
                                                      DeviceLayout.fontSize(
                                                          isSmallScreen
                                                              ? 10
                                                              : 11),
                                                  color: Colors.white
                                                      .withOpacity(0.9),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Checkbox with improved styling
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: Obx(() {
                                            final currentItem =
                                                controller.items.firstWhere(
                                              (i) => i.id == item.id,
                                              orElse: () => item,
                                            );

                                            return Container(
                                              width: DeviceLayout.spacing(28),
                                              height: DeviceLayout.spacing(28),
                                              decoration: BoxDecoration(
                                                color: currentItem.isPurchased
                                                    ? Colors.white
                                                        .withOpacity(0.3)
                                                    : Colors.transparent,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Colors.white,
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: Material(
                                                color: Colors.transparent,
                                                child: InkWell(
                                                  customBorder:
                                                      const CircleBorder(),
                                                  onTap: () => controller
                                                      .togglePurchased(item.id),
                                                  child: currentItem.isPurchased
                                                      ? Icon(
                                                          Icons.check,
                                                          size: DeviceLayout
                                                              .spacing(16),
                                                          color: Colors.white,
                                                        )
                                                      : Container(),
                                                ),
                                              ),
                                            );
                                          }),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ] else ...[
                          SizedBox(height: DeviceLayout.spacing(16)),
                          Container(
                            padding: EdgeInsets.all(DeviceLayout.spacing(10)),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(
                                  DeviceLayout.spacing(10)),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.white,
                                  size: DeviceLayout.fontSize(
                                      isSmallScreen ? 14 : 16),
                                ),
                                SizedBox(width: DeviceLayout.spacing(8)),
                                Text(
                                  'No items to restock',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: DeviceLayout.fontSize(
                                        isSmallScreen ? 12 : 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                SizedBox(height: DeviceLayout.spacing(isSmallScreen ? 16 : 20)),

                // All Items section with financial planner styling
                Row(
                  children: [
                    Container(
                      width: DeviceLayout.spacing(4),
                      height: DeviceLayout.spacing(20),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius:
                            BorderRadius.circular(DeviceLayout.spacing(2)),
                      ),
                    ),
                    SizedBox(width: DeviceLayout.spacing(8)),
                    Text(
                      'All Items',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize:
                            DeviceLayout.fontSize(isSmallScreen ? 16 : 18),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    // Count badge like financial planner
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: DeviceLayout.spacing(10),
                        vertical: DeviceLayout.spacing(6),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius:
                            BorderRadius.circular(DeviceLayout.spacing(20)),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '${filteredItems.length} items',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize:
                              DeviceLayout.fontSize(isSmallScreen ? 11 : 12),
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: DeviceLayout.spacing(12)),

                // Category selection as chips with financial planner styling
                Container(
                  height: DeviceLayout.spacing(45),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius:
                        BorderRadius.circular(DeviceLayout.spacing(25)),
                    border: Border.all(
                      color: Colors.grey.shade200,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: DeviceLayout.spacing(8),
                    vertical: DeviceLayout.spacing(4),
                  ),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.categories.length,
                    itemBuilder: (context, index) {
                      final category = controller.categories[index];
                      final isSelected =
                          controller.selectedViewCategory.value ==
                              category.name;

                      // Count items in this category
                      final categoryCount = category.name == 'All'
                          ? controller.items.length
                          : controller.items
                              .where((item) => item.category == category.name)
                              .length;

                      // Skip categories with no items
                      if (category.name != 'All' && categoryCount == 0)
                        return const SizedBox.shrink();

                      return Padding(
                        padding:
                            EdgeInsets.only(right: DeviceLayout.spacing(8)),
                        child: ChoiceChip(
                          label: Text(
                              '${category.name}${categoryCount > 0 ? ' ($categoryCount)' : ''}'),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              controller.selectedViewCategory.value =
                                  category.name;
                            }
                          },
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : theme.colorScheme.onSurface,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: DeviceLayout.fontSize(12),
                          ),
                          backgroundColor: theme.cardColor,
                          selectedColor: primaryColor,
                          shadowColor: Colors.black.withOpacity(0.1),
                          elevation: isSelected ? 2 : 0,
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(height: DeviceLayout.spacing(12)),

                // Main list of items with financial planner styling
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(DeviceLayout.spacing(16)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: DeviceLayout.spacing(10),
                          offset: Offset(0, DeviceLayout.spacing(2)),
                          spreadRadius: DeviceLayout.spacing(1),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                    child: filteredItems.isEmpty
                        ? _buildEmptyState(context, theme, isSmallScreen)
                        : ListView.builder(
                            padding: EdgeInsets.all(
                                DeviceLayout.spacing(isSmallScreen ? 8 : 12)),
                            itemCount: filteredItems.length,
                            itemBuilder: (context, index) {
                              final item = filteredItems[index];
                              return Dismissible(
                                key: ValueKey('dismiss_${item.id}'),
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: EdgeInsets.only(
                                      right: DeviceLayout.spacing(20)),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.error,
                                    borderRadius: BorderRadius.circular(
                                        DeviceLayout.spacing(12)),
                                  ),
                                  child: const Icon(Icons.delete,
                                      color: Colors.white),
                                ),
                                direction: DismissDirection.endToStart,
                                onDismissed: (_) =>
                                    controller.deleteItem(item.id),
                                child: Container(
                                  margin: EdgeInsets.only(
                                    bottom: DeviceLayout.spacing(8),
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(
                                        DeviceLayout.spacing(12)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.03),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                    border: Border.all(
                                      color: Colors.grey.shade100,
                                      width: 1,
                                    ),
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white,
                                        (item.needsRestock
                                                ? secondaryColor
                                                : primaryColor)
                                            .withOpacity(0.05),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(
                                        DeviceLayout.spacing(12)),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(
                                          DeviceLayout.spacing(12)),
                                      onTap: () => _editItem(context, item),
                                      child: Padding(
                                        padding: EdgeInsets.all(
                                            DeviceLayout.spacing(
                                                isSmallScreen ? 10 : 12)),
                                        child: Row(
                                          children: [
                                            // Category icon with styled container
                                            Container(
                                              width: DeviceLayout.spacing(
                                                  isSmallScreen ? 38 : 44),
                                              height: DeviceLayout.spacing(
                                                  isSmallScreen ? 38 : 44),
                                              decoration: BoxDecoration(
                                                color: item.needsRestock
                                                    ? secondaryColor
                                                        .withOpacity(0.15)
                                                    : primaryColor
                                                        .withOpacity(0.15),
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: item.needsRestock
                                                      ? secondaryColor
                                                          .withOpacity(0.5)
                                                      : primaryColor
                                                          .withOpacity(0.5),
                                                  width: 1.5,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: (item.needsRestock
                                                            ? secondaryColor
                                                            : primaryColor)
                                                        .withOpacity(0.1),
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Icon(
                                                _getCategoryIcon(item.category),
                                                color: item.needsRestock
                                                    ? secondaryColor
                                                    : primaryColor,
                                                size: DeviceLayout.fontSize(
                                                    isSmallScreen ? 18 : 20),
                                              ),
                                            ),
                                            SizedBox(
                                                width: DeviceLayout.spacing(
                                                    isSmallScreen ? 10 : 12)),

                                            // Item details with better organization
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item.name,
                                                    style: theme
                                                        .textTheme.titleMedium
                                                        ?.copyWith(
                                                      fontSize:
                                                          DeviceLayout.fontSize(
                                                              isSmallScreen
                                                                  ? 14
                                                                  : 15),
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      decoration:
                                                          item.isPurchased
                                                              ? TextDecoration
                                                                  .lineThrough
                                                              : null,
                                                      color: item.isPurchased
                                                          ? Colors.grey[600]
                                                          : null,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  SizedBox(
                                                      height:
                                                          DeviceLayout.spacing(
                                                              4)),
                                                  Row(
                                                    children: [
                                                      Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                          horizontal:
                                                              DeviceLayout
                                                                  .spacing(8),
                                                          vertical: DeviceLayout
                                                              .spacing(4),
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: primaryColor
                                                              .withOpacity(0.1),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  DeviceLayout
                                                                      .spacing(
                                                                          6)),
                                                        ),
                                                        child: Text(
                                                          '${item.quantity} ${item.unit}',
                                                          style: theme.textTheme
                                                              .bodySmall
                                                              ?.copyWith(
                                                            color: primaryColor,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize:
                                                                DeviceLayout
                                                                    .fontSize(
                                                                        11),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                          width: DeviceLayout
                                                              .spacing(8)),
                                                      Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                          horizontal:
                                                              DeviceLayout
                                                                  .spacing(8),
                                                          vertical: DeviceLayout
                                                              .spacing(4),
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: primaryColor
                                                              .withOpacity(0.1),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  DeviceLayout
                                                                      .spacing(
                                                                          6)),
                                                        ),
                                                        child: Text(
                                                          item.category,
                                                          style: theme.textTheme
                                                              .bodySmall
                                                              ?.copyWith(
                                                            color: primaryColor,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize:
                                                                DeviceLayout
                                                                    .fontSize(
                                                                        11),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Restock toggle with better styling
                                            Container(
                                              width: DeviceLayout.spacing(
                                                  isSmallScreen ? 40 : 44),
                                              height: DeviceLayout.spacing(
                                                  isSmallScreen ? 40 : 44),
                                              decoration: BoxDecoration(
                                                color: item.needsRestock
                                                    ? secondaryColor
                                                        .withOpacity(0.15)
                                                    : Colors.grey.shade50,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: item.needsRestock
                                                      ? secondaryColor
                                                          .withOpacity(0.5)
                                                      : Colors.grey.shade300,
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: IconButton(
                                                icon: Icon(
                                                  item.needsRestock
                                                      ? Icons.shopping_cart
                                                      : Icons
                                                          .shopping_cart_outlined,
                                                  color: item.needsRestock
                                                      ? secondaryColor
                                                      : theme.disabledColor,
                                                  size: DeviceLayout.fontSize(
                                                      isSmallScreen ? 18 : 20),
                                                ),
                                                onPressed: () => controller
                                                    .toggleRestock(item.id),
                                                tooltip: 'Toggle restock',
                                                padding: EdgeInsets.zero,
                                                splashRadius:
                                                    DeviceLayout.fontSize(
                                                        isSmallScreen
                                                            ? 20
                                                            : 22),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const ValueKey('grocery_add_button'),
        onPressed: () => _showAddItemDialog(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DeviceLayout.spacing(16)),
        ),
        icon: Icon(
          Icons.add,
          size: DeviceLayout.fontSize(isSmallScreen ? 20 : 24),
        ),
        label: Text(
          'Add Item',
          style: TextStyle(
            fontSize: DeviceLayout.fontSize(isSmallScreen ? 14 : 16),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Empty state with financial planner styling
  Widget _buildEmptyState(
      BuildContext context, ThemeData theme, bool isSmallScreen) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(DeviceLayout.spacing(20)),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(DeviceLayout.spacing(12)),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(DeviceLayout.spacing(16)),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.grey.shade200,
                    Colors.grey.shade100,
                  ],
                  radius: 0.8,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.shopping_basket,
                size: DeviceLayout.fontSize(isSmallScreen ? 40 : 48),
                color: Colors.grey[400],
              ),
            ),
            SizedBox(height: DeviceLayout.spacing(isSmallScreen ? 12 : 16)),
            Text(
              'No items in this category',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
                fontSize: DeviceLayout.fontSize(isSmallScreen ? 14 : 16),
              ),
            ),
            SizedBox(height: DeviceLayout.spacing(8)),
            TextButton.icon(
              onPressed: () => _showAddItemDialog(context),
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey.shade50,
                padding: EdgeInsets.symmetric(
                  horizontal: DeviceLayout.spacing(16),
                  vertical: DeviceLayout.spacing(8),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DeviceLayout.spacing(20)),
                  side: BorderSide(color: theme.primaryColor, width: 1),
                ),
              ),
              icon: Icon(
                Icons.add,
                size: DeviceLayout.fontSize(isSmallScreen ? 18 : 20),
                color: theme.primaryColor,
              ),
              label: Text(
                'Add item',
                style: TextStyle(
                  color: theme.primaryColor,
                  fontSize: DeviceLayout.fontSize(isSmallScreen ? 13 : 14),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required BuildContext context,
    required String title,
    required int count,
    required IconData icon,
    required bool isSmallScreen,
    Color? iconColor,
  }) {
    // Adjust sizes based on available space
    final iconSize = DeviceLayout.spacing(isSmallScreen ? 32 : 36);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.15),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Icon(
            icon,
            color: iconColor ?? Colors.white,
            size: DeviceLayout.fontSize(isSmallScreen ? 16 : 18),
          ),
        ),
        SizedBox(width: DeviceLayout.spacing(isSmallScreen ? 6 : 8)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: DeviceLayout.fontSize(isSmallScreen ? 12 : 13),
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
            ),
            Text(
              count.toString(),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: DeviceLayout.fontSize(isSmallScreen ? 16 : 18),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  // Helper function to get icon for category
  IconData _getCategoryIcon(String category) {
    final categoryObj = controller.categories.firstWhere(
      (c) => c.name == category,
      orElse: () => controller.categories.first,
    );
    return categoryObj.icon;
  }

  // Open dialog to add a new item
  void _showAddItemDialog(BuildContext context) {
    controller.resetDialogFields();

    Get.dialog(
      _buildItemDialog(
        context: context,
        title: 'Add Item',
        onSave: () => controller.addItemFromFields(),
      ),
    );
  }

  // Edit an existing item
  void _editItem(BuildContext context, GroceryItem item) {
    // First, get the most up-to-date item data
    final currentItem = controller.items.firstWhere(
      (i) => i.id == item.id,
      orElse: () => item,
    );

    // Then set dialog fields using the current item data
    controller.setDialogFieldsFromItem(currentItem);

    Get.dialog(
      _buildItemDialog(
        context: context,
        title: 'Edit Item',
        onSave: () => controller.updateItemFromFields(item.id),
        itemId: item.id, // Pass the item ID so the dialog knows we're editing
      ),
    );
  }
}
