import 'dart:async';
import 'dart:math';

import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static final FacebookLogin facebookSignIn = new FacebookLogin();

  String _message = 'Log in/out by pressing the buttons below.';

  Future<Null> _login() async {
    final FacebookLoginResult result =
        await facebookSignIn.logInWithReadPermissions(['email']);
    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final FacebookAccessToken accessToken = result.accessToken;
        _showMessage('''
         Logged in!
         Token: ${accessToken.token}
         User id: ${accessToken.userId}
         Expires: ${accessToken.expires}
         Permissions: ${accessToken.permissions}
         Declined permissions: ${accessToken.declinedPermissions}
         ''');
        break;
      case FacebookLoginStatus.cancelledByUser:
        _showMessage('Login cancelled by the user.');
        break;
      case FacebookLoginStatus.error:
        _showMessage('Something went wrong with the login process.\n'
            'Here\'s the error Facebook gave us: ${result.errorMessage}');
        break;
    }
  }

  Future<Null> _logOut() async {
    await facebookSignIn.logOut();
    _showMessage('Logged out.');
  }

  void _showMessage(String message) {
    setState(() {
      _message = message;
    });
  }




  @override
  void initState(){
    super.initState();
  }


  Future<void> requestPermission() async{
    final status = await Permission.storage.status;
    if (status == PermissionStatus.granted) return;
    final statuses = await Permission.storage.request();
  }


  Future<Null> _onShareFacebook() async{
    try {
      final ByteData bytes = await rootBundle.load('assets/image.jpeg');
      final Uint8List list = bytes.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = await new File('${tempDir.path}/image.jpeg').create();
      file.writeAsBytesSync(list);
      await facebookSignIn.shareContent('image.jpeg');
    } catch (e) {
      print('Share error: $e');
    }
  }


  Future<Null> _logEvent() async{
    await facebookSignIn.logEvent('testing_event', {'params':'testingParms'});
  }

  Future<Null> _logSignUp(double value) async{
    await facebookSignIn.logSingUp(200);
  }

  Future<Null> _onShareonInstagram() async{
    if (Platform.isIOS){
      try {
        final ByteData bytes = await rootBundle.load('assets/image.jpeg');
        final Uint8List list = bytes.buffer.asUint8List();
        final tempDir = await getTemporaryDirectory();
        final file = await new File('${tempDir.path}/image.ig').create();
        file.writeAsBytesSync(list);
        await facebookSignIn.shareContentIg(file.path, "com.shareinstagram.provider");
      } catch (e) {
        print('Share error: $e');
      }
    }else {
      await requestPermission();
      try {
        final ByteData bytes = await rootBundle.load('assets/image.jpeg');
        final Uint8List list = bytes.buffer.asUint8List();
        final tempDir = await getTemporaryDirectory();
        final file = await new File('${tempDir.path}/image.jpeg').create();
        file.writeAsBytesSync(list);
        print(file.path);
        await facebookSignIn.shareContentIg(file.path, "com.shareinstagram.provider");
      } catch (e) {
        print('Share error: $e');
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Plugin example app'),
        ),
        body: new Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text(_message),
              new RaisedButton(
                onPressed: _login,
                child: new Text('Log in'),
              ),
              new RaisedButton(
                onPressed: _logOut,
                child: new Text('Logout'),
              ),
              new RaisedButton(
                onPressed: _onShareFacebook,
                child: new Text('ShareImageFacebook'),
              ),
              new RaisedButton(
                onPressed: _onShareonInstagram,
                child: new Text('Share Instagram image'),
              ),
              new RaisedButton(
                onPressed: _logEvent,
                child: new Text('Event singup press'),
              ),
              new RaisedButton(
                onPressed: () => _logSignUp(200),
                child: new Text('Log Signup'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
