import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livora/controller/log_in_controller.dart';
import 'package:livora/widget/register_screen.dart';

class LogInScreen extends StatelessWidget {
  LogInScreen({super.key});

  final LogInController controller = Get.put(LogInController());
  final RxBool _obscurePassword = true.obs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      // 🔴 لا backgroundColor
      // ✅ الثيم يحدد الخلفية

      appBar: AppBar(
        // 🔴 لا TextStyle يدوي
        title: Text(
          'Log In'.tr,
          style: textTheme.titleLarge, // ✅ من TextTheme
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),

            // 🔴 Colors ثابتة
            Text(
              'Welcome Back'.tr,
              style: textTheme.displaySmall, // ✅
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 10),

            Text(
              'Sign in to continue'.tr,
              style: textTheme.bodyMedium, // ✅
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 50),

            // ---------------- PHONE ----------------
            TextFormField(
              controller: controller.phone,
              keyboardType: TextInputType.phone,
              decoration: _inputDecoration(
                context,
                label: 'Phone Number'.tr,
                icon: Icons.phone_outlined,
                hint: '09xxxxxxxx',
              ),
            ),

            const SizedBox(height: 20),

            // ---------------- PASSWORD ----------------
            Obx(
              () => TextFormField(
                controller: controller.password,
                obscureText: _obscurePassword.value,
                decoration: _inputDecoration(
                  context,
                  label: 'Password'.tr,
                  icon: Icons.lock_outline,
                  isPassword: true,
                  obscurePassword: _obscurePassword,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ---------------- BUTTON ----------------
            Obx(
              () => ElevatedButton(
                // 🔴 لا styleFrom
                onPressed:
                    controller.isLoading.value ? null : controller.login,
                child: controller.isLoading.value
                    ? const CircularProgressIndicator(strokeWidth: 2)
                    : Text(
                        'Log In'.tr,
                        style: textTheme.titleMedium?.copyWith(
                          color: colors.onPrimary, // ✅
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 50),

            // ---------------- REGISTER ----------------
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account?".tr,
                  style: textTheme.bodyMedium,
                ),
                GestureDetector(
                  onTap: () => Get.to(() =>RegisterScreen()),
                  child: Text(
                    'Register'.tr,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.primary, 
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- INPUT DECORATION ----------------
  InputDecoration _inputDecoration(
    BuildContext context, {
    required String label,
    required IconData icon,
    bool isPassword = false,
    String? hint,
    RxBool? obscurePassword,
  }) {
    final colors = Theme.of(context).colorScheme;

    return InputDecoration(
      labelText: label,
      hintText: hint,

      // 🔴 Colors.white
      filled: true,
      fillColor: colors.surface, // ✅

      prefixIcon: Icon(icon, color: colors.primary), // ✅

      suffixIcon: isPassword && obscurePassword != null
          ? Obx(
              () => IconButton(
                icon: Icon(
                  obscurePassword.value
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: colors.primary,
                ),
                onPressed: () =>
                    obscurePassword.value = !obscurePassword.value,
              ),
            )
          : null,

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
