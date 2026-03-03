import 'package:flutter/material.dart';

const kPrimaryColor = Color(0xFFFF9800);
const kAccentColor = Color(0xFFFFB74D);  
const kTextBlack = Color(0xFF424242);
const kTextGrey = Color(0xFF757575);

const kDefaultGradient = LinearGradient(
  colors: [kPrimaryColor, kAccentColor],
  begin: Alignment.topCenter,
  end: Alignment.bottomRight,
);

InputDecoration kInputDecoration({
  required String labelText,
  required IconData prefixIcon,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    labelText: labelText,
    labelStyle: const TextStyle(color: kTextGrey),
    prefixIcon: Icon(prefixIcon, color: kAccentColor),
    suffixIcon: suffixIcon,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    filled: true,
    fillColor: Colors.grey.shade50,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: kPrimaryColor),
    ),
  );
}

const kHeaderStyle = TextStyle(
  fontSize: 28,
  fontWeight: FontWeight.bold,
  color: kPrimaryColor,
);

const kSubHeaderStyle = TextStyle(
  fontSize: 16,
  color: kTextGrey,
);

const kButtonTextStyle = TextStyle(
  fontSize: 16,
  color: Colors.white,
  fontWeight: FontWeight.bold,
);

const kLinkTextStyle = TextStyle(
  color: kPrimaryColor,
  fontWeight: FontWeight.w600,
);