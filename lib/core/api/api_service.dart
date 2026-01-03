import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:livora/models/apartment.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';


class ApiService {
  static const String baseUrl = "https://api.albazaqar.com/api";

  // Save Token
  static String? _authToken;

  static Future<void> setAuthToken(String? token) async {
    _authToken = token;
    
    if (token != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      print('تم حفظ Token: ${token.substring(0, 20)}...');
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      print('تم حذف Token');
    }
  }

  static Future<void> loadAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
    
    if (_authToken != null) {
      print('تم تحميل Token: ${_authToken!.substring(0, 20)}...');
    } else {
      print(' لا يوجد Token محفوظ');
    }
  }

  static String? getAuthToken() {
    return _authToken;
  }

  //  REGISTER
  static Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String password,
    required String birthdate,
    String? profileImagePath,
    String? idImagePath,   
    required String role, 
  }) async {
    try {
      print('بدء عملية التسجيل');

      final url = Uri.parse("$baseUrl/register");
      var request = http.MultipartRequest("POST", url);

      request.headers['Accept'] = 'application/json';
      request.headers['Connection'] = 'Keep-Alive';

      request.fields["first_name"] = firstName;
      request.fields["last_name"] = lastName;
      request.fields["phone"] = phone;
      request.fields["password"] = password;
      request.fields["birth_date"] = birthdate;
      request.fields["role"] = role;

      print('البيانات المرسلة:');
      print('   - first_name: $firstName');
      print('   - last_name: $lastName');
      print('   - phone: $phone');
      print('   - birth_date: $birthdate');
      print('   - role: $role');

      // ADD profile_image
      if (profileImagePath != null && profileImagePath.isNotEmpty) {
        final profileFile = File(profileImagePath);
        if (await profileFile.exists()) {
          print('إضافة صورة الملف الشخصي');

          String extension = profileImagePath.split('.').last.toLowerCase();
          MediaType mediaType = MediaType(
            'image',
            extension == 'png' ? 'png' : 'jpeg',
          );

          request.files.add(
            await http.MultipartFile.fromPath(
              "profile_image",
              profileImagePath,
              contentType: mediaType,
              filename:
                  'profile_${DateTime.now().millisecondsSinceEpoch}.$extension',
            ),
          );
        }
      }

      // ADD id_image
      if (idImagePath != null && idImagePath.isNotEmpty) {
        final idFile = File(idImagePath);
        if (await idFile.exists()) {
          print('إضافة صورة الهوية');

          String extension = idImagePath.split('.').last.toLowerCase();
          MediaType mediaType = MediaType(
            'image',
            extension == 'png' ? 'png' : 'jpeg',
          );

          request.files.add(
            await http.MultipartFile.fromPath(
              "id_image",
              idImagePath,
              contentType: mediaType,
              filename:
                  'id_${DateTime.now().millisecondsSinceEpoch}.$extension',
            ),
          );
        }
      }

      print('إرسال الطلب');
      final response = await request.send().timeout(
        Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('Request timeout'),
      );

      final responseBody = await response.stream.bytesToString();
      print('الرد: ${response.statusCode}');
      print('المحتوى: $responseBody');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final jsonResponse = jsonDecode(responseBody);
          return {
            'error': false,
            'status_code': response.statusCode,
            'message':
                jsonResponse['message'] ?? 'user registered successfully',
            'data': jsonResponse,
          };
        } catch (e) {
          return {
            'error': false,
            'status_code': response.statusCode,
            'message': responseBody,
          };
        }
      } else {
        try {
          final errorJson = jsonDecode(responseBody);
          return {
            'error': true,
            'status_code': response.statusCode,
            'message': errorJson['message'] ?? 'Registration failed',
            'errors': errorJson['errors'],
          };
        } catch (e) {
          return {
            'error': true,
            'status_code': response.statusCode,
            'message': 'Registration failed',
            'raw_response': responseBody,
          };
        }
      }
    } on TimeoutException catch (e) {
      print('Timeout: $e');
      return {
        'error': true,
        'message': 'Connection timeout. Please try again.',
      };
    } on SocketException catch (e) {
      print('Network error: $e');
      return {
        'error': true,
        'message': 'Network error. Check your connection.',
      };
    } catch (e, stackTrace) {
      print('Error: $e');
      print('Stack: $stackTrace');
      return {'error': true, 'message': 'An error occurred: $e'};
    }
  }

  //  LOGIN
  static Future<Map<String, dynamic>> login(
    String phone,
    String password,
  ) async {
    try {
      print('بدء تسجيل الدخول');

      final url = Uri.parse("$baseUrl/login");
      final response = await http
          .post(
            url,
            headers: {
              "Accept": "application/json",
              "Content-Type": "application/json",
            },
            body: jsonEncode({"phone": phone, "password": password}),
          )
          .timeout(Duration(seconds: 15));

      print('استجابة: ${response.statusCode}');
      print('محتوى: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonResponse = jsonDecode(response.body);

        //   Save Token If Here 
        if (jsonResponse['token'] != null) {
          await setAuthToken(jsonResponse['token']); 
        }

        return {
          'error': false,
          'status_code': response.statusCode,
          'message': jsonResponse['message'] ?? 'Logged in successfully',
          'user': jsonResponse['user'],
          'token': jsonResponse['token'],
        };
      } else {
        try {
          final errorJson = jsonDecode(response.body);
          return {
            'error': true,
            'status_code': response.statusCode,
            'message': errorJson['message'] ?? 'Login failed',
          };
        } catch (e) {
          return {
            'error': true,
            'status_code': response.statusCode,
            'message': 'Login failed',
          };
        }
      }
    } catch (e) {
      print('Login error: $e');
      return {'error': true, 'message': 'Login error: $e'};
    }
  }

  //  LOGOUT
  static Future<Map<String, dynamic>> logout() async {
    try {
      print('تسجيل الخروج');

      final url = Uri.parse("$baseUrl/logout");

      Map<String, String> headers = {
        "Accept": "application/json",
        "Content-Type": "application/json",
      };

      if (_authToken != null) {
        headers['Authorization'] = 'Bearer $_authToken';
      }

      final response = await http
          .post(url, headers: headers)
          .timeout(Duration(seconds: 10));

      print('استجابة: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Delete Token
        await setAuthToken(null); 

        return {
          'error': false,
          'status_code': response.statusCode,
          'message': 'Logged out successfully',
        };
      } else {
        return {
          'error': true,
          'status_code': response.statusCode,
          'message': 'Logout failed',
        };
      }
    } catch (e) {
      print('Logout error: $e');
      return {'error': true, 'message': 'Logout error: $e'};
    }
  }

  // GET APARTMENTS 
  static Future<List<Apartment>> getApartments({String? token}) async {
    try {
      print('جلب الشقق');

      final url = Uri.parse("$baseUrl/apartments");
      Map<String, String> headers = {"Accept": "application/json"};

      String? useToken = token ?? _authToken;
      if (useToken != null && useToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $useToken';
        print('تم إرفاق Token');
      }

      final response = await http
          .get(url, headers: headers)
          .timeout(Duration(seconds: 20));

      print('استجابة: ${response.statusCode}');
      print('Body: ${response.body}'); 

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);

        List<dynamic> apartmentsList;

        if (data is List) {
          apartmentsList = data;
        } else if (data['data'] is List) {
          apartmentsList = data['data'];
        } else if (data['apartments'] is List) {
          apartmentsList = data['apartments'];
        } else {
          print('تنسيق غير متوقع: $data');
          throw Exception('Unexpected data format');
        }

        print('تم جلب ${apartmentsList.length} شقة');
        return apartmentsList.map((e) => Apartment.fromJson(e)).toList();
      } else {
        print('خطأ: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load apartments: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  //  GET APARTMENT DETAILS 
 static Future<Map<String, dynamic>> getApartmentDetails(
  int id, {
  String? token,
}) async {
  try {
    print('جلب تفاصيل الشقة #$id');

    final url = Uri.parse("$baseUrl/apartments/$id");

    Map<String, String> headers = {"Accept": "application/json"};

    String? useToken = token ?? _authToken;
    if (useToken != null && useToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $useToken';
    }

    final response = await http
        .get(url, headers: headers)
        .timeout(Duration(seconds: 15));

    print('استجابة: ${response.statusCode}');
    
    print(' Response Body:');
    print(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      
      print('Decoded Data:');
      print(data);
      
      return {'error': false, 'data': data};
    } else {
      print('Error Response: ${response.body}');
      throw Exception('Failed to load apartment: ${response.statusCode}');
    }
  } catch (e) {
    print(' Exception: $e');
    return {'error': true, 'message': 'Error loading apartment: $e'};
  }
}

static Future<List<Apartment>> getApartmentsWithFilter({
  String? governorate,
  String? city,
  double? minPrice,
  double? maxPrice,
  String? numberRooms,
  String? token,
}) async {
  try {
    final queryParameters = <String, String>{};

    if (governorate != null && governorate.isNotEmpty) {
      queryParameters['governorate'] = governorate;
    }

    if (city != null && city.isNotEmpty) {
      queryParameters['city'] = city;
    }

    if (minPrice != null) {
      queryParameters['min_price'] = minPrice.toInt().toString();
    }

    if (maxPrice != null) {
      queryParameters['max_price'] = maxPrice.toInt().toString();
    }

    if (numberRooms != null && numberRooms.isNotEmpty) {
      queryParameters['number_rooms'] = numberRooms;
    }

    final uri = Uri.parse("$baseUrl/apartments")
        .replace(queryParameters: queryParameters);

    print('FILTER URL: $uri');

    Map<String, String> headers = {
      "Accept": "application/json",
    };

    String? useToken = token ?? _authToken;
    if (useToken != null && useToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $useToken';
    }

    final response = await http
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: 20));

    print(' Status: ${response.statusCode}');
    print(' Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);

      List<dynamic> list = decoded['data'];
      return list.map((e) => Apartment.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load apartments');
    }
  } catch (e) {
    print(' Filter Error: $e');
    rethrow;
  }
}
  //  ADD APARTMENT 
  static Future<Map<String, dynamic>> addApartment({
    required String title,
    required String governorate,
    required String city,
    required int numberRooms,
    String? description,
    required double price,
    String? mainImagePath, 
    List<String>? imagesPath, 
    String? token,
  }) async {
    try {
      print('إضافة شقة جديدة');

      final url = Uri.parse("$baseUrl/apartments");
      
    bool hasImages = (mainImagePath != null && mainImagePath.isNotEmpty) ||
                       (imagesPath != null && imagesPath.isNotEmpty);

      if (hasImages) {
        print(' إرسال مع صور');
        return await _addApartmentWithImages(
          title: title,
          governorate: governorate,
          city: city,
          numberRooms: numberRooms,
          description: description,
          price: price,
          mainImagePath: mainImagePath,
          imagesPath: imagesPath,
          token: token,
        );
      } else {
        print(' إرسال بدون صور');
        return await _addApartmentWithoutImages(
          title: title,
          governorate: governorate,
          city: city,
          numberRooms: numberRooms,
          description: description,
          price: price,
          token: token,
        );
      }
    } catch (e) {
      print(' خطأ: $e');
      return {'error': true, 'message': 'Error adding apartment: $e'};
    }
  }

  static Future<Map<String, dynamic>> _addApartmentWithImages({
    required String title,
    required String governorate,
    required String city,
    required int numberRooms,
    String? description,
    required double price,
    String? mainImagePath,
    List<String>? imagesPath,
    String? token,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/apartments");
      var request = http.MultipartRequest("POST", url);

      // Headers
      request.headers['Accept'] = 'application/json';
      String? useToken = token ?? _authToken;
      if (useToken != null) {
        request.headers['Authorization'] = 'Bearer $useToken';
        print('Token موجود');
      }

      // Fields
      request.fields["title"] = title;
      request.fields["governorate"] = governorate;
      request.fields["city"] = city;
      request.fields["number_rooms"] = numberRooms.toString();
      request.fields["price"] = price.toString();

      if (description != null && description.isNotEmpty) {
        request.fields["description"] = description;
      }

      // Main Image
      if (mainImagePath != null && mainImagePath.isNotEmpty) {
        final mainFile = File(mainImagePath);
        if (await mainFile.exists()) {
          String extension = mainImagePath.split('.').last.toLowerCase();
          request.files.add(
            await http.MultipartFile.fromPath(
              "main_image",
              mainImagePath,
              contentType: MediaType('image', extension == 'png' ? 'png' : 'jpeg'),
            ),
          );
          print('تم إضافة الصورة الرئيسية');
        }
      }

      // Additional Images
      if (imagesPath != null && imagesPath.isNotEmpty) {
        for (var imagePath in imagesPath) {
          final imageFile = File(imagePath);
          if (await imageFile.exists()) {
            String extension = imagePath.split('.').last.toLowerCase();
            request.files.add(
              await http.MultipartFile.fromPath(
                "images[]",
                imagePath,
                contentType: MediaType('image', extension == 'png' ? 'png' : 'jpeg'),
              ),
            );
          }
        }
        print('تم إضافة ${imagesPath.length} صور إضافية');
      }

      final response = await request.send().timeout(Duration(seconds: 30));
      final responseBody = await response.stream.bytesToString();

      print('استجابة: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonResponse = jsonDecode(responseBody);
        print('تمت إضافة الشقة بنجاح');
        return {
          'error': false,
          'status_code': response.statusCode,
          'message': 'Apartment added successfully',
          'data': jsonResponse,
        };
      } else {
        final errorJson = jsonDecode(responseBody);
        print('خطأ: ${errorJson['message']}');
        return {
          'error': true,
          'status_code': response.statusCode,
          'message': errorJson['message'] ?? 'Failed to add apartment',
        };
      }
    } catch (e) {
      print(' خطأ: $e');
      return {'error': true, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> _addApartmentWithoutImages({
    required String title,
    required String governorate,
    required String city,
    required int numberRooms,
    String? description,
    required double price,
    String? token,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/apartments");

      Map<String, String> headers = {
        "Accept": "application/json",
        "Content-Type": "application/json",
      };

      String? useToken = token ?? _authToken;
      if (useToken != null) {
        headers['Authorization'] = 'Bearer $useToken';
        print('Token موجود');
      }

      Map<String, dynamic> body = {
        "title": title,
        "governorate": governorate,
        "city": city,
        "number_rooms": numberRooms,
        "price": price,
      };

      if (description != null && description.isNotEmpty) {
        body["description"] = description;
      }

      print('البيانات: $body');

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      ).timeout(Duration(seconds: 30));

      print(' استجابة: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonResponse = jsonDecode(response.body);
        print(' تمت إضافة الشقة بنجاح');
        return {
          'error': false,
          'status_code': response.statusCode,
          'message': 'Apartment added successfully',
          'data': jsonResponse,
        };
      } else {
        final errorJson = jsonDecode(response.body);
        print('خطأ: ${errorJson['message']}');
        return {
          'error': true,
          'status_code': response.statusCode,
          'message': errorJson['message'] ?? 'Failed to add apartment',
        };
      }
    } catch (e) {
      print('خطأ: $e');
      return {'error': true, 'message': 'Error: $e'};
    }
  }

  //  UPDATE APARTMENT 
  static Future<Map<String, dynamic>> updateApartment({
    required int id,
    String? title,
    String? description,
    double? price,
    String? token,
  }) async {
    try {
      print('تعديل الشقة #$id');

      final url = Uri.parse("$baseUrl/apartments/$id");

      Map<String, String> headers = {
        "Accept": "application/json",
        "Content-Type": "application/json",
      };

      String? useToken = token ?? _authToken;
      if (useToken != null) {
        headers['Authorization'] = 'Bearer $useToken';
      }

      Map<String, dynamic> body = {};
      if (title != null) body['title'] = title;
      if (description != null) body['description'] = description;
      if (price != null) body['price'] = price;

      final response = await http
          .put(url, headers: headers, body: jsonEncode(body))
          .timeout(Duration(seconds: 15));

      print('استجابة: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonResponse = jsonDecode(response.body);
        return {
          'error': false,
          'status_code': response.statusCode,
          'message': 'Apartment updated successfully',
          'data': jsonResponse,
        };
      } else {
        final errorJson = jsonDecode(response.body);
        return {
          'error': true,
          'status_code': response.statusCode,
          'message': errorJson['message'] ?? 'Failed to update apartment',
        };
      }
    } catch (e) {
      print('Error: $e');
      return {'error': true, 'message': 'Error updating apartment: $e'};
    }
  }

  // DELETE APARTMENT 
  static Future<Map<String, dynamic>> deleteApartment(
    int id, {
    String? token,
  }) async {
    try {
      print('حذف الشقة #$id');

      final url = Uri.parse("$baseUrl/apartments/$id");

      Map<String, String> headers = {"Accept": "application/json"};

      String? useToken = token ?? _authToken;
      if (useToken != null) {
        headers['Authorization'] = 'Bearer $useToken';
        print(' تم إرفاق Token للحذف');
      } else {
        print('تحذير: لا يوجد Token!');
      }

      final response = await http
          .delete(url, headers: headers)
          .timeout(Duration(seconds: 10));

      print(' استجابة الحذف: ${response.statusCode}');
      print(' Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print(' تم حذف الشقة بنجاح');
        return {
          'error': false,
          'status_code': response.statusCode,
          'message': 'Apartment deleted successfully',
        };
      } else {
        final errorBody = response.body.isNotEmpty ? response.body : 'No error details';
        print(' فشل الحذف: $errorBody');
        
        return {
          'error': true,
          'status_code': response.statusCode,
          'message': 'Failed to delete: $errorBody',
        };
      }
    } catch (e) {
      print(' Error: $e');
      return {'error': true, 'message': 'Error deleting apartment: $e'};
    }
  }

/// إنشاء حجز جديد
static Future<Map<String, dynamic>> createBooking({
  required int apartmentId,
  required String startDate,
  required String endDate,
  String? token,
}) async {
  try {
    print(' إنشاء حجز للشقة #$apartmentId');

    final url = Uri.parse("$baseUrl/apartments/$apartmentId/bookings");

    Map<String, String> headers = {
      "Accept": "application/json",
      "Content-Type": "application/json",
    };

    String? useToken = token ?? _authToken;
    if (useToken != null && useToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $useToken';
    }

    Map<String, dynamic> body = {
      'start_date': startDate,
      'end_date': endDate,
    };

    final response = await http
        .post(url, headers: headers, body: jsonEncode(body))
        .timeout(Duration(seconds: 15));

    print('استجابة: ${response.statusCode}');
    print(' Response Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonResponse = jsonDecode(response.body);
      return {
        'error': false,
        'status_code': response.statusCode,
        'message': 'Booking created successfully',
        'data': jsonResponse,
      };
    } else {
      final errorJson = jsonDecode(response.body);
      return {
        'error': true,
        'status_code': response.statusCode,
        'message': errorJson['message'] ?? 'Failed to create booking',
      };
    }
  } catch (e) {
    print(' Error: $e');
    return {'error': true, 'message': 'Error creating booking: $e'};
  }
}

/// جلب حجوزات المستخدم
static Future<Map<String, dynamic>> getMyBookings({String? token}) async {
  try {
    print('جلب حجوزاتي');

    final url = Uri.parse("$baseUrl/my-bookings");

    Map<String, String> headers = {
      "Accept": "application/json",
    };

    String? useToken = token ?? _authToken;
    if (useToken != null && useToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $useToken';
    }

    final response = await http
        .get(url, headers: headers)
        .timeout(const Duration(seconds: 15));

    print(' Status: ${response.statusCode}');
    print(' Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);

      List<dynamic> bookingsList;

      if (decoded is List) {
        bookingsList = decoded;
      } else if (decoded['data'] is List) {
        bookingsList = decoded['data'];
      } else if (decoded['bookings'] is List) {
        bookingsList = decoded['bookings'];
      } else {
        throw Exception('Unexpected bookings format');
      }

      return {
        'error': false,
        'data': bookingsList, 
      };
    } else {
      final errorJson = jsonDecode(response.body);
      return {
        'error': true,
        'message': errorJson['message'] ?? 'Failed to fetch bookings',
      };
    }
  } catch (e) {
    print(' Error: $e');
    return {
      'error': true,
      'message': 'Error fetching bookings: $e',
    };
  }
}

// جلب حجز واحد للشقة 
static Future<Map<String, dynamic>> getBookingForApartment({
  required int apartmentId,
  String? token,
}) async {
  try {
    print(' جلب حجزي للشقة #$apartmentId');

    final url = Uri.parse("$baseUrl/apartments/$apartmentId/my-booking");

    Map<String, String> headers = {"Accept": "application/json"};

    String? useToken = token ?? _authToken;
    if (useToken != null && useToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $useToken';
    }

    final response = await http
        .get(url, headers: headers)
        .timeout(Duration(seconds: 15));

    print('استجابة: ${response.statusCode}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonResponse = jsonDecode(response.body);
      return {
        'error': false,
        'data': jsonResponse,
      };
    } else if (response.statusCode == 404) {
      return {
        'error': false,
        'data': null,
      };
    } else {
      final errorJson = jsonDecode(response.body);
      return {
        'error': true,
        'message': errorJson['message'] ?? 'Failed to fetch booking',
      };
    }
  } catch (e) {
    print(' Error: $e');
    return {'error': true, 'message': 'Error fetching booking: $e'};
  }
}


// تعديل حجز  
static Future<Map<String, dynamic>> updateBooking({
  required int bookingId,
  required String startDate,
  required String endDate,
  String? token,
}) async {
  try {
    print(' تعديل الحجز #$bookingId');

    final url = Uri.parse("$baseUrl/bookings/$bookingId");

    Map<String, String> headers = {
      "Accept": "application/json",
      "Content-Type": "application/json",
    };

    String? useToken = token ?? _authToken;
    if (useToken != null && useToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $useToken';
    }

    Map<String, dynamic> body = {
      'start_date': startDate,
      'end_date': endDate,
    };

    print('البيانات المرسلة: $body');

    final response = await http
        .put(url, headers: headers, body: jsonEncode(body))
        .timeout(Duration(seconds: 15));

    print('استجابة: ${response.statusCode}');
    print('Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonResponse = jsonDecode(response.body);
      return {
        'error': false,
        'status_code': response.statusCode,
        'message': jsonResponse['message'] ?? 'Booking updated successfully',
        'data': jsonResponse,
      };
    } else {
      try {
        final errorJson = jsonDecode(response.body);
        return {
          'error': true,
          'status_code': response.statusCode,
          'message': errorJson['message'] ?? 'Failed to update booking',
          'errors': errorJson['errors'],
        };
      } catch (e) {
        return {
          'error': true,
          'status_code': response.statusCode,
          'message': 'Failed to update booking',
        };
      }
    }
  } catch (e) {
    print(' Error: $e');
    return {'error': true, 'message': 'Error updating booking: $e'};
  }
}

// إلغاء حجز  
static Future<Map<String, dynamic>> cancelBooking({
  required int bookingId,
  String? token,
}) async {
  try {
    print(' إلغاء الحجز #$bookingId');

    final url = Uri.parse("$baseUrl/bookings/$bookingId/cancel");

    Map<String, String> headers = {
      "Accept": "application/json",
      "Content-Type": "application/json",
    };

    String? useToken = token ?? _authToken;
    if (useToken != null && useToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $useToken';
    }

    final response = await http
        .patch(url, headers: headers)
        .timeout(Duration(seconds: 15));

    print(' استجابة: ${response.statusCode}');
    print(' Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final jsonResponse = jsonDecode(response.body);
        return {
          'error': false,
          'status_code': response.statusCode,
          'message': jsonResponse['message'] ?? 'Booking cancelled successfully',
          'data': jsonResponse,
        };
      } catch (e) {
        return {
          'error': false,
          'status_code': response.statusCode,
          'message': 'Booking cancelled successfully',
        };
      }
    } else {
      try {
        final errorJson = jsonDecode(response.body);
        return {
          'error': true,
          'status_code': response.statusCode,
          'message': errorJson['message'] ?? 'Failed to cancel booking',
          'errors': errorJson['errors'],
        };
      } catch (e) {
        return {
          'error': true,
          'status_code': response.statusCode,
          'message': 'Failed to cancel booking',
        };
      }
    }
  } catch (e) {
    print(' Error: $e');
    return {'error': true, 'message': 'Error cancelling booking: $e'};
  }
}

// جلب طلبات الحجز المعلّقة للمالك
static Future<Map<String, dynamic>> getOwnerPendingBookings({String? token}) async {
  try {
    print(' جلب طلبات الحجز المعلّقة للمالك');

    final url = Uri.parse("$baseUrl/owner/bookings/pending");

    Map<String, String> headers = {
      "Accept": "application/json",
    };

    String? useToken = token ?? _authToken;
    if (useToken != null && useToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $useToken';
    }

    final response = await http
        .get(url, headers: headers)
        .timeout(const Duration(seconds: 15));

    print('استجابة: ${response.statusCode}');
    print(' Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonResponse = jsonDecode(response.body);
      return {
        'error': false,
        'data': jsonResponse,
      };
    } else {
      final errorJson = jsonDecode(response.body);
      return {
        'error': true,
        'message': errorJson['message'] ?? 'Failed to fetch pending bookings',
      };
    }
  } catch (e) {
    print('Error: $e');
    return {
      'error': true,
      'message': 'Error fetching pending bookings: $e',
    };
  }
}

//  قبول حجز من قبل المالك
static Future<Map<String, dynamic>> approveBooking({
  required int bookingId,
  String? token,
}) async {
  try {
    print(' قبول الحجز #$bookingId');

    final url = Uri.parse("$baseUrl/bookings/$bookingId/approve");

    Map<String, String> headers = {
      "Accept": "application/json",
    };

    String? useToken = token ?? _authToken;
    if (useToken != null && useToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $useToken';
    }

    final response = await http
        .post(url, headers: headers)
        .timeout(const Duration(seconds: 15));

    print('استجابة: ${response.statusCode}');
    print(' Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonResponse = jsonDecode(response.body);
      return {
        'error': false,
        'message': jsonResponse['message'] ?? 'Booking approved',
        'data': jsonResponse,
      };
    } else {
      final errorJson = jsonDecode(response.body);
      return {
        'error': true,
        'message': errorJson['message'] ?? 'Failed to approve booking',
      };
    }
  } catch (e) {
    print(' Error: $e');
    return {
      'error': true,
      'message': 'Error approving booking: $e',
    };
  }
}

// رفض حجز من قبل المالك
static Future<Map<String, dynamic>> rejectBooking({
  required int bookingId,
  String? token,
}) async {
  try {
    print('رفض الحجز #$bookingId');

    final url = Uri.parse("$baseUrl/bookings/$bookingId/reject");

    Map<String, String> headers = {
      "Accept": "application/json",
    };

    String? useToken = token ?? _authToken;
    if (useToken != null && useToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $useToken';
    }

    final response = await http
        .post(url, headers: headers)
        .timeout(const Duration(seconds: 15));

    print('استجابة: ${response.statusCode}');
    print(' Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonResponse = jsonDecode(response.body);
      return {
        'error': false,
        'message': jsonResponse['message'] ?? 'Booking rejected',
        'data': jsonResponse,
      };
    } else {
      final errorJson = jsonDecode(response.body);
      return {
        'error': true,
        'message': errorJson['message'] ?? 'Failed to reject booking',
      };
    }
  } catch (e) {
    print(' Error: $e');
    return {
      'error': true,
      'message': 'Error rejecting booking: $e',
    };
  }
}
 //  جلب جميع الإشعارات
static Future<Map<String, dynamic>> getNotifications({String? token}) async {
  try {
    print(' جلب الإشعارات');

    final url = Uri.parse("$baseUrl/notifications"); 

    Map<String, String> headers = {
      "Accept": "application/json",
    };

    String? useToken = token ?? _authToken;
    if (useToken != null && useToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $useToken';
    }

    final response = await http
        .get(url, headers: headers)
        .timeout(const Duration(seconds: 15));

    print(' Status: ${response.statusCode}');
    print(' Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);

      List<dynamic> notificationsList;

      if (decoded is List) {
        notificationsList = decoded;
      } else if (decoded['data'] is List) {
        notificationsList = decoded['data'];
      } else {
        notificationsList = [];
        print(' لم يتم العثور على إشعارات');
      }

      return {
        'error': false,
        'data': notificationsList,
      };
    } else {
      final errorJson = jsonDecode(response.body);
      return {
        'error': true,
        'message': errorJson['message'] ?? 'Failed to fetch notifications',
      };
    }
  } catch (e) {
    print(' Error: $e');
    return {
      'error': true,
      'message': 'Error fetching notifications: $e',
    };
  }
}

//  تحديد جميع الإشعارات كمقروءة
static Future<Map<String, dynamic>> markAllNotificationsRead({String? token}) async {
  try {
    print(' تحديد جميع الإشعارات كمقروءة');

    final url = Uri.parse("$baseUrl/notifications/mark-all-read"); 

    Map<String, String> headers = {
      "Accept": "application/json",
    };

    String? useToken = token ?? _authToken;
    if (useToken != null && useToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $useToken';
    }

    final response = await http
        .post(url, headers: headers)
        .timeout(const Duration(seconds: 15));

    print(' Status: ${response.statusCode}');
    print(' Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonResponse = jsonDecode(response.body);
      return {
        'error': false,
        'message': jsonResponse['message'] ?? 'All notifications marked as read',
        'data': jsonResponse,
      };
    } else {
      final errorJson = jsonDecode(response.body);
      return {
        'error': true,
        'message': errorJson['message'] ?? 'Failed to mark notifications as read',
      };
    }
  } catch (e) {
    print(' Error: $e');
    return {
      'error': true,
      'message': 'Error marking notifications as read: $e',
    };
  }
}

/// إرسال تقييم 
static Future<Map<String, dynamic>> submitBookingReview({
  required int bookingId,
  required int rating, 
  String? review,      
  String? token,
}) async {
  try {
    print('إرسال تقييم للحجز #$bookingId');

    final url = Uri.parse("$baseUrl/bookings/$bookingId/review");

    Map<String, String> headers = {
      "Accept": "application/json",
      "Content-Type": "application/json",
    };

    String? useToken = token ?? _authToken;
    if (useToken != null && useToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $useToken';
    }

    Map<String, dynamic> body = {
      'rating': rating,
    };

    if (review != null && review.isNotEmpty) {
      body['review'] = review;
    }

    print(' البيانات المرسلة: $body');

    final response = await http
        .post(url, headers: headers, body: jsonEncode(body))
        .timeout(const Duration(seconds: 15));

    print('استجابة: ${response.statusCode}');
    print('Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonResponse = jsonDecode(response.body);
      return {
        'error': false,
        'message': jsonResponse['message'] ?? 'Review submitted successfully',
        'data': jsonResponse,
      };
    } else {
      final errorJson = jsonDecode(response.body);
      return {
        'error': true,
        'message': errorJson['message'] ?? 'Failed to submit review',
      };
    }
  } catch (e) {
    print(' Error: $e');
    return {
      'error': true,
      'message': 'Error submitting review: $e',
    };
  }
}


}