import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:water_delivery/bloc/auth_cubit.dart';
import 'package:water_delivery/screens/user_screen.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({Key? key}) : super(key: key);

  static const String id = "add_address_screen";

  @override
  _AddAddressScreenState createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen>  {
  final _formKey = GlobalKey<FormState>(); //нужно для Form()

  String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  //late String addressName;
  String _townName = "";
  String _streetName = "";
  String _houseNumber = "";
  String _korpusNumber = "";
  String _sectionNumber = "";
  String _apartmentNumber = "";
  String _entranceNumber = ""; //номер подъезда
  String _floorNumber = "";
  String _additionalInformAddress = ""; //дополнительная информация

  //final String photoAddressUrl = "gs://water-delivery-6ad8f.appspot.com/assets/660px-No-Image-Placeholder.svg.png";


  //TODO create all focus node
  late final FocusNode _streetFocusNode;
  late final FocusNode _houseNumberFocusNode;
  late final FocusNode _korpusNumberFocusNode;
  late final FocusNode _sectionNumberFocusNode;
  late final FocusNode _apartmentNumberFocusNode;
  late final FocusNode _entranceNumberFocusNode;
  late final FocusNode _floorNumberFocusNode;
  late final FocusNode _additionalInformAddressFocusNode;

  @override
  void initState() {
    // TODO: add all FocusNode to initState
    _streetFocusNode = FocusNode();
    _houseNumberFocusNode = FocusNode();
    _korpusNumberFocusNode = FocusNode();
    _sectionNumberFocusNode = FocusNode();
    _apartmentNumberFocusNode = FocusNode();
    _entranceNumberFocusNode = FocusNode();
    _floorNumberFocusNode = FocusNode();
    _additionalInformAddressFocusNode = FocusNode();

    super.initState();
  }

  @override
  void dispose() {
    // TODO: add all FocusNode to dispose
    _streetFocusNode.dispose();
    _houseNumberFocusNode.dispose();
    _korpusNumberFocusNode.dispose();
    _sectionNumberFocusNode.dispose();
    _apartmentNumberFocusNode.dispose();
    _entranceNumberFocusNode.dispose();
    _floorNumberFocusNode.dispose();
    _additionalInformAddressFocusNode.dispose();
    super.dispose();
  }

  void _submit (BuildContext context) {
    // Validate returns true if the form is valid, or false otherwise.
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // это вызывает метод onsave в формах
      // If the form is valid, display a snackbar. In the real world,
      // you'd often call a server or save the information in a database.
      context.read<AuthCubit>().addAddressDelivery(
        addressOwnerID: currentUserId,
        addressName: "$_streetName $_houseNumber, $_apartmentNumber",
        townName: _townName,
        streetName: _streetName,
        houseNumber: _houseNumber,
        korpusNumber: _korpusNumber,
        sectionNumber: _sectionNumber,
        apartmentNumber: _apartmentNumber,
        entranceNumber: _entranceNumber,
        floorNumber: _floorNumber,
        additionalInformAddress: _additionalInformAddress,
      )
          .then((value) => Navigator.of(context).pushReplacementNamed(UserScreen.id));
          //.catchError(onError)

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error. Check all Text Fields')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add new Address"),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: SingleChildScrollView(child: Column(
              children: [
                //Town
                TextFormField(
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      labelText: "Enter your Town"),
                  textInputAction: TextInputAction.next,
                  //Кнопка далее на клавиатуре
                  onFieldSubmitted: (_) {
                    FocusScope.of(context)
                        .requestFocus(_streetFocusNode);
                  },
                  onSaved: (value) {
                    _townName = value!.trim();
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please, enter your Town";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),
                //Street
                TextFormField(
                  focusNode: _streetFocusNode,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      labelText: "Enter your Street"),
                  textInputAction: TextInputAction.next,
                  //Кнопка далее на клавиатуре
                  onFieldSubmitted: (_) {
                    FocusScope.of(context)
                        .requestFocus(_houseNumberFocusNode);
                  },
                  onSaved: (value) {
                    _streetName = value!.trim();
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please, enter your street";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),
                //House, Section, Corpus
                Row(
                  children: [
                    //House Number
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: TextFormField(
                          focusNode: _houseNumberFocusNode,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              labelText: "House Number"),
                          textInputAction: TextInputAction.next,
                          //Кнопка далее на клавиатуре
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_korpusNumberFocusNode);
                          },
                          onSaved: (value) {
                            _houseNumber = value!.trim();
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please, enter your street";
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    //korpus Number
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: TextFormField(
                          focusNode: _korpusNumberFocusNode,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              labelText: "Korpus Number"),
                          textInputAction: TextInputAction.next,
                          //Кнопка далее на клавиатуре
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_sectionNumberFocusNode);
                          },
                          onSaved: (value) {
                            _korpusNumber = value?.trim() ?? "";
                          },
                          // validator: (value) {
                          //   if (value!.isEmpty) {
                          //     return "Please, enter your korpus Number or check -";
                          //   }
                          //   return null;
                          // },
                        ),
                      ),
                    ),
                    //Section Number
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: TextFormField(
                          focusNode: _sectionNumberFocusNode,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              labelText: "Section Number"),
                          textInputAction: TextInputAction.next,
                          //Кнопка далее на клавиатуре
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_apartmentNumberFocusNode);
                          },
                          onSaved: (value) {
                            _sectionNumber = value?.trim() ?? "";
                          },
                          // validator: (value) {
                          //   if (value!.isEmpty) {
                          //     return "Please, enter your street";
                          //   }
                          //   return null;
                          // },
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                //Appartment, Entrance, Floor
                Row(
                  children: [
                    //Appartment
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: TextFormField(
                          focusNode: _apartmentNumberFocusNode,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              labelText: "Appartment Number"),
                          textInputAction: TextInputAction.next,
                          //Кнопка далее на клавиатуре
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_entranceNumberFocusNode);
                          },
                          onSaved: (value) {
                            _apartmentNumber = value?.trim() ?? "";
                          },
                          validator: (value) {
                            // if (value!.isEmpty) {
                            //   return "Please, enter your appartment";
                            // }
                            return null;
                          },
                        ),
                      ),
                    ),
                    //Entrance Number
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: TextFormField(
                          focusNode: _entranceNumberFocusNode,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              labelText: "Entrance Number"),
                          textInputAction: TextInputAction.next,
                          //Кнопка далее на клавиатуре
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_floorNumberFocusNode);
                          },
                          onSaved: (value) {
                            _entranceNumber = value?.trim() ?? "";
                          },
                          validator: (value) {
                            // if (value!.isEmpty) {
                            //   return "Please, enter your korpus Number or check -";
                            // }
                            return null;
                          },
                        ),
                      ),
                    ),
                    //Floor Number
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: TextFormField(
                          focusNode: _floorNumberFocusNode,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              labelText: "Floor Number"),
                          textInputAction: TextInputAction.next,
                          //Кнопка далее на клавиатуре
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_additionalInformAddressFocusNode);
                          },
                          onSaved: (value) {
                            _floorNumber = value?.trim() ?? "";
                          },
                          validator: (value) {
                            // if (value!.isEmpty) {
                            //   return "Please, enter your street";
                            // }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                TextFormField(
                  focusNode: _additionalInformAddressFocusNode,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      labelText: "Enter additional information"),
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) {
                    _submit(context);
                  },
                  onSaved: (value) {
                    _additionalInformAddress = value?.trim() ?? "";
                  },
                  validator: (value) {

                    return null;
                  },
                ),
                SizedBox(height: 15),
                ElevatedButton(
                    onPressed: () {
                      _submit (context);
                    },
                    child: Text("Create address delivery")),
                SizedBox(height: 15),
                OutlinedButton(onPressed: () {
                  Navigator.pop(context);
                }, child: Text("Cancel"))
              ],
            ),),
          ),
        ),
      ),
    );
  }
}
