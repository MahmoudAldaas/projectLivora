import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:livora/core/api/api_service.dart';

class RegisterController extends GetxController {

  final TextEditingController firstName = TextEditingController();
  final TextEditingController lastName = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();
  final TextEditingController birthdate = TextEditingController();

  RxString role = ''.obs;
  RxInt currentStep = 0.obs;
  RxBool isLoading = false.obs;
  RxBool isPasswordVisible = false.obs;
  RxBool isConfirmPasswordVisible = false.obs;
  
  RxString profileImagePath = ''.obs;
  RxString idImagePath = ''.obs;

  final ImagePicker _picker = ImagePicker();

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  Future<void> pickBirthdate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      birthdate.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  Future<void> pickProfileImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        profileImagePath.value = image.path;
      }
    } catch (e) {
      Get.snackbar(
        'Error'.tr,
        'Failed to pick image'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> pickIdImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        idImagePath.value = image.path;
      }
    } catch (e) {
      Get.snackbar(
        'Error'.tr,
        'Failed to pick image'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> register() async {
    if (birthdate.text.isEmpty) {
      Get.snackbar('Error'.tr, 'Please select birthdate'.tr);
      return;
    }

    try {
      isLoading.value = true;

      final result = await ApiService.register(
        firstName: firstName.text,
        lastName: lastName.text,
        phone: phone.text,
        password: password.text,
        role: role.value,
        birthdate: birthdate.text,
        profileImagePath: profileImagePath.value.isNotEmpty ? profileImagePath.value : null,
        idImagePath: idImagePath.value.isNotEmpty ? idImagePath.value : null,
      );

      isLoading.value = false;

      print('Register Result: $result');

      final statusCode = result['status_code'];
      
      if (statusCode != null && statusCode >= 200 && statusCode < 300) {
        Get.back();
        
        Future.delayed(Duration(milliseconds: 300), () {
          Get.snackbar(
            'Success'.tr,
            result['message'] ?? 'Registration successful'.tr,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: Duration(seconds: 2),
          );
        });
        
      } else {
        Get.snackbar(
          'Error'.tr,
          result['message'] ?? 'Registration failed'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
      }
    } catch (e) {
      isLoading.value = false;
      print('Register Error: $e');
      
      Get.snackbar(
        'Error'.tr,
        'An error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    }
  }

  @override
  void onClose() {
    firstName.dispose();
    lastName.dispose();
    phone.dispose();
    password.dispose();
    confirmPassword.dispose();
    birthdate.dispose();
    super.onClose();
  }
}