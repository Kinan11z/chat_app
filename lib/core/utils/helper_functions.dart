import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class HelperFunctions {
  static String localDateTime(String date) {
    return DateFormat.yMMMEd().format(
      DateTime.fromMillisecondsSinceEpoch(
        int.parse(date),
      ),
    );
  }

  static Future<File?> pickImage() async {
    ImagePicker picker = ImagePicker();
    XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      return File(picked.path);
    }
    return null;
  }
}
