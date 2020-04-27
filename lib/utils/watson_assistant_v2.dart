import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class WatsonAssistantResponse {
  String resultText;
  WatsonAssistantResponse({this.resultText});
}

class WAConfig {
  String apiKey;
  String version;
  String url;
  String assistantID;

  WAConfig({
    @required this.apiKey,
    @required this.url,
    @required this.assistantID,
    @required this.version,
  });
}

class WatsonAssistantApiV2 {
  WAConfig waConfig;
  var auth;
  var prefs;
  var currSessionID;

  WatsonAssistantApiV2({
    @required this.waConfig,
  });

  Future sendMsg(String textInput) async {
    auth = 'Basic ' + base64Encode(utf8.encode('apikey:${waConfig.apiKey}'));
    prefs = await SharedPreferences.getInstance();

    // Read from Shared Preferences
    if (currSessionID == null) {
      currSessionID = await prefs.getString('session_id_key');
    }

    var rta;
    await _assistantMessage(currSessionID, textInput)
        .then((watsonRes1) async => {
              if (watsonRes1 == "NoSession")
                {
                  print("No active session"),
                  await createSession()
                      .then((newSess) async =>
                          await _assistantMessage(newSess, textInput))
                      .then((watsonRes2) => {
                            //print("watsonRes: " + watsonRes.toString()),
                            rta = watsonRes2
                          })
                      .catchError((err) => {print('err:' + err)})
                }
              else
                {
                  print("Resume session...$currSessionID"),
                  //print("watsonRes: " + returnRes.toString()),
                  rta = watsonRes1
                }
            });
    return rta;
  }

  _assistantMessage(sessionId, textInput) async {
    var watsonResponse;

    Map<String, dynamic> _body = {
      "input": {
        "text": textInput,
        "options": {"return_context": true},
      }
    };

    try {
      watsonResponse = await http.post(
        '${waConfig.url}/v2/assistants/${waConfig.assistantID}/sessions/$sessionId/message?version=${waConfig.version}',
        headers: {'Content-Type': 'application/json', 'Authorization': auth},
        body: json.encode(_body),
      );
      //print("Post message Status code: " + watsonResponse.statusCode.toString());

      var parsedJson = json.decode(watsonResponse.body);

      //print(parsedJson["error"]); //To check validation below

      if (parsedJson['error'] != null &&
          (parsedJson['error'].startsWith('URL sessionid parameter') ||
              parsedJson['error'].toString() == 'Invalid Session')) {
        return "NoSession";
      } else {
        return parsedJson;
      }
    } on Exception {
      print('Failed to post message');
    }
  }

  createSession() async {
    var newSession;

    auth = 'Basic ' + base64Encode(utf8.encode('apikey:${waConfig.apiKey}'));
    prefs = await SharedPreferences.getInstance();
    try {
      newSession = await http.post(
          "${waConfig.url}/v2/assistants/${waConfig.assistantID}/sessions?version=${waConfig.version}",
          headers: {'Content-Type': 'application/json', 'Authorization': auth});
      //print("Create Session Status code: " + newSession.statusCode.toString());

    } on Exception {
      print('Failed to create session');
    }

    var parsedJsonSession = json.decode(newSession.body);
    String sessionID = parsedJsonSession['session_id'];

    // write in Shared preferences
    await prefs.setString('session_id_key', sessionID);
    currSessionID = sessionID;
    print('Writing in Shared preferences: $sessionID');

    return sessionID;
  }

  deleteSession() async {
    var delSess;
    auth = 'Basic ' + base64Encode(utf8.encode('apikey:${waConfig.apiKey}'));
    prefs = await SharedPreferences.getInstance();
    var currSessionID2;
    try {
      if (currSessionID == null) {
        currSessionID2 = await prefs.getString('session_id_key');
      } else {
        currSessionID2 = currSessionID;
      }

      print('Deleting session: $currSessionID2');
      delSess = await http.delete(
          "${waConfig.url}/v2/assistants/${waConfig.assistantID}/sessions/$currSessionID2?version=${waConfig.version}",
          headers: {'Content-Type': 'application/json', 'Authorization': auth});

      //print("Delete Session Status code: " + delSess.statusCode.toString());

      if (delSess.statusCode == 200) {
        // clear preferences
        currSessionID = null;
        prefs.clear();
      } else {
        print("There's no session to delete");
      }
    } on Exception {
      print('Failed to delete session');
    }
  }
}
