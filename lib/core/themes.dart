import 'package:flutter/material.dart';
import 'package:livora/app_colors.dart';

class Themes {

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.accent,
      scaffoldBackgroundColor: AppColors.white,

      fontFamily: 'DancingScript',

      colorScheme: const ColorScheme.light(
        primary: AppColors.accent,
        secondary: AppColors.brownGray,
        surface: AppColors.white,
        error: AppColors.error,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.darkGray,
        onError: AppColors.white,
      ),

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.darkGray),
        titleTextStyle: TextStyle(
          fontFamily: 'DancingScript', 
          color: AppColors.darkGray,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),

      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'DancingScript',
          color: AppColors.darkGray,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          fontFamily: 'DancingScript',
          color: AppColors.darkGray,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          fontFamily: 'DancingScript',
          color: AppColors.darkGray,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'DancingScript',
          color: AppColors.darkGray,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'DancingScript',
          color: AppColors.darkGray,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          fontFamily: 'DancingScript',
          color: AppColors.darkGray,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'DancingScript',
          color: AppColors.darkGray,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'DancingScript',
          color: AppColors.brownGray,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        bodySmall: TextStyle(
          fontFamily: 'DancingScript',
          color: AppColors.lightGray,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontFamily: 'DancingScript', 
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accent,
          side: const BorderSide(color: AppColors.beige),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontFamily: 'DancingScript',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.beige, width: 1),
        ),
      ),

      //  lables
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.beige),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.beige),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.accent, width: 2),
        ),
        labelStyle: const TextStyle(
          fontFamily: 'DancingScript',
          color: AppColors.brownGray,
        ),
        floatingLabelStyle: const TextStyle(
          fontFamily: 'DancingScript',
          color: AppColors.accent,
          fontWeight: FontWeight.bold,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),

      // Icons
      iconTheme: const IconThemeData(
        color: AppColors.darkGray,
        size: 24,
      ),
    );
  }

  //  Dark Theme 
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.darkAccent,
      scaffoldBackgroundColor: AppColors.darkBg,

      fontFamily: 'DancingScript', 

      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkAccent,
        secondary: AppColors.darkAccent,
        surface: AppColors.darkCardBg,
        error: AppColors.darkError,
        onPrimary: AppColors.darkTextPrimary,
        onSecondary: AppColors.darkTextPrimary,
        onSurface: AppColors.darkTextPrimary,
        onError: AppColors.darkBg,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBg,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.darkTextPrimary),
        titleTextStyle: TextStyle(
          fontFamily: 'DancingScript',
          color: AppColors.darkTextPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),

      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'DancingScript',
          color: AppColors.darkTextPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          fontFamily: 'DancingScript',
          color: AppColors.darkTextPrimary,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          fontFamily: 'DancingScript',
          color: AppColors.darkTextPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'DancingScript',
          color: AppColors.darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'DancingScript',
          color: AppColors.darkTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          fontFamily: 'DancingScript',
          color: AppColors.darkTextPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'DancingScript',
          color: AppColors.darkTextPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'DancingScript',
          color: AppColors.darkTextSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        bodySmall: TextStyle(
          fontFamily: 'DancingScript',
          color: AppColors.darkTextSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkAccent,
          foregroundColor: AppColors.darkTextPrimary,
          textStyle: const TextStyle(
            fontFamily: 'DancingScript',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkCardBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        labelStyle: const TextStyle(
          fontFamily: 'DancingScript',
          color: AppColors.darkTextSecondary,
        ),
        floatingLabelStyle: const TextStyle(
          fontFamily: 'DancingScript',
          color: AppColors.darkAccent,
          fontWeight: FontWeight.bold,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.darkAccent, width: 2),
        ),
      ),

      iconTheme: const IconThemeData(
        color: AppColors.darkTextPrimary,
        size: 24,
      ),
    );
  }
}
