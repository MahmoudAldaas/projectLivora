import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livora/controller/register_controller.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});

  final RegisterController controller = Get.put(RegisterController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Register".tr),
        centerTitle: true,
      ),
      body: Obx(
        () => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // ROLE Selection
              Text(
                "I am a:".tr,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _roleButton(context, "Renter".tr, "renter"),
                  const SizedBox(width: 10),
                  _roleButton(context, "Owner".tr, "owner"),
                ],
              ),
              const SizedBox(height: 20),

              // ✅ Step 1: Names + Phone + Passwords
              if (controller.currentStep.value == 0) ...[
                _field(context, "First Name".tr, controller.firstName),
                _field(context, "Last Name".tr, controller.lastName),
                
                // Phone Number
                _field(
                  context,
                  "Phone Number".tr,
                  controller.phone,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone,
                ),
                
                // Password with visibility toggle
                _field(
                  context,
                  "Password".tr,
                  controller.password,
                  isPassword: true,
                  passwordVisible: controller.isPasswordVisible.value,
                  toggleVisibility: controller.togglePasswordVisibility,
                ),
                
                // Confirm Password
                _field(
                  context,
                  "Confirm Password".tr,
                  controller.confirmPassword,
                  isPassword: true,
                  passwordVisible: controller.isConfirmPasswordVisible.value,
                  toggleVisibility: controller.toggleConfirmPasswordVisibility,
                ),
                
                const SizedBox(height: 30),
                
                // Next Button
                ElevatedButton(
                  onPressed: () {
                    if (_validateStep1()) {
                      controller.currentStep.value = 1;
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text(
                    "Next".tr,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ] 
              // ✅ Step 2: Birthdate + Images (Optional)
              else ...[
                // Birthdate
                TextFormField(
                  controller: controller.birthdate,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: "Birthdate".tr,
                    suffixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onTap: () => controller.pickBirthdate(context),
                ),
                const SizedBox(height: 25),

                // ✅ Profile Image (Optional)
                Text(
                  "Profile Image".tr,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 8),
                _buildImagePicker(
                  context,
                  label: "Profile Image".tr,
                  imagePath: controller.profileImagePath.value,
                  onTap: controller.pickProfileImage,
                  icon: Icons.person,
                ),
                const SizedBox(height: 20),

                // ✅ ID Image (Optional)
                Text(
                  "ID Image".tr,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 8),
                _buildImagePicker(
                  context,
                  label: "ID Image".tr,
                  imagePath: controller.idImagePath.value,
                  onTap: controller.pickIdImage,
                  icon: Icons.badge,
                ),
                const SizedBox(height: 30),

                // Back + Register Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => controller.currentStep.value = 0,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: Text("Back".tr),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.register,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: controller.isLoading.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                "Register".tr,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 20),

              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account?".tr,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Text(
                      'Login'.tr,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Role Button
  Widget _roleButton(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final isSelected = controller.role.value == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => controller.role.value = value,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
              width: 2,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              color: isSelected ? Colors.white : theme.colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  // ✅ Text Field
  Widget _field(
    BuildContext context,
    String label,
    TextEditingController controller, {
    bool isPassword = false,
    bool passwordVisible = false,
    VoidCallback? toggleVisibility,
    TextInputType? keyboardType,
    IconData? prefixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword && !passwordVisible,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    passwordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: toggleVisibility,
                )
              : null,
        ),
      ),
    );
  }

  // ✅ Image Picker
  Widget _buildImagePicker(
    BuildContext context, {
    required String label,
    required String imagePath,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: imagePath.isEmpty
                ? theme.colorScheme.outline
                : theme.colorScheme.primary,
            width: 2,
          ),
        ),
        child: imagePath.isEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 50, color: theme.colorScheme.primary),
                  const SizedBox(height: 10),
                  Text(
                    label,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Tap to select".tr,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              )
            : Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(imagePath),
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            icon,
                            size: 50,
                            color: theme.colorScheme.error,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Error loading image".tr,
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ✅ Validation for Step 1
  bool _validateStep1() {
    if (controller.firstName.text.isEmpty) {
      Get.snackbar("Error".tr, "Please enter first name".tr);
      return false;
    }
    if (controller.lastName.text.isEmpty) {
      Get.snackbar("Error".tr, "Please enter last name".tr);
      return false;
    }
    if (controller.phone.text.isEmpty) {
      Get.snackbar("Error".tr, "Please enter phone number".tr);
      return false;
    }
    if (controller.phone.text.length < 10) {
      Get.snackbar("Error".tr, "Phone number must be at least 10 digits".tr);
      return false;
    }
    if (controller.password.text.isEmpty) {
      Get.snackbar("Error".tr, "Please enter password".tr);
      return false;
    }
    if (controller.password.text.length < 6) {
      Get.snackbar("Error".tr, "Password must be at least 6 characters".tr);
      return false;
    }
    if (controller.password.text != controller.confirmPassword.text) {
      Get.snackbar("Error".tr, "Passwords do not match".tr);
      return false;
    }
    return true;
  }
}