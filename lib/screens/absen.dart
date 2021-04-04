import 'dart:convert';

import 'package:daily_monitoring/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Absen extends StatefulWidget {
  @override
  _AbsenState createState() => _AbsenState();
}

class _AbsenState extends State<Absen> {

  TextEditingController _controllerKeterangan = new TextEditingController();

  double jarakmu;
  String jarakKarywanKantor;
  double latKaryawan;
  double lngKaryawan;

  ProgressDialog pr;
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // getLoc();
    getPrefs();
    getAllKantor().then((data){
      setState(() {
        lokasi_kantor = data;
        _showDialogChoiceKantor(lokasi_kantor);
      });
    });
  }

  List lokasi_kantor = [];
  getAllKantor() async {
    var url = Constant.GET_ALL_KANTOR;
    var response = await http.get(url);
    return json.decode(response.body);
  }

  String checking = '';
  String waktu = '';
  String jumlahAbsen = '';
  Future<List> cekAbsen() async {
    DateTime now = new DateTime.now();
    String formatter = DateFormat('y-M-d').format(now);
    print("ASUUU"+formatter);
    var url = Constant.CEK_ABSEN;
    final response = await http.post(
      url,
      body: {
        'id_user':id_user,
        'tanggal':formatter
      },
      headers: {"Accept": "application/json"}
    );

    var dataCek = json.decode(response.body);

    if(dataCek.length != 0){
      if(dataCek['status'] == "ada"){
        int idx = dataCek['waktu'].indexOf(" ");
        List parts = [dataCek['waktu'].substring(0,idx).trim(), dataCek['waktu'].substring(idx+1).trim()];
        setState(() {
          checking = '1';
          waktu = parts[1];
          jumlahAbsen = dataCek['jumlah'];
          print("ADA"+jumlahAbsen);
          print("CHECK"+checking);
        });
      }else{
        setState(() {
          checking = '0';
          waktu = DateFormat('hh : mm').format(now);
          jumlahAbsen = dataCek['jumlah'];
          print("CHECK"+checking);
        });
      }
    }else{
      print("Ada kesalahan"+jumlahAbsen);
    }
  }

  String id_user;
  void getPrefs() async {
    SharedPreferences prf = await SharedPreferences.getInstance();
    setState(() {
      id_user = prf.getString('id_user');
      cekAbsen();
    });
  }

  void getLokasiKantor(String id_kantor, double latKaryawan, double lngKaryawan) async {
    var url = Constant.LOKASI_KANTOR+id_kantor;
    print(url);
    final response = await http.get(
        url,
        headers: {"Accept": "application/json"}
    );

    var dataLokasiKantor = json.decode(response.body);
    if(dataLokasiKantor.length!=0){
      if(dataLokasiKantor['status']=="fail"){
        setState(() {
          final latKantor = 0;
          final lngKantor = 0;
          getJarak(latKaryawan, lngKaryawan, latKantor, lngKantor);
        });
      }else{
        setState(() {
          final latKantor = double.parse(dataLokasiKantor['lat']);
          final lngKantor = double.parse(dataLokasiKantor['lng']);
          getJarak(latKaryawan, lngKaryawan, latKantor, lngKantor);
        });
      }
    }
  }

  LocationData _currentPosition;
  Location location = Location();
  String lat;
  String lng;
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;

  void getLoc(String id_kantor) async {
    Navigator.pop(context);
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
    location.onLocationChanged.listen((LocationData currentLocation) {
      print("${currentLocation.longitude} : ${currentLocation.longitude}");
      setState(() {
        _currentPosition = currentLocation;
        latKaryawan = _currentPosition.latitude;
        lngKaryawan = _currentPosition.longitude;
        getLokasiKantor(id_kantor,latKaryawan,lngKaryawan);
      });
    });

  }

  void getJarak(double latKaryawan, double lngKaryawan, latKantor, lngKantor) {
    final pasarRumput = LatLng(latKaryawan, lngKaryawan);
    final kantor      = LatLng(latKantor, lngKantor);
    final distance    = SphericalUtil.computeDistanceBetween(pasarRumput, kantor) / 1000;
    setState(() {
      jarakmu = double.parse((distance).toStringAsFixed(2));
      jarakKarywanKantor = "${jarakmu} Km";
    });
  }



  Future<List> yesAbsen(String id_user, double latKaryawan, double lngKaryawan, double jarakmu, String keterangan, String statusAccept, String masukPulang) async {

    DateTime now = new DateTime.now();
    String formatter = DateFormat('y-M-d').format(now);

    String status_lokasi;
    if(jarakmu > 0.1){
      setState(() {
        status_lokasi = '0';
        print("NYAMPE GAK 0");
      });
    }else{
      setState(() {
        status_lokasi = '1';
        print("NYAMPE GAK 1");
      });
    }
    print("NYAMPE GAK ${status_lokasi} OK ${id_user}");
    var url = Constant.ABSEN;
    final response = await http.post(
        url,
        body: {
          "id_user":id_user,
          "lat":latKaryawan.toString(),
          "lng":lngKaryawan.toString(),
          "status_lokasi":status_lokasi,
          "keterangan":keterangan,
          "status_accept":statusAccept,
          "tanggal":formatter,
          "status":masukPulang
        },
        headers: {"Accept": "application/json"}
    );

    var dataAbsen = json.decode(response.body);

    print("BIASALAH "+masukPulang);

    if(dataAbsen.length!=0){
      if(dataAbsen['status']=="fail"){
        print("Anjeng Gagal");
        pr.hide();
      }else{
        pr.hide();
        // Navigator.pop(context);
        Navigator.pushReplacementNamed(context, '/screens/performa');
        _controllerKeterangan.clear();
        print("Anjeng Success BANGSATTT");
      }
    }else{
      print("KESALAHAN SISTEM");
      pr.hide();
    }

  }

  @override
  Widget build(BuildContext context) {

    pr = new ProgressDialog(context, showLogs: true);
    pr.style(message: 'Submiting absen...');

    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(left: 40, right: 40),
        child: Center(
          child: jarakmu == null
              ?
              Container(
                height: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/loading.gif', width: 200,),
                    Padding(padding: EdgeInsets.only(top: 30)),
                    Text("Calculating your distance.")
                  ],
                ),
              )
              :
              jarakmu > 0.1
              ?
              Container(
                height: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/absensi.jpg'),
                    Padding(padding: EdgeInsets.only(top: 20)),
                    Text("Kamu berada di luar area kantor.", style: TextStyle(color: Colors.red),),
                    Text("Apakah kamu sedang WFH?", style: TextStyle(color: Colors.red),),
                    Padding(padding: EdgeInsets.only(top: 30)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: OutlineButton(
                            borderSide: BorderSide(
                              width: 1.0,
                              color: Colors.red,
                              style: BorderStyle.solid,
                            ),
                            child: Text("Ya", style: TextStyle(color: Colors.red),),
                            onPressed: (){
                              _showDialog();
                            },
                          ),
                        ),
                        Padding(padding: EdgeInsets.only(left: 10,right: 10)),
                        Container(
                          child: OutlineButton(
                            borderSide: BorderSide(
                              width: 1.0,
                              color: Colors.blueAccent,
                              style: BorderStyle.solid,
                            ),
                            child: Text("Tidak", style: TextStyle(color: Colors.blueAccent),),
                            onPressed: (){
                              Navigator.pushReplacementNamed(context, '/screens/home');
                            },
                          ),
                        )
                      ],
                    )
                  ],
                ),
              )
              :
              Container(
                height: double.infinity,
                child: jumlahAbsen == '2' ?
                    Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/absensi.jpg'),
                          Padding(padding: EdgeInsets.only(top: 20)),
                          Text("Terimakasih Telah Bekerja dengan baik hari ini.", style: TextStyle(color: Colors.black54),),
                        ],
                      ),
                    ) :
                    Container(
                      child: checking == '1' ?
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/absensi.jpg'),
                          Padding(padding: EdgeInsets.only(top: 20)),
                          Text("Absen dulu sebelum pulang, terimakasih sudah bekerjsa dengan baik hari ini, hati hati di jalan, jaga kesehatan.", style: TextStyle(color: Colors.blueAccent),),
                          Padding(padding: EdgeInsets.only(top: 30)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("In ", style: TextStyle(color: Colors.green, fontSize: 13),),
                              Text("${waktu}", style: TextStyle(color: Colors.green[700], fontSize: 30),)
                            ],
                          ),
                          Padding(padding: EdgeInsets.only(top: 30)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                child: OutlineButton(
                                  borderSide: BorderSide(
                                    width: 1.0,
                                    color: Colors.lightBlue,
                                    style: BorderStyle.solid,
                                  ),
                                  child: Text("Pulang", style: TextStyle(color: Colors.lightBlue),),
                                  onPressed: (){
                                    pr.show();
                                    // 1 untuk PULANG
                                    yesAbsen(id_user, latKaryawan, lngKaryawan, jarakmu, '-','1','1');
                                  },
                                ),
                              ),
                            ],
                          )
                        ],
                      )
                          :
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/absensi.jpg'),
                          Padding(padding: EdgeInsets.only(top: 20)),
                          Text("Silakan absen, pakai masker dan jalankan protokol kesehatan.", style: TextStyle(color: Colors.blueAccent),),
                          Padding(padding: EdgeInsets.only(top: 30)),
                          Text("${waktu}", style: TextStyle(color: Colors.deepOrange, fontSize: 30),),
                          Padding(padding: EdgeInsets.only(top: 30)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                child: OutlineButton(
                                  borderSide: BorderSide(
                                    width: 1.0,
                                    color: Colors.lightBlue,
                                    style: BorderStyle.solid,
                                  ),
                                  child: Text("Masuk", style: TextStyle(color: Colors.lightBlue),),
                                  onPressed: (){
                                    pr.show();
                                    // 0 untuk MASUK
                                    yesAbsen(id_user, latKaryawan, lngKaryawan, jarakmu, '-','1','0');
                                  },
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    )
              )
          ,
        ),
      ),
    );
  }

  void _showDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context){
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)
            ),
            child: Container(
              padding: EdgeInsets.only(left: 40, right: 40),
              height: 300,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Berikan penjelasan'),
                  Padding(padding: EdgeInsets.only(top: 30)),
                  TextFormField(
                    textAlignVertical: TextAlignVertical.top,
                    controller: _controllerKeterangan,
                    decoration: InputDecoration(
                        labelText: 'Deskripsi',
                        border: OutlineInputBorder()
                    ),
                    maxLines: 5,
                    minLines: 3,
                  ),
                  Padding(padding: EdgeInsets.only(top: 10)),
                  Container(
                    width: double.infinity,
                    child: OutlineButton(
                      onPressed: (){
                        pr.show();
                        yesAbsen(id_user,latKaryawan,lngKaryawan,jarakmu,_controllerKeterangan.text,'0','0');
                      },
                      child: Text('Submit'),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
    );
  }

  void _showDialogChoiceKantor(List<dynamic> lokasi_kantor) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context){
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0)
          ),
          child: Container(
            padding: EdgeInsets.only(top: 10),
            height: 250,
            child: lokasi_kantor.length > 0 ?
            ListView.builder(
              itemCount: lokasi_kantor.length,
              itemBuilder: (BuildContext context, int index){
                return Container(
                  padding: EdgeInsets.only(left: 30, top: 5, right: 30),
                  child: OutlineButton(
                    onPressed: (){
                      getLoc(lokasi_kantor[index]['id_kantor']);
                      print("ASULAH"+lokasi_kantor[index]['id_kantor']);
                    },
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(lokasi_kantor[index]['nama_kantor'], style: TextStyle(color: Colors.black54),),
                        ),
                        Icon(Icons.arrow_forward_ios_outlined, size: 12,)
                      ],
                    ),
                  ),
                );
              },
            ) :
            Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        );
      }
    );
  }


}
