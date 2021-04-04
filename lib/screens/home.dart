import 'dart:convert';

import 'package:daily_monitoring/screens/absen.dart';
import 'package:daily_monitoring/screens/daily.dart';
import 'package:daily_monitoring/screens/history.dart';
import 'package:daily_monitoring/screens/perfoma.dart';
import 'package:daily_monitoring/screens/profile.dart';
import 'package:daily_monitoring/screens/weekly.dart';
import 'package:daily_monitoring/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slide_popup_dialog/slide_popup_dialog.dart' as slideDialog;
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {


  SharedPreferences prefs;
  var f = new DateFormat('yyyy');
  var now = new DateTime.now();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadPrefs();
    repeatPermission();
  }

  String id_user;
  void loadPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      id_user = prefs.getString('id_user');
      getProfile(id_user);
    });
  }

  String urlImageProfile = "http://blocservice.fanforfan.online/assets/image_profile/profile.png";
  void getProfile(String id_user) async {
    var url = Constant.UPDATE_PROFILE + id_user;
    var response = await http.get(
        url,
        headers: {'Accept': 'application/json'}
    );
    var dataProfile = json.decode(response.body);
    if (dataProfile.length != 0) {
      if(dataProfile['status'] == 'success'){
        setState(() {
          urlImageProfile = 'http://blocservice.fanforfan.online/assets/image_profile/'+dataProfile['image_profile'];
        });
      }else{
        setState(() {
          urlImageProfile = "http://blocservice.fanforfan.online/assets/image_profile/profile.png";
        });
      }
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
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.9,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: Text("Daily Monitoring", style: TextStyle(color: Colors.orange[900], fontSize: 17),),
                  ),
                  Padding(padding: EdgeInsets.only(top: 20)),
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: NetworkImage(urlImageProfile),
                          fit: BoxFit.cover
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(top: 8)),
                  Container(
                    width: 200,
                    child: FlatButton(
                      onPressed: (){
                        _showDialog();
                      },
                      child: Icon(Icons.settings, color: Colors.orange[900],),
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(top: 40)),
                  Row(
                    children: [
                      Padding(padding: EdgeInsets.only(left: 40)),
                      Expanded(
                        flex: 1,
                        child: FlatButton(
                          onPressed: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Absen()),
                            );
                          },
                          child: Container(
                            child: Column(
                              children: [
                                Padding(padding: EdgeInsets.only(top: 20)),
                                Image.asset('assets/absensi.png', width: 46, color: Colors.black54,),
                                Padding(padding: EdgeInsets.only(top: 10)),
                                Center(
                                  child: Text("Absen", style: TextStyle(color: Colors.orange[900]),),
                                ),
                                Padding(padding: EdgeInsets.only(top: 20)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: FlatButton(
                          onPressed: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Daily()),
                            );
                          },
                          child: Container(
                            child: Column(
                              children: [
                                Padding(padding: EdgeInsets.only(top: 20)),
                                Image.asset('assets/event.png', width: 46, color: Colors.black54,),
                                Padding(padding: EdgeInsets.only(top: 10)),
                                Center(
                                  child: Text("Daily", style: TextStyle(color: Colors.orange[900]),),
                                ),
                                Padding(padding: EdgeInsets.only(top: 20)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: FlatButton(
                          onPressed: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Performa()),
                            );
                          },
                          child: Container(
                            child: Column(
                              children: [
                                Padding(padding: EdgeInsets.only(top: 20)),
                                Image.asset('assets/performa.png', width: 46, color: Colors.black54,),
                                Padding(padding: EdgeInsets.only(top: 10)),
                                Center(
                                  child: Text("Performa", style: TextStyle(color: Colors.orange[900]),),
                                ),
                                Padding(padding: EdgeInsets.only(top: 20)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(right: 40)),
                    ],
                  ),
                  Row(
                    children: [
                      Padding(padding: EdgeInsets.only(left: 40)),
                      Expanded(
                        flex: 1,
                        child: FlatButton(
                          onPressed: (){},
                          child: Container(),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: FlatButton(
                          onPressed: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Weekly()),
                            );
                          },
                          child: Container(
                            child: Column(
                              children: [
                                Padding(padding: EdgeInsets.only(top: 20)),
                                Image.asset('assets/weekly.png', width: 46, color: Colors.black54,),
                                Padding(padding: EdgeInsets.only(top: 10)),
                                Center(
                                  child: Text("Weekly", style: TextStyle(color: Colors.orange[900]),),
                                ),
                                Padding(padding: EdgeInsets.only(top: 20)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: FlatButton(
                          onPressed: (){},
                          child: Container(),
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(right: 40)),
                    ],
                  )
                ],
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height*0.1,
              child: Center(
                child: Text("Copyright " + f.format(DateTime.now()) + " \u00a9 daily_monitoring - it team", style: TextStyle(fontSize: 11, color: Colors.orange[300])),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showDialog(){
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(20.0)), //this right here
            child: Container(
              height: 200,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FlatButton(
                        onPressed: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Profile()),
                          );
                        },
                        child: Row(
                          children: [
                            Icon(Icons.arrow_forward_ios, size: 11, color: Colors.orange[900],),
                            Text(" Edit profil", style: TextStyle(color: Colors.black54),)
                          ],
                        )
                    ),
                    FlatButton(
                        onPressed: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => History()),
                          );
                        },
                        child: Row(
                          children: [
                            Icon(Icons.arrow_forward_ios, size: 11, color: Colors.orange[900],),
                            Text(" History of your task", style: TextStyle(color: Colors.black54),)
                          ],
                        )
                    ),
                    FlatButton(
                        onPressed: (){
                          prefs.clear();
                          Navigator.pushReplacementNamed(context, '/screens/login');
                        },
                        child: Row(
                          children: [
                            Icon(Icons.arrow_forward_ios, size: 11, color: Colors.orange[900],),
                            Text(" Logout", style: TextStyle(color: Colors.black54),)
                          ],
                        )
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  // void _showDialog() {
  //   slideDialog.showSlideDialog(
  //       context: context,
  //       child: Container()
  //   );
  // }
}
