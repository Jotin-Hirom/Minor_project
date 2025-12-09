import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:classqr/core/config/env.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock device orientation to portrait mode
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Load environment variables (optional)
  await Env.load(); // keep whatever Env.load does in your project

  // Enable Material 3 edge-to-edge UI
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Wrap the app in ProviderScope so Riverpod works app-wide
  runApp(const ProviderScope(child: App()));
}




  // cupertino_icons: ^1.0.2
  // google_fonts: ^4.0.4
  // firebase_database: ^10.1.0
  // simple_animations: ^5.0.0+3
  // flutter_svg: ^2.0.4
  // lottie: ^2.3.1
  // cloud_firestore: ^4.5.0
  // firebase_auth: ^4.4.0
  // google_sign_in: ^6.1.0
  // animated_text_kit: ^4.2.2
  // shared_preferences: ^2.1.0
  // provider: ^6.0.5
  // searchbar_animation: ^0.0.4
  // easy_loading_button: ^0.3.2
  // flutter_loadingindicator: ^1.0.1
  // awesome_dialog: ^3.0.2
  // syncfusion_flutter_charts: ^21.1.39
  // multi_dropdown: ^1.0.9
  // slide_countdown: ^0.5.0
  // liquid_pull_to_refresh: ^3.0.1
  // flutter_staggered_animations: ^1.1.1
  // shimmer: ^2.0.0
  // connectivity_plus: ^4.0.1
  // anim_search_bar: ^2.0.3
  // animated_splash_screen: ^1.3.0
  // flutter_launcher_icons: ^0.13.1
  // flutter_native_splash: ^2.2.19
  // http: ^0.13.6
  // emailjs: ^1.1.0
  // firebase_core: ^2.9.0