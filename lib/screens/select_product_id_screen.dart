import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SelectionProductIDScreen extends StatelessWidget {
  SelectionProductIDScreen({Key? key}) : super(key: key);

  static const String id = "select_productID_screen";

  final CollectionReference products =
      FirebaseFirestore.instance.collection('products');

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _productStream = products.snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text("Выберите товар"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  StreamBuilder<QuerySnapshot>(
                      stream: _productStream,
                      builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text("Snapsot has errorr"),);
                    }
                    if (snapshot.connectionState == ConnectionState.waiting || snapshot.connectionState == ConnectionState.none) {
                      return Center(child: Column(children: [
                        Text(" Loading..."),
                        SizedBox(height: 15,),
                        CircularProgressIndicator(),
                      ],),);
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data?.docs.length ?? 0,
                        itemBuilder: (context, index) {
                      final DocumentSnapshot doc = snapshot.data!.docs[index];

                      return GestureDetector(
                        onTap: () {
                          String checkedProductID = doc.get("productID");
                          Navigator.pop(context, checkedProductID);
                        },
                        child: ListTile(
                          title: Text(doc.get("productName")),
                          subtitle: Text(doc.get("productPrise").toString() + " грн."),
                        ),

                      );

                    });
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
