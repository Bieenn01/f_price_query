// Function to format date
import 'package:intl/intl.dart';

String formatDate(dynamic dateTime) {
  try {
    // If the date is a String, parse it
    if (dateTime is String) {
      DateTime parsedDate = DateTime.parse(dateTime);
      return DateFormat('yyyy-MM-dd').format(parsedDate);
    } else if (dateTime is DateTime) {
      // If it's already a DateTime object, format it directly
      return DateFormat('yyyy-MM-dd').format(dateTime);
    } else {
      // If the type is unexpected, return the raw value
      return dateTime.toString();
    }
  } catch (e) {
    print("Error formatting date: $e");
    return dateTime.toString(); // Return the original if there's an error
  }
}
