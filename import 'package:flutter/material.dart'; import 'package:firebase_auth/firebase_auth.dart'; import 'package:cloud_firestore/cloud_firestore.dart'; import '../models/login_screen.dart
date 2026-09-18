import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'map_screen_osm.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final phoneController = TextEditingController();
  final nameController = TextEditingController();
  final otpController = TextEditingController();
  String? verificationId;
  bool showOtp = false;
  UserRole selectedRole = UserRole.client;

  Future<void> sendOtp() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+2${phoneController.text}',
      verificationCompleted: (c) {},
      verificationFailed: (e) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'خطأ'))),
      codeSent: (verId, _) {
        setState(() { verificationId = verId; showOtp = true; });
      },
      codeAutoRetrievalTimeout: (verId) => verificationId = verId,
    );
  }

  Future<void> verifyOtp() async {
    try {
      final cred = PhoneAuthProvider.credential(verificationId: verificationId!, smsCode: otpController.text);
      final userCred = await FirebaseAuth.instance.signInWithCredential(cred);
      
      // حفظ المستخدم في Firestore
      final appUser = AppUser(
        id: userCred.user!.uid,
        name: nameController.text,
        phone: phoneController.text,
        role: selectedRole,
      );
      await FirebaseFirestore.instance.collection('users').doc(appUser.id).set(appUser.toMap(), SetOptions(merge: true));
      
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MapScreen()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('كود غلط')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('كابتن فلاش', style: TextStyle(color: Color(0xFF00FF88), fontSize: 32, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          TextField(controller: nameController, style: TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'الاسم', labelStyle: TextStyle(color: Colors.white54))),
          TextField(controller: phoneController, style: TextStyle(color: Colors.white), keyboardType: TextInputType.phone, decoration: InputDecoration(labelText: 'رقم الموبايل 01xxxxxxxxx', labelStyle: TextStyle(color: Colors.white54))),
          SizedBox(height: 10),
          Row(children: [
            ChoiceChip(label: Text('عميل'), selected: selectedRole == UserRole.client, onSelected: (_) => setState(() => selectedRole = UserRole.client)),
            SizedBox(width: 10),
            ChoiceChip(label: Text('دليفري'), selected: selectedRole == UserRole.delivery, onSelected: (_) => setState(() => selectedRole = UserRole.delivery)),
          ]),
          SizedBox(height: 20),
          if (!showOtp)
            ElevatedButton(onPressed: sendOtp, style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF00FF88)), child: Text('ابعت كود OTP', style: TextStyle(color: Colors.black))),
          if (showOtp) ...[
            TextField(controller: otpController, style: TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'كود OTP', labelStyle: TextStyle(color: Colors.white54))),
            SizedBox(height: 10),
            ElevatedButton(onPressed: verifyOtp, style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF00FF88)), child: Text('تأكيد ودخول', style: TextStyle(color: Colors.black))),
          ]
        ]),
      ),
    );
  }
}
