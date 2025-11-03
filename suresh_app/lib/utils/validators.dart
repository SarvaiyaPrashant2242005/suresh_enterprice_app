class Validators {
  static bool isValidPhoneNumber(String? mobile) {
    if (mobile == null) return false;
    return RegExp(r'^[6-9]\d{9}$').hasMatch(mobile);
  }

  static bool isValidAccountNumber(String? accountNum) {
    if (accountNum == null) return false;
    return RegExp(r'^\d{9,18}$').hasMatch(accountNum);
  }

  static bool isValidIfscCode(String? ifscCode) {
    if (ifscCode == null) return false;
    return RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(ifscCode);
  }

  static bool isValidGstNumber(String? gstNumber) {
    if (gstNumber == null) return false;
    return RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$').hasMatch(gstNumber);
  }

  static bool isValidHsnCode(String? hsnCode) {
    if (hsnCode == null) return false;
    return RegExp(r'^\d{4}(\d{2})?(\d{2})?$').hasMatch(hsnCode);
  }

  static bool isValidUserName(String? name) {
    if (name == null) return false;
    return RegExp(r'^[A-Za-z .]+$').hasMatch(name);
  }

  static bool isValidEmail(String? email) {
    if (email == null) return false;
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
  }

  static bool isValidPrice(String? price) {
    if (price == null) return false;
    return RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(price);
  }

  static bool isNotEmpty(String? value) {
    return value != null && value.trim().isNotEmpty;
  }
}