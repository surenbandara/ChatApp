import 'dart:convert';

import 'package:chat_application/dataclass/localcacheuser.dart';
import 'package:chat_application/dataclass/localmainuser.dart';
import 'package:chat_application/utill/endercryptor.dart';
import 'package:chat_application/utill/keyidgen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'firebase/firbase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:crypto/crypto.dart';

class ChatPageStatefulWidget extends StatefulWidget {
  const ChatPageStatefulWidget({super.key, required this.chatUser , required this.enDeCryptor ,
    required this.keyIdGenerator , required this.accountCache ,
  required this.privatekey , required this.selfemail });

  final ChatUser? chatUser;
  final EnDeCryptor enDeCryptor ;
  final KeyIdGenerator keyIdGenerator;
  final AccountCache accountCache ;

  final String privatekey;
  final String selfemail;




  @override
  State<ChatPageStatefulWidget> createState() => ChatPageState();
}


class ChatPageState extends State<ChatPageStatefulWidget> {

  var db = FirebaseFirestore.instance;
  // Define controllers
  TextEditingController dateTextController = TextEditingController();
  TextEditingController descriptionTextController = TextEditingController();
  TextEditingController amountTextController = TextEditingController();

  final ScrollController _controller = ScrollController();


  var debits ,credits =[];
  Map<String, dynamic>  bills = {"loading" : true , "bills" : []};

  DateTime? _selectedDate = DateTime.now();

  String selectedValue = 'Credit';
  List<String> dropdownItems = ['Credit', 'Debit'];

  Map<String, Color> optionColors = {
    'Credit': Colors.deepOrangeAccent,
    'Debit': Colors.lightGreen,
    // Add more options and colors as needed
  };

  String? lastDate;
  int total = 0;

  var name =null ;


  bool deletePopupLoading = false;
  bool renamePopupLoading = false;


  final TextEditingController _textController = TextEditingController();


  ChatUser? chatUser ;
  late ImageProvider image ;



  @override
  void initState() {
    super.initState();
    print("here");
    chatUser = widget.chatUser;
    image = (widget.enDeCryptor.imageFromBase64(widget.chatUser!.image).image) as ImageProvider ;
    updateWidget();
    bills["loading"] = false;

  }

  void updateWidget() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _scrollDown();
    });
    setState(() {});
  }

  void _scrollDown() {
    print("Scrolled down ${_controller.position.maxScrollExtent}");

    _controller.animateTo(
      _controller.position.maxScrollExtent,
      curve: Curves.fastOutSlowIn,
      duration: const Duration(milliseconds: 300),
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: image,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                name ?? widget.chatUser?.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis, // Optional: Add this line to show ellipsis (...) for long texts
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.abc_outlined),
            onPressed: () {
              _renameWidget(context);
            },
          ),
          IconButton(
            icon: Icon(Icons.delete_outline),
            onPressed: () {
              _deleteProfile(context , widget.chatUser?.email, widget.chatUser?.name);
            },
          ),
        ],
      ),

      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0), // Adjust the top and bottom padding as needed
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[

              Expanded(
                child:
                Container(
                    child:
                    bills["loading"]
                        ? const Center(
                      child: SpinKitFadingCircle(
                        color: Colors.black, // Set the color of the bubbles
                        size: 50.0, // Set the size of the spinner
                      ),
                    ) :
                    widget.chatUser!.chats.isEmpty
                        ? const Center(
                      child: Text(
                        'No Chats',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ):

                    ListView.builder(
                      controller: _controller,
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: chatUser?.chats.length,
                      itemBuilder: (context, index) {
                        final chatDay = chatUser!.chats[index];

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Display the date for the current chat day
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                chatDay.day,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            // Inner ListView.builder to display individual chats for the current chat day
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: chatDay.chats.length,
                              itemBuilder: (context, innerIndex) {
                                final chat = chatDay.chats[innerIndex];
                                return ChatBubble(
                                  message: chat.text,
                                  isSelf: chat.self == "true",
                                  time: chat.time,
                                  onTap: () {
                                    // Handle onTap for each chat bubble
                                    print('Tapped on message:');
                                  },
                                );
                              },
                            ),
                          ],
                        );
                      },
                    )





                ),
              ),

              Divider(height: 1),
              Container(
                decoration: BoxDecoration(color: Theme.of(context).cardColor),
                child: _buildTextComposer(),
              ),

            ],
          ),
        ),
      ),

    );
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).canvasColor),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                onSubmitted: _handleSubmitted,
                decoration:
                InputDecoration.collapsed(hintText: 'Type a message'),
              ),
            ),
            IconButton(
              icon: Icon(Icons.send),
              onPressed: (){ _handleSubmitted(_textController.text);
                _textController.text = '';},
              color: Colors.green, // Set your desired color here
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmitted(String text) {

    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    String id = widget.keyIdGenerator.generateUniqueId(widget.selfemail, widget.chatUser!.email);
    Map<String,dynamic> data = {"text" :text , "id" : id
      , "date" : formattedDate , "time" : DateFormat('hh:mm').format(now) , "self" : "true"};

    widget.chatUser?.addChat(formattedDate, data , "true");
    _scrollDown();

    widget.accountCache.AddChache(ChatCaches("append", id, widget.chatUser!.email, category: "chat", data: data) , updateWidget);



  }

  void _deleteProfile(BuildContext context,email ,name ) async {
    print("Delte");
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                backgroundColor: Colors.white,
                title: Center(
                  child: Text(
                    deletePopupLoading ? "Deleting ..!" :"Do you want to delete ${name ?? "User"}?"
                    ,

                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                content:
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children:  deletePopupLoading
                      ? [const Center(
                    child: SpinKitFadingCircle(
                      color: Colors.black, // Set the color of the bubbles
                      size: 50.0, // Set the size of the spinner
                    ),
                  ) ]:<Widget>[


                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () async {


                            deletePopupLoading=true;
                            setState((){});

                            String selfEmail = FirebaseAuth.instance.currentUser?.email ?? "Unknown";
                            CollectionReference usersRefSelf = FirebaseFirestore.instance.collection(
                                selfEmail);
                            CollectionReference usersRefOther = FirebaseFirestore.instance.collection(
                                email);

                            var querySnapshot_self = await usersRefSelf.where('email', isEqualTo: email)
                                .get();
                            var querySnapshot_other = await usersRefOther.where('email', isEqualTo: selfEmail)
                                .get();

                            if (querySnapshot_self.docs.isNotEmpty) {
                              var userDocument_self = querySnapshot_self.docs.first;
                              var documentId_self = userDocument_self.id;
                              await usersRefSelf
                                  .doc(documentId_self)
                                  .delete();
                            }

                            if (querySnapshot_other.docs.isNotEmpty) {
                              var userDocument_other = querySnapshot_other.docs.first;
                              var documentId_other = userDocument_other.id;

                              await usersRefOther
                                  .doc(documentId_other)
                                  .update({
                                'request' : {
                                  'accept' : "false",
                                  'send' : "false" ,
                                  'recieve' : "false",
                                  'delete' : "true"
                                }
                              });
                            }

                            deletePopupLoading=false;
                            setState((){});
                            Navigator.pop(context );
                            Navigator.pop(context, 42);

                          },
                          style: ElevatedButton.styleFrom(primary: Colors.red),
                          child: const Text('Delete',
                              style: TextStyle(
                                color: Colors.white,

                              )),
                        ),
                        ElevatedButton(
                          onPressed: () {

                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(primary: Colors.white12),
                          child: const Text('Cancel',
                              style: TextStyle(
                                color: Colors.black,

                              )),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        }
    );





    
  }

  void _renameWidget(BuildContext context){

    final newNameController = TextEditingController();


    void showErrorDialog(String message) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Warning ! ',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
            content: Text(message,
              style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500
              ),),
            actions: <Widget>[

              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the popup
                },
                style: ElevatedButton.styleFrom(primary: Colors.white12),
                child: const Text('Ok' ,
                  style: TextStyle(
                    color: Colors.black,

                  ),),
              )
            ],
          );
        },
      );
    }

    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                backgroundColor: Colors.white,
                title: const Center(
                  child: Text(
                    "Rename ",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children:  renamePopupLoading
                  ? [const Center(
                    child: SpinKitFadingCircle(
                      color: Colors.black, // Set the color of the bubbles
                      size: 50.0, // Set the size of the spinner
                    ),
                  ) ]: <Widget>[
                    Container(
                      child: TextField(
                        controller: newNameController,
                        decoration: const InputDecoration(
                          hintText: 'New name',
                        ),

                      ),
                    ),

                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            if (newNameController.text.isEmpty ) {
                              showErrorDialog('All fields are required');
                            } else {

                              chatUser?.name = newNameController.text;

                              updateWidget();
                              Navigator.pop(  context );

                              setState((){});
                              newNameController.text = '';
                            }
                          },
                          style: ElevatedButton.styleFrom(primary: Colors.indigo),
                          child: const Text('Rename',
                              style: TextStyle(
                                color: Colors.white,

                              )),
                        ),
                        ElevatedButton(
                          onPressed: () {

                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(primary: Colors.white12),
                          child: const Text('Cancel',
                              style: TextStyle(
                                color: Colors.black,

                              )),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        }
    );
  }

  void _addTicket(String date , String description ,String amount , String type  ,String id) {
    setState(() {
      bills["bills"].add( {'date': date, 'description': description , 'amount' : amount , 'type' : type , 'id' : id});
    });
  }

  String generateUniqueId(String email , String desciption , String amount) {
    int milliseconds = DateTime.now().millisecondsSinceEpoch;
    String input = '$email-$milliseconds-$desciption-$amount';

    // Create an MD5 hash
    var bytes = utf8.encode(input);
    var md5Hash = md5.convert(bytes);

    // Convert the hash to a hexadecimal string
    String uniqueId = md5Hash.toString();

    return uniqueId;
  }


}

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isSelf;
  final VoidCallback onTap;
  final String time;

  ChatBubble({required this.message, required this.isSelf, required this.onTap , required this.time});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8.0),
        alignment: isSelf ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: isSelf ? Colors.blue : Colors.grey,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            crossAxisAlignment: isSelf ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width *3/5 ),
                child: Text(
                  message,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16, // Adjust the font size for the message text
                  ),
                ),
              ),
              Text(
                time,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 7, // Adjust the font size for the date
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}


