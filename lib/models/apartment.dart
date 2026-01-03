class Apartment {
  final int? id;
  final String title;
  final String? governorate;
  final String? city;
  final int? numberRooms;
  final String? description;
  final String price;
  final String? mainImage;
  final List<String>? images;
  final int? ownerId;
  final String? ownerName;

  Apartment({
    this.id,
    required this.title,
    this.governorate,
    this.city,
    this.numberRooms,
    this.description,
    required this.price,
    this.mainImage,
    this.images,
    this.ownerId,
    this.ownerName,
  });

  factory Apartment.fromJson(Map<String, dynamic> json) {
    List<String>? imagesList;
    if (json['images'] != null) {
      if (json['images'] is List) {
        imagesList = List<String>.from(json['images']);
      } else if (json['images'] is String) {
        imagesList = [json['images']];
      }
    }

    return Apartment(
      id: json['id'],
      title: json['title'] ?? 'بدون عنوان',
      governorate: json['governorate'],
      city: json['city'],
      numberRooms: json['number_rooms'],
      description: json['description'],
      price: json['price']?.toString() ?? '0',
      mainImage: json['main_image'],
      images: imagesList,
      ownerId: json['owner_id'],
      ownerName: json['owner_name'], 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'governorate': governorate,
      'city': city,
      'number_rooms': numberRooms,
      'description': description,
      'price': price,
      'main_image': mainImage,
      'images': images,
      'owner_id': ownerId,
      'owner_name': ownerName,
    };
  }
}