import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemesController extends GetxController {
  final _storage = GetStorage();
  final _key = 'isDarkMode';
  
  // ✅ متغير reactive لحالة الثيم
  late RxBool isDarkMode;

  // ✅ Constructor لاستقبال القيمة الأولية
  ThemesController({bool? initialDarkMode}) {
    // إذا في قيمة محملة من main.dart استخدمها، وإلا اقرأ من GetStorage
    isDarkMode = (initialDarkMode ?? _storage.read(_key) ?? false).obs;
  }

  @override
  void onInit() {
    super.onInit();
    _applyTheme();
  }

  // ✅ تطبيق الثيم
  void _applyTheme() {
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  // ✅ تبديل الثيم
  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    _saveAndApplyTheme();
  }

  // ✅ تغيير الثيم بشكل مباشر
  void setTheme(bool isDark) {
    isDarkMode.value = isDark;
    _saveAndApplyTheme();
  }

  // ✅ حفظ وتطبيق الثيم
  void _saveAndApplyTheme() {
    _storage.write(_key, isDarkMode.value);
    _applyTheme();
  }
}
