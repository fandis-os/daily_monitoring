import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:async';

import 'package:daily_monitoring/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  ProgressDialog pr;
  double percentage = 0.0;

  TextEditingController _ctrNama    = new TextEditingController();
  TextEditingController _ctrAlamat  = new TextEditingController();
  TextEditingController _ctrEmail   = new TextEditingController();
  TextEditingController _ctrNoHP    = new TextEditingController();

  File _image;
  final picker = ImagePicker();
  String messageField = "";
  String idImage = '';

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

  Future upload_profile(File image, String nama, String alamat, String email, String no_hp, String idImage) async {
    var stream = new http.ByteStream(_image.openRead());
    stream.cast();
    var length = await image.length();
    var uri = Uri.parse(Constant.UPDATE_PROFILE);
    var request = new http.MultipartRequest("POST", uri);
    var multipartFile = new http.MultipartFile("file", stream, length, filename: basename(image.path));
    request.files.add(multipartFile);
    request.fields['id_user'] = id_user;
    request.fields['nama'] = nama;
    request.fields['alamat'] = alamat;
    request.fields['email'] = email;
    request.fields['no_hp'] = no_hp;

    var response = await request.send();

    print(response.statusCode);
    if(response.statusCode==200){
      print("Success ${response.statusCode}");
    }else{
      print("Fail");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPrefs();
  }

  String id_user;
  void getPrefs() async {
    SharedPreferences prf = await SharedPreferences.getInstance();
    setState(() {
      id_user = prf.getString('id_user');
      getProfile(id_user);
    });
  }

  String urlImageProfile = "http://blocservice.fanforfan.online/assets/image_profile/profile.png";
  List data;
  void getProfile(String id_user) async {
    var url = Constant.UPDATE_PROFILE+id_user;
    var response = await http.get(
        url,
        headers: {'Accept':'application/json'}
    );
    var dataProfile = json.decode(response.body);
    if(dataProfile.length != 0){
      if(dataProfile['status'] == 'success'){
        setState(() {
          _ctrNama.text = dataProfile['nama'];
          _ctrAlamat.text = dataProfile['alamat'];
          _ctrEmail.text = dataProfile['email'];
          _ctrNoHP.text = dataProfile['no_hp'];
          urlImageProfile = 'http://blocservice.fanforfan.online/assets/image_profile/'+dataProfile['image_profile'];
        });
      }else{
        setState(() {
          _ctrNama.text = "";
          _ctrAlamat.text = "";
          _ctrEmail.text = "";
          _ctrNoHP.text = "";
          urlImageProfile = 'http://blocservice.fanforfan.online/assets/image_profile/profile.png';
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {

    pr = ProgressDialog(
        context,
        type: ProgressDialogType.Download,
        isDismissible: true
    );

    pr.style(
        message: "Updating Profile",
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

    var duration = const Duration(seconds: 5);

    return Scaffold(
      body: Container(
        height: double.infinity,
        padding: EdgeInsets.only(left: 40, right: 40),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(padding: EdgeInsets.only(top: 80)),
              Stack(
                children: [
                  Center(
                    child: _image == null ?
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
                    ) :
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: FileImage(_image),
                            fit: BoxFit.cover
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(right: 20, bottom: 10),
                    height: 200,
                    alignment: Alignment.bottomRight,
                    child: FlatButton(
                      onPressed: getImage,
                      child: Icon(Icons.camera_alt, color: Colors.deepOrange,),
                    ),
                  )
                ],
              ),
              Padding(padding: EdgeInsets.only(top: 30)),
              TextFormField(
                controller: _ctrNama,
                decoration: InputDecoration(
                    labelText: 'Nama',
                    border: OutlineInputBorder()
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 10)),
              TextFormField(
                controller: _ctrAlamat,
                decoration: InputDecoration(
                    labelText: 'Alamat',
                    border: OutlineInputBorder()
                ),
                maxLines: 5,
                minLines: 3,
                textAlignVertical: TextAlignVertical.top,
              ),
              Padding(padding: EdgeInsets.only(top: 10)),
              TextFormField(
                controller: _ctrEmail,
                decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder()
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 10)),
              TextFormField(
                controller: _ctrNoHP,
                decoration: InputDecoration(
                    labelText: 'No. HP',
                    border: OutlineInputBorder()
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 50)),
              Text(messageField, style: TextStyle(color: Colors.red, fontSize: 9),),
              Padding(padding: EdgeInsets.only(top: 9)),
              Container(
                width: double.infinity,
                height: 50,
                child: OutlineButton(
                  onPressed: () async {
                    if(_ctrNama.text == ""){
                      setState(() {
                        messageField = "Nama harus diisi.";
                      });
                    }else if(_ctrAlamat.text == ""){
                      setState(() {
                        messageField = "Alamat harus diisi.";
                      });
                    }else if(_ctrEmail.text == ""){
                      setState(() {
                        messageField = "Email harus diisi.";
                      });
                    }else if(_ctrNoHP.text == ""){
                      setState(() {
                        messageField = "No. HP harus diisi.";
                      });
                    }else if(_image == null){
                      setState(() {
                        messageField = "Foto profil belum di ganti.";
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

                      upload_profile(_image,_ctrNama.text,_ctrAlamat.text,_ctrEmail.text,_ctrNoHP.text,idImage);
                    }
                  },
                  child: Text("Simpan", style: TextStyle(color: Colors.deepOrange),),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
