import 'package:cloud_firestore/cloud_firestore.dart';

int getCurrentValue(
  QuerySnapshot<Object?> listOfData,
  String attribute,
) {
  List<int> itemId = [];

  // get all id from database
  for (var data in listOfData.docs) {
    String value = data[attribute];
    String convertedValue = value.replaceAll(RegExp(r'[^0-9]'), '');
    itemId.add(int.parse(convertedValue));
  }

  // sort in descending order
  itemId.sort((a, b) => b.compareTo(a));

  return itemId.isEmpty ? 0 : itemId[0];
}

String generateCode(
  String prefix,
  int currentValue,
) {
  // increment value
  currentValue++;
  return '$prefix${currentValue.toString().padLeft(4, '0')}';
}
