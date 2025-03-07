import 'package:get/get.dart';
import '../controller/onboard_controller.dart';

class OnboardBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(OnboardController());
  }
}
