import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class Order {
  final String orderID;
  final String orderClientID;
  final String orderProductID;
  final Timestamp orderCreateTimeStamp;
  //final Map orderProductsList;
  final String orderDeliveryAddressID;
  final String orderStatus;
  final double orderPrise;
  final Timestamp orderConfirmTimeStamp;
  final Timestamp orderDeliveredTimeStamp;
  final Timestamp orderDeliveryStartTimeStamp;
  final Timestamp orderDeliveryFinishTimeStamp;

  Order({
    required this.orderID,
    required this.orderClientID,
    required this.orderProductID,
    required this.orderCreateTimeStamp,
    //required this.orderProductsList,
    required this.orderDeliveryAddressID,
    required this.orderStatus,
    required this.orderPrise,
    required this.orderConfirmTimeStamp,
    required this.orderDeliveredTimeStamp,
    required this.orderDeliveryStartTimeStamp,
    required this.orderDeliveryFinishTimeStamp,
  });
}
