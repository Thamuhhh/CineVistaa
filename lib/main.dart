import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/movie_provider.dart';
import 'screens/main_navigation.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const MovieReviewApp());
}

class MovieReviewApp extends StatelessWidget {
  const MovieReviewApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MovieProvider()),
      ],
      child: MaterialApp(
        title: 'CineVistaa',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF000000), // True black for streaming
          primaryColor: const Color(0xFF7B2FFF), // Disney+ Royal Purple accent
          textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF000000),
            elevation: 0,
          ),
          colorScheme: const ColorScheme.dark(
            primary: Colors.white,
            secondary: Color(0xFF7B2FFF),
            surface: Color(0xFF141414), // Dark Grey for cards
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
