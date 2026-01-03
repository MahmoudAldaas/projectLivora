import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:livora/core/api/api_service.dart';
import 'package:livora/models/apartment.dart';

class ApartmentDetailsController extends GetxController {
  final int apartmentId;
  
  ApartmentDetailsController(this.apartmentId);

  Rx<Apartment?> apartment = Rx<Apartment?>(null);
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;
  
  RxInt currentUserId = 0.obs;
  RxBool isOwner = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCurrentUser();
    loadApartmentDetails();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      currentUserId.value = prefs.getInt('user_id') ?? 0;
      final role = prefs.getString('user_role') ?? '';
      isOwner.value = role == 'owner';
      
      print('User Info: ID=${currentUserId.value}, IsOwner=${isOwner.value}');
    } catch (e) {
      print('Error loading user: $e');
    }
  }

  bool get canEditApartment {
    if (!isOwner.value) {
      print('المستخدم ليس owner');
      return false;
    }
    
    if (currentUserId.value <= 0) {
      print(' User ID غير صالح');
      return false;
    }
    
    if (apartment.value?.ownerId == null) {
      print('الشقة بدون owner_id');
      return false;
    }
    
    final canEdit = apartment.value?.ownerId == currentUserId.value;
    
    print('التحقق من الملكية:');
    print('   Apartment ID: ${apartment.value?.id}');
    print('   Apartment Owner ID: ${apartment.value?.ownerId}');
    print('   Current User ID: ${currentUserId.value}');
    print('   Can Edit: $canEdit');
    
    return canEdit;
  }

  Future<void> loadApartmentDetails() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      print('بدء تحميل الشقة #$apartmentId');
      
      final result = await ApiService.getApartmentDetails(apartmentId);

      print('Result من API:');
      print(result);
      
      if (result['error'] == true) {
        errorMessage.value = result['message'] ?? 'Failed to load apartment';
        print(' خطأ: ${errorMessage.value}');
        return;
      }

      final data = result['data'];
      print(' Data:');
      print(data);
      
      final apartmentData = data['data'] ?? data['apartment'] ?? data;
      print('Apartment Data قبل التحويل:');
      print(apartmentData);
      
      apartment.value = Apartment.fromJson(apartmentData);
      
      print('تم التحويل بنجاح:');
      print('   ID: ${apartment.value?.id}');
      print('   Title: ${apartment.value?.title}');
      print('   Price: ${apartment.value?.price}');
      print('   Description: ${apartment.value?.description}');
      print('   Owner ID: ${apartment.value?.ownerId}');
      print('   Owner Name: ${apartment.value?.ownerName}');
      print('   City: ${apartment.value?.city}');
      print('   Governorate: ${apartment.value?.governorate}');
      print('   Number Rooms: ${apartment.value?.numberRooms}');
      print('   Main Image: ${apartment.value?.mainImage}');
      print('════════════════════════════════════════');

    } catch (e) {
      errorMessage.value = 'Error: $e';
      print(' Error loading apartment details: $e');
      print('Stack trace:');
      print(StackTrace.current);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshApartmentDetails() async {
    await loadApartmentDetails();
  }
}