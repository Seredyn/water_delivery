import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:water_delivery/screens/select_address_delivery.dart';
import 'package:water_delivery/screens/select_product_id_screen.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({Key? key}) : super(key: key);

  static const String id = "create_order_screen";

  @override
  _CreateOrderScreenState createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  //Тут объявляются динамические переменные

  final GlobalKey<FormState> _myFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late String checkedAddressID;
  late String currentUserId;
  late String addressName;
  late String checkedProductID;
  late String productName;
  late int quantity;
  late double productPrise;
  late double orderPrise;

  late List<String> waitingTimeHourStartList;
  late List<String> waitingTimeMinutesStartList;
  late List<String> waitingTimeHourFinishList;
  late List<String> waitingTimeMinutesFinishList;

  //late Map<DropdownMenuItem<int>> waitingTimeHourMap;

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
    orderPrise = 0.0;

    waitingTimeHourStartList = [
      "9",
      "10",
      "11",
      "12",
      "13",
      "14",
      "15",
      "16",
      "17",
      "18",
      "19",
      "20"
    ];
    waitingTimeMinutesStartList = ["00", "15", "30", "45"];

    waitingTimeHourFinishList = waitingTimeHourStartList;
    waitingTimeMinutesFinishList = waitingTimeMinutesStartList;

    nowTime = DateTime.now();
    waitingTimeFrom = nowTime;
    waitingTimeTo = waitingTimeFrom.add(const Duration(hours: 3));

    currentWaitingTimeHourStart = waitingTimeHourStartList[0];
    currentWaitingTimeMinutesStart = waitingTimeMinutesStartList[0];
    currentWaitingTimeHourFinish = waitingTimeHourStartList.last;
    currentWaitingTimeMinutesFinish = waitingTimeMinutesStartList.last;



    initializeDateFormatting('uk_UK', null);
    Intl.defaultLocale = 'uk_UK';
    //_initialValue = DateTime.now().toString();
    _controller1 = TextEditingController(text: DateTime.now().toString());
    _controller2 = TextEditingController(text: DateTime.now().toString());
    _controller3 = TextEditingController(text: DateTime.now().toString());

    String lsHour = TimeOfDay.now().hour.toString().padLeft(2, '0');
    String lsMinute = TimeOfDay.now().minute.toString().padLeft(2, '0');
    _controller4 = TextEditingController(text: '$lsHour:$lsMinute');

    _myControllerData = TextEditingController(text: DateTime.now().weekday == DateTime.sunday ? DateTime.now().add(Duration(days: 1)).toString() : DateTime.now().toString());
    _myControllerTimeStart = TextEditingController(text: '09:00');
    _initialDateValue = nowTime.year.toString().padLeft(2, '0') + "-" + nowTime.month.toString().padLeft(2, '0') + "-" + nowTime.day.toString().padLeft(2, '0');

    //Меняем firstDateInForm и _initialDateValue если сейчас воскресенье или уже более 19 часов
    if (DateTime.now().weekday == 7 || DateTime.now().hour > 19) {
      firstDateInForm = DateTime.now().add(Duration(days: 1));
      DateTime nowTimePlusOneDay = DateTime.now().add(Duration(days: 1));
      _initialDateValue = nowTimePlusOneDay.year.toString().padLeft(2, '0') + "-" + nowTimePlusOneDay.month.toString().padLeft(2, '0') + "-" + nowTimePlusOneDay.day.toString().padLeft(2, '0');
    }
    //Меняем lastDateInForm если сейчас суббота
    if (DateTime.now().weekday == 6) {
      lastDateInForm = DateTime.now().add(Duration(days: 2));
    }

    _getValue();
  }

  Future<void> _getValue() async {
    await Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        //_initialValue = '2000-10-22 14:30';
        _controller1.text = '2000-09-20 14:30';
        _controller2.text = '2001-10-21 15:31';
        _controller3.text = '2002-11-22';
        _controller4.text = '17:01';
        _myControllerTimeStart.text = '09;00';
      });
    });
  }

  void _checkTimeToDelivery() {}

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
        orderPrise = productPrise * quantity;
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text('orderPrise: $orderPrise')));
      });
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
                                      orderPrise = productPrise * quantity;
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
                                      orderPrise = productPrise * quantity;
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
                                    Text(orderPrise.toStringAsFixed(2) + " грн.",
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        "C",
                        style: TextStyle(fontSize: 23),
                      ),
                    ),
                    Container(
                      child: Row(
                        children: [
                          DropdownButton<String>(
                            value: currentWaitingTimeHourStart,
                            icon: Icon(Icons.arrow_downward),
                            style: TextStyle(fontSize: 23, color: Colors.indigo),
                            iconSize: 20,
                            elevation: 16,
                            underline: Container(
                              height: 2,
                              color: Colors.indigo,
                            ),
                            onChanged: (String? newValue) {
                              setState(() {
                                currentWaitingTimeHourStart = newValue!;
                                // waitingTimeHourFinishList.clear();
                                // for (int i = int.parse(currentWaitingTimeHourStart) + 2; i <= 19; i++) {
                                //   waitingTimeHourFinishList.add(i.toString());
                                // }
                                // currentWaitingTimeHourFinish = waitingTimeHourFinishList[0];
                              });
                            },
                            items: waitingTimeHourStartList
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              ":",
                              style:
                                  TextStyle(fontSize: 23, color: Colors.indigo),
                            ),
                          ),
                          DropdownButton<String>(
                            value: currentWaitingTimeMinutesStart,
                            icon: Icon(Icons.arrow_downward),
                            style: TextStyle(fontSize: 23, color: Colors.indigo),
                            iconSize: 20,
                            elevation: 16,
                            underline: Container(
                              height: 2,
                              color: Colors.indigo,
                            ),
                            onChanged: (String? newValue) {
                              setState(() {
                                currentWaitingTimeMinutesStart = newValue!;
                              });
                            },
                            items: waitingTimeMinutesStartList
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        "ДО",
                        style: TextStyle(fontSize: 23),
                      ),
                    ),
                    Container(
                      child: Row(
                        children: [
                          DropdownButton<String>(
                            value: currentWaitingTimeHourFinish,
                            icon: Icon(Icons.arrow_downward),
                            iconSize: 20,
                            style: TextStyle(fontSize: 23, color: Colors.indigo),
                            elevation: 16,
                            underline: Container(
                              height: 2,
                              color: Colors.indigo,
                            ),
                            onChanged: (String? newValue) {
                              int check =
                                  int.parse(currentWaitingTimeHourFinish) -
                                      int.parse(currentWaitingTimeHourStart);
                              if (check < 2) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text(
                                        "Время ожидания должно быть более 2-х часов")));
                                setState(() {
                                  currentWaitingTimeHourFinish =
                                      (int.parse(currentWaitingTimeHourStart) + 2)
                                          .toString();
                                });
                              } else {
                                setState(() {
                                  currentWaitingTimeHourFinish = newValue!;
                                });
                              }
                            },
                            items: waitingTimeHourFinishList
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              ":",
                              style:
                                  TextStyle(fontSize: 23, color: Colors.indigo),
                            ),
                          ),
                          DropdownButton<String>(
                            value: currentWaitingTimeMinutesFinish,
                            icon: Icon(Icons.arrow_downward),
                            iconSize: 20,
                            style: TextStyle(fontSize: 23, color: Colors.indigo),
                            elevation: 16,
                            underline: Container(
                              height: 2,
                              color: Colors.indigo,
                            ),
                            onChanged: (String? newValue) {
                              setState(() {
                                currentWaitingTimeMinutesFinish = newValue!;
                              });
                            },
                            items: waitingTimeMinutesStartList
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                Text("Время доставки Вариант 2:",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    )),

                Form(
                  key: _myFormKey,
                  child: Column(children: [
                    DateTimePicker(
                      type: DateTimePickerType.date,
                      //dateMask: 'dd/MM/yyyy',
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
                      onPressed: () {
                        final loForm = _myFormKey.currentState;

                        if (loForm?.validate() == true) {
                          loForm?.save();
                        }
                      },
                      child: Text('Submit'),
                    ),
                    Text("_valueToValidateToParseDateTimeStart:$_valueToValidateToParseDateTimeStart"),
                    Text("_valueToValidateToParseDateTimeFinish:$_valueToValidateToParseDateTimeFinish"),
                    Text("_initialDateValue:$_initialDateValue"),
                    Text("_valueToParseDateTimeStart:$_valueToParseDateTimeStart"),
                    Text("_valueChangedToParseDateTimeStart:$_valueChangedToParseDateTimeStart"),
                    Text("Changed"),
                    Text("$_valueChangedDate $_valueChangedTimeStart"),
                    Text("$_valueChangedDate $_valueChangedTimeFinish"),
                    Text("Validate"),
                    Text("$_valueToValidateDate, $_valueToValidateTimeStart"),
                    Text("$_valueToValidateDate, $_valueToValidateTimeFinish"),
                    Text("Saved"),
                    Text("$_valueToValidateDate, $_valueToValidateTimeStart"),
                    Text("$_valueToValidateDate, $_valueToValidateTimeFinish"),
                    SizedBox(height: 20,),
                    DateTimePicker(
                      type: DateTimePickerType.time,
                      //timePickerEntryModeInput: true,
                      //controller: _controller4,
                      initialValue: '',
                      //_initialValue,
                      icon: Icon(Icons.access_time),
                      timeLabelText: "Время",
                      //use24HourFormat: false,
                      locale: Locale('uk', 'UA'),
                      onChanged: (val) => setState(() => _valueChanged4 = val),
                      validator: (val) {
                        setState(() => _valueToValidate4 = val ?? '');
                        return null;
                      },
                      onSaved: (val) =>
                          setState(() => _valueSaved4 = val ?? ''),
                    ),
                    ],
                  ),
                ),


                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      DateTimePicker(
                        type: DateTimePickerType.dateTimeSeparate,
                        dateMask: 'd MMM, yyyy',
                        controller: _controller1,
                        //initialValue: _initialValue,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        icon: Icon(Icons.event),
                        dateLabelText: 'Date',
                        timeLabelText: "Hour",
                        //use24HourFormat: false,
                        //locale: Locale('pt', 'BR'),
                        selectableDayPredicate: (date) {
                          if (date.weekday == 6 || date.weekday == 7) {
                            return false;
                          }
                          return true;
                        },
                        onChanged: (val) => setState(() => _valueChanged1 = val),
                        validator: (val) {
                          setState(() => _valueToValidate1 = val ?? '');
                          return null;
                        },
                        onSaved: (val) =>
                            setState(() => _valueSaved1 = val ?? ''),
                      ),
                      DateTimePicker(
                        type: DateTimePickerType.dateTime,
                        dateMask: 'd MMMM, yyyy - hh:mm a',
                        controller: _controller2,
                        //initialValue: _initialValue,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        //icon: Icon(Icons.event),
                        dateLabelText: 'Date Time',
                        use24HourFormat: false,
                        locale: Locale('en', 'US'),
                        onChanged: (val) => setState(() => _valueChanged2 = val),
                        validator: (val) {
                          setState(() => _valueToValidate2 = val ?? '');
                          return null;
                        },
                        onSaved: (val) =>
                            setState(() => _valueSaved2 = val ?? ''),
                      ),
                      DateTimePicker(
                        type: DateTimePickerType.date,
                        //dateMask: 'yyyy/MM/dd',
                        controller: _controller3,
                        //initialValue: _initialValue,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        icon: Icon(Icons.event),
                        dateLabelText: 'Date',
                        locale: Locale('pt', 'BR'),
                        onChanged: (val) => setState(() => _valueChanged3 = val),
                        validator: (val) {
                          setState(() => _valueToValidate3 = val ?? '');
                          return null;
                        },
                        onSaved: (val) =>
                            setState(() => _valueSaved3 = val ?? ''),
                      ),
                      DateTimePicker(
                        type: DateTimePickerType.time,
                        //timePickerEntryModeInput: true,
                        //controller: _controller4,
                        initialValue: '',
                        //_initialValue,
                        icon: Icon(Icons.access_time),
                        timeLabelText: "Time",
                        use24HourFormat: false,
                        locale: Locale('pt', 'BR'),
                        onChanged: (val) => setState(() => _valueChanged4 = val),
                        validator: (val) {
                          setState(() => _valueToValidate4 = val ?? '');
                          return null;
                        },
                        onSaved: (val) =>
                            setState(() => _valueSaved4 = val ?? ''),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'DateTimePicker data value onChanged:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      SelectableText(_valueChanged1),
                      SelectableText(_valueChanged2),
                      SelectableText(_valueChanged3),
                      SelectableText(_valueChanged4),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          final loForm = _formKey.currentState;

                          if (loForm?.validate() == true) {
                            loForm?.save();
                          }
                        },
                        child: Text('Submit'),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'DateTimePicker data value onChanged:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      SelectableText(_valueChanged1),
                      SelectableText(_valueChanged2),
                      SelectableText(_valueChanged3),
                      SelectableText(_valueChanged4),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          final loForm = _formKey.currentState;

                          if (loForm?.validate() == true) {
                            loForm?.save();
                          }
                        },
                        child: Text('Submit'),
                      ),
                      SizedBox(height: 30),
                      Text(
                        'DateTimePicker data value validator:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      SelectableText(_valueToValidate1),
                      SelectableText(_valueToValidate2),
                      SelectableText(_valueToValidate3),
                      SelectableText(_valueToValidate4),
                      SizedBox(height: 10),
                      Text(
                        'DateTimePicker data value onSaved:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      SelectableText(_valueSaved1),
                      SelectableText(_valueSaved2),
                      SelectableText(_valueSaved3),
                      SelectableText(_valueSaved4),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          final loForm = _formKey.currentState;
                          loForm?.reset();

                          setState(() {
                            _valueChanged1 = '';
                            _valueChanged2 = '';
                            _valueChanged3 = '';
                            _valueChanged4 = '';
                            _valueToValidate1 = '';
                            _valueToValidate2 = '';
                            _valueToValidate3 = '';
                            _valueToValidate4 = '';
                            _valueSaved1 = '';
                            _valueSaved2 = '';
                            _valueSaved3 = '';
                            _valueSaved4 = '';
                          });

                          _controller1.clear();
                          _controller2.clear();
                          _controller3.clear();
                          _controller4.clear();
                        },
                        child: Text('Reset'),
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height: 30,
                ),
                Text(
                    "Water type <List> or Map with count. Возможность заказать несколько разных баллонов на один адресс"),
                Text("Время ожидания доставки"),
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
