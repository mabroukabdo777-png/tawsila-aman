import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

class LocationService {
  final _firestore = FirebaseFirestore.instance;
  final _realtime = FirebaseDatabase.instance.ref();

  // يبدأ تتبع الدليفري
  void startTracking(String deliveryId) {
    Geolocator.getPositionStream(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10)
    ).listen((Position pos) async {
      // 1- تحديث سريع جدا في Realtime Database (للخريطة اللايف)
      await _realtime.child('live_locations/$deliveryId').set({
        'lat': pos.latitude,
        'lng': pos.longitude,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });

      // 2- تحديث في Firestore (للحفظ الدائم)
      await _firestore.collection('users').doc(deliveryId).update({
        'lat': pos.latitude,
        'lng': pos.longitude,
      });
    });
  }

  // تحويل الحالة: اخضر فاضي / احمر مشغول
  Future<void> setStatus(String deliveryId, String status) async {
    // status = 'green' أو 'red'
    await _firestore.collection('users').doc(deliveryId).update({'status': status});
    
    if (status == 'red') {
      // لما يبقى احمر، شيله من الخريطة اللايف مؤقتا
      await _realtime.child('live_locations/$deliveryId').remove();
    }
  }

  Future<Position> getCurrentLocation() async {
    return await Geolocator.getCurrentPosition();
  }
}
