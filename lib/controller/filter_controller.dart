import 'package:get/get.dart';

class FilterController extends GetxController {

  var selectedGovernorate = ''.obs;
  var selectedCity = ''.obs;
  var minPrice = 100000.0.obs;
  var maxPrice = 1000000.0.obs;
  var selectedBedrooms = ''.obs;

  final Map<String, List<String>> governorates = {
    'دمشق': ['دمشق', 'المزة'],
    'ريف دمشق': ['دوما', 'جرمانا'],
    'حلب': ['حلب', 'عفرين'],
    'حمص': ['حمص', 'تلكلخ'],
    'حماة': ['حماة', 'السلمية'],
    'اللاذقية': ['اللاذقية', 'جبلة'],
    'طرطوس': ['طرطوس', 'بانياس'],
    'إدلب': ['إدلب', 'معرة النعمان'],
    'الحسكة': ['الحسكة', 'القامشلي'],
    'دير الزور': ['دير الزور', 'الميادين'],
    'الرقة': ['الرقة', 'تل أبيض'],
    'درعا': ['درعا', 'الصنمين'],
    'السويداء': ['السويداء', 'صلخد'],
    'القنيطرة': ['جبا', 'خان ارنبة'],
  };

  final List<String> bedroomsOptions = ['1', '2', '3', '4', '5'];

  List<String> get cities {
    if (selectedGovernorate.value.isEmpty) return [];
    return governorates[selectedGovernorate.value] ?? [];
  }

  bool get hasActiveFilters {
    return selectedGovernorate.value.isNotEmpty ||
        selectedCity.value.isNotEmpty ||
        selectedBedrooms.value.isNotEmpty ||
        minPrice.value != 100000.0 ||
        maxPrice.value != 1000000.0;
  }

  void setGovernorate(String governorate) {
    selectedGovernorate.value = governorate;
    selectedCity.value = ''; 
  }

  void setCity(String city) {
    selectedCity.value = city;
  }

  void setBedrooms(String bedrooms) {
    selectedBedrooms.value = bedrooms;
  }

  String formatPrice(double price) {
    return '${price.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} S.P';
  }

  void applyFilter() {
    Get.back();   }

  void resetFilter() {
    selectedGovernorate.value = '';
    selectedCity.value = '';
    minPrice.value = 100000.0;
    maxPrice.value = 1000000.0;
    selectedBedrooms.value = '';

  }
}
