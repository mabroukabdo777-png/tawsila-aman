import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';
import 'dart:math';
import 'package:latlong2/latlong.dart';

class OrderService {
  final _firestore = FirebaseFirestore.instance;
  final _realtime = FirebaseDatabase.instance.ref();

  double _calcKm(LatLng a, LatLng b) {
    const p = 0.017453292519943295;
    final dLat = (b.latitude - a.latitude) * p;
    final dLon = (b.longitude - a.longitude) * p;
    final hav = 0.5 - cos(dLat)/2 + cos(a.latitude * p) * cos(b.latitude * p) * (1 - cos(dLon))/2;
    return 12742 * asin(sqrt(hav));
  }

  // العميل يطلب دليفري معين
  Future<String> createOrder({required String clientId, required String deliveryId, required LatLng clientLoc, required LatLng deliveryLoc}) async {
    final orderId = _firestore.collection('orders').doc().id;
    final order = OrderModel(
      id: orderId, clientId: clientId, deliveryId: deliveryId,
      status: 'pending',
      pickupLat: deliveryLoc.latitude, pickupLng: deliveryLoc.longitude,
      dropoffLat: clientLoc.latitude, dropoffLng: clientLoc.longitude,
      createdAt: DateTime.now(),
    );
    await _firestore.collection('orders').doc(orderId).set(order.toMap());
    
    // أول ما يطلب، حول الدليفري لأحمر فورا (أمان)
    await _firestore.collection('users').doc(deliveryId).update({'status': 'red'});
    await _realtime.child('live_locations/$deliveryId').remove();
    
    return orderId;
  }

  // الدليفري يقبل
  Future<void> acceptOrder(String orderId) async {
    await _firestore.collection('orders').doc(orderId).update({'status': 'accepted'});
  }

  // الدليفري يدوس "ابدأ الرحلة" - يبدأ حساب المسافة
  Future<void> startTrip(String orderId, LatLng startPoint) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': 'started',
      'startLat': startPoint.latitude,
      'startLng': startPoint.longitude,
      'startTime': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // الدليفري يدوس "انهاء الرحلة" - هنا السحر كله
  Future<Map<String, double>> finishTrip(String orderId) async {
    final orderDoc = await _firestore.collection('orders').doc(orderId).get();
    final data = orderDoc.data()!;
    final deliveryId = data['deliveryId'];
    
    // هات الدليفري عشان نعرف عمولته 10% ولا 15%
    final deliveryDoc = await _firestore.collection('users').doc(deliveryId).get();
    final delivery = AppUser.fromMap(deliveryDoc.data()!);
    
    final start = LatLng(data['startLat'], data['startLng']);
    final endDoc = await _firestore.collection('users').doc(deliveryId).get();
    final end = LatLng(endDoc.data()!['lat'], endDoc.data()!['lng']);
    
    double km = _calcKm(start, end);
    if (km < 0.5) km = 0.5; // أقل مسافة 500 متر
    
    final calc = OrderModel.calculatePrice(km, delivery.commissionRate);
    
    // حدث الأوردر
    await _firestore.collection('orders').doc(orderId).update({
      'status': 'finished',
      'distanceKm': km,
      'price': calc['price'],
      'commission': calc['commission'],
      'driverEarning': calc['driverEarning'],
      'finishedAt': DateTime.now().millisecondsSinceEpoch,
    });

    // حدث محفظة الدليفري
    await _firestore.collection('users').doc(deliveryId).update({
      'totalTrips': FieldValue.increment(1),
      'totalKm': FieldValue.increment(km),
      'totalEarnings': FieldValue.increment(calc['driverEarning']!),
      'status': 'green', // رجعه اخضر تاني
    });

    // اعمل شيك للمالك تلقائي
    await _firestore.collection('checks').doc(deliveryId).collection('items').doc(orderId).set({
      'orderId': orderId,
      'clientId': data['clientId'],
      'distanceKm': km,
      'price': calc['price'],
      'commission': calc['commission'],
      'driverEarning': calc['driverEarning'],
      'commissionRate': delivery.commissionRate,
      'rank': delivery.rankName,
      'date': DateTime.now().toIso8601String(),
    });

    return calc;
  }
}
