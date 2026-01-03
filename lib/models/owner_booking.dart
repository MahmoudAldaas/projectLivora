class OwnerBooking {
  final int id;
  final String startDate;
  final String endDate;
  final String status;
  final String userName;
  final String userPhone;
  final String apartmentTitle;

  OwnerBooking({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.userName,
    required this.userPhone,
     required this.apartmentTitle,
  });

  factory OwnerBooking.fromJson(Map<String, dynamic> json) {
    return OwnerBooking(
      id: json['id'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      status: json['status'],
      userName: json['user']?['name'] ?? '',
      userPhone: json['user']?['phone'] ?? '',
      apartmentTitle: json['apartment']?['title'] ?? '',
    );
  }
}
