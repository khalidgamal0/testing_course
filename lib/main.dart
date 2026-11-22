import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/core/services/get_it.dart';

export 'src/app.dart';

void main() {
  setupDependencies();
  runApp(const MyApp());
}
