import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/inventory_item.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<InventoryItem>> getInventoryItems() {
    return _db.collection('inventory').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => InventoryItem.fromFirestore(doc)).toList());
  }
}
