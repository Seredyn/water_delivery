import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class Order {
  final String orderID;
  final String orderClientID;
  final Timestamp orderCreateTimeStamp;
  final Map orderProductsList;
  final String orderDeliveryAddress;
  final LatLng orderDeliveryLatLng;
  final String orderStatus;
  final double orderPrise;
  final String orderPayMethod;
  final bool orderHasBeenPaid;
  final Timestamp orderConfirmTimeStamp;
  final Timestamp orderDeliveredTimeStamp;

  Order({
    required this.orderID,
    required this.orderClientID,
    required this.orderCreateTimeStamp,
    required this.orderProductsList,
    required this.orderDeliveryAddress,
    required this.orderDeliveryLatLng,
    required this.orderStatus,
    required this.orderPrise,
    required this.orderPayMethod,
    required this.orderHasBeenPaid,
    required this.orderConfirmTimeStamp,
    required this.orderDeliveredTimeStamp,
  });
}
