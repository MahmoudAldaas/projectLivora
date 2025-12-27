import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyLocalController extends GetxController {
  Locale? currentLocale;
  late SharedPreferences sharedPref;

  @override
  void onInit() {
    super.onInit();
    initializeLang();
  }

  Future<void> initializeLang() async {
    sharedPref = await SharedPreferences.getInstance();
    String? langCode = sharedPref.getString('lang');
    currentLocale = Locale(langCode ?? 'ar');
    update();
  }

  void changeLang(String codeLang) {
    currentLocale = Locale(codeLang);
    sharedPref.setString("lang", codeLang);
    Get.updateLocale(currentLocale!);
    update();
  }
}