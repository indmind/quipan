import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quizpancasila/presentation/constants/colors.dart';
import 'package:quizpancasila/presentation/screens/home_screen.dart';
import 'package:quizpancasila/presentation/utils/sound_player.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  Get.put<SoundPlayer>(
    SoundPlayerImpl(),
    permanent: true,
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Quiz Pancasila',
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.size,
      theme: ThemeData(
        primaryColor: kPrimaryColor,
        scaffoldBackgroundColor: kBackgroundColor,
        textTheme: GoogleFonts.workSansTextTheme(const TextTheme(
          bodyText1: TextStyle(color: kTextColor),
          headline4: TextStyle(color: kTextColor, fontWeight: FontWeight.bold),
        )),
        appBarTheme: const AppBarTheme(
          toolbarHeight: 60,
          color: kBackgroundColor,
          elevation: 0,
          foregroundColor: kTextColor,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: kTextColor,
          ),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: kPrimaryColor,
            statusBarIconBrightness: Brightness.dark,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            primary: kPrimaryColor,
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
