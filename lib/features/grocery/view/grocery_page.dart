import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mydaymate/features/grocery/controller/grocery_controller.dart';
import 'package:mydaymate/features/grocery/model/grocery_item.dart';

class GroceryPage extends GetView<GroceryController> {
  const GroceryPage({super.key});

  // Build dialog for adding/editing items
  Widget _buildItemDialog(
      {required BuildContext context,
      required String title,
      required VoidCallback onSave}) {
    final theme = Theme.of(context);

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
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancel'),
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
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final secondaryColor = theme.colorScheme.secondary;

    // Get screen size for responsiveness
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grocery List'),
      ),
      body: Obx(() {
        // Filter items based on selected category
        List<GroceryItem> filteredItems =
            controller.selectedViewCategory.value == 'All'
                ? controller.items
                : controller.items
                    .where((item) =>
                        item.category == controller.selectedViewCategory.value)
                    .toList();

        // Get items that need restocking
        List<GroceryItem> restockItems =
            controller.items.where((item) => item.needsRestock).toList();

        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Need to Restock section - only show if there are items needing restock
              if (restockItems.isNotEmpty) ...[
                Text(
                  'Need to Restock',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  height: isSmallScreen ? 100 : 120,
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: theme.dividerColor.withOpacity(0.5)),
                  ),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: restockItems.length,
                    itemBuilder: (context, index) {
                      final item = restockItems[index];
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 6.0 : 8.0,
                          vertical: 8.0,
                        ),
                        child: GestureDetector(
                          onTap: () => _editItem(context, item),
                          child: Container(
                            width: isSmallScreen ? 100 : 120,
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: secondaryColor.withOpacity(0.5),
                              ),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Checkbox(
                                      value: item.isPurchased,
                                      onChanged: (_) =>
                                          controller.togglePurchased(item.id),
                                      activeColor: primaryColor,
                                    ),
                                    Flexible(
                                      child: Text(
                                        item.name,
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          decoration: item.isPurchased
                                              ? TextDecoration.lineThrough
                                              : null,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${item.quantity} ${item.unit}',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // All Items section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Items',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${filteredItems.where((item) => item.isPurchased).length}/${filteredItems.length} Purchased',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Category selection as chips
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.categories.length,
                  itemBuilder: (context, index) {
                    final category = controller.categories[index];
                    final isSelected =
                        controller.selectedViewCategory.value == category.name;

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
                      padding: const EdgeInsets.only(right: 8.0),
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
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        backgroundColor: theme.cardColor,
                        selectedColor: primaryColor,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),

              // Main list of items
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: theme.dividerColor.withOpacity(0.5)),
                  ),
                  child: filteredItems.isEmpty
                      ? Center(
                          child: Text('No items in this category',
                              style: theme.textTheme.bodyMedium))
                      : ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = filteredItems[index];
                            return Dismissible(
                              key: ValueKey(
                                  'dismiss_${item.id}'), // Unique dismissible key
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                color: theme.colorScheme.error,
                                child: const Icon(Icons.delete,
                                    color: Colors.white),
                              ),
                              direction: DismissDirection.endToStart,
                              onDismissed: (_) =>
                                  controller.deleteItem(item.id),
                              child: Card(
                                elevation: 1,
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                // If item needs restock, highlight the card
                                color: item.needsRestock
                                    ? secondaryColor.withOpacity(0.05)
                                    : null,
                                child: ListTile(
                                  title: Text(
                                    item.name,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      decoration: item.isPurchased
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                  subtitle: Row(
                                    children: [
                                      Text(
                                        '${item.quantity} ${item.unit}',
                                        style: theme.textTheme.bodySmall,
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: primaryColor.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          item.category,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: primaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      if (item.needsRestock)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: secondaryColor
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              'Restock',
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                color: secondaryColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Show restock toggle button
                                      IconButton(
                                        icon: Icon(
                                          item.needsRestock
                                              ? Icons.shopping_cart
                                              : Icons.shopping_cart_outlined,
                                          color: item.needsRestock
                                              ? secondaryColor
                                              : theme.disabledColor,
                                        ),
                                        onPressed: () =>
                                            controller.toggleRestock(item.id),
                                        tooltip: 'Toggle restock',
                                        iconSize: isSmallScreen ? 20 : 24,
                                      ),
                                      // Only show checkbox for items that need restocking
                                      if (item.needsRestock)
                                        SizedBox(
                                          width: isSmallScreen ? 40 : 48,
                                          height: isSmallScreen ? 40 : 48,
                                          child: Checkbox(
                                            value: item.isPurchased,
                                            onChanged: (_) => controller
                                                .togglePurchased(item.id),
                                            activeColor: primaryColor,
                                          ),
                                        ),
                                    ],
                                  ),
                                  onTap: () => _editItem(context, item),
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
      floatingActionButton: FloatingActionButton(
        key: const ValueKey('grocery_add_button'), // Add a key for the FAB
        onPressed: () => _showAddItemDialog(context),
        backgroundColor: secondaryColor,
        child: const Icon(Icons.add),
      ),
    );
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
    controller.setDialogFieldsFromItem(item);

    Get.dialog(
      _buildItemDialog(
        context: context,
        title: 'Edit Item',
        onSave: () => controller.updateItemFromFields(item.id),
      ),
    );
  }
}
