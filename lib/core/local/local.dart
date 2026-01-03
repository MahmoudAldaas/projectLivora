import 'package:get/get.dart';

class MyLocal implements Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'ar': {

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
      'renter': 'مستأجر',
      'Renter': 'مستأجر',
      'Owner': 'مالك',
      'owner': 'مالك',
      'Back': 'رجوع',

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
      'Failed to load': 'حدث خطأ في التحميل',
      'Retry': 'إعادة المحاولة',
      'Notification': 'الاشعارات',

      //apartment details
      'Apartment Details': 'تفاصيل الشقة',
      'عدد الغرف': 'عدد الغرف',
      'الموقع': 'الموقع',
      'احجز الان': 'احجز الان',
      'صور اضافية': 'صور اضافية',
      'الوصف': 'الوصف',

      //add apartment
      'إضافة شقة جديدة': 'إضافة شقة جديدة',
      'عنوان الشقة': 'عنوان الشقة',
      'الصورة الرئيسية': 'الصورة الرئيسية',
      'صور إضافية': 'صور إضافية',
      'إضافة الشقة': 'إضافة الشقة',
      'اضغط لاختيار صورة رئيسية': 'اضغط لاختيار صورة رئيسية',
      'إضافة المزيد': 'إضافة المزيد',
      'إضافة صور': 'إضافة صور',

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
      //  المحافظات
      'gov_damascus': 'دمشق',
      'gov_rif_damascus': 'ريف دمشق',
      'gov_aleppo': 'حلب',
      'gov_homs': 'حمص',
      'gov_hama': 'حماة',
      'gov_latakia': 'اللاذقية',
      'gov_tartous': 'طرطوس',
      'gov_idleb': 'ادلب',
      'gov_hasaka': 'الحسكة',
      'gov_deir_ezzor': 'دير الزور',
      'gov_raqqa': 'الرقة',
      'gov_daraa': 'درعا',
      'gov_sweida': 'السويداء',
      'gov_quneitra': 'القنيطرة',
      

      //المدن
      'city_damascus': 'دمشق',
      'city_mazzeh': 'المزة',
      'city_douma': 'دوما',
      'city_jaramana': 'جرمانا',
      'city_aleppo': 'حلب',
      'city_afrin': 'عفرين',
      'city_homs': 'حمص',
      'city_talkalakh': 'تلكلخ',
      'city_hama': 'حماة',
      'city_salamiyah': 'السلمية',
      'city_latakia': 'اللاذقية',
      'city_jableh': 'جبلة',
      'city_tartous': 'طرطوس',
      'city_baniyas': 'بانياس',
      'city_idleb': 'إدلب',
      'city_maarat': 'معرة النعمان',
      'city_hasaka': 'الحسكة',
      'city_qamishli': 'القامشلي',
      'city_deir': 'دير الزور',
      'city_mayadin': 'الميادين',
      'city_raqqa': 'الرقة',
      'city_tal_abyad': 'تل أبيض',
      'city_daraa': 'درعا',
      'city_sanamayn': 'الصنمين',
      'city_sweida': 'السويداء',
      'city_salkhad': 'صلخد',
      'city_jaba': 'جبا',
      'city_khan_arnabah': 'خان أرنبة',
     

      // My Booking
      'MyBooking': 'حجوزاتي',

      'phone': ' رقم الهاتف',

      //profile screen
      'profile': 'الملف الشخصي',
      'حجوزاتي': 'حجوزاتي',
      'الوضع الليلي': 'الوضع الليلي',
      'اللغة': 'اللغة',
      'تسجيل الخروج': 'تسجيل الخروج',
      'الغاء': 'الغاء',

    },
    'en': {

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
      'Renter': 'renter',
      'Owner': 'owner',
      'Back': 'back',

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
      'Failed to load': 'failed to load',
      'Retry': 'retry',

      // Main / Bottom Nav / General
      'Livora': 'Livora',
      'Favorites': 'Favorites',
      'Profile': 'Profile',
      'Notification': 'notification',
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

      ///Governorates
      'gov_damascus': 'Damascus',
      'gov_rif_damascus': 'Rif Dimashq',
      'gov_aleppo': 'Aleppo',
      'gov_homs': 'Homs',
      'gov_hama': 'Hama',
      'gov_latakia': 'Latikia',
      'gov_tartous': 'Tartous',
      'gov_idleb': 'Idleb',
      'gov_hasaka': 'Hasaka',
      'gov_deir_ezzor': 'Deir ez-Zor',
      'gov_raqqa': 'Raqqa',
      'gov_daraa': 'Daraa',
      'gov_sweida': 'As-Suwayda',
      'gov_quneitra': 'Quneitra',

      // Cities
      'city_damascus': 'Damascus',
      'city_mazzeh': 'Mazzeh',
      'city_douma': 'Douma',
      'city_jaramana': 'Jaramana',
      'city_aleppo': 'Aleppo',
      'city_afrin': 'Afrin',
      'city_homs': 'Homs',
      'city_talkalakh': 'Talkalakh',
      'city_hama': 'Hama',
      'city_salamiyah': 'Salamiyah',
      'city_latakia': 'Latakia',
      'city_jableh': 'Jableh',
      'city_tartous': 'Tartous',
      'city_baniyas': 'Baniyas',
      'city_idleb': 'Idlib',
      'city_maarat': 'Maarrat al-Numan',
      'city_hasaka': 'Hasakah',
      'city_qamishli': 'Qamishli',
      'city_deir': 'Deir ez-Zor',
      'city_mayadin': 'Al Mayadin',
      'city_raqqa': 'Raqqa',
      'city_tal_abyad': 'Tal Abyad',
      'city_daraa': 'Daraa',
      'city_sanamayn': 'Al Sanamayn',
      'city_sweida': 'As-Suwayda',
      'city_salkhad': 'Salkhad',
      'city_jaba': 'Jaba',
      'city_khan_arnabah': 'Khan Arnabah',
      
      //apartment details
      'Apartment Details': 'apartment details',
      'عدد الغرف': 'Number of rooms',
      'الموقع': 'the site',
      'احجز الان': 'Book now',
      'صور اضافية': 'Additional photos',
      'الوصف': 'Description',

      //add apartment
      'إضافة شقة جديدة': 'Add a new apartment',
      'عنوان الشقة': 'address apartment',
      'الصورة الرئيسية': 'main photo',
      'صور إضافية': 'Additional photos',
      'إضافة الشقة': 'Add Apartment',
      'اضغط لاختيار صورة رئيسية': 'prees to add photo main',
      'إضافة المزيد': 'add more',
      'إضافة صور': 'add photo',

      // My Booking
      'MyBooking': 'My Booking',

      'phone': 'Phone Number',

      // ProfileScreen 
      'profile': 'Profile',
      'حجوزاتي': 'My Booking',
      'الوضع الليلي': 'Dark Mode',
      'اللغة': 'Language',
      'تسجيل الخروج': 'Logout',
      'الغاء': 'cancle',

    },
  };
}
