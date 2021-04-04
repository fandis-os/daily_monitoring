import 'dart:convert';
import 'dart:math';

import 'package:daily_monitoring/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:select_form_field/select_form_field.dart';
import 'package:http/http.dart' as http;

class Weekly extends StatefulWidget {
  @override
  _WeeklyState createState() => _WeeklyState();
}

class _WeeklyState extends State<Weekly> {

  ProgressDialog pr;

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

  final List<Map<String, dynamic>> _itemDivisi = [
    {
      'value': '1',
      'label': '  QAI',
      'icon': Icon(Icons.arrow_forward_ios, size: 8, color: Colors.deepOrange),
      'textStyle': TextStyle(color: Colors.black54),
    },
    {
      'value': '2',
      'label': '  NGS Jakarta',
      'icon': Icon(Icons.arrow_forward_ios, size: 8, color: Colors.deepOrange),
      'textStyle': TextStyle(color: Colors.black54),
    },
    {
      'value': '3',
      'label': '  NGS Paspro',
      'icon': Icon(Icons.arrow_forward_ios, size: 8, color: Colors.deepOrange),
      'textStyle': TextStyle(color: Colors.black54),
    },
    {
      'value': '4',
      'label': '  Anara',
      'icon': Icon(Icons.arrow_forward_ios, size: 8, color: Colors.deepOrange),
      'textStyle': TextStyle(color: Colors.black54),
    },
  ];

  String _valueChangedDivisi  = '';
  String _valueChangedYesNo   = '';

  TextEditingController _controllerTarget = TextEditingController();
  TextEditingController _controllerTanggal= TextEditingController();
  TextEditingController _controllerPic    = TextEditingController();
  TextEditingController _controllerKeterangan = TextEditingController();

  @override
  Widget build(BuildContext context) {

    pr = new ProgressDialog(context, showLogs: true);
    pr.style(message: 'Submiting weekly...');

    return Scaffold(
      body: Container(
        height: double.infinity,
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(left: 40,right: 40),
            child: Column(
              children: [
                Text("Form Weekly Monitoring", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                Padding(padding: EdgeInsets.only(top: 60)),
                TextFormField(
                  controller: _controllerTarget,
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.domain_verification_outlined),
                      labelText: 'Target',
                      border: OutlineInputBorder()
                  ),
                  textAlignVertical: TextAlignVertical.top,
                  maxLines: 3,
                  minLines: 1,
                ),
                Padding(padding: EdgeInsets.only(top: 10)),
                TextFormField(
                  controller: _controllerPic,
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.verified_user),
                      labelText: 'PIC',
                      border: OutlineInputBorder()
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 10)),
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
                Padding(padding: EdgeInsets.only(top: 10)),
                TextFormField(
                  controller: _controllerKeterangan,
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.plagiarism_outlined),
                      labelText: 'Keterangan',
                      border: OutlineInputBorder()
                  ),
                  textAlignVertical: TextAlignVertical.top,
                  minLines: 3,
                  maxLines: 5,
                ),
                Padding(padding: EdgeInsets.only(top: 10)),
                SelectFormField(
                  initialValue: '',
                  icon: Icon(Icons.playlist_add_check_sharp),
                  labelText: 'Divisi',
                  items: _itemDivisi,
                  onChanged: (val){
                    setState(() {
                      _valueChangedDivisi = val;
                    });
                  },
                ),
                Padding(padding: EdgeInsets.only(top: 10)),
                SelectFormField(
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
                Padding(padding: EdgeInsets.only(top: 10)),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(top: 40, bottom: 20),
                  child: OutlineButton(
                    child: Text("Submit", style: TextStyle(color: Colors.black38),),
                    onPressed: (){
                      if(_controllerTarget.text == ""){
                        _showDialog("Target harus di isi.");
                      }else if(_controllerPic.text == ""){
                        _showDialog("PIC harus diisi.");
                      }else if(_controllerTanggal.text == ""){
                        _showDialog("Pilih tanggal.");
                      }else if(_controllerKeterangan.text == ""){
                        _showDialog("Keternagan harus diisi.");
                      }else if(_valueChangedDivisi == ""){
                        _showDialog("Pilih divisi.");
                      }else{
                        pr.show();
                        submitWeekly(_controllerTarget.text,_controllerPic.text,_controllerTanggal.text,_controllerKeterangan.text,_valueChangedDivisi,_valueChangedYesNo);
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

  Future<List> submitWeekly(String target, String pic, String tanggal, String keterangan, String divisi, String status) async {
    var url = Constant.WEEKLY;
    final response = await http.post(
        url,
        body: {
          "target":target,
          "pic":pic,
          "tanggal":tanggal,
          "divisi":divisi,
          "keterangan":keterangan,
          "status":status
        },
        headers: {"Accept": "application/json"}
    );

    var dataWeekly = json.decode(response.body);
    if(dataWeekly.length!=0){
      if(dataWeekly['status'] == "success"){
        print("success");
        setState(() {
          _valueChangedDivisi = '';
          _valueChangedYesNo = '';
        });
        _controllerPic.clear();
        _controllerTanggal.clear();
        _controllerTarget.clear();
        _controllerKeterangan.clear();
        pr.hide();
      }else{
        print("gagal");
      }
    }else{
      print("Kesalahan Sistem");
    }
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context){
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0)
          ),
          child: Container(
            padding: EdgeInsets.only(left: 40, right: 40, top: 20, bottom: 20),
            child: Text(message, style: TextStyle(color: Colors.red),),
          ),
        );
      }
    );
  }
}
