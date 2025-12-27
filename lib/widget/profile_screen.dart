import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livora/controller/profile_controller.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({Key? key}) : super(key: key);

  final ProfileController controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // ✅ استخدام الثيم
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'profile'.tr,
          style: textTheme.headlineMedium, // ✅ من TextTheme
        ),
        centerTitle: true,
        // ❌ حذف backgroundColor
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ---------------- MY BOOKINGS ----------------
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.book_online,
                  color: colors.primary, // ✅ من ColorScheme
                ),
                title: Text(
                  'حجوزاتي'.tr,
                  style: textTheme.titleLarge, // ✅
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: controller.goToMyBookings,
              ),
            ),

            const SizedBox(height: 12),

            // ---------------- DARK MODE ----------------
            Card(
              child: Obx(
                () => SwitchListTile(
                  secondary: Icon(
                    controller.isDarkMode.value
                        ? Icons.dark_mode
                        : Icons.light_mode,
                    color: colors.primary, // ✅
                  ),
                  title: Text(
                    'الوضع الليلي'.tr,
                    style: textTheme.titleLarge,
                  ),
                  value: controller.isDarkMode.value,
                  activeColor: colors.primary,
                  onChanged: controller.toggleDarkMode,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ---------------- LANGUAGE ----------------
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.language,
                  color: colors.primary,
                ),
                title: Text(
                  'اللغة'.tr,
                  style: textTheme.titleLarge,
                ),
                trailing: SizedBox(
                  width: 110,
                  child: DropdownButton<String>(
                    value: Get.locale?.languageCode == 'ar'
                        ? 'العربية'
                        : 'English',
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(
                        value: 'العربية',
                        child: Text('العربية'),
                      ),
                      DropdownMenuItem(
                        value: 'English',
                        child: Text('English'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        controller.changeLanguage(value);
                      }
                    },
                  ),
                ),
              ),
            ),

            const Spacer(),

            // ---------------- LOGOUT ----------------
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(
                  color: colors.error, // ✅
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextButton.icon(
                onPressed: controller.showLogoutDialog,
                icon: Icon(
                  Icons.logout,
                  color: colors.error,
                  size: 20,
                ),
                label: Text(
                  'تسجيل الخروج'.tr,
                  style: textTheme.titleLarge?.copyWith(
                    color: colors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
