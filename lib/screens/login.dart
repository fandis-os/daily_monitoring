import 'dart:convert';

import 'package:daily_monitoring/screens/home.dart';
import 'package:daily_monitoring/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  SharedPreferences prefs;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // checkPrefs();
    repeatPermission();
  }

  var f = new DateFormat('yyyy');
  var now = new DateTime.now();

  TextEditingController username = new TextEditingController();
  TextEditingController password = new TextEditingController();

  ProgressDialog pr;
  String msg = '';
  bool _showPassword = false;
  void _togglevisibility(){
    setState(() {
      _showPassword = !_showPassword;
    });
  }

  Future<List> login() async {
    var url = Constant.LOGIN;
    final response = await http.post(
        url,
        body: {
          "username":username.text,
          "password":password.text
        },
        headers: {"Accept": "application/json"}
    );

    var dataUser = json.decode(response.body);
    if(dataUser.length!=0){
      if(dataUser['status']=="fail"){
        setState(() {
          msg = "Username atau password salah.";
        });
      }else{
        setState(() async {
          prefs = await SharedPreferences.getInstance();
          prefs.setString('username', dataUser['username']);
          prefs.setString('id_user', dataUser['id_users']);
          prefs.setString('islogin', 'yes');
          prefs.setString('level_user', dataUser['level_user']);
          Navigator.pushReplacementNamed(context, '/screens/home');
        });
      }
    }else{
      setState(() {
        msg = "Ada yang salah.";
      });
    }
  }

  Location location = Location();
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  repeatPermission() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    pr = new ProgressDialog(context, showLogs: true);
    pr.style(message: 'Please wait...');

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.only(left: 40.0, right: 40.0),
          child: Center(
            child: Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height*0.9,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/logo.png', width: 170,),
                      Padding(padding: EdgeInsets.only(top: 50)),
                      Text("Daily Monitoring Login"),
                      Padding(padding: EdgeInsets.only(bottom: 30)),
                      TextFormField(
                        controller: username,
                        decoration: InputDecoration(
                            prefixIcon: Icon(Icons.account_circle),
                            labelText: 'Username',
                            border: OutlineInputBorder()
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(top: 5)),
                      TextFormField(
                        controller: password,
                        obscureText: !_showPassword,
                        decoration: InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.vpn_key),
                            suffixIcon: GestureDetector(
                              onTap: (){
                                _togglevisibility();
                              },
                              child: Icon(
                                _showPassword ? Icons.visibility : Icons.visibility_off, color: Colors.blue,
                              ),
                            )
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(top: 15.0),),
                      Container(
                        alignment: Alignment.centerRight,
                        child: Text("Forgot Password?", style: TextStyle(color: Colors.deepOrange, fontSize: 11.0),),
                      ),
                      Padding(padding: EdgeInsets.only(top: 22.0),),
                      SizedBox(
                        width: double.infinity,
                        height: 50.0,
                        child: RaisedButton(
                          child: Text("Login", style: TextStyle(color: Colors.white),),
                          color: Color.fromRGBO(10, 102, 204, 100),
                          onPressed: (){
                            if(username.text == ""){
                              setState(() {
                                msg = "Username harus di isi.";
                              });
                            }else if(password.text == ""){
                              setState(() {
                                msg = "Password harus di isi.";
                              });
                            }else{
                              pr.show();
                              print("ANJINNNNNNNNNGGGG");
                              Future.delayed(Duration(seconds: 3)).then((value){
                                pr.hide().whenComplete((){
                                  login();
                                });
                              });
                            }
                          },
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(top: 10.0),),
                      Text(msg, style: TextStyle(fontSize: 11.0, color: Colors.red),),
                      Padding(padding: EdgeInsets.only(top: 20.0),),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text("Don't have account?", style: TextStyle(fontSize: 11),),
                          FlatButton(
                            onPressed: (){},
                            child: Text("contact admin to create account", style: TextStyle(color: Colors.blue, fontSize: 11),),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height*0.1,
                  child: Center(
                    child: Text("Copyright " + f.format(DateTime.now()) + " \u00a9 daily_monitoring - it team", style: TextStyle(fontSize: 11, color: Colors.blueGrey)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // void checkPrefs() async {
  //   prefs = await SharedPreferences.getInstance();
  //   if(prefs.getString('islogin') == 'yes'){
  //     Navigator.pushReplacementNamed(context, '/screens/home');
  //   }
  // }
}
