import 'package:get/get.dart';
import 'package:mydaymate/features/add_expences_or_incomes/controller/expense_controller.dart';
import 'package:mydaymate/features/chatbot/service/gemini_service.dart';
import 'package:mydaymate/features/financial_planner/service/financial_service.dart';

class ExpenseBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure dependencies are registered
    if (!Get.isRegistered<GeminiService>()) {
      Get.put(GeminiService());
    }

    if (!Get.isRegistered<FinancialService>()) {
      Get.put(FinancialService());
    }

    // Register the controller
    Get.put(ExpenseController());
  }
}
