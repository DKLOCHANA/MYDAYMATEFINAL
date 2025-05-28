import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mydaymate/features/chatbot/controller/chatbot_controller.dart';
import 'package:mydaymate/features/chatbot/model/chatbot_model.dart';
import 'package:mydaymate/features/home/controller/home_controller.dart';
import 'package:mydaymate/widgets/custom_appbar.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ChatbotPage extends GetView<ChatbotController> {
  const ChatbotPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: "Assistant"),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black,
                    ),
                  ),
                  if (message.imageUrl != null) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        File(message.imageUrl!),
                        width: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isUser) _buildAvatar(isUser),
        ],
      ),
    );
  }

  // Update the _buildAvatar method to use the user's profile photo
  Widget _buildAvatar(bool isUser) {
    if (isUser) {
      // Use Obx here to reactively update when profile image changes
      return Obx(() {
        final profileImagePath =
            Get.find<HomeController>().profileImagePath.value;

        // If user has a profile image, use it
        if (profileImagePath != null && profileImagePath.isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0, left: 8.0),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: FileImage(File(profileImagePath)),
            ),
          );
        }
        // Otherwise use default avatar
        return Padding(
          padding: const EdgeInsets.only(right: 8.0, left: 8.0),
          child: CircleAvatar(
            backgroundColor: Colors.blue[800],
            child: Icon(
              Icons.person,
              color: Colors.white,
              size: 20,
            ),
          ),
        );
      });
    } else {
      // Bot avatar remains the same
      return Padding(
        padding: const EdgeInsets.only(right: 8.0, left: 8.0),
        child: CircleAvatar(
          backgroundColor: Colors.green[600],
          child: Icon(
            Icons.smart_toy,
            color: Colors.white,
            size: 20,
          ),
        ),
      );
    }
  }

  // Build the input area with voice and image options
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
          // Voice input button
          Obx(() => IconButton(
                icon: Icon(
                  controller.isListening.value ? Icons.mic : Icons.mic_none,
                  color: controller.isListening.value
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                ),
                onPressed: () => _handleVoiceInput(context),
              )),

          // Image upload button
          IconButton(
            icon: const Icon(Icons.receipt_long),
            color: Colors.grey,
            tooltip: 'Upload Receipt',
            onPressed: () => _pickImage(context),
          ),

          // Text input field
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

  // Handle voice input
  Future<void> _handleVoiceInput(BuildContext context) async {
    if (controller.isListening.value) {
      await controller.stopListening();
    } else {
      final status = await Permission.microphone.request();
      if (status.isGranted) {
        await controller.startListening();
      } else {
        Get.snackbar(
          'Permission Required',
          'Microphone permission is needed for voice input',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  // Pick image from gallery or camera
  Future<void> _pickImage(BuildContext context) async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Photo Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (image != null) {
      controller.processReceiptImage(image.path);
    }
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
