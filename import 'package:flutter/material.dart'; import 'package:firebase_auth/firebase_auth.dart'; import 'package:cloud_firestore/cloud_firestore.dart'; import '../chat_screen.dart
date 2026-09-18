import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  final String orderId;
  ChatScreen({required this.orderId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final msgController = TextEditingController();
  final myId = FirebaseAuth.instance.currentUser!.uid;

  void sendMessage() async {
    if (msgController.text.trim().isEmpty) return;
    await FirebaseFirestore.instance
       .collection('orders').doc(widget.orderId)
       .collection('messages').add({
      'senderId': myId,
      'text': msgController.text.trim(),
      'type': 'text', // text or voice
      'time': FieldValue.serverTimestamp(),
    });
    msgController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Color(0xFF00FF88),
        title: Text('شات الأوردر', style: TextStyle(color: Colors.black)),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                 .collection('orders').doc(widget.orderId)
                 .collection('messages').orderBy('time').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final m = docs[i].data();
                    final isMe = m['senderId'] == myId;
                    return Align(
                      alignment: isMe? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe? Color(0xFF00FF88) : Colors.white24,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          m['text'],
                          style: TextStyle(color: isMe? Colors.black : Colors.white),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Divider(color: Colors.white24),
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: msgController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'اكتب رسالة...',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  onPressed: sendMessage,
                  icon: Icon(Icons.send, color: Color(0xFF00FF88)),
                ),
                // زرار الفويس هنفعله في التحديث الجاي بعد ما ترفع التطبيق
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('الفويس هيشتغل في التحديث الجاي - حاليا شات كتابة')),
                    );
                  },
                  icon: Icon(Icons.mic, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
