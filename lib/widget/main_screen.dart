import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livora/controller/local_conroller.dart';
import 'package:livora/controller/navgation_controller.dart';
import 'package:livora/controller/home_controller.dart';
import 'package:livora/widget/favorites_screen.dart';
import 'package:livora/widget/filter_screen.dart';
import 'package:livora/widget/home_screen.dart';
import 'package:livora/widget/notification_screen.dart';
import 'package:livora/widget/profile_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final NavigationController navController = Get.put(NavigationController());
    Get.put(MyLocalController());
    final HomeController homeController = Get.put(HomeController());

    final List<Widget> screens = [
      HomeScreen(),
      FavoritesScreen(),
      NotificationScreen(),
      ProfileScreen(),
    ];

    final List<String> titles = [
      'Livora'.tr,
      'Favorites'.tr,
      'Notification'.tr,
      'Profile'.tr,
    ];

    return Obx(
      () => Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: (navController.currentIndex.value == 3) // إخفاء AppBar لصفحة Notification
            ? null
            : AppBar(
                backgroundColor: theme.appBarTheme.backgroundColor,
                elevation: 0,
                title: Text(
                  titles[navController.currentIndex.value],
                  style: theme.textTheme.headlineMedium,
                ),
                centerTitle: false,
                actions: navController.currentIndex.value == 0
                    ? [
                        IconButton(
                          icon: Icon(Icons.search, color: theme.iconTheme.color),
                          onPressed: () {
                            Get.to(() => FilterScreen());
                          },
                        ),
                      ]
                    : [],
              ),
        body: screens[navController.currentIndex.value],
        floatingActionButton: Obx(() {
          if (navController.currentIndex.value == 0 &&
              homeController.isOwner.value) {
            return FloatingActionButton(
              onPressed: () {
                _showApartmentOptionsMenu(context, theme);
              },
              backgroundColor: theme.colorScheme.primary,
              child: Icon(Icons.add, color: theme.colorScheme.onPrimary),
            );
          }
          return const SizedBox.shrink();
        }),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: navController.currentIndex.value,
          onTap: navController.changeIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
          selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor,
          unselectedItemColor: theme.bottomNavigationBarTheme.unselectedItemColor,
          showSelectedLabels: false,  // إخفاء النص للأيقونة المحددة
          showUnselectedLabels: false, // إخفاء النص للأيقونات غير المحددة
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '', // يجب وضع label فارغ
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: '',
            ),
             BottomNavigationBarItem(
              icon: Icon(Icons.notifications_active_sharp),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: '',
            ),
           
          ],
        ),
      ),
    );
  }

  void _showApartmentOptionsMenu(BuildContext context, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 10),
            Text(
              'Apartment Options'.tr,
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}