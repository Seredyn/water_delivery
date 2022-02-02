import 'package:latlong2/latlong.dart';

class Address {
  final String addressOwnerID;
  final String addressID;

  final String addressName;
  final String townName;
  final String streetName;
  final String houseNumber;
  final String korpusNumber;
  final String sectionNumber;
  final String apartmentNumber;
  final String entranceNumber; //номер подъезда
  final String floorNumber;
  final String additionalInformAddress; //дополнительная информация

  final String photoAddressUrl;

  Address({
      required this.addressOwnerID,
      required this.addressID,
      required this.addressName,
      required this.townName,
      required this.streetName,
      required this.houseNumber,
      required this.korpusNumber,
      required this.sectionNumber,
      required this.apartmentNumber,
      required this.entranceNumber,
      required this.floorNumber,
      required this.additionalInformAddress,
      required this.photoAddressUrl});

//final LatLng addressLatLng;



}