// class Account {
//   String email;
//   Map<String , dynamic> selfinfo;
//   List<Map<String , dynamic>> usersdata;
//   late List<ChatUser> users = [];
//
//
//   Account({
//     required this.email,
//     required this.selfinfo,
//     required this.usersdata,
//   })
//     {
//
//       for(Map<String,dynamic> i in usersdata ){
//         users.add(ChatUser(email: i["email"], name: i["name"], image: i["image"], publickey: i["publickey"], unreadmsg: i["unreadmsg"], last: i["last"] , chatsdata: i["chats"]));
//
//       }
//     }
//
//
//
//   Map<String, dynamic> toMap() {
//     return {
//       'email': email,
//       'selfinfo': selfinfo,
//       'users': users.map((user) => user.toMap()).toList(),
//     };
//   }
//
//
//   String getSelfinfo(String key){
//     return  selfinfo[key];
//   }
//
//   void setSelfinfo(Map<String,String> selfInfo) {
//     List<String> keys = selfInfo.keys.toList();
//     for(String i in keys){
//       selfinfo[i] = selfInfo[i];
//     }
//   }
//
//   List<ChatUser> getUsers() {
//     return users;
//   }
//
//   set setEmail(String newEmail){
//     this.email = newEmail;
//   }
//
// }
//
// class ChatUser {
//   final String email;
//   String name;
//   String image;
//   String publickey;
//   int unreadmsg ;
//   Map<String , dynamic> last;
//   List<Map<String , dynamic>> chatsdata;
//   late List<Chatday> chats =[];
//
//   ChatUser({
//     required this.email,
//     required this.name,
//     required this.image,
//     required this.publickey,
//     required this.unreadmsg,
//     required this.last,
//     required this.chatsdata,
//   }){
//     for(Map<String ,dynamic> i in chatsdata){
//       chats.add(Chatday(day: i["day"], chatsdata: i["chats"]));
//
//     }
//   }
//
//   Map<String, dynamic> toMap() {
//     return {
//       'email': email,
//       'name': name,
//       'image': image,
//       'publickey': publickey,
//       'unreadmsg': unreadmsg,
//       'last': last,
//       'chats': chats.map((chatday) => chatday.toMap()).toList(),
//     };
//   }
//
//   // Setter for 'name'
//   void setName(String newName) {
//     name = newName;
//   }
//
//   // Setter for 'image'
//   void setImage(String newImage) {
//     image = newImage;
//   }
//
//   // Setter for 'publickey'
//   void setPublickey(String newPublickey) {
//     publickey = newPublickey;
//   }
//
//   // Setter for 'unreadmsg'
//   void setUnreadmsg(int newUnreadmsg) {
//     unreadmsg = newUnreadmsg;
//   }
//
//   void setLastdmsg(Map<String,String> Lastmsg) {
//     List<String> keys = Lastmsg.keys.toList();
//     for(String i in keys){
//       last[i] = Lastmsg[i];
//     }
//   }
//
//   void addChat(String date, Map<String,dynamic> chat , String self) {
//     bool found = false;
//     for(Chatday i in chats){
//       if(i.day==date){
//         i.setMsg(Chat(text : chat["text"] , id: chat["id"] , date : chat["date"] , time : chat["time"] , self : self ));
//         found = true;
//         break;
//       }
//     }
//     if(!found) {
//       chats.add(Chatday(day: date, chatsdata: [chat]));
//     }
//   }
//
//   void deleteChat(String date, String id) {
//     for(Chatday i in chats){
//       if(i.day==date){
//         i.deleteChatById(id);
//         break;
//       }
//     };
//   }
//
//
// }
//
// class Chatday {
//   final String day;
//   List<Map<String , dynamic>> chatsdata;
//   late List<Chat> chats;
//
//   Chatday({
//     required this.day,
//     required this.chatsdata,
//   }){
//     for(Map<String , dynamic> i in chatsdata){
//       chats.add(Chat(text : i["text"] , id: i["id"] , date : i["date"] , time : i["time"] , self : i["self"]));
//     }
//   }
//
//   Map<String, dynamic> toMap() {
//     return {
//       'day': day,
//       'chats': chats.map((chat) => chat.toMap()).toList(),
//     };
//   }
//
//
//   void setMsg(Chat chat) {
//     chats.add(chat);
//   }
//
//   void deleteChatById(String chatId) {
//     chats.removeWhere((chat) => chat.id == chatId);
//   }
//
// }
//
// class Chat {
//   String text ;
//   String id;
//   String date;
//   String time;
//   String self;
//
//   Chat({
//     required this.text,
//     required this.id,
//     required this.date,
//     required this.time,
//     required this.self
//   });
//
//   Map<String, dynamic> toMap() {
//     return {
//       'text': text,
//       'id': id,
//       'date': date,
//       'time': time,
//       'self': self
//     };
//   }
//
// }

class Account {
  String email;
  Map<String , dynamic> selfinfo;
  List<dynamic> usersdata;
  late List<ChatUser> users = [];


  Account({
    required this.email,
    required this.selfinfo,
    required this.usersdata,
  })
  {

    for(Map<String,dynamic> i in usersdata ){
      users.add(ChatUser(email: i["email"], name: i["name"], image: i["image"], publickey: i["publickey"], unreadmsg: i["unreadmsg"], last: i["last"] , chatsdata: i["chats"]));

    }
  }



  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'selfinfo': selfinfo,
      'users': users.map((user) => user.toMap()).toList(),
    };
  }


  String getSelfinfo(String key){
    return  selfinfo[key];
  }

  void setSelfinfo(Map<String,String> selfInfo) {
    List<String> keys = selfInfo.keys.toList();
    for(String i in keys){
      selfinfo[i] = selfInfo[i];
    }
  }

  List<ChatUser> getUsers() {
    return users;
  }

  set setEmail(String newEmail){
    this.email = newEmail;
  }

}

class ChatUser {
  final String email;
  String name;
  String image;
  String publickey;
  int unreadmsg ;
  Map<String , dynamic> last;
  List<dynamic> chatsdata;
  List<Chatday> chats =[];

  ChatUser({
    required this.email,
    required this.name,
    required this.image,
    required this.publickey,
    required this.unreadmsg,
    required this.last,
    required this.chatsdata,
  }){
    for(Map<String ,dynamic> i in chatsdata){
      chats.add(Chatday(day: i["day"], chatsdata: i["chats"]));

    }
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'image': image,
      'publickey': publickey,
      'unreadmsg': unreadmsg,
      'last': last,
      'chats': chats.map((chatday) => chatday.toMap()).toList(),
    };
  }

  // Setter for 'name'
  void setName(String newName) {
    name = newName;
  }

  // Setter for 'image'
  void setImage(String newImage) {
    image = newImage;
  }

  // Setter for 'publickey'
  void setPublickey(String newPublickey) {
    publickey = newPublickey;
  }

  // Setter for 'unreadmsg'
  void setUnreadmsg(int newUnreadmsg) {
    unreadmsg = newUnreadmsg;
  }

  void setLastdmsg(Map<String,String> Lastmsg) {
    List<String> keys = Lastmsg.keys.toList();
    for(String i in keys){
      last[i] = Lastmsg[i];
    }
  }

  void addChat(String date, Map<String,dynamic> chat , String self) {
    bool found = false;
    for(Chatday i in chats){
      if(i.day==date){
        i.setMsg(Chat(text : chat["text"] , id: chat["id"] , date : chat["date"] , time : chat["time"] , self : self ));
        found = true;
        break;
      }
    }
    if(!found) {
      chats.add(Chatday(day: date, chatsdata: [chat]));
    }
  }

  void deleteChat(String date, String id) {
    for(Chatday i in chats){
      if(i.day==date){
        i.deleteChatById(id);
        break;
      }
    };
  }


}

class Chatday {
  final String day;
  List<dynamic> chatsdata;
  List<Chat> chats =[];

  Chatday({
    required this.day,
    required this.chatsdata,
  }){
    for(Map<String , dynamic> i in chatsdata){
      chats.add(Chat(text : i["text"] , id: i["id"] , date : i["date"] , time : i["time"] , self : i["self"]));
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'chats': chats.map((chat) => chat.toMap()).toList(),
    };
  }

  List<Chat> getChats(){
    return chats;
  }


  void setMsg(Chat chat) {
    chats.add(chat);
  }

  void deleteChatById(String chatId) {
    chats.removeWhere((chat) => chat.id == chatId);
  }

}

class Chat {
  String text ;
  String id;
  String date;
  String time;
  String self;

  Chat({
    required this.text,
    required this.id,
    required this.date,
    required this.time,
    required this.self
  });

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'id': id,
      'date': date,
      'time': time,
      'self': self
    };
  }

}