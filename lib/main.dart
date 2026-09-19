import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const TawsilaAmanApp());
}

class TawsilaAmanApp extends StatelessWidget {
  const TawsilaAmanApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'توصيلة أمان',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.local_taxi, size: 90, color: Colors.green),
              const Text('توصيلة أمان', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const Text('مصر كلها - آمان وسرعة'),
              const SizedBox(height: 40),
              SizedBox(width: double.infinity, height: 55, child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClientScreen())),
                child: const Text('أنا عميل - أطلب توصيلة', style: TextStyle(color: Colors.white, fontSize: 18)),
              )),
              const SizedBox(height: 12),
              SizedBox(width: double.infinity, height: 55, child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CaptainScreen())),
                child: const Text('أنا كابتن', style: TextStyle(color: Colors.white, fontSize: 18)),
              )),
              const SizedBox(height: 12),
              SizedBox(width: double.infinity, height: 55, child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black87),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OwnerLoginScreen())),
                child: const Text('لوحة المالك', style: TextStyle(color: Colors.white, fontSize: 18)),
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class ClientScreen extends StatefulWidget {
  const ClientScreen({super.key});
  @override
  State<ClientScreen> createState() => _ClientScreenState();
}
class _ClientScreenState extends State<ClientScreen> {
  String selectedType = 'توكتوك';
  double distanceKm = 3.0;
  final Map<String, Map<String, double>> pricing = {
    'توكتوك': {'base': 10, 'km': 5},
    'مكنة': {'base': 10, 'km': 5},
    'دليفري': {'base': 10, 'km': 5},
    'ملاكي عادي': {'base': 25, 'km': 7},
    'ملاكي مكيف': {'base': 30, 'km': 8},
  };
  double get totalPrice => pricing[selectedType]!['base']! + (pricing[selectedType]!['km']! * distanceKm);
  double get commission => totalPrice * 0.15;

  Future<void> requestRide() async {
    Position pos = await Geolocator.getCurrentPosition();
    await FirebaseFirestore.instance.collection('requests').add({
      'type': selectedType, 'distance': distanceKm, 'price': totalPrice,
      'commission': commission, 'lat': pos.latitude, 'lng': pos.longitude,
      'status': 'waiting', 'payment': 'كاش فقط', 'createdAt': FieldValue.serverTimestamp(),
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال الطلب - الكباتن شايفاك!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('طلب توصيلة - كاش فقط')), body: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('اختر نوع التوصيلة:', style: TextStyle(fontWeight: FontWeight.bold)),
        Wrap(spacing: 8, children: pricing.keys.map((type) => ChoiceChip(label: Text(type), selected: selectedType==type, onSelected: (v){ if(v) setState(()=>selectedType=type); })).toList()),
        Text('المسافة: ${distanceKm.toStringAsFixed(1)} كم'),
        Slider(min:1, max:30, value: distanceKm, onChanged: (v)=>setState(()=>distanceKm=v)),
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('البداية: ${pricing[selectedType]!['base']} جنيه + ${pricing[selectedType]!['km']} للكيلو'),
            Text('الإجمالي: ${totalPrice.toStringAsFixed(0)} جنيه - كاش فقط', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
            Text('عمولة 15%: ${commission.toStringAsFixed(0)} جنيه'),
          ]),
        ),
        const Spacer(),
        SizedBox(width: double.infinity, height: 55, child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          onPressed: requestRide,
          child: const Text('اطلب الآن - تتبع مباشر + SOS', style: TextStyle(color: Colors.white, fontSize: 18)),
        )),
      ]),
    ));
  }
}

class CaptainScreen extends StatelessWidget {
  const CaptainScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('الكابتن')), body: StreamBuilder(
      stream: FirebaseFirestore.instance.collection('requests').where('status', isEqualTo: 'waiting').orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if(!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        return ListView.builder(itemCount: docs.length, itemBuilder: (c,i){
          final data = docs[i].data();
          return Card(child: ListTile(title: Text('${data['type']} - ${data['price']} جنيه'), subtitle: Text('${data['distance']} كم'),
            onTap: () => FirebaseFirestore.instance.collection('requests').doc(docs[i].id).update({'status':'accepted'})));
        });
      },
    ));
  }
}

class OwnerLoginScreen extends StatefulWidget {
  const OwnerLoginScreen({super.key});
  @override
  State<OwnerLoginScreen> createState() => _OwnerLoginScreenState();
}
class _OwnerLoginScreenState extends State<OwnerLoginScreen> {
  final ctrl = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('لوحة المالك')), body: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(children: [
        TextField(controller: ctrl, obscureText: true, decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'الباسورد')),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: (){
          if(ctrl.text=='261997') Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> const OwnerPanel()));
        }, child: const Text('دخول'))),
      ]),
    ));
  }
}
class OwnerPanel extends StatelessWidget {
  const OwnerPanel({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('لوحة تحكم المالك')), body: StreamBuilder(
      stream: FirebaseFirestore.instance.collection('requests').orderBy('createdAt', descending: true).snapshots(),
      builder: (c,s){
        if(!s.hasData) return const Center(child: CircularProgressIndicator());
        double total = 0; for(var d in s.data!.docs) total += (d.data()['commission']?? 0).toDouble();
        return Column(children: [
          Container(color: Colors.black87, width: double.infinity, padding: const EdgeInsets.all(16), child: Text('عمولة 15%: ${total.toStringAsFixed(0)} ج\nالطلبات: ${s.data!.docs.length}', style: const TextStyle(color: Colors.white))),
          Expanded(child: ListView.builder(itemCount: s.data!.docs.length, itemBuilder: (c,i){ final data = s.data!.docs[i].data(); return ListTile(title: Text('${data['type']} - ${data['price']} ج')); })),
        ]);
      },
    ));
  }
}
