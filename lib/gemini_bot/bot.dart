import 'dart:convert';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gemini_chat/API/key.dart';
import 'package:http/http.dart' as http;

class GeminiChat extends StatefulWidget {
  const GeminiChat({super.key});

  @override
  State<GeminiChat> createState() => _GeminiChatState();
}

class _GeminiChatState extends State<GeminiChat> {

  final myUrl = ApiKey.myUrl;


  /// ************* [ M E S S A G E S   L I S T ] *************
  List<ChatMessage> messageList = [];
  /// ************* [ T Y P I N G    L I S T ] *************
  List<ChatUser> typing = [];

  /// ************* [ C H A T   U S E R S ] *************
  ChatUser user = ChatUser(id: '1', firstName: 'Hamad');
  ChatUser bot = ChatUser(id: '2', firstName: 'Gemini');

  /// ************* [ H E A D E R ] *************
  final header ={
    'Content-Type': 'application/json'
  };

  /// ************* [ F U N C T I O N ] *************
  getData(ChatMessage m) async{
    typing.add(bot);
    messageList.insert(0, m);
    setState(() {
    });

    var data ={"contents":[{"parts":[{"text":m.text}]}]};

    await http.post(Uri.parse(myUrl),headers: header, body:  jsonEncode(data))
        .then((value) {
          if (value.statusCode == 200){
            var result = jsonDecode(value.body);
            print(result['candidates'][0]['content']['parts'][0]['text']);

            ChatMessage botmessage = ChatMessage(
            text: result['candidates'][0]['content']['parts'][0]['text'],
              user: bot,
              createdAt: DateTime.now(),
            );
            messageList.insert(0, botmessage);

          }else{
            print('************************---------error occurred---------- ************************');
          }
    })
        .catchError((e){});
    typing.remove(bot);
    setState(() {
    });

  }

  // Function to copy message text to clipboard
  Future<void> _copyMessageText(ChatMessage message) async {
    final copied = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Copy Message?'),
        content: const Text('Do you want to copy this text to your clipboard?',style: TextStyle(fontWeight: FontWeight.w500),),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel',style: TextStyle(color: Colors.black),),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Copy',style: TextStyle(color: Colors.black),),
          ),
        ],
      ),
    );

    if (copied == true) {
      await Clipboard.setData(ClipboardData(text: message.text));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Copied to clipboard!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text('Gemini Chat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),),
      ),
      body: DashChat(
        typingUsers: typing,
          currentUser: user,
          onSend: (ChatMessage m){
            getData(m);
          },
          messages: messageList,
        inputOptions: const InputOptions(
          alwaysShowSend: true,
        ),
        messageOptions: MessageOptions(
          showTime: true,
          onLongPressMessage: (ChatMessage message) => _copyMessageText(message), // Assign _copyMessageText function
          timeTextColor: Colors.grey.shade600,
          currentUserTimeTextColor: Colors.grey.shade600,
          containerColor: Colors.grey.shade300,
          currentUserContainerColor: Colors.black,
          currentUserTextColor: Colors.white,
          textColor: Colors.black,
        ),
      ),
    );
  }
}
