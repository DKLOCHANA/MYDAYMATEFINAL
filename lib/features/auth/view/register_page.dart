import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/custom_textfield.dart';
import '../controller/auth_controller.dart';
import '../../../core/utils/devices.dart';

class RegisterPage extends GetView<AuthController> {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    DeviceLayout.init(context);
    return Scaffold(
      body: Obx(() => Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                          height:
                              DeviceLayout.getProportionateScreenHeight(40)),
                      Text(
                        "Join Our Community!",
                        style:
                            Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  fontSize: DeviceLayout.fontSize(28),
                                ),
                      ),
                      SizedBox(height: DeviceLayout.spacing(40)),
                      Obx(() => Column(
                            children: [
                              CustomTextfield(
                                controller: controller.usernameController,
                                hintText: "Username",
                              ),
                              const SizedBox(height: 10),
                              CustomTextfield(
                                controller: controller.emailController,
                                hintText: "Email",
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 10),
                              CustomTextfield(
                                controller: controller.phoneController,
                                hintText: "Contact Number",
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 10),
                              CustomTextfield(
                                controller: controller.ageController,
                                hintText: "Birth Date", // Changed text
                                readOnly: true,
                                // Added birthday icon
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.calendar_today),
                                  onPressed: controller.selectDate,
                                ),
                              ),
                              const SizedBox(height: 10),
                              CustomTextfield(
                                controller: controller.passwordController,
                                hintText: "Password",
                                obscureText: controller.obscurePassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    controller.obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                  onPressed: controller.toggleObscurePassword,
                                ),
                              ),
                              const SizedBox(height: 10),
                              CustomTextfield(
                                controller:
                                    controller.confirmPasswordController,
                                hintText: "Confirm Password",
                                obscureText: controller.obscureConfirmPassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    controller.obscureConfirmPassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                  onPressed:
                                      controller.toggleObscureConfirmPassword,
                                ),
                              ),
                            ],
                          )),
                      SizedBox(height: DeviceLayout.spacing(24)),
                      ElevatedButton(
                        onPressed: controller.register,
                        child: Text(
                          "Create an account",
                          style: TextStyle(fontSize: DeviceLayout.fontSize(16)),
                        ),
                      ),
                      SizedBox(height: DeviceLayout.spacing(24)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Already have an account?"),
                          TextButton(
                            onPressed: controller.goToLogin,
                            child: const Text("Login"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (controller.isLoading.value)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          )),
    );
  }
}
