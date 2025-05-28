import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/devices.dart';
import '../../../widgets/custom_appbar.dart';
import '../controller/profile_controller.dart';

class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbar(
        title: 'Profile',
        showProfileImage: false,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final userData = controller.userData.value;
        if (userData == null) {
          return const Center(child: Text('No user data found'));
        }

        return Padding(
          padding: EdgeInsets.all(DeviceLayout.spacing(16)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => _showImageSourceActionSheet(context),
                child: Stack(
                  children: [
                    Obx(() {
                      if (controller.profileImagePath.value.isNotEmpty) {
                        return CircleAvatar(
                          radius: 50,
                          backgroundImage: FileImage(
                              File(controller.profileImagePath.value)),
                        );
                      } else {
                        return const CircleAvatar(
                          radius: 50,
                          backgroundImage:
                              AssetImage('assets/images/home/profile.png'),
                        );
                      }
                    }),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: DeviceLayout.spacing(20)),
              _buildProfileItem(
                context: context,
                title: 'Username',
                value: userData['username'] ?? '',
                icon: Icons.person_outline,
                onTap: () => _showEditBottomSheet(
                  context: context,
                  title: 'Username',
                  controller: controller.editUsernameController,
                  onSave: () => controller.updateField(
                    'username',
                    controller.editUsernameController.text,
                  ),
                ),
              ),
              _buildProfileItem(
                context: context,
                title: 'Email',
                value: userData['email'] ?? '',
                icon: Icons.email_outlined,
                onTap: () => _showEditBottomSheet(
                  context: context,
                  title: 'Email',
                  controller: controller.editEmailController,
                  keyboardType: TextInputType.emailAddress,
                  onSave: () => controller.updateField(
                    'email',
                    controller.editEmailController.text,
                  ),
                ),
              ),
              _buildProfileItem(
                context: context,
                title: 'Phone',
                value: userData['phone'] ?? '',
                icon: Icons.phone_outlined,
                onTap: () => _showEditBottomSheet(
                  context: context,
                  title: 'Phone',
                  controller: controller.editPhoneController,
                  keyboardType: TextInputType.phone,
                  onSave: () => controller.updateField(
                    'phone',
                    controller.editPhoneController.text,
                  ),
                ),
              ),
              _buildProfileItem(
                context: context,
                title: 'Birth Date',
                value: userData['birthDate'] ?? '',
                icon: Icons.calendar_today_outlined,
                onTap: () => _showDateBottomSheet(context),
              ),
              _buildProfileItem(
                context: context,
                title: 'Emergency Contact',
                value: userData['emergencyContact'] ?? '',
                icon: Icons.contact_emergency_outlined,
                onTap: () => _showEditBottomSheet(
                  context: context,
                  title: 'Emergency Contact',
                  controller: controller.editEmergencyContactController,
                  keyboardType: TextInputType.phone,
                  onSave: () => controller.updateField(
                    'emergencyContact',
                    controller.editEmergencyContactController.text,
                  ),
                ),
              ),
              const Spacer(),
              AnimatedContainer(
                duration: const Duration(seconds: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 250, 1, 1), // Bold Red
                      Color.fromARGB(255, 250, 1, 1), // Light Red
                      Color.fromARGB(255, 250, 1, 1), // Dark blue
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.6, 1.0, 0.2],
                  ),
                ),
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: DeviceLayout.spacing(10)),
                  child: ElevatedButton.icon(
                    onPressed: controller.signOut,
                    icon: const Icon(Icons.logout,
                        color: Colors.white), // Icon at the start
                    label: const Text('Sign Out',
                        style: TextStyle(
                            color: Colors.white)), // Text in the middle
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          vertical: DeviceLayout.spacing(10)),
                      elevation: 0, // Remove the shadow
                      backgroundColor: Colors
                          .transparent, // Make button background transparent
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfileItem({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(DeviceLayout.spacing(10)),
        margin: EdgeInsets.only(bottom: DeviceLayout.spacing(16)),
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 5), // changes position of shadow
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            SizedBox(width: DeviceLayout.spacing(16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.black, fontWeight: FontWeight.bold)),
                  Text(value, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  void _showEditBottomSheet({
    required BuildContext context,
    required String title,
    required TextEditingController controller,
    TextInputType? keyboardType,
    required VoidCallback onSave,
  }) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(DeviceLayout.spacing(16)),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Edit $title', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: DeviceLayout.spacing(16)),
            TextField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                labelText: title,
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: DeviceLayout.spacing(16)),
            ElevatedButton(
              onPressed: onSave,
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDateBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(DeviceLayout.spacing(16)),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Edit Birth Date',
                style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: DeviceLayout.spacing(16)),
            TextField(
              controller: controller.editBirthDateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Birth Date',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: controller.selectDate,
                ),
              ),
            ),
            SizedBox(height: DeviceLayout.spacing(16)),
            ElevatedButton(
              onPressed: () => controller.updateField(
                'birthDate',
                controller.editBirthDateController.text,
              ),
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  controller.pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  controller.pickImage(ImageSource.camera);
                },
              ),
              if (controller.profileImagePath.value.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remove Photo',
                      style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    controller.removeProfileImage();
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
