import 'package:get/get.dart';
import '../controller/financial_planner_controller.dart';

class FinancialPlannerBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(FinancialPlannerController());
  }
}
