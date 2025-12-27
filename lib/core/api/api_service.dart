import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:livora/models/apartment.dart';

class ApiService {
  static const String baseUrl = "https://api.albazaqar.com/api";

  // Save Token
  static String? _authToken;

  static void setAuthToken(String? token) {
    _authToken = token;
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

      // Headers
      request.headers['Accept'] = 'application/json';
      request.headers['Connection'] = 'Keep-Alive';

      //  Fields
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
          setAuthToken(jsonResponse['token']);
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

      //  Add headers Token
      if (_authToken != null) {
        headers['Authorization'] = 'Bearer $_authToken';
      }

      final response = await http
          .post(url, headers: headers)
          .timeout(Duration(seconds: 10));

      print('استجابة: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Delete Token
        setAuthToken(null);

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

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        return {'error': false, 'data': data};
      } else {
        throw Exception('Failed to load apartment: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      return {'error': true, 'message': 'Error loading apartment: $e'};
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
  String? mainImagePath, // ✅ اختيارية
  List<String>? imagesPath, // ✅ اختيارية
  String? token,
}) async {
  try {
    print('📤 إضافة شقة جديدة');

    final url = Uri.parse("$baseUrl/apartments");
    
    // ✅ نشوف إذا في صور ولا لأ
    bool hasImages = (mainImagePath != null && mainImagePath.isNotEmpty) ||
                     (imagesPath != null && imagesPath.isNotEmpty);

    if (hasImages) {
      // 📸 إذا في صور → نستخدم MultipartRequest
      print('📸 إرسال مع صور');
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
      // 📝 إذا ما في صور → نستخدم JSON عادي
      print('📝 إرسال بدون صور');
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
    print('❌ خطأ: $e');
    return {'error': true, 'message': 'Error adding apartment: $e'};
  }
}

// 📸 إضافة شقة مع صور
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
      print('🔑 Token موجود');
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
        print('✅ تم إضافة الصورة الرئيسية');
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
      print('✅ تم إضافة ${imagesPath.length} صور إضافية');
    }

    final response = await request.send().timeout(Duration(seconds: 30));
    final responseBody = await response.stream.bytesToString();

    print('📥 استجابة: ${response.statusCode}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonResponse = jsonDecode(responseBody);
      print('✅ تمت إضافة الشقة بنجاح');
      return {
        'error': false,
        'status_code': response.statusCode,
        'message': 'Apartment added successfully',
        'data': jsonResponse,
      };
    } else {
      final errorJson = jsonDecode(responseBody);
      print('❌ خطأ: ${errorJson['message']}');
      return {
        'error': true,
        'status_code': response.statusCode,
        'message': errorJson['message'] ?? 'Failed to add apartment',
      };
    }
  } catch (e) {
    print('❌ خطأ: $e');
    return {'error': true, 'message': 'Error: $e'};
  }
}

// 📝 إضافة شقة بدون صور
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
      print('🔑 Token موجود');
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

    print('📋 البيانات: $body');

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    ).timeout(Duration(seconds: 30));

    print('📥 استجابة: ${response.statusCode}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonResponse = jsonDecode(response.body);
      print('✅ تمت إضافة الشقة بنجاح');
      return {
        'error': false,
        'status_code': response.statusCode,
        'message': 'Apartment added successfully',
        'data': jsonResponse,
      };
    } else {
      final errorJson = jsonDecode(response.body);
      print('❌ خطأ: ${errorJson['message']}');
      return {
        'error': true,
        'status_code': response.statusCode,
        'message': errorJson['message'] ?? 'Failed to add apartment',
      };
    }
  } catch (e) {
    print('❌ خطأ: $e');
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
      }

      final response = await http
          .delete(url, headers: headers)
          .timeout(Duration(seconds: 10));

      print('استجابة: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'error': false,
          'status_code': response.statusCode,
          'message': 'Apartment deleted',
        };
      } else {
        return {
          'error': true,
          'status_code': response.statusCode,
          'message': 'Failed to delete apartment',
        };
      }
    } catch (e) {
      print('Error: $e');
      return {'error': true, 'message': 'Error deleting apartment: $e'};
    }
  }
}
