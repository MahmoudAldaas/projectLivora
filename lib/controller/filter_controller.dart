import 'package:get/get.dart';
import 'package:livora/core/api/api_service.dart';
import 'package:livora/models/apartment.dart';

class FilterController extends GetxController {

  var selectedGovernorate = ''.obs;
  var selectedCity = ''.obs;
  var minPrice = 200.0.obs;
  var maxPrice = 10000.0.obs;
  var selectedBedrooms = ''.obs;
  
  var isLoading = false.obs;
  var filteredApartments = <Apartment>[].obs;

  final Map<String, List<String>> governorates = {
    'gov_damascus': ['city_damascus', 'city_mazzeh'],
    'gov_rif_damascus': ['city_douma', 'city_jaramana'],
    'gov_aleppo': ['city_aleppo', 'city_afrin'],
    'gov_homs': ['city_homs', 'city_talkalakh'],
    'gov_hama': ['city_hama', 'city_salamiyah'],
    'gov_latakia': ['city_latakia', 'city_jableh'],
    'gov_tartous': ['city_tartous', 'city_baniyas'],
    'gov_idleb': ['city_idleb', 'city_maarat'],
    'gov_hasaka': ['city_hasaka', 'city_qamishli'],
    'gov_deir_ezzor': ['city_deir', 'city_mayadin'],
    'gov_raqqa': ['city_raqqa', 'city_tal_abyad'],
    'gov_daraa': ['city_daraa', 'city_sanamayn'],
    'gov_sweida': ['city_sweida', 'city_salkhad'],
    'gov_quneitra': ['city_jaba', 'city_khan_arnabah'],
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
        minPrice.value != 200.0 ||
        maxPrice.value != 10000.0;
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
    return '${price.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},'
    )} USD';
  }

  Future<void> applyFilter() async {
    try {
      isLoading.value = true;

      print('تطبيق الفلتر:');
      print(' - المحافظة: ${selectedGovernorate.value}');
      print('- المدينة: ${selectedCity.value}');
      print('- السعر: ${minPrice.value} - ${maxPrice.value}');
      print('- الغرف: ${selectedBedrooms.value}');

      final apartments = await ApiService.getApartmentsWithFilter(
        governorate: selectedGovernorate.value.isNotEmpty 
            ? selectedGovernorate.value 
            : null,
        city: selectedCity.value.isNotEmpty 
            ? selectedCity.value 
            : null,
        minPrice: minPrice.value,
        maxPrice: maxPrice.value,
        numberRooms: selectedBedrooms.value.isNotEmpty 
            ? selectedBedrooms.value 
            : null,
      );

      filteredApartments.value = apartments;

      print('تم جلب ${apartments.length} شقة');

      Get.back();
      
      if (apartments.isEmpty) {
        Get.snackbar(
          'no_results'.tr,
          'no_apartments_match_filter'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          'success'.tr,
          '${apartments.length} ${'apartments_found'.tr}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Get.theme.colorScheme.onPrimary,
          duration: const Duration(seconds: 2),
        );
      }
      
    } catch (e) {
      print('خطأ في الفلتر: $e');
      
      Get.snackbar(
        'error'.tr,
        'failed_to_fetch_apartments'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void resetFilter() {
    selectedGovernorate.value = '';
    selectedCity.value = '';
    minPrice.value = 200.0;
    maxPrice.value = 10000.0;
    selectedBedrooms.value = '';
    filteredApartments.clear();

    print('تم إعادة تعيين الفلتر');

    Get.snackbar(
      'reset'.tr,
      'filter_reset_successfully'.tr,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void onInit() {
    super.onInit();
    print(' FilterController initialized');
  }

  @override
  void onClose() {
    print('🗑️ FilterController disposed');
    super.onClose();
  }
}