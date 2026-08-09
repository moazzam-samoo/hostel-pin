import 'package:intl/intl.dart';

class Formatters {
  static final _currencyFormat = NumberFormat.currency(
    symbol: 'Rs ',
    decimalDigits: 0,
  );

  static final _compactFormat = NumberFormat.compact();

  static String currency(num amount) {
    return _currencyFormat.format(amount);
  }

  static String period(num amount, {String period = 'month'}) {
    return '${currency(amount)}/$period';
  }

  static String compact(num amount) {
    return _compactFormat.format(amount).toLowerCase();
  }

  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}
