import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SelectionAddressDeliveryScreen extends StatefulWidget {
  SelectionAddressDeliveryScreen({Key? key}) : super(key: key);

  static const String id = "select_address_delivery_screen";

  @override
  _SelectionAddressDeliveryScreenState createState() =>
      _SelectionAddressDeliveryScreenState();

}

class _SelectionAddressDeliveryScreenState extends State<SelectionAddressDeliveryScreen> {

  final CollectionReference users = FirebaseFirestore.instance.collection('users');
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;


  @override
  Widget build(BuildContext context) {

    final Stream<QuerySnapshot> _addressStream = users.doc(currentUserId).collection("addresses").snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text("Выберите адрес"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: _addressStream,
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
                            onTap: (){
                              String checkedAddressID = doc.get("addressID");
                              Navigator.pop(context, checkedAddressID);
                            },
                            child: ListTile(
                              leading: Icon(Icons.map),
                              title: Text(doc.get("streetName") +
                                  ", " +
                                  doc.get("houseNumber") +
                                  ", " +
                                  doc.get("apartmentNumber")),
                              subtitle: Text(doc.get("streetName")),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  SizedBox(height: 15,),
                  ElevatedButton(
                      onPressed: () async {
                        //await _goToAddAddressScreen();
                      },
                      child: Text("Add Address")),
                  SizedBox(
                    height: 30,
                  ),
                  ElevatedButton(
                    child: Text("Create order"),
                    onPressed: () async {
                      //await _goToCreateOrderScreen();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
