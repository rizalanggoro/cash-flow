import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

@Deprecated('Gunakan extension')
TextTheme useTextTheme() {
  final context = useContext();
  return Theme.of(context).textTheme;
}

@Deprecated('Gunakan extension')
ColorScheme useColorScheme() {
  final context = useContext();
  return Theme.of(context).colorScheme;
}

@Deprecated('Gunakan extension')
void useSnackBar({required String message}) =>
    ScaffoldMessenger.of(useContext()).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );