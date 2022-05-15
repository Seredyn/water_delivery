import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:water_delivery/bloc/auth_cubit.dart';
import 'package:water_delivery/screens/select_address_delivery.dart';
import 'package:water_delivery/screens/select_product_id_screen.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:water_delivery/screens/user_screen.dart';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({Key? key}) : super(key: key);

  static const String id = "create_order_screen";

  @override
  _CreateOrderScreenState createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  //Тут объявляются динамические переменные

  final GlobalKey<FormState> _myFormKey = GlobalKey<FormState>();

  late String checkedAddressID;
  late String currentUserId;
  late String addressName;
  late String checkedProductID;
  late String productName;
  late int quantity;
  late double productPrise;
  late double orderPrice;

  late DateTime nowTime;

  late DateTime waitingTimeFrom;
  late DateTime waitingTimeTo;

  late int starterWaitingTimeHour;
  late int starterWaitingTimeMinutes;

  late String currentWaitingTimeHourStart;
  late String currentWaitingTimeMinutesStart;
  late String currentWaitingTimeHourFinish;
  late String currentWaitingTimeMinutesFinish;

  late TextEditingController _controller1;
  late TextEditingController _controller2;
  late TextEditingController _controller3;
  late TextEditingController _controller4;

  late TextEditingController _myControllerData;
  late TextEditingController _myControllerTimeStart;
  late TextEditingController _myControllerTimeFinish;

  //String _initialValue = '';
  String _valueChanged1 = '';
  String _valueToValidate1 = '';
  String _valueSaved1 = '';
  String _valueChanged2 = '';
  String _valueToValidate2 = '';
  String _valueSaved2 = '';
  String _valueChanged3 = '';
  String _valueToValidate3 = '';
  String _valueSaved3 = '';
  String _valueChanged4 = '';
  String _valueToValidate4 = '';
  String _valueSaved4 = '';

  String _valueChangedDate = "";
  String _valueToValidateDate = "";
  String _valueSavedDate = "";
  String _valueChangedTimeStart = "";
  String _valueToValidateTimeStart = "";
  String _valueSavedTimeStart = "";
  String _valueChangedTimeFinish = "";
  String _valueToValidateTimeFinish = "";
  String _valueSavedTimeFinish = "";

  String _valueChangedToParseDateTimeStart = "";
  String _valueToValidateToParseDateTimeStart = "";
  String _valueToValidateToParseDateTimeFinish = "";
  String _valueSavedToParseDateTimeStart = "";
  String _valueToParseDateTimeStart = "";
  String _valueToParseDateTimeFinish = "";

  String _initialDateValue = "";

  DateTime firstDateInForm = DateTime.now();
  DateTime lastDateInForm = DateTime.now().add(Duration(days: 1));

  //DateTime validateDateTimeStart = DateTime.now();
  //DateTime validateDateTimeFinish = DateTime.now();

  @override
  void initState() {
    // TODO: implement initState
    super.initState(); //super.initState() обязательно нужно вызывать
    //Этот метод вызывается один раз при вставке
    // виджета стфулл в дерево виджетов. тут нужно
    // определять первые значения динамических переменных
    checkedAddressID = "";
    currentUserId = FirebaseAuth.instance.currentUser!.uid;
    addressName = "";
    checkedProductID = "";
    productName = "";
    quantity = 1;
    productPrise = 0.0;
    orderPrice = 0.0;

    nowTime = DateTime.now();
    waitingTimeFrom = nowTime;
    waitingTimeTo = waitingTimeFrom.add(const Duration(hours: 3));

    initializeDateFormatting('uk_UK', null);
    Intl.defaultLocale = 'uk_UK';

    // String lsHour = TimeOfDay.now().hour.toString().padLeft(2, '0');
    // String lsMinute = TimeOfDay.now().minute.toString().padLeft(2, '0');
    // _controller4 = TextEditingController(text: '$lsHour:$lsMinute');

    _myControllerData = TextEditingController(text: DateTime.now().weekday == DateTime.sunday ? DateTime.now().add(Duration(days: 1)).toString() : DateTime.now().toString());
    _myControllerTimeStart = TextEditingController(text: '09:00');
    _initialDateValue = nowTime.year.toString().padLeft(2, '0') + "-" + nowTime.month.toString().padLeft(2, '0') + "-" + nowTime.day.toString().padLeft(2, '0');

    //Меняем firstDateInForm и _initialDateValue если сейчас воскресенье или уже более 19 часов
    if (DateTime.now().weekday == 7 || DateTime.now().hour > 18) {
      firstDateInForm = DateTime.now().add(Duration(days: 1));
      DateTime nowTimePlusOneDay = DateTime.now().add(Duration(days: 1));
      _initialDateValue = nowTimePlusOneDay.year.toString().padLeft(2, '0') + "-" + nowTimePlusOneDay.month.toString().padLeft(2, '0') + "-" + nowTimePlusOneDay.day.toString().padLeft(2, '0');
    }
    //Меняем lastDateInForm если сейчас суббота
    if (DateTime.now().weekday == 6) {
      lastDateInForm = DateTime.now().add(Duration(days: 2));
    }

  }

  void _navigateAndGetAddressDelivery(BuildContext context) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final String result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SelectionAddressDeliveryScreen()));

    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('Address: $result')));

    checkedAddressID = result;

    //в такой метод setState нужно передавать измененные перемнные,
    // чтоб флаттер понимал факт их изменения и заново вызывал
    //void _navigateAndGetAddressDelivery(BuildContext context)
    //при этом перестраивается весь виджет билда соответственно с новыми
    // значениями переменных

    //DocumentReference doc = FirebaseFirestore.instance.collection('users').doc("currentUserId").collection("addresses").doc("checkedAddressID");
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection("addresses")
        .doc(checkedAddressID)
        .get()
        .then((value) {
      setState(() {
        addressName = value.get("addressName");
      });
    });
  }

  void _navigateAndGetProductID(BuildContext context) async {
    final String result = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => SelectionProductIDScreen()));

    checkedProductID = result;

    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('Product: $result')));

    await FirebaseFirestore.instance
        .collection("products")
        .doc(checkedProductID)
        .get()
        .then((value) {
      setState(() {
        productName = value.get("productName");
        productPrise = value.get("productPrise").toDouble();
        orderPrice = productPrise * quantity;
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text('orderPrise: $orderPrice')));
      });
    });
  }

  void _submitFormOrder () {
    if (_myFormKey.currentState!.validate()) {
      _myFormKey.currentState!.save();

      _createOrder (context);

    } else {
      ScaffoldMessenger.of(context)..removeCurrentSnackBar()..showSnackBar(const SnackBar(content: Text("Ошибка в форме, проверьте все поля")));
    }
  }

  void _createOrder (BuildContext context){
    if (currentUserId == "") {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Возникла ошибка. Необходимо заново зайти в приложение")));
      return;
    }
    if (checkedAddressID == "") {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Выберите адрес доставки")));
      return;
    }
    if (checkedProductID == "") {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Выберите товар")));
      return;
    }
    context.read<AuthCubit>().addOrderToFirebase(
      orderClientID: currentUserId,
      orderProductID: checkedProductID,
      orderProductQuantity: quantity,
      orderDeliveryAddressID: checkedAddressID,
      orderPrice: orderPrice,
      orderDeliveryStartTimeStamp: Timestamp.fromDate(DateTime.parse(_valueToValidateToParseDateTimeStart)),
      orderDeliveryFinishTimeStamp: Timestamp.fromDate(DateTime.parse(_valueToValidateToParseDateTimeFinish)),
    ).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Заказ отправлен в обработку")));
      Navigator.of(context).pushReplacementNamed(UserScreen.id);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Создание заказа"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              children: [
                Container(
                  child: checkedAddressID == ""
                      ? Text("Выберите адрес:",
                          style: Theme.of(context).textTheme.headline5)
                      : Text("Адрес доставки:",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          )),
                ),
                // Visibility(
                //   visible: checkedAddressID == "" ? true : false,
                //     child: Text("Выберите адрес:", style: Theme.of(context).textTheme.headline5)),
                Text(
                  addressName,
                  style: TextStyle(
                    fontSize: 26,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                //Text("Доставить сюда: $checkedAddressID"),
                ElevatedButton(
                  child: checkedAddressID == ""
                      ? Text("Выбрать адрес")
                      : Text("Изменить адрес"),
                  onPressed: () {
                    _navigateAndGetAddressDelivery(context);
                  },
                ),
                SizedBox(
                  height: 30,
                ),
                Container(
                  child: checkedProductID == ""
                      ? Text("Выберите товар:",
                          style: Theme.of(context).textTheme.headline5)
                      : Text("Выбранный товар:",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          )),
                ),
                Text(
                  productName,
                  style: TextStyle(
                    fontSize: 26,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  child: checkedProductID == ""
                      ? Container()
                      : Column(
                          children: [
                            Text("Количество:",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                )),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  child: Text("-"),
                                  onPressed: () {
                                    if (quantity <= 1) {
                                      ScaffoldMessenger.of(context)
                                        ..removeCurrentSnackBar()
                                        ..showSnackBar(SnackBar(
                                            content: Text(
                                                "Количество не может быть меньше 1 шт.")));
                                      return;
                                    }
                                    setState(() {
                                      quantity--;
                                      orderPrice = productPrise * quantity;
                                    });
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    quantity.toString(),
                                    style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  child: Text("+"),
                                  onPressed: () {
                                    setState(() {
                                      quantity++;
                                      orderPrice = productPrise * quantity;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                ),
                ElevatedButton(
                  child: checkedProductID == ""
                      ? Text("Выбрать товар")
                      : Text("Изменить товар"),
                  onPressed: () {
                    _navigateAndGetProductID(context);
                  },
                ),

                Container(
                  child: checkedProductID == ""
                      ? Container()
                      : Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Стоимость заказа",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  )),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child:
                                    Text(orderPrice.toStringAsFixed(2) + " грн.",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        )),
                              ),
                            ],
                          ),
                        ),
                ),

                SizedBox(
                  height: 30,
                ),

                Text("Время доставки:",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    )),
                SizedBox(
                  height: 30,
                ),
                Text("Сегодня/Завтра"),
                Form(
                  key: _myFormKey,
                  child: Column(children: [
                    DateTimePicker(
                      type: DateTimePickerType.date,
                      dateMask: 'dd MMMM yyyy',
                      //controller: _myControllerData,
                      initialValue: _initialDateValue,
                      firstDate: firstDateInForm,
                      lastDate: lastDateInForm,
                      icon: Icon(Icons.event),
                      dateLabelText: 'Дата',
                      //locale: Locale('uk', 'UK'),
                      onChanged: (val) => setState(() => _valueChangedDate = val),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return "Выберите дату";
                        }
                        setState(() => _valueToValidateDate = val);
                        return null;
                      },
                      onSaved: (val) =>
                          setState(() => _valueSavedDate = val ?? ''),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                      Expanded(
                        child: DateTimePicker(
                          type: DateTimePickerType.time,
                          //timePickerEntryModeInput: true,
                          //controller: _myControllerTimeStart,
                          initialValue: '09:00',
                          //_initialValue,
                          icon: Icon(Icons.access_time),
                          timeLabelText: "Время С",
                          //use24HourFormat: false,
                          locale: Locale('uk', 'UA'),
                          onChanged: (val) => setState(() {
                            _valueChangedTimeStart = val;
                            _valueChangedToParseDateTimeStart = _valueChangedDate + " " + _valueChangedTimeStart;
                          } ),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return "Выберите время";
                            }
                            setState(() {
                              _valueToValidateTimeStart = val;
                            } );
                            return null;
                          },
                          onSaved: (val) =>
                              setState(() => _valueSavedTimeStart = val ?? ''),
                        ),
                      ),
                      Expanded(
                        child: DateTimePicker(
                          type: DateTimePickerType.time,
                          //timePickerEntryModeInput: true,
                          //controller: _controller4,
                          initialValue: '20:00',
                          //_initialValue,
                          icon: Icon(Icons.access_time),
                          timeLabelText: "Время ДО",
                          //use24HourFormat: false,
                          locale: Locale('uk', 'UA'),
                          onChanged: (val) => setState(() => _valueChangedTimeFinish = val),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return "Выберите время";
                            }
                            //setState(() => _valueToValidateTimeFinish = val ?? '');

                            _valueToValidateTimeFinish = val;
                            _valueToValidateToParseDateTimeStart = _valueToValidateDate + " " + _valueToValidateTimeStart;
                            _valueToValidateToParseDateTimeFinish = _valueToValidateDate + " " + _valueToValidateTimeFinish;
                            DateTime validateDateTimeStart = DateTime.parse(_valueToValidateToParseDateTimeStart);
                            DateTime validateDateTimeFinish = DateTime.parse(_valueToValidateToParseDateTimeFinish);
                            if (validateDateTimeFinish.hour > 21) {
                              return "слишком позднее время";

                            }
                            if (validateDateTimeFinish.isBefore(validateDateTimeStart) || validateDateTimeFinish.isAtSameMomentAs(validateDateTimeStart)){
                              return "укажите время поздее начала ожидания";
                            }
                            Duration differenceOnValue = validateDateTimeFinish.difference(validateDateTimeStart);
                            if (differenceOnValue.inHours < 2) {
                              return "Укажите более 2 часов";
                            }
                            Duration differenceOnRealTime = validateDateTimeFinish.difference(DateTime.now());
                            if (differenceOnRealTime.inHours < 1) {
                              return "Укажите более 1 часа до конца доставки";
                            }
                            return null;
                          },
                          onSaved: (val) =>
                              setState(() => _valueSavedTimeFinish = val ?? ''),
                        ),
                      ),
                    ],),
                    ElevatedButton(
                      onPressed: _submitFormOrder,
                      child: Text('Submit'),
                    ),
                    Text("_valueToValidateToParseDateTimeStart:$_valueToValidateToParseDateTimeStart"),
                    Text("_valueToValidateToParseDateTimeFinish:$_valueToValidateToParseDateTimeFinish"),
                    Text("_initialDateValue:$_initialDateValue"),
                    Text("_valueToParseDateTimeStart:$_valueToParseDateTimeStart"),
                    Text("_valueChangedToParseDateTimeStart:$_valueChangedToParseDateTimeStart"),
                    SizedBox(height: 20,),
                    ],
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                FloatingActionButton.extended(
                  onPressed: () {},
                  label: Text("Confirm"),
                ),
                ElevatedButton(
                  child: Text("Show SnackBar"),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("checkedAddressID: $checkedAddressID")));
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
