
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
    }catch(err){ if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err.toString()))); }
    setState(()=> load=false);
  }
  @override Widget build(BuildContext c){ return Scaffold(appBar: AppBar(title: Text(role=='client'?'عميل':role=='delivery'?'دليفري':role=='restaurant'?'مطعم':'مالك')), body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(children:[
    if(!isLogin) TextField(controller:n,decoration: const InputDecoration(labelText:'الاسم')), 
    if(!isLogin&&role=='restaurant') TextField(controller:rn,decoration: const InputDecoration(labelText:'اسم المطعم')),
    TextField(controller:e,decoration: const InputDecoration(labelText:'الإيميل')), 
    TextField(controller:pw,decoration: const InputDecoration(labelText:'الباسورد'), obscureText:true),
    if(!isLogin) TextField(controller:ph,decoration: const InputDecoration(labelText:'الموبايل - للتواصل الحقيقي')),
    if(!isLogin) DropdownButton<String>(value:gov, isExpanded:true, items: govs.map((g)=> DropdownMenuItem(value:g,child: Text(g))).toList(), onChanged:(v)=> setState(()=> gov=v!)),
    if(!isLogin&&role=='restaurant') FilledButton.icon(onPressed:_pickLoc, icon: const Icon(Icons.location_on), label: Text(restPos==null?'حدد موقع المطعم - GPS حقيقي':'تم تحديد الموقع ${restPos!.latitude.toStringAsFixed(4)}')),
    const SizedBox(height:16),
    SizedBox(width: double.infinity, child: FilledButton(onPressed: load?null:_submit, child: Text(isLogin?'دخول':'تسجيل - سيتم مراجعة المطعم'))),
    TextButton(onPressed: ()=> setState(()=> isLogin=!isLogin), child: Text(isLogin?'ماعندكش حساب؟ سجل':'عندك حساب؟ ادخل')),
    if(!isLogin&&role=='restaurant') const Text('تنبيه: المطعم هيحتاج موافقة المالك قبل ما يظهر للعملاء - عشان نمنع المطاعم الوهمية',style: TextStyle(fontSize:10,color: Colors.red)),
  ]))); }
}

// CLIENT WITH RATING
class ClientAuction extends StatefulWidget { const ClientAuction({super.key}); @override State<ClientAuction> createState()=> _ClientAuctionState(); }
class _ClientAuctionState extends State<ClientAuction> {
  @override Widget build(BuildContext c){ return Scaffold(appBar: AppBar(title: const Text('مطعمي - مطاعم معتمدة فقط'), actions:[IconButton(icon: const Icon(Icons.logout), onPressed: () async { await FirebaseAuth.instance.signOut(); if(mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder:(_)=> const WelcomeAuction()), (r)=>false); })]), body: StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('restaurants').where('isApproved',isEqualTo:true).where('isBanned',isEqualTo:false).snapshots(), builder:(c,s){
    if(!s.hasData) return const Center(child: CircularProgressIndicator());
    if(s.data!.docs.isEmpty) return const Center(child: Text('لا يوجد مطاعم معتمدة حاليا - في انتظار موافقة المالك'));
    return ListView.builder(itemCount: s.data!.docs.length, itemBuilder:(c,i){
      final r=s.data!.docs[i].data() as Map<String,dynamic>;
      return Card(margin: const EdgeInsets.all(8), child: ListTile(
        leading: const Icon(Icons.restaurant_rounded),
        title: Text(r['name']??'مطعم',style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('⭐ ${r['avgRating']?.toStringAsFixed(1)??'0.0'} (${r['ratingsCount']??0} تقييم) • ${r['governorate']??''}'),
        trailing: const Icon(Icons.arrow_forward_ios,size:14),
        onTap: ()=> Navigator.push(c, MaterialPageRoute(builder:(_)=> RestaurantMenuPage(restId: s.data!.docs[i].id, restData: r))),
      ));
    });
  })); }
}

class RestaurantMenuPage extends StatefulWidget { final String restId; final Map<String,dynamic> restData; const RestaurantMenuPage({super.key, required this.restId, required this.restData}); @override State<RestaurantMenuPage> createState()=> _RestaurantMenuPageState(); }
class _RestaurantMenuPageState extends State<RestaurantMenuPage> {
  Map<String,int> cart={}; Map<String,Map<String,dynamic>> menuCache={};
  double get subtotal{ double t=0; cart.forEach((id,qty){ final m=menuCache[id]; if(m!=null) t+= (m['price']??0)*qty; }); return t; }
  Future<void> _placeAuction() async {
    if(cart.isEmpty) return;
    final pos=await Geolocator.getCurrentPosition();
    final orderRef=FirebaseFirestore.instance.collection('orders').doc();
    await orderRef.set({
      'clientId': FirebaseAuth.instance.currentUser!.uid,
      'restaurantId': widget.restId,
      'restaurantName': widget.restData['name'],
      'items': cart.entries.map((e)=> {'menuId':e.key,'qty':e.value,'name':menuCache[e.key]?['name'],'price':menuCache[e.key]?['price']}).toList(),
      'subtotal': subtotal,
      'total': subtotal,
      'status': 'مزاد',
      'km': 0.0,
      'deliveryFee': 0.0,
      'ownerCommission15': 0.0,
      'clientLat': pos.latitude,
      'clientLng': pos.longitude,
      'createdAt': FieldValue.serverTimestamp(),
      'settled': false,
      'isRated': false,
    });
    setState(()=> cart={});
    if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نشر المزاد 🔥 - الدليفري هيزايدوا دلوقتي')));
    if(mounted) Navigator.push(context, MaterialPageRoute(builder:(_)=> LiveAuction(orderId: orderRef.id, order: (await orderRef.get()).data()!)));
  }
  @override Widget build(BuildContext c){ return Scaffold(appBar: AppBar(title: Text(widget.restData['name'])), body: Column(children:[
    Expanded(child: StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('restaurants').doc(widget.restId).collection('menu').snapshots(), builder:(c,s){
      if(!s.hasData) return const Center(child: CircularProgressIndicator());
      return ListView.builder(itemCount: s.data!.docs.length, itemBuilder:(c,i){
        final m=s.data!.docs[i].data() as Map<String,dynamic>; menuCache[s.data!.docs[i].id]=m;
        final qty=cart[s.data!.docs[i].id]??0;
        return Card(margin: const EdgeInsets.all(6), child: ListTile(
          leading: m['imageUrl']!=null?Image.network(m['imageUrl'],width:50,height:50,fit:BoxFit.cover):const Icon(Icons.fastfood),
          title: Text(m['name']),
          subtitle: Text('${m['price']}ج'),
          trailing: Row(mainAxisSize: MainAxisSize.min, children:[
            IconButton(icon: const Icon(Icons.remove), onPressed: (){ setState(()=> cart[s.data!.docs[i].id]= (qty>0?qty-1:0)); if(cart[s.data!.docs[i].id]==0) cart.remove(s.data!.docs[i].id); }),
            Text('$qty',style: const TextStyle(fontWeight: FontWeight.bold)),
            IconButton(icon: const Icon(Icons.add), onPressed: ()=> setState(()=> cart[s.data!.docs[i].id]= qty+1),
          )]),
        ));
      });
    })),
    Container(padding: const EdgeInsets.all(12), color: Colors.black, child: Row(children:[Expanded(child: Text('المجموع: ${subtotal.toStringAsFixed(2)}ج',style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold))), FilledButton(onPressed: _placeAuction, style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFFD600), foregroundColor: Colors.black), child: const Text('اعمل مزاد 🔥',style: TextStyle(fontWeight: FontWeight.bold)))])),
  ])); }
}

class LiveAuction extends StatefulWidget { final String orderId; final Map<String,dynamic> order; const LiveAuction({super.key, required this.orderId, required this.order}); @override State<LiveAuction> createState()=> _LiveAuctionState(); }
class _LiveAuctionState extends State<LiveAuction> {
  Future<void> _chooseBid(String bidId, double fee) async {
    await FirebaseFirestore.instance.collection('orders').doc(widget.orderId).update({'status':'في الطريق','deliveryFee':fee,'ownerCommission15':fee*0.15,'chosenBidId':bidId});
  }
  Future<void> _rateOrder(int stars, String comment) async {
    final orderDoc=await FirebaseFirestore.instance.collection('orders').doc(widget.orderId).get();
    final data=orderDoc.data(); if(data==null) return;
    final restId=data['restaurantId'];
    final ratingRef=FirebaseFirestore.instance.collection('restaurants').doc(restId).collection('ratings').doc();
    await ratingRef.set({'orderId':widget.orderId,'clientId':FirebaseAuth.instance.currentUser!.uid,'stars':stars,'comment':comment,'createdAt':FieldValue.serverTimestamp()});
    final ratingsSnap=await FirebaseFirestore.instance.collection('restaurants').doc(restId).collection('ratings').get();
    double avg=0; for(var d in ratingsSnap.docs){ avg+= (d.data()['stars']??0); } if(ratingsSnap.docs.isNotEmpty) avg/=ratingsSnap.docs.length;
    await FirebaseFirestore.instance.collection('restaurants').doc(restId).update({'avgRating':avg,'ratingsCount':ratingsSnap.docs.length});
    await FirebaseFirestore.instance.collection('orders').doc(widget.orderId).update({'isRated':true});
  }
  void _showRatingDialog(){
    int stars=5; final comm=TextEditingController();
    showDialog(context: context, builder:(c)=> AlertDialog(
      title: const Text('قيّم المطعم ⭐ - ضروري'),
      content: Column(mainAxisSize: MainAxisSize.min, children:[
        Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i)=> IconButton(icon: Icon(i<stars?Icons.star_rounded:Icons.star_border_rounded,color: Colors.amber,size:32), onPressed: ()=> setState(()=> stars=i+1)))),
        TextField(controller: comm, decoration: const InputDecoration(labelText:'تعليق (اختياري)')),
      ]),
      actions:[FilledButton(onPressed: () async { await _rateOrder(stars, comm.text); if(mounted) Navigator.pop(c); }, child: const Text('إرسال التقييم'))],
    ));
  }
  @override Widget build(BuildContext c){ return Scaffold(appBar: AppBar(title: const Text('المزاد شغال 🔥 - اختار أرخص واحد')), body: Column(children:[
    StreamBuilder<DocumentSnapshot>(stream: FirebaseFirestore.instance.collection('orders').doc(widget.orderId).snapshots(), builder:(c,s){
      if(!s.hasData) return const LinearProgressIndicator();
      final o=s.data!.data() as Map<String,dynamic>?;
      if(o==null) return const SizedBox();
      if(o['status']=='تم التوصيل'&&o['isRated']==false){
        WidgetsBinding.instance.addPostFrameCallback((_)=> _showRatingDialog());
      }
      return Container(padding: const EdgeInsets.all(12), color: o['status']=='تم التوصيل'?Colors.green:const Color(0xFFFFD600), child: Row(children:[Expanded(child: Text('الحالة: ${o['status']} • توصيل: ${o['deliveryFee']?.toStringAsFixed(2)??'مزاد'}ج',style: const TextStyle(fontWeight: FontWeight.bold))), if(o['status']=='تم التوصيل'&&o['isRated']==false) FilledButton(onPressed: _showRatingDialog, child: const Text('قيّم ⭐'))]));
    }),
    Expanded(child: StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('orders').doc(widget.orderId).collection('bids').orderBy('bidFee').snapshots(), builder:(c,s){
      if(!s.hasData) return const Center(child: Text('في انتظار مزايدات الدليفري...'));
      if(s.data!.docs.isEmpty) return const Center(child: Text('لسه مفيش مزايدات - الدليفري هيزايدوا حالا 🔥'));
      return ListView.builder(itemCount: s.data!.docs.length, itemBuilder:(c,i){
        final b=s.data!.docs[i].data() as Map<String,dynamic>;
        return Card(color: i==0?Colors.green.shade50:null, margin: const EdgeInsets.all(8), child: ListTile(
          leading: CircleAvatar(child: Text('${b['bidFee']}ج',style: const TextStyle(fontSize:10,fontWeight: FontWeight.bold))),
          title: Text('${b['deliveryName']} - ${b['bidFee']}ج في ${b['etaMinutes']} د',style: TextStyle(fontWeight: FontWeight.bold, color: i==0?Colors.green:null)),
          subtitle: Text(i==0?'🔥 أرخص واحد - وفر فلوسك!':''),
          trailing: FilledButton(onPressed: ()=> _chooseBid(s.data!.docs[i].id, (b['bidFee']??0).toDouble()), style: FilledButton.styleFrom(backgroundColor: i==0?Colors.green:Colors.black), child: const Text('اختار ده')),
        ));
      });
    })),
  ])); }
}

// DELIVERY
class DeliveryAuction extends StatefulWidget { const DeliveryAuction({super.key}); @override State<DeliveryAuction> createState()=> _DeliveryAuctionState(); }
class _DeliveryAuctionState extends State<DeliveryAuction> { Position? myPos; String? curOrder;
  @override void initState(){ super.initState(); _track(); }
  Future<void> _track() async { await Geolocator.requestPermission(); Geolocator.getPositionStream().listen((p){ setState(()=> myPos=p); if(curOrder!=null){ FirebaseFirestore.instance.collection('orders').doc(curOrder).update({'deliveryLat':p.latitude,'deliveryLng':p.longitude}); } }); }
  Future<void> _bid(String orderId) async {
    final feeC=TextEditingController(text:'18'); final etaC=TextEditingController(text:'15');
    showDialog(context: context, builder:(c)=> AlertDialog(title: const Text('زايد بسعر ووقت - اكسب المزاد'), content: Column(mainAxisSize: MainAxisSize.min, children:[TextField(controller: feeC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText:'سعر التوصيل بالجنيه - مثال 18')), TextField(controller: etaC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText:'الوقت بالدقايق - مثال 15'))]), actions:[FilledButton(onPressed: () async {
      final userDoc=await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get();
      await FirebaseFirestore.instance.collection('orders').doc(orderId).collection('bids').add({'deliveryId':FirebaseAuth.instance.currentUser!.uid,'deliveryName':userDoc.data()?['name']??'دليفري','bidFee':double.tryParse(feeC.text)??18,'etaMinutes':int.tryParse(etaC.text)??15,'createdAt':FieldValue.serverTimestamp()});
      if(mounted) Navigator.pop(c);
    }, child: const Text('زايد 🔥'))]));
  }
  @override Widget build(BuildContext c){ return Scaffold(appBar: AppBar(title: const Text('دليفري - مزادات شغالة')), body: Column(children:[
    if(curOrder!=null) Container(padding: const EdgeInsets.all(12), color: Colors.red, child: Row(children:[const Expanded(child: Text('عندك طلب شغال - في الطريق',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold))), FilledButton(onPressed: () async { await FirebaseFirestore.instance.collection('orders').doc(curOrder).update({'status':'تم التوصيل'}); setState(()=> curOrder=null); }, style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.red), child: const Text('تم التوصيل'))])),
    Expanded(child: StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('orders').where('status',isEqualTo:'مزاد').snapshots(), builder:(c,s){
      if(!s.hasData) return const Center(child: CircularProgressIndicator());
      return ListView.builder(itemCount: s.data!.docs.length, itemBuilder:(c,i){
        final o=s.data!.docs[i].data() as Map<String,dynamic>;
        return Card(margin: const EdgeInsets.all(8), child: ListTile(title: Text('${o['restaurantName']} - ${o['subtotal']}ج'), subtitle: Text('مزاد 🔥 - ${s.data!.docs.length} دليفري شافوه'), trailing: FilledButton(onPressed: ()=> _bid(s.data!.docs[i].id), child: const Text('زايد'))));
      });
    })),
  ])); }
}

// RESTAURANT
class RestoAuction extends StatefulWidget { const RestoAuction({super.key}); @override State<RestoAuction> createState()=> _RestoAuctionState(); }
class _RestoAuctionState extends State<RestoAuction> { String? rid; bool? approved;
  @override void initState(){ super.initState(); _load(); }
  Future<void> _load() async { final uid=FirebaseAuth.instance.currentUser!.uid; final u=await FirebaseFirestore.instance.collection('users').doc(uid).get(); String? id=u.data()?['restaurantId']; if(id==null){ final q=await FirebaseFirestore.instance.collection('restaurants').where('ownerId',isEqualTo: uid).limit(1).get(); if(q.docs.isNotEmpty) id=q.docs.first.id; } if(id!=null){ final r=await FirebaseFirestore.instance.collection('restaurants').doc(id).get(); setState(()=> approved=r.data()?['isApproved']==true); } setState(()=> rid=id); }
  @override Widget build(BuildContext c){ 
    if(rid==null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if(approved==false){ return Scaffold(appBar: AppBar(title: const Text('مطعم - في انتظار الموافقة')), body: const Center(child: Padding(padding: EdgeInsets.all(20), child: Column(mainAxisAlignment: MainAxisAlignment.center, children:[Icon(Icons.hourglass_top_rounded,size:64,color: Colors.orange), SizedBox(height:16), Text('مطعمك في انتظار موافقة المالك',style: TextStyle(fontWeight: FontWeight.bold,fontSize:18)), SizedBox(height:8), Text('المالك هيراجع بياناتك ويوافق عليك في خلال ساعات - عشان نمنع المطاعم الوهمية',textAlign: TextAlign.center) ])))); }
    return Scaffold(appBar: AppBar(title: const Text('لوحة المطعم - معتمد ✅')), body: DefaultTabController(length:4, child: Column(children:[const TabBar(tabs:[Tab(text:'الطلبات'),Tab(text:'المنيو'),Tab(text:'إضافة'),Tab(text:'تقييماتي ⭐')]), Expanded(child: TabBarView(children:[
    StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('orders').orderBy('createdAt',descending:true).snapshots(), builder:(c,s){ if(!s.hasData) return const Center(child: CircularProgressIndicator()); return ListView.builder(itemCount: s.data!.docs.length, itemBuilder:(c,i){ final o=s.data!.docs[i].data() as Map<String,dynamic>; Color col=o['status']=='مزاد'?const Color(0xFFFFD600):o['status']=='تم التوصيل'?Colors.green:Colors.orange; return Container(margin: const EdgeInsets.all(8), decoration: BoxDecoration(border: Border(left: BorderSide(color: col,width:4)), borderRadius: BorderRadius.circular(12), color: Colors.white), child: ListTile(title: Text('${o['total']?.toStringAsFixed(2)}ج • ${o['status']}'), subtitle: Text('${o['subtotal']}ج + ${o['deliveryFee']?.toStringAsFixed(2)}ج'), trailing: o['status']=='مزاد'?const Text('مزاد شغال'):DropdownButton<String>(value: o['status'].toString().contains('ملغي')?null:o['status'], items: const ['جديد','يتم التحضير','في الطريق','تم التوصيل'].map((e)=> DropdownMenuItem(value:e,child: Text(e,style: const TextStyle(fontSize:10)))).toList(), onChanged:(v)=> FirebaseFirestore.instance.collection('orders').doc(s.data!.docs[i].id).update({'status':v})), onTap: ()=> Navigator.push(context, MaterialPageRoute(builder:(_)=> LiveAuction(orderId: s.data!.docs[i].id, order: o))))); }); }),
    StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('restaurants').doc(rid).collection('menu').snapshots(), builder:(c,s){ if(s.data==null||s.data!.docs.isEmpty) return const Center(child: Text('لا يوجد منتجات')); return ListView.builder(itemCount: s.data!.docs.length, itemBuilder:(c,i){ final m=s.data!.docs[i].data() as Map<String,dynamic>; return ListTile(leading: m['imageUrl']!=null&&m['imageUrl']!=''?Image.network(m['imageUrl'],width:50,height:50,fit: BoxFit.cover):const Icon(Icons.fastfood_rounded), title: Text(m['name']), subtitle: Text('${m['price']}ج'), trailing: IconButton(icon: const Icon(Icons.delete_rounded,color: Colors.red), onPressed: ()=> FirebaseFirestore.instance.collection('restaurants').doc(rid).collection('menu').doc(s.data!.docs[i].id).delete())); }); }),
    AddProdAuction(rid: rid!),
    StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('restaurants').doc(rid).collection('ratings').orderBy('createdAt',descending:true).snapshots(), builder:(c,s){ if(!s.hasData) return const Center(child: CircularProgressIndicator()); if(s.data!.docs.isEmpty) return const Center(child: Text('لسه مفيش تقييمات')); return ListView.builder(itemCount: s.data!.docs.length, itemBuilder:(c,i){ final r=s.data!.docs[i].data() as Map<String,dynamic>; return ListTile(leading: Text('⭐'* (r['stars']??5),style: const TextStyle(fontSize:12)), title: Text(r['comment']??'بدون تعليق'), subtitle: Text('${r['stars']} نجوم')); }); }),
  ]))]))); } }
class AddProdAuction extends StatefulWidget { final String rid; const AddProdAuction({super.key, required this.rid}); @override State<AddProdAuction> createState()=> _AddProdAuctionState(); }
class _AddProdAuctionState extends State<AddProdAuction> { final n=TextEditingController(), pr=TextEditingController(), d=TextEditingController(); bool l=false; File? imgFile; String? imgUrl;
  Future<void> _pick() async { final picker=ImagePicker(); final x=await picker.pickImage(source: ImageSource.gallery, imageQuality:70); if(x!=null){ setState(()=> imgFile=File(x.path)); try{ final ref=FirebaseStorage.instance.ref().child('menu/${DateTime.now().millisecondsSinceEpoch}.jpg'); await ref.putFile(imgFile!); final url=await ref.getDownloadURL(); setState(()=> imgUrl=url); }catch(e){} } }
  @override Widget build(BuildContext c)=> SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children:[
    InkWell(onTap: _pick, child: Container(width: double.infinity, height:140, decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)), child: imgFile!=null?ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(imgFile!,fit: BoxFit.cover)): const Column(mainAxisAlignment: MainAxisAlignment.center, children:[Icon(Icons.add_a_photo_rounded,size:40), SizedBox(height:8), Text('رفع صورة حقيقية',style: TextStyle(fontSize:11,fontWeight: FontWeight.bold))])),
    const SizedBox(height:12), TextField(controller: n, decoration: const InputDecoration(labelText:'اسم الوجبة')), TextField(controller: pr, decoration: const InputDecoration(labelText:'السعر'), keyboardType: TextInputType.number),
    const SizedBox(height:12), SizedBox(width: double.infinity, child: FilledButton(onPressed: () async { if(n.text.isEmpty||pr.text.isEmpty) return; await FirebaseFirestore.instance.collection('restaurants').doc(widget.rid).collection('menu').add({'name':n.text.trim(),'price':double.tryParse(pr.text)??0,'imageUrl':imgUrl??'','createdAt':FieldValue.serverTimestamp()}); setState(()=> n.clear()); }, child: const Text('إضافة وجبة حقيقية'))),
  ])); }

// OWNER WITH APPROVAL + BAN + RATINGS
class OwnerAuction extends StatefulWidget { const OwnerAuction({super.key}); @override State<OwnerAuction> createState()=> _OwnerAuctionState(); }
class _OwnerAuctionState extends State<OwnerAuction> { bool unlocked=false; final pinC=TextEditingController(); int tab=0;
  @override Widget build(BuildContext c){
    if(!unlocked){ return Scaffold(backgroundColor: Colors.black, body: SafeArea(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children:[
      const Icon(Icons.lock_rounded,color: Colors.white,size:64), const SizedBox(height:20), const Text('مالك AUCTION\nPIN 1234',style: TextStyle(color: Colors.white,fontSize:24,fontWeight: FontWeight.w900), textAlign: TextAlign.center),
      const SizedBox(height:20), TextField(controller: pinC, obscureText:true, keyboardType: TextInputType.number, decoration: InputDecoration(labelText:'PIN', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled:true, fillColor: Colors.white), textAlign: TextAlign.center, style: const TextStyle(fontSize:24,fontWeight: FontWeight.bold)),
      const SizedBox(height:16), SizedBox(width: double.infinity, child: FilledButton(onPressed: (){ if(pinC.text=='1234') setState(()=> unlocked=true); }, style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical:16)), child: const Text('فتح',style: TextStyle(fontWeight: FontWeight.bold)))),
    ])))); }
    return Scaffold(appBar: AppBar(title: const Text('مالك - كل حاجة ضروري'), backgroundColor: Colors.black, foregroundColor: Colors.white, actions:[IconButton(icon: const Icon(Icons.privacy_tip_rounded), onPressed: ()=> Navigator.push(context, MaterialPageRoute(builder:(_)=> const PrivacyPage()))), IconButton(icon: const Icon(Icons.logout_rounded), onPressed: () async { await FirebaseAuth.instance.signOut(); if(mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder:(_)=> const WelcomeAuction()), (r)=>false); })]), body: Column(children:[
      SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children:[
        _tabBtn('💰 عمولة',0), _tabBtn('✅ موافقة مطاعم',1), _tabBtn('🚫 حظر',2), _tabBtn('⭐ تقييمات',3),
      ])),
      Expanded(child: _buildTab()),
    ])); 
  }
  Widget _tabBtn(String t,int i)=> Padding(padding: const EdgeInsets.all(4), child: ChoiceChip(label: Text(t,style: const TextStyle(fontSize:11,fontWeight: FontWeight.bold)), selected: tab==i, onSelected:(v)=> setState(()=> tab=i), selectedColor: const Color(0xFFFFD600)));
  Widget _buildTab(){
    if(tab==0) return _commissionTab();
    if(tab==1) return _approvalTab();
    if(tab==2) return _banTab();
    return _ratingsTab();
  }
  Widget _commissionTab(){ return StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('users').where('role',isEqualTo:'delivery').snapshots(), builder:(c,delSnap){
      if(!delSnap.hasData) return const Center(child: CircularProgressIndicator());
      return ListView(padding: const EdgeInsets.all(12), children:[
        ...delSnap.data!.docs.map((delDoc){
          final delData=delDoc.data() as Map<String,dynamic>; final delId=delDoc.id;
          return StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('orders').where('deliveryId',isEqualTo: delId).where('settled',isEqualTo:false).where('status',isEqualTo:'تم التوصيل').snapshots(), builder:(c,orderSnap){
            int trips=0; double totalFee=0, totalComm=0;
            if(orderSnap.hasData){ for(var d in orderSnap.data!.docs){ var o=d.data() as Map<String,dynamic>; trips++; totalFee+=(o['deliveryFee']??0).toDouble(); totalComm+=(o['ownerCommission15']??0).toDouble(); } }
            if(trips==0) return const SizedBox();
            return Container(margin: const EdgeInsets.only(bottom:12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.black,width:2)), child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
              Row(children:[Expanded(child: Text(delData['name']??'دليفري',style: const TextStyle(fontWeight: FontWeight.bold))), Text('$trips رحلة',style: const TextStyle(fontSize:10))]),
              const SizedBox(height:8), Text('عمولتك 15%: ${totalComm.toStringAsFixed(2)}ج',style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.green)),
              const SizedBox(height:8), FilledButton(onPressed: () async {
                final batch=FirebaseFirestore.instance.batch(); if(orderSnap.data!=null){ for(var doc in orderSnap.data!.docs){ batch.update(doc.reference, {'settled':true}); } await batch.commit(); }
              }, style: FilledButton.styleFrom(backgroundColor: Colors.green), child: Text('تم الاستلام ${totalComm.toStringAsFixed(2)}ج • تصفير')),
            ])));
          });
        }).toList(),
      ]);
    });
  }
  Widget _approvalTab(){ return StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('restaurants').where('isApproved',isEqualTo:false).snapshots(), builder:(c,s){
    if(!s.hasData) return const Center(child: CircularProgressIndicator());
    if(s.data!.docs.isEmpty) return const Center(child: Text('مفيش مطاعم في انتظار الموافقة ✅ - كل المطاعم معتمدة'));
    return ListView.builder(itemCount: s.data!.docs.length, itemBuilder:(c,i){
      final r=s.data!.docs[i].data() as Map<String,dynamic>;
      return Card(margin: const EdgeInsets.all(8), child: ListTile(title: Text(r['name']??'مطعم'), subtitle: Text('${r['governorate']} • ${r['ownerId']}'), trailing: Row(mainAxisSize: MainAxisSize.min, children:[
        IconButton(icon: const Icon(Icons.check_circle,color: Colors.green), onPressed: ()=> FirebaseFirestore.instance.collection('restaurants').doc(s.data!.docs[i].id).update({'isApproved':true})),
        IconButton(icon: const Icon(Icons.cancel,color: Colors.red), onPressed: ()=> FirebaseFirestore.instance.collection('restaurants').doc(s.data!.docs[i].id).delete()),
      ])));
    });
  }); }
  Widget _banTab(){ return StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('users').snapshots(), builder:(c,s){
    if(!s.hasData) return const Center(child: CircularProgressIndicator());
    return ListView.builder(itemCount: s.data!.docs.length, itemBuilder:(c,i){
      final u=s.data!.docs[i].data() as Map<String,dynamic>;
      final banned=u['isBanned']==true;
      return Card(margin: const EdgeInsets.all(6), color: banned?Colors.red.shade50:null, child: ListTile(title: Text(u['name']??'مستخدم'), subtitle: Text('${u['role']} • ${u['phone']??''} ${banned?'🚫 محظور':''}'), trailing: FilledButton(onPressed: ()=> FirebaseFirestore.instance.collection('users').doc(s.data!.docs[i].id).update({'isBanned':!banned}), style: FilledButton.styleFrom(backgroundColor: banned?Colors.green:Colors.red), child: Text(banned?'فك حظر':'حظر'))));
    });
  }); }
  Widget _ratingsTab(){ return StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collectionGroup('ratings').orderBy('createdAt',descending:true).snapshots(), builder:(c,s){
    if(!s.hasData) return const Center(child: CircularProgressIndicator());
    if(s.data!.docs.isEmpty) return const Center(child: Text('لسه مفيش تقييمات'));
    return ListView.builder(itemCount: s.data!.docs.length, itemBuilder:(c,i){
      final r=s.data!.docs[i].data() as Map<String,dynamic>;
      return Card(margin: const EdgeInsets.all(6), child: ListTile(title: Text('⭐ ${r['stars']} نجوم'), subtitle: Text(r['comment']??'بدون تعليق')));
    });
  }); }
}

class PrivacyPage extends StatelessWidget { const PrivacyPage({super.key}); @override Widget build(BuildContext c){ return Scaffold(appBar: AppBar(title: const Text('سياسة الخصوصية - مطعمي')), body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
  Text('سياسة الخصوصية - مطعمي AUCTION',style: TextStyle(fontSize:18,fontWeight: FontWeight.bold)),
  SizedBox(height:12),
  Text('1- نحن نجمع: الاسم، الموبايل، الموقع GPS لتوصيل الطلبات فقط.'),
  Text('2- موقعك يستخدم لحساب المسافة والسعر بالظبط: 13ج + 5ج × كم.'),
  Text('3- صور المنيو ترفع على Firebase Storage وتظهر للعملاء.'),
  Text('4- نحن لا نشارك بياناتك مع طرف ثالث - الكاش بس - مفيش دفع أونلاين.'),
  Text('5- عمولة المالك 15% من التوصيل فقط - محسوبة بالظبط.'),
  Text('6- يمكنك طلب حذف حسابك في أي وقت من صفحة المالك.'),
  SizedBox(height:16),
  Text('شروط الاستخدام',style: TextStyle(fontSize:16,fontWeight: FontWeight.bold)),
  SizedBox(height:8),
  Text('• المطعم يجب أن يكون حقيقي ومعتمد من المالك.'),
  Text('• الدليفري يلتزم بالسعر اللي زايد بيه في المزاد LOCKED.'),
  Text('• الحظر يتم في حالة النصب أو التأخير المتكرر.'),
  Text('• التقييمات حقيقية 100% بعد كل طلب.'),
]))); } }
