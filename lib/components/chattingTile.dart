import 'package:flutter/material.dart';
import 'package:link_text/link_text.dart';

class ChattingTile extends StatelessWidget {
  final bool isByMe;
  final String message;
  ChattingTile({@required this.isByMe, @required this.message});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double realHeight = MediaQuery.of(context).devicePixelRatio * screenHeight;
    return AnimatedContainer(
      duration: Duration(seconds: 1),
      margin: EdgeInsets.only(bottom: 22),
      alignment: isByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        decoration: BoxDecoration(
            color: isByMe ? Color(0x22AB8FFF) : Color(0xff3F8AFF),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
                bottomLeft: isByMe ? Radius.circular(40) : Radius.circular(0),
                bottomRight:
                    isByMe ? Radius.circular(0) : Radius.circular(40))),
        padding: EdgeInsets.symmetric(
            vertical: (realHeight < 1500)
                ? screenHeight * 0.016
                : screenHeight * 0.016,
            horizontal: screenWidth * 0.05),
        child: Container(
          constraints: BoxConstraints(maxWidth: screenWidth * 0.6),
          child: LinkText(
            text: message,
            linkStyle: TextStyle(
                color: Colors.white70,
                fontSize: (realHeight < 1500)
                    ? screenHeight * 0.0245
                    : screenHeight * 0.022,
                fontWeight: FontWeight.w400),
            textStyle: TextStyle(
                color: isByMe ? Colors.black87 : Colors.white,
                fontSize: (realHeight < 1500)
                    ? screenHeight * 0.0245
                    : screenHeight * 0.022,
                fontWeight: FontWeight.w400),
          ),
        ),
      ),
    );
  }
}
