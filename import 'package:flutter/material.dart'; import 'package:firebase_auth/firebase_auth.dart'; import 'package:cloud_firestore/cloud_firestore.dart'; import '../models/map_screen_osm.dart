import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/location_service.dart';
import '../models/user_model.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? myLocation;
  List<Marker> deliveryMarkers = [];
  final mapController = MapController();
  final locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final pos = await locationService.getCurrentLocation();
    setState(() => myLocation = LatLng(pos.latitude, pos.longitude));
    
    final myId = FirebaseAuth.instance.currentUser?.uid;
    if (myId != null) {
      // لو أنا دليفري، ابدأ تتبع
      final myDoc = await FirebaseFirestore.instance.collection('users').doc(myId).get();
      if (myDoc.exists && myDoc.data()?['role'] == 'delivery') {
        locationService.startTracking(myId);
      }
    }

    // اسمع للدليفري المتاحين لايف (اخضر بس)
    FirebaseFirestore.instance.collection('users')
      .where('role', isEqualTo: 'delivery')
      .where('status', isEqualTo: 'green')
      .snapshots().listen((snapshot) {
        List<Marker> markers = [];
        for (var doc in snapshot.docs) {
          final user = AppUser.fromMap(doc.data());
          if (user.lat != 0) {
            markers.add(
              Marker(
                point: LatLng(user.lat, user.lng),
                width: 80, height: 80,
                child: Column(children: [
                  Icon(Icons.delivery_dining, color: Color(0xFF00FF88), size: 40),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    color: Colors.black,
                    child: Text('${user.name} - ${user.rankName}', style: TextStyle(color: Colors.white, fontSize: 8)),
                  )
                ]),
              ),
            );
          }
        }
        setState(() => deliveryMarkers = markers);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (myLocation == null) return Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator(color: Color(0xFF00FF88))));
    return Scaffold(
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(initialCenter: myLocation!, initialZoom: 15),
        children: [
          TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.captainflash.app'),
          MarkerLayer(markers: [
            Marker(point: myLocation!, child: Icon(Icons.person_pin_circle, color: Colors.blue, size: 50)),
            ...deliveryMarkers
          ]),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Color(0xFF00FF88),
        onPressed: () {},
        label: Text('الدليفري المتاح: ${deliveryMarkers.length}', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        icon: Icon(Icons.flash_on, color: Colors.black),
      ),
    );
  }
}
