import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FavoritesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Favorites'.tr,
        style: TextStyle(
          fontSize: 24,
          fontFamily: 'DancingScript',
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
