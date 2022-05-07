import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:water_delivery/bloc/auth_cubit.dart';
import 'package:water_delivery/screens/sign_in_screen.dart';

class BecomeSupplierScreen extends StatefulWidget {
  const BecomeSupplierScreen({Key? key}) : super(key: key);

  static const String id = "become_supplier_screen";

  @override
  State<BecomeSupplierScreen> createState() => _BecomeSupplierScreenState();
}

class _BecomeSupplierScreenState extends State<BecomeSupplierScreen> {
  final _formKey = GlobalKey<FormState>();

  String _companyName = "";
  String _site = "";
  String _contactPhoneNumber = "";
  String _contactEmail = "";
  String _contactOther = "";
  String _serviceZone = "";
  String _companySalesQuantity = "";
  String _otherInfo = "";

  late final FocusNode _siteFocusNode;
  late final FocusNode _contactPhoneNumberFocusNode;
  late final FocusNode _contactEmailFocusNode;
  late final FocusNode _contactOtherFocusNode;
  late final FocusNode _serviceZoneFocusNode;
  late final FocusNode _companySalesQuantityFocusNode;
  late final FocusNode _otherInfoFocusNode;


  @override
  void initState() {
    super.initState();
    _siteFocusNode = FocusNode();
    _contactPhoneNumberFocusNode = FocusNode();
    _contactEmailFocusNode = FocusNode();
    _contactOtherFocusNode = FocusNode();
    _serviceZoneFocusNode = FocusNode();
    _companySalesQuantityFocusNode = FocusNode();
    _otherInfoFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _siteFocusNode.dispose();
    _contactPhoneNumberFocusNode.dispose();
    _contactEmailFocusNode.dispose();
    _contactOtherFocusNode.dispose();
    _serviceZoneFocusNode.dispose();
    _companySalesQuantityFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Стать поставщиком"),
        // actions: [
        //   IconButton(
        //       onPressed: () {
        //         context.read<AuthCubit>().signOut().then((value) =>
        //             Navigator.of(context)
        //                 .pushReplacementNamed(SignInScreen.id));
        //         //если будет ошибка при разлогине, то переход не будет исполняться.
        //       },
        //       icon: Icon(Icons.logout)),
        // ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  Text("Написать вводную информацию для поставщиков"),
                  SizedBox(
                    height: 20,
                  ),
                  Text("Подать заявку на регистрацию поставщика",
                      style: Theme.of(context).textTheme.headline5),
                  Text(
                      "Заполните требуемые поля и прикрепите необходимые файлы.",
                      style: Theme.of(context).textTheme.bodyText1),
                  Form(
                      key: _formKey,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Center(
                          child: Column(
                            children: [
                              //_companyName
                              TextFormField(
                                onSaved: (value) {
                                  _companyName = value!.trim();
                                },
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  labelText: "Название фирмы",
                                  border: OutlineInputBorder(),
                                ),
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Укажите название вашей фирмы';
                                  }
                                  return null;
                                },
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context).requestFocus(_siteFocusNode);
                                },
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              //_site
                              TextFormField(
                                focusNode: _siteFocusNode,
                                onSaved: (value) {
                                  _site = value == null ? "" : value.trim();
                                },
                                keyboardType: TextInputType.url,
                                decoration: InputDecoration(
                                  labelText: "Сайт (если есть)",
                                  border: OutlineInputBorder(),
                                ),
                                textInputAction: TextInputAction.next,
                                // validator: (value) {
                                //   if (value == null || value.isEmpty) {
                                //     return 'Укажите название вашей фирмы';
                                //   }
                                //   return null;
                                // },
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context).requestFocus(_contactPhoneNumberFocusNode);
                                },
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              //_contactPhoneNumber
                              TextFormField(
                                focusNode: _contactPhoneNumberFocusNode,
                                onSaved: (value) {
                                  _contactPhoneNumber = value!.trim();
                                },
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  labelText: "Контактый телефон",
                                  border: OutlineInputBorder(),
                                ),
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Укажите телефон для связи';
                                  }
                                  if (value.length < 9) {
                                    return "Слишком мало цифр";
                                  }
                                  if (value.length > 13) {
                                    return "Слишком много цифр";
                                  }
                                  return null;
                                },
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context).requestFocus(_contactEmailFocusNode);
                                },
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              //_contactEmail
                              TextFormField(
                                onSaved: (value) {
                                  _contactEmail = value!.trim();
                                },
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: "Контактый E-mail",
                                  border: OutlineInputBorder(),
                                ),
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Укажите рабочую почту';
                                  }
                                  return null;
                                },
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context).requestFocus(_contactOtherFocusNode);
                                },
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              //_contactOther
                              TextFormField(
                                maxLines: 3,
                                onSaved: (value) {
                                  _contactOther = value == null ? "" : value.trim();
                                },
                                keyboardType: TextInputType.multiline,
                                decoration: InputDecoration(
                                  labelText: "Другие контакты",
                                  border: OutlineInputBorder(),
                                ),
                                textInputAction: TextInputAction.next,
                                // validator: (value) {
                                //   if (value == null || value.isEmpty) {
                                //     return 'Укажите примерную зону обслуживания';
                                //   }
                                //   return null;
                                // },
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context).requestFocus(_serviceZoneFocusNode);
                                },
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              //_serviceZone
                              TextFormField(
                                maxLines: 3,
                                focusNode: _serviceZoneFocusNode,
                                onSaved: (value) {
                                  _serviceZone = value!.trim();
                                },
                                keyboardType: TextInputType.multiline,
                                decoration: InputDecoration(
                                  labelText: "Зона обслуживния",
                                  border: OutlineInputBorder(),
                                ),
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Укажите примерную зону обслуживания';
                                  }
                                  return null;
                                },
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context).requestFocus(_companySalesQuantityFocusNode);
                                },
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              //_companySalesQuantity
                              TextFormField(
                                focusNode: _companySalesQuantityFocusNode,
                                onSaved: (value) {
                                  _companySalesQuantity = value!.trim();
                                },
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  labelText: "Количество заказов в месяц",
                                  border: OutlineInputBorder(),
                                ),
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Укажите примерное количество заказов в месяц';
                                  }
                                  return null;
                                },
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context).requestFocus(_otherInfoFocusNode);
                                },

                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              TextFormField(
                                maxLines: 3,
                                focusNode: _otherInfoFocusNode,
                                onSaved: (value) {
                                  _otherInfo = value == null ? "" : value.trim();
                                },
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  labelText: "Другая информация",
                                  border: OutlineInputBorder(),
                                ),
                                textInputAction: TextInputAction.done,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Укажите примерную зону обслуживания';
                                  }
                                  return null;
                                },
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context).requestFocus(_companySalesQuantityFocusNode);
                                },
                              ),


                            ],
                          ),
                        ),
                      )),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pushReplacementNamed(BecomeSupplierScreen.id);
                    },
                    child: const Text('Подать заявку'),
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
