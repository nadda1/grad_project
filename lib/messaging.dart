import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';
import 'profile.dart';
import 'post.dart';
import 'dart:async';
import 'package:web_socket_channel/io.dart';

class MessagePage extends StatefulWidget {
  final int userid;
  final String username;

  const MessagePage({Key? key, required this.userid, required this.username}) : super(key: key);

  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  TextEditingController messageController = TextEditingController();
  List<String> sentMessages = [];

  Future<void> sendMessage() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      String content = messageController.text;
      if (content.isNotEmpty) {
        final response = await http.post(
          Uri.parse('https://snapwork-133ce78bbd88.herokuapp.com/api/messages'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'receiver_id': widget.userid,
            'content': content,
          }),
        );

        print(response.body); // Print response body for debugging

        if (response.statusCode == 201) {
          var responseData = json.decode(response.body)['data'];
          var messageContent = responseData['message'];
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Message sent successfully")));
          setState(() {
            sentMessages.add(messageContent); // Add sent message to the list
          });
          messageController.clear();
        } else {
          var responseBody = json.decode(response.body);
          var errorMessage = responseBody['message'];
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please enter a message")));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Token not found")));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:Text('Messages', style: TextStyle(color: Color(0xFF343ABA),)),
      ),
      body: Container(
        color: Colors.white, // Set background color to white
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ' ${widget.username}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var message in sentMessages) // Display sent messages
                        ListTile(
                          title: Text(message),
                          // Add any other relevant information here
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0), // Set border radius
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.emoji_emotions),
                          onPressed: () {
                            // Implement emoji option
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: sendMessage,
                    child: Text('Send'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  @override
  void initState() {
    super.initState();



  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<dynamic> futureMessages = [];


  @override
  void initState() {
    super.initState();

    fetchMessages();
  }

  @override
  void dispose() {

    super.dispose();
  }

  Future<void> fetchMessages() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    int id = prefs.getInt('user_id') ?? 0; // Provide a default value or handle the null case

    final response = await http.get(
      Uri.parse('https://snapwork-133ce78bbd88.herokuapp.com/api/messages'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      setState(() {
        List<dynamic> allMessages = json.decode(response.body)['data'];
        futureMessages = allMessages.where((message) => message['sender']['id'] != id &&message['receiver']['id'] == id).toList();
      });
    } else {
      throw Exception('Failed to load messages');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
        backgroundColor: Colors.grey[200],
        elevation: 4,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              // Implement more options functionality
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _getUniqueSenders().length,
        itemBuilder: (context, index) {
          var senderId = _getUniqueSenders()[index];
          var sendername = _getname()[index];
          var lastMessage = _getLastMessage(senderId);
          var receiver_id= lastMessage['receiver']['id'];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Card(
              elevation: 4, // Add shadow to the card
              child: ListTile(
                title: Text('$sendername'),
                subtitle: Text(lastMessage['message']),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatDetailScreen(senderId: senderId,receiverId: receiver_id,Sendername: sendername,),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        color: Color(0xFFF1F5FC),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.home, color: Color(0xFF343ABA)),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => MyHomePage(title: "home")));
              },
            ),
            IconButton(
              icon: Icon(Icons.account_circle_outlined, color: Color(0xFF343ABA)),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }

  List<int> _getUniqueSenders() {
    Set<int> senders = Set();
    futureMessages.forEach((message) {
      senders.add(message['sender']['id']);
    });
    return senders.toList();
  }
  List<String> _getname() {
    Set<String> senders = Set();
    futureMessages.forEach((message) {
      senders.add(message['sender']['name']);
    });
    return senders.toList();
  }

  Map<String, dynamic> _getLastMessage(int senderId) {
    var messagesFromSender =
    futureMessages.where((message) => message['sender']['id'] == senderId);
    return messagesFromSender.isNotEmpty
        ? messagesFromSender.last
        : {'message': 'No messages from this sender'};
  }
}

class ChatDetailScreen extends StatefulWidget {
  final int senderId;
  final int receiverId;
  final String Sendername;

  const ChatDetailScreen({Key? key, required this.senderId, required this.receiverId, required this.Sendername}) : super(key: key);

  @override
  _ChatDetailScreenState createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  List<dynamic> messages = [];
  TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchMessages();
  }

  Future<void> fetchMessages() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    int? id = prefs.getInt('user_id');
    print("debug");
    print(id);
    print(widget.senderId);
    print(widget.receiverId);

    if (token != null && id != null) {
      final response = await http.get(
        Uri.parse('https://snapwork-133ce78bbd88.herokuapp.com/api/messages'),
        headers: {'Authorization': 'Bearer $token'},
      );
      final o_response = await http.get(
        Uri.parse('https://snapwork-133ce78bbd88.herokuapp.com/api/messages/${widget.senderId}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 && o_response.statusCode==200) {

        List<dynamic> allMessagess = json.decode(o_response.body)['data'];
        List<dynamic> allMessages = json.decode(response.body)['data'];
        print(allMessages);
        List<dynamic> sentMessages = allMessages
            .where((message) => message['sender']['id'] == id && message['receiver']['id'] == widget.senderId )
            .map((message) => {...message, 'type': 'received'})
            .toList();
        print("the sent ");
        print(sentMessages);

        List<dynamic> receivedMessages = allMessagess.where((message) => message['sender']['id'] ==  widget.senderId ).map((message) => {...message, 'type': 'sent'}).toList();

        setState(() {
          messages = [...receivedMessages,...sentMessages];
          // messages.sort((a, b) {
          //   var aTimestamp = a['timestamp'];
          //   var bTimestamp = b['timestamp'];
          //   if (aTimestamp == null) return -1;
          //   if (bTimestamp == null) return 1;
          //   return DateTime.parse(aTimestamp).compareTo(DateTime.parse(bTimestamp));
          // });
        });
      } else {
        throw Exception('Failed to load messages');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Token or User ID not found")));
    }
  }

  Future<void> sendMessage(String content) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      if (content.isNotEmpty) {
        final response = await http.post(
          Uri.parse('https://snapwork-133ce78bbd88.herokuapp.com/api/messages'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'receiver_id': widget.senderId,
            'content': content,
          }),
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Message sent successfully")));
          setState(() {
            messages.add({
              'content': content,
              'type': 'sent',
            });
            messageController.clear();
          });


        } else {
          var responseBody = json.decode(response.body);
          var errorMessage = responseBody['message'];
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please enter a message")));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Token not found")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.Sendername),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                var message = messages[index];
                bool isSender = message['type'] == 'sent';
                String messageContent = message['message'] ?? '';
                Color color = isSender ? Color(0xFFADD8E6) : Color(0xFF90EE90); // Blue for sent, green for received
                return Align(
                  alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0),
                        bottomRight: isSender ? Radius.circular(20.0) : Radius.zero,
                        bottomLeft: isSender ? Radius.zero : Radius.circular(20.0),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                        ),
                        padding: EdgeInsets.all(12.0),
                        child: Text(
                          messageContent,
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.send),
                        onPressed: () {
                          sendMessage(messageController.text);
                          fetchMessages();
                          messageController.clear();

                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  @override
  void dispose() {
    super.dispose();
  }

}