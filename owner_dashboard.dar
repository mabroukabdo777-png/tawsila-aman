import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OwnerDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Color(0xFF00FF88),
        title: Text('لوحة المالك - الشيكات', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'delivery').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator(color: Color(0xFF00FF88)));
          
          final deliveries = snapshot.data!.docs;
          double totalCommission = 0;
          
          return Column(
            children: [
              // ملخص عام
              FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance.collectionGroup('items').get(),
                builder: (context, checksSnap) {
                  double totalPrice = 0;
                  double totalComm = 0;
                  int totalTrips = 0;
                  if (checksSnap.hasData) {
                    for (var d in checksSnap.data!.docs) {
                      totalPrice += (d['price'] ?? 0).toDouble();
                      totalComm += (d['commission'] ?? 0).toDouble();
                      totalTrips++;
                    }
                  }
                  return Container(
                    color: Colors.white10,
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _stat('إجمالي الرحلات', '$totalTrips'),
                        _stat('إجمالي المبيعات', '${totalPrice.toStringAsFixed(0)} ج'),
                        _stat('عمولتك (10%/15%)', '${totalComm.toStringAsFixed(0)} ج', isGreen: true),
                      ],
                    ),
                  );
                },
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: deliveries.length,
                  itemBuilder: (context, i) {
                    final d = deliveries[i].data() as Map<String, dynamic>;
                    return Card(
                      color: Colors.white12,
                      margin: EdgeInsets.all(8),
                      child: ExpansionTile(
                        title: Text('${d['name']} - ${d['rank'] ?? 'delivery'}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text('الرحلات: ${d['totalTrips'] ?? 0} - الكيلوات: ${(d['totalKm'] ?? 0).toStringAsFixed(1)} - أرباحه: ${(d['totalEarnings'] ?? 0).toStringAsFixed(0)} ج', style: TextStyle(color: Colors.white70)),
                        children: [
                          StreamBuilder(
                            stream: FirebaseFirestore.instance.collection('checks').doc(d['id']).collection('items').orderBy('date', descending: true).snapshots(),
                            builder: (context, checks) {
                              if (!checks.hasData) return CircularProgressIndicator();
                              return Column(
                                children: checks.data!.docs.map((check) {
                                  final c = check.data() as Map<String, dynamic>;
                                  return ListTile(
                                    title: Text('${c['distanceKm'].toStringAsFixed(2)} كم - السعر: ${c['price'].toStringAsFixed(0)} ج', style: TextStyle(color: Colors.white)),
                                    subtitle: Text('الرتبة: ${c['rank']} - النسبة: ${(c['commissionRate']*100).toInt()}% - عمولتك: ${c['commission'].toStringAsFixed(0)} ج', style: TextStyle(color: Colors.white54)),
                                    trailing: Text('${c['driverEarning'].toStringAsFixed(0)} ج للطيار', style: TextStyle(color: Color(0xFF00FF88))),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _stat(String title, String value, {bool isGreen = false}) {
    return Column(children: [
      Text(title, style: TextStyle(color: Colors.white54, fontSize: 12)),
      SizedBox(height: 4),
      Text(value, style: TextStyle(color: isGreen? Color(0xFF00FF88) : Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
    ]);
  }
}
