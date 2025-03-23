import 'package:get/get.dart';
import 'package:mydaymate/features/grocery/controller/grocery_controller.dart';

class GroceryBinding extends Bindings {
  @override
  void dependencies() {
    // Register the controller
    Get.lazyPut<GroceryController>(() => GroceryController());
  }
}
