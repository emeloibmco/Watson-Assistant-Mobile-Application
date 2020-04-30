import 'package:watsonapp/utils/watson_assistant_v2.dart';

class WatsonHelper {
  final _waCredentials = WAConfig(
      version: "2020-02-05",
      apiKey: "",
      url: "",
      assistantID: "");

  var _assistant;

  WatsonHelper() {
    _assistant = new WatsonAssistantApiV2(waConfig: _waCredentials);
  }

  Future<List<String>> sendToWatson(String inputText) async {
    List<String> returnTxt = new List();
    print("Send to Watson: " + inputText.toString());
    await _assistant.sendMsg(inputText).then((res) => {
      print("Respuesta Watson: " + res.toString()),
      if (res['output']['generic'].length == 0)
        {
          returnTxt.add("Estamos presentando inconvenientes, intenta más tarde."),
        }
      else
        {
          if (res['output']['generic'][0]['response_type'] == 'text')
            {
              for (int i = 0; i < res['output']['generic'].length; i++) {returnTxt.add(res['output']['generic'][i]['text'])},
            }
          else if (res['output']['generic'][0]['response_type'] == 'option')
            {
              returnTxt.add(res['output']['generic'][0]['title']),
              for (int i = 0; i < res['output']['generic'][0]['options'].length; i++)
                {returnTxt.add(res['output']['generic'][0]['options'][i]['label'])},
            }
          else if (res['output']['generic'][0]['response_type'] == 'suggestion')
              {returnTxt.add("Por el momento la aplicación no soporta suggestion type :(. Por favor reformula la pregunta.")},
        }
    });
    return returnTxt;
  }

  createSession() async {
    await _assistant.createSession().then((res) => {res});
  }

  deleteSession() async {
    await _assistant.deleteSession();
  }
}
