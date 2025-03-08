import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
              const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/images/home/profile.png'),
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
              const Spacer(),
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: DeviceLayout.spacing(20)),
                child: ElevatedButton(
                  onPressed: controller.signOut,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(
                        vertical: DeviceLayout.spacing(12)),
                  ),
                  child: Text(
                    'Sign Out',
                    style: TextStyle(
                      fontSize: DeviceLayout.fontSize(16),
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
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
        padding: EdgeInsets.all(DeviceLayout.spacing(16)),
        margin: EdgeInsets.only(bottom: DeviceLayout.spacing(16)),
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(10),
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
                  Text(value, style: Theme.of(context).textTheme.bodyLarge),
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
}
