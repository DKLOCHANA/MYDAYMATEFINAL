import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/custom_textfield.dart';
import '../../../core/utils/devices.dart';
import '../controller/auth_controller.dart';

class LoginPage extends GetView<AuthController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    DeviceLayout.init(context);
    return Scaffold(
      body: Obx(() => Stack(
            children: [
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(DeviceLayout.spacing(16)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                          height:
                              DeviceLayout.getProportionateScreenHeight(60)),
                      Text(
                        "Welcome Back!",
                        style:
                            Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  fontSize: DeviceLayout.fontSize(28),
                                ),
                      ),
                      SizedBox(height: DeviceLayout.spacing(40)),
                      CustomTextfield(
                        controller: controller.usernameController,
                        hintText: "Email",
                      ),
                      SizedBox(height: DeviceLayout.spacing(16)),
                      Obx(() => CustomTextfield(
                            controller: controller.passwordController,
                            hintText: "Password",
                            obscureText: !controller.isPasswordVisible.value,
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.isPasswordVisible.value
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: controller.togglePasswordVisibility,
                            ),
                          )),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: controller.showForgotPasswordDialog,
                          child: Text("Forgot Password?"),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: controller.login,
                        child: Text(
                          "Login",
                          style: TextStyle(fontSize: DeviceLayout.fontSize(16)),
                        ),
                      ),
                      SizedBox(height: DeviceLayout.spacing(24)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account?"),
                          TextButton(
                            onPressed: controller.goToRegister,
                            child: const Text("Register"),
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
