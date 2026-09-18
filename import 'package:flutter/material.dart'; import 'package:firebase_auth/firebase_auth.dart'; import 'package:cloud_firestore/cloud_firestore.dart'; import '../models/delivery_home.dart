import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:latlong2/latlong.dart';
import '../../services/order_service.dart';
import '../../services/location_service.dart';

class DeliveryHome extends StatefulWidget {
  @override
  _DeliveryHomeState createState() => _DeliveryHomeState();
}

class _DeliveryHomeState extends State<DeliveryHome> {
  final orderService = OrderService();
  String? activeOrderId;
  LatLng? startPoint;

  @override
  Widget build(BuildContext context) {
    final myId = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text('كابتن فلاش - لوحة الطيار'), backgroundColor: Color(0xFF00FF88)),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('orders')
            .where('deliveryId', isEqualTo: myId)
            .where('status', whereIn: ['pending','accepted','started']).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('مفيش طلبات حاليا - انت متاح 🟢', style: TextStyle(color: Colors.white, fontSize: 20)));
          }
          final order = snapshot.data!.docs.first;
          final data = order.data();
          activeOrderId = order.id;
          
          return Padding(
            padding: EdgeInsets.all(20),
            child: Column(children: [
              Text('عندك طلب جديد!', style: TextStyle(color: Colors.white, fontSize: 24)),
              SizedBox(height: 20),
              if (data['status'] == 'pending')
                ElevatedButton(
                  onPressed: () => orderService.acceptOrder(order.id),
                  style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF00FF88)),
                  child: Text('قبول الطلب', style: TextStyle(color: Colors.black)),
                ),
              if (data['status'] == 'accepted')
                ElevatedButton(
                  onPressed: () async {
                    final pos = await LocationService().getCurrentLocation();
                    startPoint = LatLng(pos.latitude, pos.longitude);
                    await orderService.startTrip(order.id, startPoint!);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: Text('ابدأ الرحلة - هتحمر 🔴', style: TextStyle(color: Colors.white)),
                ),
              if (data['status'] == 'started')
                ElevatedButton(
                  onPressed: () async {
                    final result = await orderService.finishTrip(order.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('تم! المسافة: ${order['distanceKm']?.toStringAsFixed(1)} كم - حسابك: ${result['driverEarning']?.toStringAsFixed(0)} جنيه')),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text('انهاء الرحلة - حساب وترجع اخضر 🟢', style: TextStyle(color: Colors.white)),
                ),
            ]),
          );
        },
      ),
    );
  }
}
