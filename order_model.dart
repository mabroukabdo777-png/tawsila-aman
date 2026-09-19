class OrderModel {
  String id;
  String clientId;
  String? deliveryId;
  String status; // pending, accepted, started, finished, cancelled
  double pickupLat, pickupLng;
  double dropoffLat, dropoffLng;
  double distanceKm;
  double price;
  double commission;
  double driverEarning;
  DateTime createdAt;

  OrderModel({
    required this.id,
    required this.clientId,
    this.deliveryId,
    this.status = 'pending',
    required this.pickupLat, required this.pickupLng,
    required this.dropoffLat, required this.dropoffLng,
    this.distanceKm = 0, this.price = 0,
    this.commission = 0, this.driverEarning = 0,
    required this.createdAt,
  });

  // القاعدة الذهبية: 13 + 5*كم
  static Map<String, double> calculatePrice(double km, double commissionRate) {
    double price = 13 + (5 * km);
    double commission = price * commissionRate;
    return {
      'price': price,
      'commission': commission,
      'driverEarning': price - commission
    };
  }

  Map<String, dynamic> toMap() => {
    'id': id, 'clientId': clientId, 'deliveryId': deliveryId,
    'status': status, 'pickupLat': pickupLat, 'pickupLng': pickupLng,
    'dropoffLat': dropoffLat, 'dropoffLng': dropoffLng,
    'distanceKm': distanceKm, 'price': price,
    'commission': commission, 'driverEarning': driverEarning,
    'createdAt': createdAt.millisecondsSinceEpoch,
  };
}
