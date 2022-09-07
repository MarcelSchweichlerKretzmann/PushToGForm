import 'dart:async';

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';

class FormGForms extends StatelessWidget {
  const FormGForms({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NewFormGForms(),
    );
  }
}

class NewFormGForms extends StatefulWidget {
  @override
  NewFormGFormsState createState() {
    return NewFormGFormsState();
  }
}

class NewFormGFormsState extends State<NewFormGForms> {
  TextEditingController descriptionController = new TextEditingController();
  TextEditingController costController = new TextEditingController();
  final GlobalKey<FormState> _formStateKey = GlobalKey<FormState>();

  late Future<void> _launched;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ScanResult? scanResult;
  String result = "a";
  bool resultScanned = false;
  late TapGestureRecognizer _flutterTapRecognizer;
  Future _scanQR() async {
    try {
      final scan = await BarcodeScanner.scan();
      FlutterBeep.beep(false);
      Vibration.vibrate(duration: 200);
      setState(() => scanResult = scan);
      //print(scanResult!.rawContent);

      setState(() {
        result = scanResult!.rawContent;
      });
    } on PlatformException catch (ex) {
      if (ex.code == BarcodeScanner.cameraAccessDenied) {
        setState(() {
          result = "No Camera Persmissions!";
        });
      } else {
        setState(() {
          result = "$ex Error occurred.";
        });
      }
    } on FormatException {
      setState(() {
        result = "Nothing scaned!";
      });
    } catch (ex) {
      setState(() {
        result = "$ex Error occured.";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _flutterTapRecognizer = TapGestureRecognizer()
      ..onTap = () => _openUrl(result);
  }

  @override
  void dispose() {
    _flutterTapRecognizer.dispose();
    super.dispose();
  }

  Future<void> _launchInBrowser(String url) async {
    var uerl = Uri.parse(url);
    var response = await http.post(uerl);
  }

  void _openUrl(String url) async {
    // Close the about dialog.
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (BuildContext context) => NewFormGForms(),
        ),
        (Route route) => route == null);

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      await launch(url);
      throw 'Problem launching $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final scanResult = this.scanResult;
    if (result != "a") {
      Clipboard.setData(
        ClipboardData(text: result),
      );
      setState(() {
        resultScanned = true;
      });
      _scaffoldKey.currentState!.showSnackBar(
        const SnackBar(
          content: Text('Your scan was copied!'),
        ),
      );
    } else {
      // setState(() {
      //   resultScanned = false;
      // });
    }
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(35, 31, 32, 1),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: const [],
        ),
      ),
      body: Stack(
        children: <Widget>[
          Center(
            child: InkWell(
              onTap: _scanQR,
              child: Container(
                width: 270.0,
                height: 80.0,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: (Colors.blueGrey[300])!,
                      blurRadius: 15.0, // soften the shadow
                      spreadRadius: 2.0, //extend the shadow
                      offset: const Offset(
                        0.0, // Move to right 10  horizontally
                        10.0, // Move to bottom 10 Vertically
                      ),
                    )
                  ],
                  color: const Color.fromRGBO(35, 31, 32, 1),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const <Widget>[
                      Icon(
                        Icons.camera_alt,
                        color: Color.fromRGBO(100, 180, 30, 1),
                        size: 50,
                      ),
                      Text(
                        ' Scan Code',
                        style: TextStyle(
                          fontSize: 30.0,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          resultScanned
              ? AlertDialog(
                  title: const Text('Code:'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      RichText(
                        text: TextSpan(
                          text: result,
                          recognizer: _flutterTapRecognizer,
                          style: const TextStyle(
                            color: Color.fromRGBO(35, 31, 32, 1),
                            decoration: TextDecoration.underline,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      TextField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Description",
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextField(
                        controller: costController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Costs",
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              _formStateKey.currentState?.save();
                              setState(
                                () {
                                  _launched = _launchInBrowser(
                                    'https://docs.google.com/forms/d/e/YourSignature/formResponse?&entry.913721339=' +
                                        result +
                                        '&entry.1887040525=' +
                                        descriptionController.text +
                                        '&entry.332607661=' +
                                        costController.text +
                                        '&submit=SUBMIT',
                                  );
                                },
                              );
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const FormGForms(),
                                ),
                              );
                            },
                            label: const Text(
                              "Send",
                              style:
                                  TextStyle(color: Colors.indigo, fontSize: 18),
                            ),
                            icon: const Icon(
                              Icons.done_outline_rounded,
                              color: Colors.indigo,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const FormGForms(),
                                ),
                              );
                            },
                            label: const Text(
                              "Cancle",
                              style: TextStyle(color: Colors.red, fontSize: 18),
                            ),
                            icon: const Icon(
                              Icons.highlight_off,
                              color: Colors.red,
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                  actions: const <Widget>[],
                )
              : Container(),
        ],
      ),
    );
  }
}
