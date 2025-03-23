import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mydaymate/features/chatbot/controller/chatbot_controller.dart';
import 'package:mydaymate/features/chatbot/model/chatbot_model.dart';

class ChatbotPage extends GetView<ChatbotController> {
  const ChatbotPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Day Mate'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              _showUserProfileModal(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages list
          Expanded(
            child: Obx(() {
              return ListView.builder(
                controller: controller.scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final message = controller.messages[index];
                  return _buildMessageItem(context, message);
                },
              );
            }),
          ),

          // Loading indicator
          Obx(() {
            if (controller.isLoading.value) {
              return const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          }),

          // Input area
          _buildInputArea(context),
        ],
      ),
    );
  }

  // Build a message bubble
  Widget _buildMessageItem(BuildContext context, Message message) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) _buildAvatar(isUser),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color:
                    isUser ? Theme.of(context).primaryColor : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
          if (isUser) _buildAvatar(isUser),
        ],
      ),
    );
  }

  // Build avatar for messages
  Widget _buildAvatar(bool isUser) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0, left: 8.0),
      child: CircleAvatar(
        backgroundColor: isUser ? Colors.blue[800] : Colors.green[600],
        child: Icon(
          isUser ? Icons.person : Icons.smart_toy,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  // Build the input area
  Widget _buildInputArea(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.textController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (text) {
                if (text.trim().isNotEmpty) {
                  controller.addUserMessage(text);
                  controller.textController.clear();
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            onPressed: () {
              final text = controller.textController.text;
              if (text.trim().isNotEmpty) {
                controller.addUserMessage(text);
                controller.textController.clear();
              }
            },
            mini: true,
            child: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  // Show user profile modal
  void _showUserProfileModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Your Profile',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Obx(() {
                final profile = controller.userProfile.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileItem('Name', profile.name ?? 'Not set'),
                    _buildProfileItem('Age', profile.age ?? 'Not set'),
                    _buildProfileItem(
                        'Medical Conditions',
                        profile.medicalConditions.isEmpty
                            ? 'None'
                            : profile.medicalConditions.join(', ')),
                    _buildProfileItem('Wake up time',
                        profile.dailyRoutine['wakeup'] ?? 'Not set'),
                    _buildProfileItem('Bedtime',
                        profile.dailyRoutine['bedtime'] ?? 'Not set'),
                    _buildProfileItem(
                        'Hobbies',
                        profile.hobbies.isEmpty
                            ? 'None'
                            : profile.hobbies.join(', ')),
                    _buildProfileItem(
                        'Meal times',
                        profile.mealTimes.isEmpty
                            ? 'Not set'
                            : profile.mealTimes.entries
                                .map((e) => '${e.key}: ${e.value}')
                                .join(', ')),
                    _buildProfileItem(
                        'Favorite foods',
                        profile.favoriteFoods.isEmpty
                            ? 'None'
                            : profile.favoriteFoods.join(', ')),
                  ],
                );
              }),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    controller.isFirstTime.value = true;
                    controller.currentQuestionIndex.value = 0;
                    controller.userProfile.value = UserProfile();
                    controller.saveUserProfile();
                    controller.messages.clear();
                    controller.addBotMessage(controller.onboardingQuestions[0]);
                    controller.saveChatHistory();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Reset Profile'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Build profile item
  Widget _buildProfileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
