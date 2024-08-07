// ignore_for_file: prefer_const_constructors

import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:apptest/pages/login.dart';
import 'package:apptest/pages/report.dart';
import 'package:apptest/services/auth.dart';
import 'package:apptest/services/classifier.dart';
import 'package:apptest/services/classifier_quant.dart';
import 'package:flutter/widgets.dart';
import 'package:tflite_flutter_helper_plus/tflite_flutter_helper_plus.dart';
//import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:get/get.dart';
import 'package:apptest/widgets/appbar.dart';

class homeScreen extends StatefulWidget {
  @override
  State<homeScreen> createState() => _homeScreenState();
}

class _homeScreenState extends State<homeScreen> {
  late Classifier _classifier;
  final AuthService _auth = AuthService();
  File? _image;
  final picker = ImagePicker();
  String? category = "";
  Image? _imageWidget;
  late bool scancamera;
  late List<String> labels;

  bool isplantsel = false;
  final _authh = FirebaseAuth.instance;
  final db = AuthService().db;
  late User? user = _authh.currentUser;
  late String uid = user!.uid;

  String _predict() {
    img.Image imageInput = img.decodeImage(_image!.readAsBytesSync())!;
    //_classifier.predict(imageInput);
    print('hello1');
    var pred = _classifier.predict(imageInput);
    print(pred);
    print('hello2');
    return (pred);
  }

  Future getImage(scancamera) async {
    XFile? pickedFile;
    labels = await FileUtil.loadLabels('assets/labels.txt');
    if (scancamera) {
      XFile? pickedFile = await picker.pickImage(source: ImageSource.camera);
      setState(() {
        _image = File(pickedFile!.path);
        _imageWidget = Image.file(_image!);
        var index = int.parse(_predict());
        category = labels[index];

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => report(
                // Pass the automatically generated path to
                // the DisplayPictureScreen widget.
                imagePath: pickedFile.path,
                category: category,
                isprevreport: false),
          ),
        );
      });
    } else {
      XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
      setState(() {
        _image = File(pickedFile!.path);
        _imageWidget = Image.file(_image!);
        var index = int.parse(_predict());
        category = labels[index];

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => report(
                // Pass the automatically generated path to
                // the DisplayPictureScreen widget.
                imagePath: pickedFile.path,
                category: category,
                isprevreport: false),
          ),
        );
      });
    }
  }

  Future<void> fetch_isplantselect() async {
    try {
      final User? user = _authh.currentUser;
      final uid = user!.uid;
      var collection = db.collection('users');
      var docSnapshot = await collection.doc(uid).get();

      if (docSnapshot.exists) {
        Map<String, dynamic> data = docSnapshot.data()!;
        setState(() {
          isplantsel = data['isplantselect'];
          print(isplantsel);
        });
      }
    } catch (e) {
      print('Erro ao buscar dados do Firestore: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    //fetch_isplantselect();
    _classifier = ClassifierQuant();
  }

  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.expand(),
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/hello.png"), fit: BoxFit.cover)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: common_nav_bar(appBar: AppBar(), auth: _auth),
        body: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    margin: const EdgeInsets.only(top: 80),
                    child: Text(
                      "homepage_title".tr,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32.0,
                        letterSpacing: 2.0,
                      ),
                    )),
                Container(
                  height: MediaQuery.of(context).size.height * 0.55 - 75,
                  width: MediaQuery.of(context).size.width * 1,
                  decoration: BoxDecoration(
                      color: Colors.teal,
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(40.0),
                          topLeft: Radius.circular(40.0))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          child: Icon(Icons.qr_code_scanner,
                              size: 170, color: Colors.blueGrey[900])),
                      TextButton(
                        style: ButtonStyle(
                          //  textColor: Colors.white,
                          //color: Colors.blueGrey[900],
                          foregroundColor: MaterialStateProperty.all<Color>(
                              Color.fromARGB(255, 223, 215, 215)),
                        ),
                        onPressed: () async {
                          await fetch_isplantselect();
                          if (isplantsel == true) {
                            scancamera = true;
                            await showDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  elevation: 16,
                                  child: Container(
                                    height: 350.0,
                                    padding: EdgeInsets.all(10.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        Row(
                                          children: [
                                            Container(
                                              width: 70.0,
                                              child: Image.asset(
                                                "assets/scanleaf.png",
                                                height: 55.0,
                                              ),
                                            ),
                                            SizedBox(width: 15.0),
                                            Container(
                                              width: 200,
                                              child: Text(
                                                "visible".tr,
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Container(
                                              width: 70.0,
                                              child: Image.asset(
                                                  "assets/blur.png",
                                                  height: 70.0,
                                                  width: 40.0),
                                            ),
                                            SizedBox(width: 15.0),
                                            Container(
                                              width: 200,
                                              child: Text(
                                                "blur".tr,
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Container(
                                              width: 60.0,
                                              child: Image.asset(
                                                "assets/singleleaf.png",
                                                height: 50.0,
                                              ),
                                            ),
                                            SizedBox(width: 20.0),
                                            Container(
                                              width: 200,
                                              child: Text(
                                                "single".tr,
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ),
                                          ],
                                        ),
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            child: Text("OK"))
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                            getImage(scancamera);
                          } else {
                            Navigator.pushNamed(context, '/selectPlants');
                          }
                          //Navigator.pushReplacementNamed(context, '/scan')
                        },

                        child: Text('scan_button'.tr),
                        //textColor: Colors.white,
                        //color: Colors.blueGrey[900],
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 7.0, bottom: 7.0),
                        child: const Text(
                          "OU",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14.0),
                        ),
                      ),
                      TextButton(
                        style: ButtonStyle(
                          //  textColor: Colors.white,
                          //color: Colors.blueGrey[900],
                          foregroundColor: MaterialStateProperty.all<Color>(
                              Color.fromARGB(255, 237, 242, 245)),
                        ),
                        onPressed: () async {
                          await fetch_isplantselect();
                          if (isplantsel == true) {
                            scancamera = false;
                            await showDialog(
                              // ignore: use_build_context_synchronously
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  elevation: 16,
                                  child: Container(
                                    height: 350.0,
                                    padding: EdgeInsets.all(10.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        Row(
                                          children: [
                                            Container(
                                              width: 70.0,
                                              child: Image.asset(
                                                "assets/scanleaf.png",
                                                height: 55.0,
                                              ),
                                            ),
                                            SizedBox(width: 15.0),
                                            // ignore: sized_box_for_whitespace
                                            Container(
                                              width: 200,
                                              child: Text(
                                                "Segure seu dispositivo sobre uma folha para que fique claramente visível na tela do seu smartphone.",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            // ignore: sized_box_for_whitespace
                                            Container(
                                              width: 70.0,
                                              child: Image.asset(
                                                  "assets/blur.png",
                                                  height: 70.0,
                                                  width: 40.0),
                                            ),
                                            SizedBox(width: 15.0),
                                            Container(
                                              width: 200,
                                              child: Text(
                                                "blur".tr,
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Container(
                                              width: 60.0,
                                              child: Image.asset(
                                                "assets/singleleaf.png",
                                                height: 50.0,
                                              ),
                                            ),
                                            SizedBox(width: 20.0),
                                            Container(
                                              width: 200,
                                              child: Text(
                                                "single".tr,
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ),
                                          ],
                                        ),
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            child: Text("OK"))
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                            getImage(scancamera);
                          } else {
                            Navigator.pushNamed(context, '/selectPlants');
                          }

                          //Navigator.pushReplacementNamed(context, '/scan')
                        },

                        child: Text('upload_button'.tr),
                        //textColor: Colors.white,
                        //color: Colors.blueGrey[900],
                      )
                    ],
                  ),
                ),
              ],
            ),
            Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.55 * 0.35,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 100.0,
                      width: 90.0,
                      margin: EdgeInsets.only(top: 90),
                      decoration: BoxDecoration(
                          border: Border.all(width: 4, color: Colors.white),
                          image: DecorationImage(
                              image: AssetImage("assets/image1.jpg"),
                              fit: BoxFit.cover),
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                    ),
                    Container(
                      height: 100.0,
                      width: 90.0,
                      margin: EdgeInsets.only(top: 70, left: 10),
                      decoration: BoxDecoration(
                          border: Border.all(width: 4, color: Colors.white),
                          image: DecorationImage(
                              image: AssetImage("assets/image2.jpg"),
                              fit: BoxFit.cover),
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                    ),
                    Container(
                      height: 100.0,
                      width: 90.0,
                      margin: EdgeInsets.only(top: 90, left: 10),
                      decoration: BoxDecoration(
                          border: Border.all(width: 4, color: Colors.white),
                          image: DecorationImage(
                              image: AssetImage("assets/image3.jpg"),
                              fit: BoxFit.cover),
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
