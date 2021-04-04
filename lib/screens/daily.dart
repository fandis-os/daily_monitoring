import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:async';

import 'package:daily_monitoring/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:path/path.dart';
import 'package:async/async.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:select_form_field/select_form_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Daily extends StatefulWidget {
  @override
  _DailyState createState() => _DailyState();
}

class _DailyState extends State<Daily> {

  ProgressDialog pr;
  double percentage = 0.0;

  final List<Map<String, dynamic>> _itemYesNo = [
    {
      'value': 'Selesai',
      'label': '  Selesai',
      'icon': Icon(Icons.arrow_forward_ios, size: 8, color: Colors.green),
      'textStyle': TextStyle(color: Colors.green),
    },
    {
      'value': 'Belum Selesai',
      'label': '  Belum',
      'icon': Icon(Icons.arrow_forward_ios, size: 8, color: Colors.red),
      'textStyle': TextStyle(color: Colors.red),
    }
  ];

  final List<Map<String, dynamic>> _itemPic = [
    {
      'value': '1',
      'label': '  Joko Nursapto',
      'icon': Icon(Icons.arrow_forward_ios, size: 8, color: Colors.deepOrange),
      'textStyle': TextStyle(color: Colors.deepOrange),
    },
  ];

  TextEditingController _controllerYesNo;
  TextEditingController _controllerPic;
  String _valueChangedYesNo = '';
  String _valueChangedPic = '';

  TextEditingController _controllerItem = new TextEditingController();
  TextEditingController _controllerTanggal = new TextEditingController();
  TextEditingController _controllerTimeStart = new TextEditingController();
  TextEditingController _controllerTimeFinish = new TextEditingController();
  TextEditingController _controllerKeterangan = new TextEditingController();

  String messageImg = "Need a photos to evidence.";
  String messageField = "";
  String idImage = '';

  File _image;
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPrefs();
    getLoc();
    repeatPermission();
  }

  String id_user;
  void getPrefs() async {
    SharedPreferences prf = await SharedPreferences.getInstance();
    setState(() {
      id_user = prf.getString('id_user');
    });
  }

  LocationData _currentPosition;
  String _address,_dateTime;
  GoogleMapController mapController;
  Marker marker;
  Location location = Location();
  GoogleMapController _controller;
  LatLng _initialcameraposition = LatLng(0.5937, 0.9629);
  String lat;
  String lng;
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
        getLoc();
      }
    }
  }

  getLoc() async {
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

    _currentPosition = await location.getLocation();

    LatLng(_currentPosition.latitude,_currentPosition.longitude);
    location.onLocationChanged.listen((LocationData currentLocation) {
      print("${currentLocation.longitude} : ${currentLocation.longitude}");
      setState(() {
        _currentPosition = currentLocation;
        _initialcameraposition = LatLng(_currentPosition.latitude,_currentPosition.longitude);

        DateTime now = DateTime.now();
        _dateTime = DateFormat('EEE d MMM kk:mm:ss ').format(now);
        _getAddress(_currentPosition.latitude, _currentPosition.longitude)
            .then((value) {
          setState(() {
            _address = "${value.first.addressLine}";
            lat = "${_currentPosition.latitude}";
            lng = "${_currentPosition.longitude}";
            print("${_address}");
          });
        });
      });
    });
  }

  Future<List<Address>> _getAddress(double lat, double lang) async {
    final coordinates = new Coordinates(lat, lang);
    List<Address> add =
    await Geocoder.local.findAddressesFromCoordinates(coordinates);
    return add;
  }

  @override
  Widget build(BuildContext context) {

    pr = ProgressDialog(
      context,
      type: ProgressDialogType.Download,
      isDismissible: true
    );

    pr.style(
      message: "Submiting Daily",
      borderRadius: 10,
      backgroundColor: Colors.white,
      elevation: 10,
      insetAnimCurve: Curves.easeInOut,
      progress: 0.0,
      progressWidgetAlignment: Alignment.center,
      maxProgress: 100.0,
      progressTextStyle: TextStyle(
          color: Colors.deepOrange, fontSize: 12.0, fontWeight: FontWeight.w400
      ),
      messageTextStyle: TextStyle(
          color: Colors.deepOrangeAccent, fontSize: 18.0, fontWeight: FontWeight.w500
      )
    );

    return Scaffold(
      body: Container(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(left: 40, right: 40),
            child: Column(
              children: [
                Padding(padding: EdgeInsets.only(top: 60)),
                Text("Form Daily Monitoring", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                Padding(padding: EdgeInsets.only(top: 20)),
                _address == null
                    ? Container(
                  child: Text("Identifikasi lokasi..."),
                )
                    : Container(
                  child: Column(
                      children: [
                        Text("Keberadaanmu Terdeteksi di sekitar"),

                        Padding(padding: EdgeInsets.only(top: 6)),
                        Text("${_address}", style: TextStyle(color: Colors.black54),),
                        Padding(padding: EdgeInsets.only(top: 6)),
                        Text("${lat}, ${lng}", style: TextStyle(color: Colors.black38),),
                      ],
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 8)),
                Text(messageField, style: TextStyle(fontSize: 12, color: Colors.red),),
                TextFormField(
                  controller: _controllerItem,
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.list_rounded),
                      labelText: 'Item to do',
                      border: OutlineInputBorder()
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 8)),
                GestureDetector(
                  onTap: (){
                    DatePicker.showDatePicker(context,
                        showTitleActions: true,
                        minTime: DateTime(2019,1,1),
                        maxTime: DateTime(2022,12,12),
                        theme: DatePickerTheme(
                          headerColor: Colors.white70,
                          backgroundColor: Colors.white54,
                          itemStyle: TextStyle(
                              color: Colors.black54
                          ),
                          doneStyle: TextStyle(color: Colors.black54),
                        ),
                        onChanged: (date){
                          print('change $date in time zone ' + date.timeZoneOffset.inHours.toString());
                          String tanggal = DateFormat("yyyy-MM-dd").format(DateTime.parse('$date'));
                          setState(() {
                            _controllerTanggal = new TextEditingController(text: '${tanggal}');
                          });
                        },
                        onConfirm: (date){
                          print('confirm $date');
                          // String tanggal = DateFormat('d MMM yyyy').format(DateTime.parse('$date'));
                          String tanggal = DateFormat("yyyy-MM-dd").format(DateTime.parse('$date'));
                          setState(() {
                            _controllerTanggal = new TextEditingController(text: '${tanggal}');
                          });
                        },
                        currentTime: DateTime.now(), locale: LocaleType.en
                    );
                  },
                  child: TextFormField(
                    enabled: false,
                    controller: _controllerTanggal,
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.date_range),
                        labelText: 'Tanggal',
                        border: OutlineInputBorder()
                    ),
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 8)),
                GestureDetector(
                  onTap: (){
                    DatePicker.showTimePicker(context, showTitleActions: true, onChanged: (date) {
                      String startTime = DateFormat("HH:mm").format(DateTime.parse('$date'));
                      print('change $date in time zone ' + date.timeZoneOffset.inHours.toString());
                      setState(() {
                        _controllerTimeStart = new TextEditingController(text: '${startTime}');
                      });
                    }, onConfirm: (date) {
                      print('confirm $date');
                      String startTime = DateFormat("HH:mm").format(DateTime.parse('$date'));
                      setState(() {
                        _controllerTimeStart = new TextEditingController(text: '${startTime}');
                      });
                    }, currentTime: DateTime.now());
                  },
                  child: TextFormField(
                    enabled: false,
                    controller: _controllerTimeStart,
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.timer),
                        labelText: 'Start',
                        border: OutlineInputBorder()
                    ),
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 8)),
                GestureDetector(
                  onTap: (){
                    DatePicker.showTimePicker(context, showTitleActions: true, onChanged: (date) {
                      String finishTime = DateFormat("HH:mm").format(DateTime.parse('$date'));
                      print('change $date in time zone ' + date.timeZoneOffset.inHours.toString());
                      setState(() {
                        _controllerTimeFinish = new TextEditingController(text: '${finishTime}');
                      });
                    }, onConfirm: (date) {
                      print('confirm $date');
                      String finishTime = DateFormat("HH:mm").format(DateTime.parse('$date'));
                      setState(() {
                        _controllerTimeFinish = new TextEditingController(text: '${finishTime}');
                      });
                    }, currentTime: DateTime.now());
                  },
                  child: TextFormField(
                    enabled: false,
                    controller: _controllerTimeFinish,
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.timer_off),
                        labelText: 'Finish',
                        border: OutlineInputBorder()
                    ),
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 8)),
                SelectFormField(
                  controller: _controllerYesNo,
                  initialValue: '',
                  icon: Icon(Icons.playlist_add_check_sharp),
                  labelText: 'Status',
                  items: _itemYesNo,
                  onChanged: (val){
                    setState(() {
                      _valueChangedYesNo = val;
                    });
                  },
                ),
                Padding(padding: EdgeInsets.only(top: 8)),
                _valueChangedYesNo == "Belum Selesai"
                    ? TextFormField(
                  controller: _controllerKeterangan,
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.warning_amber_outlined),
                      labelText: 'Keterangan Tindak Lanjut',
                      border: OutlineInputBorder()
                  ),
                )
                    : Container(),
                Padding(padding: EdgeInsets.only(top: 8)),
                SelectFormField(
                  controller: _controllerPic,
                  initialValue: '',
                  icon: Icon(Icons.account_circle_outlined),
                  labelText: 'Report to',
                  items: _itemPic,
                  onChanged: (val){
                    setState(() {
                      _valueChangedPic = val;
                    });
                  },
                ),
                Padding(padding: EdgeInsets.only(top: 20)),
                FlatButton(
                  onPressed: getImage,
                  child: Icon(Icons.add_a_photo, color: Colors.black38,),
                ),
                Container(
                  child: _image == null
                      ? Container(
                    padding: EdgeInsets.only(top: 30),
                    child: Text(messageImg, style: TextStyle(color: Colors.black38),),
                  )
                      : Padding(
                    padding: EdgeInsets.only(top: 30),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(_image),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(top: 40, bottom: 20),
                  child: FlatButton(
                    child: Text("Submit", style: TextStyle(color: Colors.black38),),
                    onPressed: () async {
                      if(_address==null){
                        repeatPermission();
                      }else if(_controllerItem.text == ""){
                        setState(() {
                          messageField = "Item todo harus di isi";
                        });
                      }else if(_controllerTanggal.text == ""){
                        setState(() {
                          messageField = "Tanggal harus di isi";
                        });
                      }else if(_controllerTimeStart.text == ""){
                        setState(() {
                          messageField = "Time start harus di isi";
                        });
                      }else if(_controllerTimeFinish.text == ""){
                        setState(() {
                          messageField = "Time finish harus di isi";
                        });
                      }else if(_image == null){
                        setState(() {
                          messageImg = "Shot a photo to evidence.";
                        });
                      }else{
                        await pr.show();

                        Future.delayed(Duration(seconds: 2)).then((onValue){
                          percentage = percentage + 10.0;
                          pr.update(
                            progress: percentage,
                            message: "Please wait...",
                              progressWidget: Container(
                                  padding: EdgeInsets.all(8.0),
                                  child: CircularProgressIndicator()
                              ),
                              maxProgress: 100.0,
                              progressTextStyle: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w400
                              ),
                              messageTextStyle: TextStyle(
                                color: Colors.deepOrangeAccent,
                                fontSize: 18.0,
                                fontWeight: FontWeight.w500,
                              )
                          );
                        });
                        Future.delayed(Duration(seconds: 2)).then((value){
                          percentage = percentage + 10.0;
                          pr.update(
                              progress: percentage, message: "Few more seconds..."
                          );
                          print(percentage);
                          Future.delayed(Duration(seconds: 2)).then((value){
                            percentage = percentage + 10.0;
                            pr.update(progress: percentage, message: "Almost done...");
                            print(percentage);

                            Future.delayed(Duration(seconds: 2)).then((value){
                              pr.hide().whenComplete((){
                                print(pr.isShowing());
                              });
                              percentage = 0.0;
                              setState(() {
                                _image = null;
                              });
                            });
                          });
                        });

                        Future.delayed(Duration(seconds: 10)).then((onValue){
                          print("PR status ${pr.isShowing()}");
                          if(pr.isShowing())
                            pr.hide().then((isHidden){
                              print(isHidden);
                            });
                          print("PR status ${pr.isShowing()}");
                        });

                        setState(() {
                          Random _random = Random.secure();
                          var values = List<int>.generate(32, (i) => _random.nextInt(256));
                          idImage = base64Url.encode(values);
                        });

                        upload(_image,_controllerItem.text,_controllerTanggal.text,_controllerTimeStart.text,_controllerTimeFinish.text,_valueChangedYesNo,_controllerKeterangan.text,idImage,lat,lng, _valueChangedPic, context);
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future upload(File imageFile, String itemTodo, String tanggal, String start, String finish, String status, String keterangan, String idImage, String lat, String lng, String valueChangedPic, BuildContext context) async {

    if(keterangan == ""){
      setState(() {
        keterangan = "-";
      });
    }

    var stream = new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    var length = await imageFile.length();
    var uri = Uri.parse(Constant.DAILY);

    var request = new http.MultipartRequest("POST", uri);
    var multipartFile = new http.MultipartFile("file", stream, length, filename: basename(imageFile.path));
    request.files.add(multipartFile);
    request.fields['list_to_do'] = itemTodo;
    request.fields['status'] = status;
    request.fields['tanggal'] = tanggal;
    request.fields['keterangan'] = keterangan;
    request.fields['id_user']    = id_user;
    request.fields['tindak_lanjut'] = keterangan;
    request.fields['start'] = start;
    request.fields['finish'] = finish;
    request.fields['lat'] = lat;
    request.fields['lng'] = lng;

    var response = await request.send();

    print(response.statusCode);
    if(response.statusCode==200){
      print("Success ${response.statusCode}");
      _controllerItem.clear();
      _controllerTanggal.clear();
      _controllerTimeStart.clear();
      _controllerTimeFinish.clear();
      _controllerPic.clear();
    }else{
      print("Fail");
    }
  }
}

