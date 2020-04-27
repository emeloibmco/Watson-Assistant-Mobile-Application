import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:page_transition/page_transition.dart';
import 'package:watsonapp/views/chat.dart';

class MySplashScreen extends StatefulWidget {
  @override
  _MySplashScreenState createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    FlutterStatusbarcolor.setStatusBarWhiteForeground(false);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    double _size = MediaQuery.of(context).size.width * 0.8;

    return Container(
        color: Color.fromRGBO(30, 30, 30, 1.0),
        alignment: Alignment.center,
        child: AnimatedContainer(
          //color: Colors.grey,
          duration: Duration(milliseconds: 500),
          width: _size ,
          height: _size ,
          child: Hero(
            tag: 'watson',
            child: FlareActor("assets/flare/watsonLogo.flr",
                alignment: Alignment.center,
                fit: BoxFit.contain,
                callback: (res) => {
                      Navigator.pushReplacement(
                          context,
                          PageTransition(
                              type: PageTransitionType.fade,
                              duration: Duration(milliseconds: 1800),
                              child: ChatScreen()))
                    },
                animation: "Animation"),
          ),
        ));
  }
}
