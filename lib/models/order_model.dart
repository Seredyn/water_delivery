import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final String orderID;
  final String orderClientID;
  final String orderProductID;
  final Timestamp orderCreateTimeStamp;
  final String orderDeliveryAddressID;
  final String orderStatus;
  final double orderPrice;
  final Timestamp orderDeliveryStartTimeStamp;
  final Timestamp orderDeliveryFinishTimeStamp;
  final Timestamp? orderConfirmTimeStamp;
  final Timestamp? orderDeliveredTimeStamp;


  Order({
    required this.orderID,
    required this.orderClientID,
    required this.orderProductID,
    required this.orderCreateTimeStamp,
    required this.orderDeliveryAddressID,
    required this.orderStatus,
    required this.orderPrice,
    required this.orderDeliveryStartTimeStamp,
    required this.orderDeliveryFinishTimeStamp,
    this.orderConfirmTimeStamp,
    this.orderDeliveredTimeStamp,
  });

  Order.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      )   : orderID = snapshot.data()?["orderID"],
        orderClientID = snapshot.data()?["orderClientID"],
        orderProductID = snapshot.data()?["orderProductID"],
        orderCreateTimeStamp = snapshot.data()?["orderCreateTimeStamp"],
        orderDeliveryAddressID = snapshot.data()?["orderDeliveryAddressID"],
        orderStatus = snapshot.data()?["orderStatus"],
        orderPrice = snapshot.data()?["orderPrice"],
        orderDeliveryStartTimeStamp = snapshot.data()?["orderDeliveryStartTimeStamp"],
        orderDeliveryFinishTimeStamp = snapshot.data()?["orderDeliveryFinishTimeStamp"],
        orderConfirmTimeStamp = snapshot.data()?["orderConfirmTimeStamp"],
        orderDeliveredTimeStamp = snapshot.data()?["orderDeliveredTimeStamp"];

  Map<String, dynamic> toFirestore() {
    return {
      if (orderID != null) "orderID": orderID,
      if (orderClientID != null) "orderClientID": orderClientID,
      if (orderProductID != null) "orderProductID": orderProductID,
      if (orderCreateTimeStamp != null) "orderCreateTimeStamp": orderCreateTimeStamp,
      if (orderDeliveryAddressID != null) "orderDeliveryAddressID": orderDeliveryAddressID,
      if (orderStatus != null) "orderStatus": orderStatus,
      if (orderPrice != null) "orderPrice": orderPrice,
      if (orderDeliveryStartTimeStamp != null) "orderDeliveryStartTimeStamp": orderDeliveryStartTimeStamp,
      if (orderDeliveryFinishTimeStamp != null) "orderDeliveryFinishTimeStamp": orderDeliveryFinishTimeStamp,
      if (orderConfirmTimeStamp != null) "orderConfirmTimeStamp": orderConfirmTimeStamp,
      if (orderDeliveredTimeStamp != null) "orderDeliveredTimeStamp": orderDeliveredTimeStamp,
    };
  }


}
