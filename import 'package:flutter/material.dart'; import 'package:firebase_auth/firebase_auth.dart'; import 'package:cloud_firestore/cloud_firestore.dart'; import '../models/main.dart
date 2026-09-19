import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/map_screen_osm.dart';
import 'screens/delivery/delivery_home.dart';
import 'screens/owner/owner_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(CaptainFlashApp());
}

class CaptainFlashApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'كابتن فلاش',
      home: AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LoginScreen();
        
        // لو مسجل دخول، شوف دوره ايه
        return FutureBuilder(
          future: FirebaseFirestore.instance.collection('users').doc(snapshot.data!.uid).get(),
          builder: (context, userSnap) {
            if (!userSnap.hasData) return Scaffold(body: Center(child: CircularProgressIndicator()));
            final role = userSnap.data!.data()?['role'];
final phone = userSnap.data!.data()?['phone'];
// رقمك انت كمالك - غيره لرقمك
if (phone == '01002548338' || role == 'owner') return OwnerDashboard();
if (role == 'delivery') return DeliveryHome();
return MapScreen();
          },
        );
      },
    );
  }
}
