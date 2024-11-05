import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryHomePage extends StatefulWidget {
  @override
  _InventoryHomePageState createState() => _InventoryHomePageState();
}

class _InventoryHomePageState extends State<InventoryHomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Inventory Management")),
      body: StreamBuilder(
        stream: _firestore.collection('inventory').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var item = snapshot.data!.docs[index];
              return ListTile(
                title: Text(item['itemName']),
                subtitle: Text("Quantity: ${item['quantity']}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _editItem(context, item),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteItem(item.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addItem(context),
        tooltip: 'Add Item',
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> _addItem(BuildContext context) async {
    TextEditingController nameController = TextEditingController();
    TextEditingController quantityController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add New Item"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: "Item Name")),
            TextField(controller: quantityController, decoration: InputDecoration(labelText: "Quantity")),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty && quantityController.text.isNotEmpty) {
                await _firestore.collection('inventory').add({
                  'itemName': nameController.text,
                  'quantity': int.parse(quantityController.text),
                });
                Navigator.pop(context);
              }
            },
            child: Text("Add"),
          ),
        ],
      ),
    );
  }

  Future<void> _editItem(BuildContext context, QueryDocumentSnapshot item) async {
    TextEditingController nameController = TextEditingController(text: item['itemName']);
    TextEditingController quantityController = TextEditingController(text: item['quantity'].toString());
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Item"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: "Item Name")),
            TextField(controller: quantityController, decoration: InputDecoration(labelText: "Quantity")),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await _firestore.collection('inventory').doc(item.id).update({
                'itemName': nameController.text,
                'quantity': int.parse(quantityController.text),
              });
              Navigator.pop(context);
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteItem(String id) async {
    await _firestore.collection('inventory').doc(id).delete();
  }
}
