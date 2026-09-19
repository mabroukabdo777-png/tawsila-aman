import 'package:firebase_database/firebase_database.dart';
class FirebaseService { final db = FirebaseDatabase.instanceFor(app: null, databaseURL: 'https://soqshpin-default-rtdb.firebaseio.com').ref(); }
