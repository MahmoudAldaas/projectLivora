import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:livora/controller/local_conroller.dart';
import 'package:livora/widget/log_in_screen.dart';
import 'package:livora/widget/my_booking_screen.dart';
import 'package:livora/widget/owner_booking_screen.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import '../controller/navgation_controller.dart';
import '../controller/home_controller.dart';
class ProfileController extends GetxController {
  var isDarkMode = false.obs;
  var userRole = ''.obs; 
  
  final String _themeKey = 'isDarkMode'; 
  
  final MyLocalController localController = Get.find<MyLocalController>();
  
  @override
  void onInit() {
    super.onInit();
    _loadThemeFromPrefs();
    _loadUserRole(); 
  }
  
  Future<void> _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkMode.value = prefs.getBool(_themeKey) ?? false;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    userRole.value = prefs.getString('user_role') ?? '';
  }
  
  Future<void> toggleDarkMode(bool value) async {
    isDarkMode.value = value;
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, value);
  }
      
  void changeLanguage(String language) {
    if (language == 'العربية') {
      localController.changeLang('ar');
    } else {
      localController.changeLang('en');
    }
  }

  void goToMyBookings() {
    Get.to(() => MyBookingsScreen());
  }

  void goToOwnerBookings() {
    Get.to(() =>OwnerBookingScreen());
  }

  void showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('تسجيل الخروج'.tr), 
        content: Text('هل أنت متأكد من تسجيل الخروج؟'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('الغاء'.tr),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              logout();
            },
            child: Text(
              'تسجيل الخروج'.tr,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('user_phone');
    await prefs.remove('user_role');
  
    if (Get.isRegistered<NavigationController>()) {
      final navController = Get.find<NavigationController>();
      navController.currentIndex.value = 0;
    }
  
    Get.delete<NavigationController>();
    Get.delete<HomeController>();
    Get.delete<ProfileController>();
  
    Get.offAll(() => LogInScreen());
  }
}
