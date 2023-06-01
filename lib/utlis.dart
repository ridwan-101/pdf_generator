import 'package:intl/intl.dart';

class Utils {
  static formatPrice(double price) => '\$ ${price.toStringAsFixed(2)}';
  static formatDate(DateTime date, Type font) => DateFormat.yMd().format(date);
}
