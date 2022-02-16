import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:water_delivery/bloc/auth_cubit.dart';
import 'package:water_delivery/screens/add_product_screen.dart';
import 'package:water_delivery/screens/admin_screen.dart';

class ManageProductsScreen extends StatefulWidget {
  const ManageProductsScreen({Key? key}) : super(key: key);

  static const String id = "manage_goods_screen";

  @override
  _ManageProductsState createState() => _ManageProductsState();
}

class _ManageProductsState extends State<ManageProductsScreen> {

  _activeOrDeactiveProduct ({
      required String productID,
      required bool isProductActive,
  }) {
    if (productID != null) {
      if (isProductActive) {
        context.read<AuthCubit>().deactivateProduct(productID: productID);
      } else {
        context.read<AuthCubit>().activateProduct(productID: productID);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(" Errorr: productID is null")));
    }
  }


  @override
  Widget build(BuildContext context) {

    final Stream<QuerySnapshot> _productsStream = FirebaseFirestore.instance
    .collection("products")
    .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Products"),
        actions: [
          IconButton(onPressed: () {
            Navigator.pushReplacementNamed(context, AdminScreen.id);
          }, icon: Icon(Icons.clear)),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Text("Управление товарами", style: Theme.of(context).textTheme.headline5,),
                ),
                StreamBuilder<QuerySnapshot>(
                    stream: _productsStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text("Snapshot has error"),);
                      }
                      if (snapshot.connectionState == ConnectionState.waiting ||
                          snapshot.connectionState == ConnectionState.none) {
                        return Center(child: CircularProgressIndicator(),);
                      }
                      return Container(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data?.docs.length ?? 0,
                            itemBuilder: (context, index) {
                            final DocumentSnapshot doc = snapshot.data!.docs[index];

                            return ListTile (
                              
                              //trailing: Icon(Icons.more_vert),
                              leading: Icon(Icons.shopping_cart),
                              title: Text(doc.get("productName"), style: Theme.of(context).textTheme.headline6,),
                              subtitle: (doc.get("productActive")? Text("Active") : Text("Not active", style: TextStyle(color: Colors.red),)),
                              
                              onTap: () {
                                String _productID = doc.get("productID");
                                bool _isProductActive = doc.get("productActive");
                                _activeOrDeactiveProduct(productID: _productID, isProductActive: _isProductActive);
                              },
                              onLongPress: () {
                                
                              },
                            );
                            }),
                      );
                    }),
                ElevatedButton(onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AddProductScreen()),);
                }, child: Text("Add Product"))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
