import 'package:daily_monitoring/screens/absen.dart';
import 'package:daily_monitoring/screens/home.dart';
import 'package:daily_monitoring/screens/login.dart';
import 'package:daily_monitoring/screens/perfoma.dart';
import 'package:daily_monitoring/screens/splash.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Monitoring',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Splash(),
      routes: <String,WidgetBuilder>{
        '/screens/home':(BuildContext context)=> Home(),
        '/screens/login':(BuildContext context)=> Login(),
        '/screens/performa':(BuildContext context)=> Performa()
      },
    );
  }
}
