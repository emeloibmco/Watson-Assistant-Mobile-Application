import 'package:watsonapp/data/watson_helper.dart';
import 'package:watsonapp/models/message_model.dart';

class ChatMessages {
  List<MessageModel> messages = new List();
  WatsonHelper _watsonHelper = new WatsonHelper();

  sendMessage(String inputText) async {
    List<String> txtList;
    //By me
    MessageModel messageModel = new MessageModel();

    txtList = await _watsonHelper.sendToWatson(inputText.toString());
    //Bot response
    for (int i = 0; i < txtList.length; i++) {
      messageModel = new MessageModel();
      messageModel.isByme = false;
      messageModel.message = txtList[i];
      messages.add(messageModel);
    }
  }

  sendMyMessage(String inputText) {
    MessageModel messageModel = new MessageModel();
    messageModel.isByme = true;
    messageModel.message = inputText;
    messages.add(messageModel);
  }

  createSession() async {
    await _watsonHelper.createSession();
  }

  deleteSession() async {
    await _watsonHelper.deleteSession();
  }

  sendWelcomeMessage() async {
    // Initialize with empty message to start the conversation.

    List<String> txtList;
    MessageModel messageModel = new MessageModel();
    txtList = await _watsonHelper.sendToWatson('');
    //Bot response
    for (int i = 0; i < txtList.length; i++) {
      messageModel = new MessageModel();
      messageModel.isByme = false;
      messageModel.message = txtList[i];
      messages.add(messageModel);
    }
  }

  List<MessageModel> getMessages() {
    return messages;
  }
}
