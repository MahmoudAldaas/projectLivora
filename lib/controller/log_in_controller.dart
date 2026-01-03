import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livora/core/api/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widget/main_screen.dart';

class LogInController extends GetxController {
  final phone = TextEditingController();
  final password = TextEditingController();

  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkSavedLogin();
  }

  Future<void> _checkSavedLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userJson = prefs.getString('user');

      if (token != null && userJson != null) {
        await ApiService.setAuthToken(token); 
        Get.offAll(() => const MainScreen());
      }
    } catch (e) {
      print('Error checking saved login: $e');
    }
  }

  Future<void> login() async {
    if (phone.text.isEmpty || password.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter phone and password",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
      );
      return;
    }

    if (!phone.text.startsWith('09') || phone.text.length != 10) {
      Get.snackbar(
        "Error",
        "Please enter a valid Syrian phone number",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
      );
      return;
    }

    try {
      isLoading.value = true;
      print('Logging in with phone: ${phone.text}');

      final result = await ApiService.login(
        phone.text.trim(),
        password.text.trim(),
      );

      if (result['error'] == true) {
        Get.snackbar(
          "Login Failed",
          result['message'] ?? 'Invalid credentials',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
        );
        return;
      }

      final user = result['user'];
      final token = result['token'];

      if (token == null || user == null) {
        Get.snackbar(
          "Error",
          "Invalid login response from server",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
        );
        return;
      }

      await _saveUserData(token, user);

      
      await ApiService.setAuthToken(token);

      Get.snackbar(
        "Success",
        result['message'] ?? 'Logged in successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        duration: const Duration(seconds: 2),
      );

      await Future.delayed(const Duration(milliseconds: 500));
      Get.offAll(() => const MainScreen());
    } catch (e) {
      print('Login error: $e');
      Get.snackbar(
        "Error",
        "Something went wrong. Please try again.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _saveUserData(String token, Map<String, dynamic> user) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('token', token);
      await prefs.setString('user', jsonEncode(user));
      await prefs.setInt('user_id', user['id'] ?? 0);
      await prefs.setString(
          'user_name', '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}');
      await prefs.setString('user_phone', user['phone'] ?? '');
      await prefs.setString('user_role', user['role'] ?? 'renter');

      print(' User data saved to SharedPreferences');
    } catch (e) {
      print('Error saving user data: $e');
    }
  }

  static Future<Map<String, dynamic>?> getSavedUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');

      if (userJson != null) {
        return jsonDecode(userJson);
      }
    } catch (e) {
      print('Error getting saved user data: $e');
    }
    return null;
  }

  @override
  void onClose() {
    phone.dispose();
    password.dispose();
    super.onClose();
  }
}