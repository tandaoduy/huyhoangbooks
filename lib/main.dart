import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:huyhoangbooks/pages/page_home.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://hezravfbckbbkrilzkyb.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhlenJhdmZiY2tiYmtyaWx6a3liIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAzMTgzNDgsImV4cCI6MjA5NTg5NDM0OH0.mo5NGk6v94ZoquUq9vmFMV1CEAAMWOaW7-xAcjaL7ss',
  );

  runApp(const BookstoreApp());
}

class BookstoreApp extends StatelessWidget {
  const BookstoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Huy Hoang Books',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFFEF4D2F),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: PageHome(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, this.title});

  final String? title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return PageHome();
  }
}
