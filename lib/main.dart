
// مطعمي AUCTION - النسخة الكاملة الضروري - موافقة + تقييم + حظر + سياسة خصوصية
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'firebase_options.dart';

Future<void> _fcmBg(RemoteMessage m) async { await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform); }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_fcmBg);
  await FirebaseMessaging.instance.requestPermission(alert:true,badge:true,sound:true);
  runApp(const AuctionApp());
}

class AuctionApp extends StatelessWidget { const AuctionApp({super.key}); @override Widget build(BuildContext c)=> MaterialApp(debugShowCheckedModeBanner:false, theme: ThemeData(useMaterial3:true, colorSchemeSeed: Colors.black), home: const Gate()); }
class Gate extends StatelessWidget { const Gate({super.key}); @override Widget build(BuildContext c)=> StreamBuilder<User?>(stream: FirebaseAuth.instance.authStateChanges(), builder:(c,s){ if(s.connectionState==ConnectionState.waiting) return const Scaffold(body: Center(child: CircularProgressIndicator())); if(s.data==null) return const WelcomeAuction(); return const RouterAuction(); }); }
class RouterAuction extends StatefulWidget { const RouterAuction({super.key}); @override State<RouterAuction> createState()=> _RouterAuctionState(); }
class _RouterAuctionState extends State<RouterAuction> { 
  @override void initState(){ super.initState(); _initFCM(); _go(); }
  Future<void> _initFCM() async { try{ String? tok=await FirebaseMessaging.instance.getToken(); if(tok!=null&&FirebaseAuth.instance.currentUser!=null){ await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).update({'fcmToken':tok}); } }catch(e){} }
  Future<void> _go() async { 
    final d=await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get(); 
    if(!mounted) return; 
    final data=d.data();
    if(data==null) return;
    if(data['isBanned']==true){
      await FirebaseAuth.instance.signOut();
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حظر حسابك - تواصل مع الإدارة')));
      return;
    }
    final r=data['role']??'client'; 
    if(r=='client') Navigator.pushReplacement(context, MaterialPageRoute(builder:(_)=> const ClientAuction())); 
    else if(r=='restaurant') Navigator.pushReplacement(context, MaterialPageRoute(builder:(_)=> const RestoAuction())); 
    else if(r=='delivery') Navigator.pushReplacement(context, MaterialPageRoute(builder:(_)=> const DeliveryAuction())); 
    else Navigator.pushReplacement(context, MaterialPageRoute(builder:(_)=> const OwnerAuction())); 
  } 
  @override Widget build(BuildContext c)=> const Scaffold(body: Center(child: CircularProgressIndicator())); 
}

const govs=['القاهرة','الجيزة','الإسكندرية','القليوبية','الشرقية','الغربية','المنوفية','الدقهلية','كفر الشيخ','البحيرة','دمياط','بورسعيد','الإسماعيلية','السويس','الفيوم','بني سويف','المنيا','أسيوط','سوهاج','قنا','الأقصر','أسوان','البحر الأحمر','الوادي الجديد','مطروح','شمال سيناء','جنوب سيناء'];

class WelcomeAuction extends StatelessWidget { const WelcomeAuction({super.key}); @override Widget build(BuildContext c){ return Scaffold(backgroundColor: Colors.black, body: SafeArea(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
  Row(children:[Container(width:56,height:56, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: const Center(child: Text('م',style: TextStyle(fontSize:30,fontWeight: FontWeight.w900)))), const SizedBox(width:12), const Column(crossAxisAlignment: CrossAxisAlignment.start, children:[Text('مطعمي AUCTION',style: TextStyle(fontSize:24,fontWeight: FontWeight.w900,color: Colors.white)), Text('مزاد التوصيل - فكرة جديدة',style: TextStyle(color: Color(0xFFFFD600),fontSize:11,fontWeight: FontWeight.bold))])]),
  const SizedBox(height:16), const Text('أول تطبيق في مصر\nفيه مزاد توصيل',style: TextStyle(fontSize:30,fontWeight: FontWeight.w900,color: Colors.white,height:1.1)),
  const SizedBox(height:12), Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
    Text('🔥 فكرة المزاد الجديدة:',style: TextStyle(color: Color(0xFFFFD600),fontSize:12,fontWeight: FontWeight.bold)),
    SizedBox(height:6),
    Text('• العميل ينزل طلب مزاد',style: TextStyle(color: Colors.white,fontSize:11)),
    Text('• 3 دليفري يزايدوا: واحد يقول 18ج في 20 دقيقة',style: TextStyle(color: Colors.white,fontSize:11)),
    Text('• العميل يختار الأرخص أو الأسرع',style: TextStyle(color: Colors.greenAccent,fontSize:11,fontWeight: FontWeight.bold)),
  ])),
  const Spacer(),
  _btn(c,'عميل - اعمل مزاد واختار أرخص واحد',const LoginAuction(role:'client')),
  const SizedBox(height:8), _btn(c,'دليفري - زايد بسعر ووقت واكسب',const LoginAuction(role:'delivery')),
  const SizedBox(height:8), _btn(c,'صاحب مطعم',const LoginAuction(role:'restaurant')),
  const SizedBox(height:8), _btn(c,'المالك PIN 1234',const LoginAuction(role:'owner')),
  const SizedBox(height:12), TextButton(onPressed: ()=> Navigator.push(c, MaterialPageRoute(builder:(_)=> const PrivacyPage())), child: const Text('سياسة الخصوصية وشروط الاستخدام',style: TextStyle(color: Colors.white54,fontSize:10))),
])))); } Widget _btn(BuildContext c,String t,Widget p)=> InkWell(onTap: ()=> Navigator.push(c, MaterialPageRoute(builder:(_)=> p)), child: Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), child: Row(children:[Expanded(child: Text(t,style: const TextStyle(fontWeight: FontWeight.bold,fontSize:12))), const Icon(Icons.arrow_forward_ios_rounded,size:12)]))); }

class LoginAuction extends StatefulWidget { final String role; const LoginAuction({super.key, required this.role}); @override State<LoginAuction> createState()=> _LoginAuctionState(); }
class _LoginAuctionState extends State<LoginAuction> {
  final e=TextEditingController(), pw=TextEditingController(), n=TextEditingController(), rn=TextEditingController(), ph=TextEditingController(); String gov='القاهرة'; bool isLogin=true, load=false; late String role; Position? restPos;
  @override void initState(){ super.initState(); role=widget.role; }
  Future<void> _pickLoc() async { try{ final perm=await Geolocator.requestPermission(); final p=await Geolocator.getCurrentPosition(); setState(()=> restPos=p); }catch(e){} }
  Future<void> _submit() async {
    if(e.text.isEmpty||pw.text.isEmpty) return; setState(()=> load=true);
    try{
      if(isLogin){
        await FirebaseAuth.instance.signInWithEmailAndPassword(email:e.text.trim(),password:pw.text.trim());
      } else {
        final cred=await FirebaseAuth.instance.createUserWithEmailAndPassword(email:e.text.trim(),password:pw.text.trim());
        final uid=cred.user!.uid;
        final data={'name':n.text.trim(),'email':e.text.trim(),'phone':ph.text.trim(),'role':role,'governorate':gov,'createdAt':FieldValue.serverTimestamp(),'isBanned':false};
        if(role=='restaurant'){
          final restDoc=FirebaseFirestore.instance.collection('restaurants').doc();
          await restDoc.set({'name':rn.text.trim(),'ownerId':uid,'governorate':gov,'lat':restPos?.latitude??30.0444,'lng':restPos?.longitude??31.2357,'isApproved':false,'isBanned':false,'avgRating':0.0,'ratingsCount':0,'createdAt':FieldValue.serverTimestamp()});
          data['restaurantId']=restDoc.id;
        }
        await FirebaseFirestore.instance.collection('users').doc(uid).set(data);
      }
      if(mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder:(_)=> const Gate()), (r)=>false);
    }catch(err){ if(mounted) ScaffoldMessenger.of
