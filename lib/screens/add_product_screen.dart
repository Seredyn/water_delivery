import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:water_delivery/bloc/auth_cubit.dart';
import 'package:water_delivery/screens/manage_products_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  static const String id = "add_product_screen";

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>(); //нужно для Form()

  String _productName = "";
  String _productDescription = "";
  String _productSorting = "";
  String _productCode = "";
  double _productPrise = 0.00;

  late final FocusNode _productDescriptionFocusNode;
  late final FocusNode _productSortingFocusNode;
  late final FocusNode _productCodeFocusNode;
  late final FocusNode _productPriseFocusNode;

  @override
  void initState() {
    // TODO: implement initState
    _productDescriptionFocusNode = FocusNode();
    _productSortingFocusNode = FocusNode();
    _productCodeFocusNode = FocusNode();
    _productPriseFocusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _productDescriptionFocusNode.dispose();
    _productSortingFocusNode.dispose();
    _productCodeFocusNode.dispose();
    _productPriseFocusNode.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();// это вызывает метод onsave в формах
      context.read<AuthCubit>().addProduct(
          productName: _productName,
          productDescription: _productDescription,
          productSorting: _productSorting,
          productCode: _productCode,
          productPrise: _productPrise)
      .then((value) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Product will be addedd")));

      }).catchError((errorr) => print("Some error when product added"));

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Product"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pushReplacementNamed(
                    context, ManageProductsScreen.id);
              },
              icon: Icon(Icons.add_shopping_cart)),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  //_productName
                  TextFormField(
                    keyboardType: TextInputType.text,
                    decoration:
                        InputDecoration(labelText: "Enter Name of Product"),
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_productDescriptionFocusNode),
                    onSaved: (value) {
                      _productName = value!.trim();
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please, enter  product Name";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 15,),
                  //_productDescription
                  TextFormField(
                    keyboardType: TextInputType.text,
                    decoration:
                    InputDecoration(labelText: "Enter description of Product"),
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_productSortingFocusNode),
                    onSaved: (value) {
                      _productDescription = value!.trim();
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please, enter  product description";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 15,),
                  //_productSorting
                  TextFormField(
                    keyboardType: TextInputType.number,
                    decoration:
                    InputDecoration(labelText: "Enter sorting key of Product"),
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_productCodeFocusNode),
                    onSaved: (value) {
                      _productSorting = value!.trim();
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please, sorting key of Product";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 15,),
                  //_productCode
                  TextFormField(
                      keyboardType: TextInputType.text,
                    decoration:
                    InputDecoration(labelText: "Enter Code of Product (Like A21T3452)"),
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_productPriseFocusNode),
                    onSaved: (value) {
                      _productCode = value!.trim();
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please, enter  Code of Product";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 15,),
                  //_productPrise
                  TextFormField(
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: <TextInputFormatter> [
                      //FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?\.?\d{0,2}')),
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(12), //max length of 12 characters
                    ],
                    decoration:
                    InputDecoration(labelText: "Enter Product prise. Only digits. (Like 125)"),
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(context),
                    onSaved: (value) {
                      _productPrise = double.parse(value!);
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please, enter Product Prise";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 25,),
                  ElevatedButton(onPressed: () => _submit(context), child: Text("Create Product")),
                  SizedBox(height: 15,),
                  OutlinedButton(onPressed: () => Navigator.pop(context), child: Text("Cancel"))

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
