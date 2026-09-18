import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  final _messaging = FirebaseMessaging.instance;

  Future<void> init() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    // خلي الإشعار يظهر بصوت عالي ومهم جدا
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true, badge: true, sound: true,
    );

    final token = await _messaging.getToken();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid!= null && token!= null) {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'fcmToken': token,
      });
    }

    FirebaseMessaging.onMessage.listen((msg) {
      // هنا تقدر تشغل صوت عالي
      print('جالك طلب جديد: ${msg.notification?.title}');
    });
  }

  Future<void> sendToUser(String toUserId, String title, String body) async {
    // هنبعت عن طريق Firestore trigger (هنعمله في لوحة المالك بعدين)
    await FirebaseFirestore.instance.collection('notifications_queue').add({
      'to': toUserId,
      'title': title,
      'body': body,
      'time': DateTime.now().millisecondsSinceEpoch,
    });
  }
}
