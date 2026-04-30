import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vitatrack_1/core/theme.dart';
import 'package:flutter_vitatrack_1/core/constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_vitatrack_1/features/auth/presentation/widgets/auth_wrapper.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: VitaTrackApp()));
}

class VitaTrackApp extends StatelessWidget {
  const VitaTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: VitaTrackConstants.tenApp,
      debugShowCheckedModeBanner: false,
      theme: VitaTrackTheme.layTheme(),
      home: const AuthWrapper(),
    );
  }
}