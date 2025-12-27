import 'package:get/get.dart';

class MyLocal implements Translations{
  @override
  Map<String, Map<String, String>> get keys => {
        'ar': {
          // ... existing code ...

          // Register Screen
          'Create Account': 'إنشاء حساب',
          'I am a:': 'أنا:',
          'First Name': 'الاسم الأول ',
          'Last Name': 'اسم العائلة ',
          'Phone': 'رقم الهاتف ',
          'Password': 'كلمة المرور ',
          'Confirm Password': 'تأكيد كلمة المرور ',
          'Birthdate': 'تاريخ الميلاد ',
          'Profile Image': 'الصورة الشخصية',
          'ID Image': 'صورة الهوية',
          'Register': 'تسجيل',
          'Already have an account?': 'لديك حساب بالفعل؟ ',
          'Login': 'تسجيل الدخول',
          'Tap to select': 'اضغط للاختيار',
          'renter':'مستأجر',
          'Renter':'مستأجر',
          'Owner':'مالك',
          'owner':'مالك',
          'Back':'رجوع',

          // Log In Screen
          'Log In': 'تسجيل الدخول',
          'Welcome Back': 'مرحباً بعودتك',
          'Sign in to continue': 'سجّل الدخول للمتابعة',
          'Phone Number': 'رقم الهاتف',
          "Don't have an account?": 'ليس لديك حساب؟',

          // Home Screen
          'Home': 'الرئيسية ',
          'حدث خطأ في التحميل': 'حدث خطأ في التحميل',
          'إعادة المحاولة': 'إعادة المحاولة',
          'لا توجد شقق متاحة': 'لا توجد شقق متاحة',

          // Main / Bottom Nav / General
          'Livora': 'ليفورا',
          'Favorites': 'المفضلة',
          'Profile': 'الملف الشخصي',
          'Apartment Options': 'خيارات الشقة',
          'Failed to load':'حدث خطأ في التحميل',
          'Retry':'إعادة المحاولة',
          'Notification':'الاشعارات',

          //apartment details
          'Apartment Details':'تفاصيل الشقة',
          'عدد الغرف':'عدد الغرف',
          'الموقع':'الموقع',
          'احجز الان':'احجز الان',
          'صور اضافية':'صور اضافية',
          'الوصف':'الوصف',



          // Filter Screen
          'filter': 'تصفية',
          'reset': 'إعادة تعيين',
          'governorate': 'المحافظة',
          'choose_governorate': 'اختر المحافظة',
          'city': 'المدينة',
          'choose_city': 'اختر المدينة',
          'price': 'السعر',
          'from': 'من',
          'to': 'إلى',
          'number_of_bedrooms': 'عدد الغرف',
          'choose_bedrooms': 'اختر عدد الغرف',
          'one_bedroom': 'غرفة واحدة',
          'two_bedrooms': 'غرفتان',
          'five_bedrooms': 'خمس غرف',
          'bedrooms_n': '@n غرف',
          'search': 'بحث',

          // My Booking
          'MyBooking': 'حجوزاتي',

          // تصحيح سابق
          'phone': ' رقم الهاتف',
           
           //profile screen
           'profile': 'الملف الشخصي',
          'حجوزاتي': 'حجوزاتي',
          'الوضع الليلي': 'الوضع الليلي',
          'اللغة': 'اللغة',
          'تسجيل الخروج': 'تسجيل الخروج',
          'الغاء':'الغاء',

          // ... existing code ...
        },
        'en': {
          // ... existing code ...

          // Register Screen
          'Create Account': 'Create Account',
          'I am a:': 'I am a:',
          'First Name ': 'First Name ',
          'Last Name ': 'Last Name ',
          'Phone': 'Phone ',
          'Password ': 'Password ',
          'Confirm Password ': 'Confirm Password ',
          'Birthdate ': 'Birthdate ',
          'Profile Image ': 'Profile Image ',
          'ID Image': 'ID Image',
          'Register': 'Register',
          'Already have an account? ': 'Already have an account? ',
          'Login': 'Login',
          'Tap to select': 'Tap to select',
          'Renter':'renter',
          'Owner':'owner',
          'Back':'back',

          // Log In Screen
          'Log In': 'Log In',
          'Welcome Back': 'Welcome Back',
          'Sign in to continue': 'Sign in to continue',
          'Phone Number': 'Phone Number',
          "Don't have an account?": "Don't have an account?",
          
          // Home Screen
          'Home': 'Home ',
          'حدث خطأ في التحميل': 'An error occurred while loading',
          'إعادة المحاولة': 'Retry',
          'لا توجد شقق متاحة': 'No apartments available',
          'Failed to load':'failed to load',
          'Retry':'retry',


          // Main / Bottom Nav / General
          'Livora': 'Livora',
          'Favorites': 'Favorites',
          'Profile': 'Profile',
          'Notification':'notification',
          'Apartment Options': 'Apartment Options',

          // Filter Screen
          'filter': 'Filter',
          'reset': 'Reset',
          'governorate': 'Governorate',
          'choose_governorate': 'Choose governorate',
          'city': 'City',
          'choose_city': 'Choose city',
          'price': 'Price',
          'from': 'From',
          'to': 'To',
          'number_of_bedrooms': 'Number of bedrooms',
          'choose_bedrooms': 'Choose number of bedrooms',
          'one_bedroom': 'One bedroom',
          'two_bedrooms': 'Two bedrooms',
          'five_bedrooms': 'Five bedrooms',
          'bedrooms_n': '@n bedrooms',
          'search': 'Search',
          

          //apartment details
          'Apartment Details':'apartment details',
          'عدد الغرف':'Number of rooms',
          'الموقع':'the site',
          'احجز الان':'Book now',
          'صور اضافية':'Additional photos',
          'الوصف':'Description',

          // My Booking
          'MyBooking': 'My Booking',

          // تصحيح سابق
          'phone': 'Phone Number',

         // ProfileScreen =====
          'profile': 'Profile',
          'حجوزاتي': 'My Booking',
          'الوضع الليلي': 'Dark Mode',
          'اللغة': 'Language',
          'تسجيل الخروج': 'Logout',
          'الغاء':'cancle'


                // ... existing code ...
        },
      };
}