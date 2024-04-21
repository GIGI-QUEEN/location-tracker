import 'dart:math';

String? signUpEmailValidator(String? value) {
  if (value!.isEmpty ||
      !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
    return 'Please enter a valid email';
  }
  return null;
}

String? signUpPasswordValidator(value) {
  if (value!.isEmpty || value.length < 6) {
    return 'Password must be at least 6 characters';
  }
  return null;
}

String? loginEmailValidator(String? value) {
  if (value!.isEmpty) {
    return 'Please, enter email';
  }
  return null;
}

String? loginPasswordValidator(String? value) {
  if (value!.isEmpty) {
    return 'Please, enter password';
  }
  return null;
}

double generateRandomLatitude() {
  return Random().nextDouble() * 180 - 90;
}

double generateRandomLongitude() {
  return Random().nextDouble() * 360 - 180;
}