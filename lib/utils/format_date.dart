import 'package:intl/intl.dart';

String formatDateBydMMMYYYY(DateTime dateTime) {
  return DateFormat('d MMM, yyyy').format(dateTime);
}

String formatDateBydMy(DateTime dateTime) {
  return DateFormat('d/M/y').format(dateTime);
}

String formatDateByMMM(DateTime dateTime) {
  return DateFormat('MMM').format(dateTime);
}

String formatDateByYYYY(DateTime dateTime) {
  return DateFormat('yyyy').format(dateTime);
}
