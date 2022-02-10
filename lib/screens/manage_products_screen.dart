import 'package:flutter/material.dart';
import 'package:water_delivery/screens/add_product_screen.dart';
import 'package:water_delivery/screens/admin_screen.dart';

class ManageProductsScreen extends StatefulWidget {
  const ManageProductsScreen({Key? key}) : super(key: key);

  static const String id = "manage_goods_screen";

  @override
  _ManageProductsState createState() => _ManageProductsState();
}

class _ManageProductsState extends State<ManageProductsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Products"),
        actions: [
          IconButton(onPressed: () {
            Navigator.pushReplacementNamed(context, AdminScreen.id);
          }, icon: Icon(Icons.clear)),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AddProductScreen()),);
            }, child: Text("Add Product"))
          ],
        ),
      ),
    );
  }
}
