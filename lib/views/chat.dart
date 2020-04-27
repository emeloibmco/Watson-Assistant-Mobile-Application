import 'dart:async';
import 'dart:io';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:watsonapp/components/chattingTile.dart';
import 'package:watsonapp/data/chat_messages.dart';
import 'package:watsonapp/models/message_model.dart';
import 'package:flare_flutter/flare_actor.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<MessageModel> messages = new List();
  TextEditingController _textController;
  ScrollController _scrollController = new ScrollController();
  ChatMessages _chatMessages = new ChatMessages();
  bool _sendActive = true;
  String _inputText;
  bool _isLoading = false;
  FocusNode keyboardFocus;
  FocusScopeNode currentFocus;
  bool isAndroid = true;

  _handleSubmittedLocal() {
    _inputText = _textController.text;
  }

  @override
  void initState() {
    super.initState();

    keyboardFocus = FocusNode();
    _textController = TextEditingController();
    initPlatformState();
    _chatMessages.deleteSession().then(
          (r) => _chatMessages.createSession().then(
                (e) => _chatMessages.sendWelcomeMessage().then(
                      (s) => {
                        setState(() {
                          messages = _chatMessages.getMessages();
                          _isLoading = false;
                        })
                      },
                    ),
              ),
        );
  }

  initPlatformState() async {
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        print('Running on ${androidInfo.model}'); // e.g. "Moto G (4)"
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        print('Running on ${iosInfo.utsname.machine}');
      }
    } on PlatformException {
      print('Error en platform');
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _handleChange(String text) {
    setState(() {
      _sendActive = text.length != 0;
    });
  }

  _scrollToEnd(_scrollController) {
    Timer(
        Duration(milliseconds: 200),
        () => _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              curve: Curves.easeOut,
              duration: const Duration(milliseconds: 300),
            ));
  }

  _sendMsgButton() {
    if (_inputText.trim().length == 0) {
    } else {
      _chatMessages.sendMyMessage(_inputText);
      _chatMessages.sendMessage(_inputText).then((res2) => setState(() {
            _isLoading = false;
            messages = _chatMessages.getMessages();
            _scrollToEnd(_scrollController);
          }));
      _scrollToEnd(_scrollController);
      setState(() {
        _isLoading = true;
        messages = _chatMessages.getMessages();
        _textController.clear();
        _inputText = '';
        _handleChange('');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeightNoBar = screenHeight - statusBarHeight;
    double realHeight = MediaQuery.of(context).devicePixelRatio * screenHeight;

    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    FlutterStatusbarcolor.setStatusBarWhiteForeground(true);

    return WillPopScope(
      onWillPop: null,
      child: Scaffold(
        body: Container(
          color: Color.fromRGBO(30, 30, 30, 1.0),
          width: screenWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: statusBarHeight,
              ),
              Container(
                  height: screenHeightNoBar * 0.18,
                  child: Column(
                    children: <Widget>[
                      Stack(
                        alignment: Alignment.topCenter,
                        children: <Widget>[
                          Container(
                              alignment: Alignment.topCenter,
                              width: (realHeight < 1500)
                                  ? screenHeight * 0.115
                                  : screenHeight * 0.115,
                              height: (realHeight < 1500)
                                  ? screenHeight * 0.115
                                  : screenHeight * 0.115,
                              padding:
                                  EdgeInsets.only(top: screenHeight * 0.01),
                              child: Hero(
                                  tag: 'watson',
                                  child: FlareActor(
                                    "assets/flare/watsonAvatar.flr",
                                    alignment: Alignment.center,
                                    fit: BoxFit.contain,
                                    animation: "Breathe",
                                  )))
                        ],
                      ),
                      SizedBox(height: screenHeightNoBar * 0.004),
                      Text(
                        "Watson Assistant",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: (realHeight < 1500)
                              ? screenHeight * 0.024
                              : screenHeight * 0.02,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(
                          height: (realHeight < 1500)
                              ? 0
                              : screenHeightNoBar * 0.002),
                      Text("IBM",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: (realHeight < 1500)
                                  ? screenHeight * 0.0168
                                  : screenHeight * 0.0145,
                              fontWeight: FontWeight.w400)),
                    ],
                  )),
              Expanded(
                  child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                          width: 0, color: Color.fromRGBO(254, 254, 254, 1.0)),
                      color: Color.fromRGBO(254, 254, 254, 1.0),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      )),
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: BouncingScrollPhysics(),
                    itemCount: messages.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return ChattingTile(
                        isByMe: messages[index].isByme,
                        message: messages[index].message,
                      );
                    },
                  ),
                ),
              )
              ),
              _isLoading
                  ? Container(
                      height: screenHeight * 0.013,
                      alignment: Alignment.bottomCenter,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(254, 254, 254, 1.0),
                        border: Border.all(
                            width: 0,
                            color: Color.fromRGBO(254, 254, 254, 1.0)),
                      ),
                      child: FlareActor("assets/flare/loadingDots.flr",
                          alignment: Alignment.center,
                          fit: BoxFit.cover,
                          animation: "Loading"))
                  : Container(),
              Container(
                decoration: BoxDecoration(
                  color: Color.fromRGBO(254, 254, 254, 1.0),
                  border: Border.all(
                      width: 0, color: Color.fromRGBO(254, 254, 254, 1.0)),
                ),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                width: screenWidth,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Expanded(
                        flex: 90,
                        child: AnimatedContainer(
                          duration: Duration(seconds: 1),
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.03,
                              vertical: screenHeight * 0.015),
                          decoration: BoxDecoration(
                              color: Color.fromRGBO(220, 220, 220, 1.0),
                              borderRadius: BorderRadius.circular(30)),
                          child: Container(
                            alignment: Alignment.center,
                            width: screenWidth,
                            child: TextField(
                              focusNode: keyboardFocus,
                              controller: _textController,
                              cursorColor: Color(0xFF835afc),
                              autocorrect: true,
                              keyboardType: TextInputType.text,
                              maxLines: 3,
                              minLines: 1,
                              style: TextStyle(
                                fontSize: (realHeight < 1500)
                                    ? screenHeight * 0.025
                                    : screenHeight * 0.023,
                              ),
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: -4),
                                  isDense: true,
                                  hintText: "...",
                                  hintStyle: TextStyle(
                                    fontSize: (realHeight < 1500)
                                        ? screenHeight * 0.028
                                        : screenHeight * 0.023,
                                  )),
                              onTap: () {
                                _scrollToEnd(_scrollController);
                              },
                              onSubmitted: (r) {
                                _sendMsgButton();
                                keyboardFocus.requestFocus();
                              },
                              onChanged: (String text) {
                                if (_handleChange == null) {
                                  return;
                                }
                                _handleChange(text);
                                _handleSubmittedLocal();
                              },
                            ),
                          ),
                        )),
                    !_sendActive
                        ? Expanded(
                            flex: 0,
                            child: Container(
                              width: 0,
                              height: 0,
                            ))
                        : Expanded(
                            flex: 10,
                            child: Container(
                              padding: EdgeInsets.only(bottom: 1),
                              alignment: Alignment.bottomRight,
                              child: GestureDetector(
                                onTap: () {
                                  _sendMsgButton();
                                },
                                child: CircleAvatar(
                                  radius: (realHeight < 1500)
                                      ? screenHeight * 0.024
                                      : screenHeight * 0.021,
                                  child: Padding(
                                    padding:
                                        EdgeInsets.only(left: 3, bottom: 1),
                                    child: Icon(
                                      Icons.send,
                                      color: Colors.white,
                                      size: (realHeight < 1500)
                                          ? screenHeight * 0.023
                                          : screenHeight * 0.022,
                                    ),
                                  ),
                                  backgroundColor: Color(0xDD835afc),
                                ),
                              ),
                            ),
                          )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
