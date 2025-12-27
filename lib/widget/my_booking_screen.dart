import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyBookingScreen extends StatelessWidget {
  const MyBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // ✅

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'MyBooking'.tr,
          style: theme.textTheme.headlineMedium, // ✅ بدل TextStyle
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'MyBooking'.tr,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold, // ✅ تعديل وزن فقط
          ),
        ),
      ),
    );
  }
}
