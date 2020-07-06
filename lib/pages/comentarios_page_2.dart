import 'package:flutter/material.dart';
import 'package:dash_chat/dash_chat.dart';
final DateTime timestamp= DateTime.now();
class ComentariosPage2 extends StatefulWidget {
  @override
  _ComentariosPage2State createState() => _ComentariosPage2State();
}

class _ComentariosPage2State extends State<ComentariosPage2> {

  final GlobalKey<DashChatState> _chatViewKey = GlobalKey<DashChatState>();

  final ChatUser user = ChatUser(
    name: "Fayeed",
    firstName: "Fayeed",
    lastName: "Pawaskar",
    uid: "12345678",
    avatar: "https://www.wrappixel.com/ampleadmin/assets/images/users/4.jpg",
  );

  final ChatUser otherUser = ChatUser(
    name: "Mrfatty",
    uid: "25649654",
  );

  List<ChatMessage> messages = List<ChatMessage>();
  var m = List<ChatMessage>();
  

  var i = 0;

  send(){
    // messages.add(ChatMessage(
    // user: user,  
    // text: "hola....njashfkjdjkfjksdhfkjdhkjfshskjdfhkjshfkjsjcbjskbdcjksdbjbskjdfhjkdsbcjksdbjckbsdkjbjkshdskj........",
    // createdAt: DateTime.now(),
    // ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
          backgroundColor: Theme.of(context).accentColor,
          centerTitle: true,
          title: Text(
      'Comentarios',
      style: TextStyle(
       color:Colors.white,
       fontFamily: 'Signatra',
       fontSize: 22.0,
        ),
        ),
      ),
      body: DashChat(
        key: _chatViewKey,  
        inverted: false,
        user: user,
        
        sendOnEnter: true,
        textInputAction: TextInputAction.send,
        onSend: send(),
        showUserAvatar: true,
        scrollToBottom: true,
        messageContainerPadding: EdgeInsets.only(left: 5.0, right: 5.0),
        alwaysShowSend: true,
        inputTextStyle: TextStyle(fontSize: 16.0),
        messages: messages,
        onQuickReply: (Reply reply) {
          print('reply-----');
          print(reply.value);

         setState(() {
             messages.add(ChatMessage(
             text: reply.value,
             createdAt: DateTime.now(),
             user: user));
      
                  });
                 },
               
    ),
    );
  }
}