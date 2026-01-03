import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemesController extends GetxController {
  final _storage = GetStorage();
  final _key = 'isDarkMode';
  
  late RxBool isDarkMode;

  ThemesController({bool? initialDarkMode}) {
    isDarkMode = (initialDarkMode ?? _storage.read(_key) ?? false).obs;
  }

  @override
  void onInit() {
    super.onInit();
    _applyTheme();
  }

  void _applyTheme() {
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    _saveAndApplyTheme();
  }

  void setTheme(bool isDark) {
    isDarkMode.value = isDark;
    _saveAndApplyTheme();
  }

  void _saveAndApplyTheme() {
    _storage.write(_key, isDarkMode.value);
    _applyTheme();
  }
}
