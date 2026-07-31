import 'package:flutter/material.dart';

/// Breakpoint sederhana: di bawah lebar ini dianggap layar HP,
/// di atasnya dianggap tablet/laptop dan sidebar ditampilkan permanen.
const double kMobileBreakpoint = 760;

bool isMobileWidth(BuildContext context) {
  return MediaQuery.of(context).size.width < kMobileBreakpoint;
}