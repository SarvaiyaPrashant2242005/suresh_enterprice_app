import 'package:flutter/material.dart';

mixin FormValidationMixin<T extends StatefulWidget> on State<T> {
  Map<String, String> errors = {};
  
  void setError(String field, String? error) {
    setState(() {
      if (error != null) {
        errors[field] = error;
      } else {
        errors.remove(field);
      }
    });
  }

  bool validateField(String field, String? value, bool Function(String?) validator, String errorMessage) {
    bool isValid = validator(value);
    setError(field, isValid ? null : errorMessage);
    return isValid;
  }

  bool validateFields(Map<String, ValidationRule> validations) {
    bool isValid = true;
    validations.forEach((field, rule) {
      if (!validateField(field, rule.value, rule.validator, rule.errorMessage)) {
        isValid = false;
      }
    });
    return isValid;
  }

  /// Convenience validator used directly from `TextFormField.validator` callbacks.
  /// Returns an error string when the value is empty, otherwise null.
  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
}

class ValidationRule {
  final String? value;
  final bool Function(String?) validator;
  final String errorMessage;

  ValidationRule({
    required this.value,
    required this.validator,
    required this.errorMessage,
  });
}