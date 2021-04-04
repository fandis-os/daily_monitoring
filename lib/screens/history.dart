import 'dart:convert';

import 'package:daily_monitoring/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class History extends StatefulWidget {
  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {

  SharedPreferences prefs;
  String id_user = '';

  List dailyTask      = [];
  List filterDailyTask= [];
  bool isSearching    = false;

  getDaily(String id_user) async {

    var now = DateTime.now();
    final date = new DateFormat('dd');
    String tgl = date.format(now);
    int get_tgl = int.parse(tgl);
    String minggu_ke;
    if(get_tgl >=1 && get_tgl <=7){
      minggu_ke = '1';
    }else if(get_tgl >=8 && get_tgl <=14){
      minggu_ke = '2';
    }else if(get_tgl >=14 && get_tgl <=21){
      minggu_ke = '3';
    }else{
      minggu_ke = '4';
    }

    var url = Constant.DAILY_TASK;
    final response = await http.post(
        url,
        body: {
          'id_user':id_user,
          'minggu_ke':minggu_ke
        }
    );
    return json.decode(response.body);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    get_pref();
  }

  void get_pref() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      id_user = prefs.getString('id_user');
      getDaily(id_user).then((data){
        setState(() {
          dailyTask = filterDailyTask = data;
        });
      });
    });
  }

  _filterDailyTask(value){
    setState(() {
      filterDailyTask = dailyTask
          .where((dailytask) =>
          dailytask['list_to_do'].toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: !isSearching
            ? Text('Histori Of Daily Task', style: TextStyle(color: Colors.black54),)
            : TextField(
          onChanged: (value){
            _filterDailyTask(value);
          },
          decoration: InputDecoration(
            hintText: "Search",
          ),
        ),
        actions: [
          isSearching ?
          Container(
            padding: EdgeInsets.only(right: 40),
            child: IconButton(
                icon: Icon(Icons.cancel, color: Colors.black54,),
                onPressed: (){
                  setState(() {
                    isSearching = false;
                    filterDailyTask = dailyTask;
                  });
                }
            ),
          )
              :
          Container(
            padding: EdgeInsets.only(right: 40),
            child: IconButton(
                icon: Icon(Icons.search, color: Colors.black54,),
                onPressed: (){
                  setState(() {
                    isSearching = true;
                  });
                }
            ),
          )
        ],
      ),
      body: Container(
        child: Container(
          padding: EdgeInsets.only(top: 10),
          child: filterDailyTask.length > 0
              ?
          ListView.builder(
            itemCount: filterDailyTask.length,
            itemBuilder: (BuildContext context, int index){

              var pic = filterDailyTask[index]['pic'] == null ? "-" : filterDailyTask[index]['pic'];
              var tgl = filterDailyTask[index]['tanggal'] == null ? "-" : filterDailyTask[index]['tanggal'];
              var ltd = filterDailyTask[index]['list_to_do'] == null ? "-" : filterDailyTask[index]['list_to_do'];

              return Container(
                padding: EdgeInsets.only(left: 5, right: 5),
                child: Card(
                  elevation: 0.1,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      children: [
                        filterDailyTask[index]['status'] == 'Selesai' ?
                        Icon(Icons.check, size: 14, color: Colors.blueAccent,) :
                        Icon(Icons.close, size: 14, color: Colors.red,),
                        Padding(padding: EdgeInsets.only(left: 8)),
                        Expanded(
                          child: Column(
                            children: [
                              Container(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: [
                                    Text("PIC : ", style: TextStyle(color: Colors.black54, fontSize: 10),),
                                    Text(pic, style: TextStyle(color: Colors.black54),)
                                  ],
                                ),
                              ),
                              Padding(padding: EdgeInsets.only(top: 3)),
                              Container(
                                alignment: Alignment.centerLeft,
                                child: Text(tgl, style: TextStyle(color: Colors.deepOrange, fontSize: 11),),
                              ),
                              Padding(padding: EdgeInsets.only(top: 3)),
                              Container(
                                alignment: Alignment.centerLeft,
                                child: Text(ltd, style: TextStyle(color: Colors.black54, fontSize: 13),),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          child: filterDailyTask[index]['status'] == 'Selesai' ?
                          Container() :
                          IconButton(
                              icon: Icon(Icons.visibility, color: Colors.black54,),
                              onPressed: (){}
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          )
              :
          Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
