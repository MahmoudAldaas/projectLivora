import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:livora/controller/local_conroller.dart';
import 'package:livora/widget/log_in_screen.dart';
import 'package:livora/widget/my_booking_screen.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 👈 أضف هذا

class ProfileController extends GetxController {
  // Dark Mode
  var isDarkMode = false.obs;
  
  final String _themeKey = 'isDarkMode'; // 👈 مفتاح الحفظ
  
  // الحصول على LocalController
  final MyLocalController localController = Get.find<MyLocalController>();
  
  @override
  void onInit() {
    super.onInit();
    _loadThemeFromPrefs(); // 👈 تحميل الثيم المحفوظ
  }
  
  // 👇 تحميل الثيم من SharedPreferences
  Future<void> _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkMode.value = prefs.getBool(_themeKey) ?? false;
    
    // تطبيق الثيم المحفوظ
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }
  
  // 👇 تبديل الوضع الليلي وحفظه
  Future<void> toggleDarkMode(bool value) async {
    isDarkMode.value = value;
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
    
    // حفظ في SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, value);
  }
      
  // تغيير اللغة (دالة واحدة فقط!)
  void changeLanguage(String language) {
    if (language == 'العربية') {
      localController.changeLang('ar');
    } else {
      localController.changeLang('en');
    }
  }

  // الانتقال لصفحة الحجوزات
  void goToMyBookings() {
    Get.to(() => MyBookingScreen());
  }

  // تسجيل الخروج
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
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void logout() async {
    // مسح التوكن والإعدادات
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    // ملاحظة: ممكن تخلي الثيم واللغة محفوظين حتى بعد الخروج
    // أو تمسحهم إذا بدك:
    // await prefs.remove(_themeKey);
    
    Get.offAll(() => LogInScreen());
  }
}