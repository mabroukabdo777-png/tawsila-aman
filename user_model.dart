enum UserRole { client, delivery, owner }
enum DeliveryStatus { green, red } // اخضر فاضي - احمر معاه اوردر
enum DeliveryRank { captainFlash, flash, tayar, delivery }

class AppUser {
  String id;
  String name;
  String phone;
  UserRole role;
  double rating; // من 5
  int totalTrips;
  double totalKm;
  double totalEarnings;
  DeliveryStatus status;
  DeliveryRank rank;
  double lat;
  double lng;

  AppUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    this.rating = 5.0,
    this.totalTrips = 0,
    this.totalKm = 0,
    this.totalEarnings = 0,
    this.status = DeliveryStatus.green,
    this.rank = DeliveryRank.delivery,
    this.lat = 0,
    this.lng = 0,
  });

  // حساب العمولة حسب الرتبة
  double get commissionRate {
    if (rank == DeliveryRank.captainFlash) return 0.10; // كابتن فلاش الممتاز 10%
    return 0.15; // الباقي كله 15%
  }

  String get rankName {
    switch (rank) {
      case DeliveryRank.captainFlash: return 'كابتن فلاش';
      case DeliveryRank.flash: return 'فلاش';
      case DeliveryRank.tayar: return 'طيار';
      case DeliveryRank.delivery: return 'دليفري';
    }
  }

  Map<String, dynamic> toMap() => {
    'id': id, 'name': name, 'phone': phone,
    'role': role.name, 'rating': rating,
    'totalTrips': totalTrips, 'totalKm': totalKm,
    'totalEarnings': totalEarnings,
    'status': status.name, 'rank': rank.name,
    'lat': lat, 'lng': lng,
  };

  static AppUser fromMap(Map map) => AppUser(
    id: map['id'], name: map['name'], phone: map['phone'],
    role: UserRole.values.byName(map['role']),
    rating: (map['rating'] ?? 5).toDouble(),
    totalTrips: map['totalTrips'] ?? 0,
    totalKm: (map['totalKm'] ?? 0).toDouble(),
    totalEarnings: (map['totalEarnings'] ?? 0).toDouble(),
    status: DeliveryStatus.values.byName(map['status'] ?? 'green'),
    rank: DeliveryRank.values.byName(map['rank'] ?? 'delivery'),
    lat: (map['lat'] ?? 0).toDouble(),
    lng: (map['lng'] ?? 0).toDouble(),
  );
}
