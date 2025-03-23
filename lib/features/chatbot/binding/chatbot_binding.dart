import 'package:get/get.dart';
import 'package:mydaymate/features/chatbot/controller/chatbot_controller.dart';

class ChatbotBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatbotController>(() => ChatbotController());
  }
}
