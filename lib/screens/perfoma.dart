import 'dart:async';
import 'dart:convert';

import 'package:daily_monitoring/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class Performa extends StatefulWidget {
  @override
  _PerformaState createState() => _PerformaState();
}

class _PerformaState extends State<Performa> {

  SharedPreferences prefs;
  String id_user = '';
  String level_user = '';
  String title_chart = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getTanggal();
    get_pref();
  }

  String tanggal;
  void getTanggal() {
    DateTime now = new DateTime.now();
    String mont = DateFormat('M').format(now);
    String day = DateFormat('d').format(now);
    String year = DateFormat('y').format(now);

    if(mont == "1"){
      setState(() {
        tanggal = "${day} Jan ${year}";
      });
    }else if(mont == "2"){
      setState(() {
        tanggal = "${day} Feb ${year}";
      });
    }else if(mont == "3"){
      setState(() {
        tanggal = "${day} Mar ${year}";
      });
    }else if(mont == "4"){
      setState(() {
        tanggal = "${day} Apr ${year}";
      });
    }else if(mont == "5"){
      setState(() {
        tanggal = "${day} Mei ${year}";
      });
    }else if(mont == "6"){
      setState(() {
        tanggal = "${day} Jun ${year}";
      });
    }else if(mont == "7"){
      setState(() {
        tanggal = "${day} Jul ${year}";
      });
    }else if(mont == "8"){
      setState(() {
        tanggal = "${day} Agu ${year}";
      });
    }else if(mont == "9"){
      setState(() {
        tanggal = "${day} Sep ${year}";
      });
    }else if(mont == "10"){
      setState(() {
        tanggal = "${day} Okt ${year}";
      });
    }else if(mont == "11"){
      setState(() {
        tanggal = "${day} Nov ${year}";
      });
    }else if(mont == "12"){
      setState(() {
        tanggal = "${day} Des ${year}";
      });
    }
  }

  void get_pref() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      id_user = prefs.getString('id_user');
      level_user = prefs.getString('level_user');
      getPerformaAbsenMasuk(id_user);
      getPerformaAbsenPulang(id_user);
      getTotalTask(id_user);
      getDataChart(level_user);

      if(level_user == '1'){
        title_chart = "Diagram Task Admin Operasional";
      }else if(level_user == '2'){
        title_chart = "Diagram Task Admin Finance";
      }else if(level_user == '3'){
        title_chart = "Diagram Task Lahan";
      }else if(level_user == '4'){
        title_chart = "Diagram Task Business Development";
      }
    });
  }

  String jamMasuk = '';
  getPerformaAbsenMasuk(String id_user) async {
    DateTime now = new DateTime.now();
    String tanggal = DateFormat('y-M-d').format(now);
    var url = Constant.GET_ABSEN_MASUK;
    final response = await http.post(
      url,
      body: {
        'id_user':id_user,
        'tanggal':tanggal
      },
      headers: {"Accept": "application/json"}
    );
    var dataMasuk = json.decode(response.body);
    if(dataMasuk.length != 0){
      if(dataMasuk['status'] == 'ada'){
        print("ANJEENG ${dataMasuk['create_date']}");
        setState(() {
          int idx = dataMasuk['create_date'].indexOf(" ");
          List parts = [dataMasuk['create_date'].substring(0,idx).trim(), dataMasuk['create_date'].substring(idx+1).trim()];
          jamMasuk = "${parts[1]}";

        });
      }else{
        print("ANJEENG GA ADA");
        setState(() {
          jamMasuk = '00:00:00';
        });
      }
    }else{
      setState(() {
        jamMasuk = '00:00:00';
      });
    }
  }

  String jamPulang = '';
  getPerformaAbsenPulang(String id_user) async {
    DateTime now = new DateTime.now();
    String tanggal = DateFormat('y-M-d').format(now);
    var url = Constant.GET_ABSEN_PULANG;
    final response = await http.post(
        url,
        body: {
          'id_user':id_user,
          'tanggal':tanggal
        },
        headers: {"Accept": "application/json"}
    );
    var dataPulang = json.decode(response.body);
    if(dataPulang.length != 0){
      if(dataPulang['status'] == 'ada'){
        print("PULANG ${dataPulang['create_date']}");
        setState(() {
          int idx = dataPulang['create_date'].indexOf(" ");
          List parts = [dataPulang['create_date'].substring(0,idx).trim(), dataPulang['create_date'].substring(idx+1).trim()];
          jamPulang = "${parts[1]}";
        });
      }else{
        print("PULANG GA ADA");
        setState(() {
          jamPulang = '00:00:00';
        });
      }
    }else{
      setState(() {
        jamPulang = '00:00:00';
      });
    }
  }

  double hh;
  double ii;
  double ss;
  String jamKerja = '';
  // getTotalJamKerja(String jamPulang, String jamMasuk){
  //   var arr = jamPulang.split(':');
  //   print("JANCOK ${arr}");
  //   print("JAM MASUK ${jamPulang} & ${jamMasuk}");
  //
  //   // int idxMasuk = jamMasuk.indexOf(" : ");
  //   // List partsMasuk = [jamMasuk.substring(0,idxMasuk).trim(), jamMasuk.substring(idxMasuk+1).trim()];
  //   // int idxPulang = jamPulang.indexOf(":");
  //   // List partsPulang = [jamPulang.substring(0,idxPulang).trim(), jamPulang.substring(idxPulang+1).trim()];
  //   // setState(() {
  //   //   hh = double.parse(partsPulang[0]-partsMasuk[0]);
  //   //   ii = double.parse(partsPulang[1]-partsMasuk[1]);
  //   //   ss = double.parse(partsPulang[2]-partsMasuk[2]);
  //   //   jamKerja = "${hh} : ${ii} : ${ss}";
  //   // });
  // }

  String taskTotal = '';
  String taskSelesai = '';
  String taskBelum = '';
  getTotalTask(String id_user) async {
    var url = Constant.TOTAL_TASK;
    final response = await http.post(
      url,
      body: {
          'id_user':id_user
      },
      headers: {"Accept": "application/json"}
    );
    var dataTaskTotal = json.decode(response.body);
    if(dataTaskTotal != 0){
      if(dataTaskTotal['status']=='success'){
        setState(() {
          taskTotal   = "${dataTaskTotal['jumlah_task']}";
          taskSelesai = "${dataTaskTotal['jumlah_selesai']}";
          taskBelum   = "${dataTaskTotal['jumlah_belum']}";
        });
      }else{
        setState(() {
          taskTotal   = "0";
          taskBelum   = "0";
          taskSelesai = "0";
        });
      }

    }else{
      setState(() {
        taskTotal   = "0";
        taskBelum   = "0";
        taskSelesai = "0";
      });
    }
  }

  List data;
  Timer timer;
  getDataChart(String level_user) async {
    var url = Constant.CHART;
    print("HALOO"+level_user);
    var response = await http.post(
      url,
      body: {
        'level_user':level_user
      },
      headers: {'Accept':'application/json'}
    );
    setState(() {
      data = json.decode(response.body);
    });
  }

  @override
  Widget build(BuildContext context) {

    if(jamMasuk != "" && jamPulang != ""){
      print("JAM MASUK ${jamPulang} & ${jamMasuk}");
      var arr = jamPulang.split(':');
      print("JANCOK ${arr[0]}");
    }
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(left: 40, right: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(tanggal, style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold),),
            Padding(padding: EdgeInsets.only(top: 30)),
            Row(
              children: [
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    child: Text("In", style: TextStyle(color: Colors.green),),
                  ),
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    child: Text("Out", style: TextStyle(color: Colors.red),),
                  ),
                )
              ],
            ),
            Padding(padding: EdgeInsets.only(top: 10)),
            Row(
              children: [
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(jamMasuk, style: TextStyle(color: Colors.green[700], fontSize: 24),),
                  ),
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(jamPulang, style: TextStyle(color: Colors.red[700], fontSize: 24),),
                  ),
                )
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(jamKerja, style: TextStyle(color: Colors.green[700], fontSize: 24),),
                  ),
                ),
              ],
            ),
            Padding(padding: EdgeInsets.only(top: 30)),
            Text("Daily Task", style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold),),
            Padding(padding: EdgeInsets.only(top: 20)),
            Card(
              elevation: 0.5,
              child: Container(
                padding: EdgeInsets.only(left: 30, right: 30, top: 30, bottom: 30),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            alignment: Alignment.center,
                            child: Text("Total Task", style: TextStyle(color: Colors.black54),),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            alignment: Alignment.center,
                            child: Text("Selesai", style: TextStyle(color: Colors.green),),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            alignment: Alignment.center,
                            child: Text("Belum selesai", style: TextStyle(color: Colors.red),),
                          ),
                        )
                      ],
                    ),
                    Padding(padding: EdgeInsets.only(top: 10)),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(taskTotal, style: TextStyle(color: Colors.black54, fontSize: 24),),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(taskSelesai, style: TextStyle(color: Colors.green, fontSize: 24),),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(taskBelum, style: TextStyle(color: Colors.red, fontSize: 24),),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 30)),
            Text(title_chart, style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold),),
            Padding(padding: EdgeInsets.only(top: 10)),
            Card(
              elevation: 0.5,
              child: Container(
                padding: EdgeInsets.only(bottom: 15, left: 10, right: 10),
                height: 130,
                child: data == null ?
                Center(
                  child: CircularProgressIndicator(),
                ) :
                createChart(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  charts.Series<ModelChart, String> createSeries(String id, int i){
    print("${data[i]['value_satu']},${data[i]['value_dua']},${data[i]['value_tiga']}");
    return level_user == "4" ?
    charts.Series<ModelChart, String>(
      id: id,
      domainFn: (ModelChart _modelChart, _) => _modelChart._label,
      measureFn: (ModelChart _modelChart, _) => _modelChart._value,
      labelAccessorFn: (ModelChart _modelChart, _) => '${_modelChart._label} : ${_modelChart._value} Task',
      data: [
        ModelChart('Dina Ullistiya', int.parse(data[i]['value_satu'])),
      ]
    ) : level_user == "3" ?
    charts.Series<ModelChart, String>(
        id: id,
        domainFn: (ModelChart _modelChart, _) => _modelChart._label,
        measureFn: (ModelChart _modelChart, _) => _modelChart._value,
        labelAccessorFn: (ModelChart _modelChart, _) => '${_modelChart._label} : ${_modelChart._value} Task',
        data: [
          ModelChart('Rr. Hurub Hutami', int.parse(data[i]['value_satu'])),
          ModelChart('Ayudyah Desy Wulandari', int.parse(data[i]['value_dua'])),
          ModelChart('Talitha Nuroini Ahdianitasary', int.parse(data[i]['value_tiga'])),
          ModelChart('Hanan Pavita Ihsani', int.parse(data[i]['value_empat']))
        ]
    ) : level_user == "2" ?
    charts.Series<ModelChart, String>(
        id: id,
        domainFn: (ModelChart _modelChart, _) => _modelChart._label,
        measureFn: (ModelChart _modelChart, _) => _modelChart._value,
        labelAccessorFn: (ModelChart _modelChart, _) => '${_modelChart._label} : ${_modelChart._value} Task',
        data: [
          ModelChart('Ariffudin Hamzah', int.parse(data[i]['value_satu'])),
          ModelChart('Nasya Miftahuljanah', int.parse(data[i]['value_dua'])),
        ]
    ) :
    charts.Series<ModelChart, String>(
        id: id,
        domainFn: (ModelChart _modelChart, _) => _modelChart._label,
        measureFn: (ModelChart _modelChart, _) => _modelChart._value,
        labelAccessorFn: (ModelChart _modelChart, _) => '${_modelChart._label} : ${_modelChart._value} Task',
        data: [
          ModelChart('Sirojuddin Ahmad', int.parse(data[i]['value_satu'])),
          ModelChart('Miranda Hetu Marsella', int.parse(data[i]['value_dua'])),
          ModelChart('Alvian Ilham Ramadhan', int.parse(data[i]['value_tiga'])),
        ]
    );
  }

  Widget createChart() {
    List<charts.Series<ModelChart, String>> seriesList = [];

    for(int i=0; i<data.length; i++){
      String id = 'DLY${i+1}';
      seriesList.add(createSeries(id, i));
    }

    return charts.BarChart(
      seriesList,
      barGroupingType: charts.BarGroupingType.grouped,
      vertical: false,
      barRendererDecorator: new charts.BarLabelDecorator<String>(),
      domainAxis: new charts.OrdinalAxisSpec(renderSpec: new charts.NoneRenderSpec()),
    );
  }
}

class ModelChart {
  final String _label;
  final int _value;

  ModelChart(this._label, this._value);
}
