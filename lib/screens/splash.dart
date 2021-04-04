import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {

  SharedPreferences prefs;
  var pindahnya;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startSplash();
  }

  startSplash() async {
    prefs = await SharedPreferences.getInstance();
    var duration = const Duration(seconds: 5);
    return Timer(duration, (){
      if(prefs.getString('islogin') == 'yes'){
        Navigator.pushReplacementNamed(context, '/screens/home');
      }else{
        Navigator.pushReplacementNamed(context, '/screens/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xffff6600),
        height: double.infinity,
        child: Center(
          child: Image.asset('assets/logo.png', width: 170,),
        ),
      ),
    );
  }

}
