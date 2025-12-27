import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:livora/controller/themes_controller.dart';
import 'package:livora/core/api/api_service.dart';
import 'package:livora/core/local/local.dart';
import 'package:livora/core/themes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widget/log_in_screen.dart';
import 'widget/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  
  // ✅ 1. تحميل اللغة
  final String langCode = prefs.getString('lang') ?? 'ar';
  final Locale initialLocale = Locale(langCode);
  
  // ✅ 2. تحميل الثيم من SharedPreferences قبل بدء التطبيق
  final bool isDarkMode = prefs.getBool('isDarkMode') ?? false;
  
  // ✅ 3. تسجيل ThemeController مع القيمة المحملة
  Get.put(ThemesController(initialDarkMode: isDarkMode));
  
  runApp(MyApp(initialLocale: initialLocale));
}

class MyApp extends StatelessWidget {
  final Locale initialLocale;
  
  const MyApp({Key? key, required this.initialLocale}) : super(key: key);

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      ApiService.setAuthToken(token);
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // ✅ الحصول على الـ Controller
    final ThemesController themesController = Get.find();
    
    return Obx(() => GetMaterialApp(
      debugShowCheckedModeBanner: false,
      locale: initialLocale,
      translations: MyLocal(),
      theme: Themes.lightTheme,
      darkTheme: Themes.darkTheme,
      // ✅ ربط ThemeMode مع Controller
      themeMode: themesController.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
      home: FutureBuilder<bool>(
        future: isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text('خطأ: ${snapshot.error}')),
            );
          }
          
          final isLoggedIn = snapshot.data ?? false;
          return isLoggedIn ? const MainScreen() : LogInScreen();
        },
      ),
    ));
  }
}