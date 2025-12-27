import 'package:get/get.dart';
import 'package:livora/core/api/api_service.dart';
import 'package:livora/models/apartment.dart';

class ApartmentDetailsController extends GetxController {
  final int apartmentId;
  
  ApartmentDetailsController(this.apartmentId);

  // البيانات
  Rx<Apartment?> apartment = Rx<Apartment?>(null);
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadApartmentDetails();
  }

  // جلب تفاصيل الشقة
  Future<void> loadApartmentDetails() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await ApiService.getApartmentDetails(apartmentId);

      if (result['error'] == true) {
        errorMessage.value = result['message'] ?? 'Failed to load apartment';
        return;
      }

      // تحويل البيانات إلى Apartment object
      final data = result['data'];
      
      // إذا البيانات جاية داخل 'apartment'
      final apartmentData = data['apartment'] ?? data;
      
      apartment.value = Apartment.fromJson(apartmentData);

    } catch (e) {
      errorMessage.value = 'Error: $e';
      print('❌ Error loading apartment details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // إعادة التحميل
  Future<void> refreshApartmentDetails() async {
    await loadApartmentDetails();
  }
}