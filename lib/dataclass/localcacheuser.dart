import 'package:chat_application/dataclass/localmainuser.dart';
import 'package:chat_application/utill/firbasemanager.dart';

// class AccountCache{
//   final String email;
//   List<Map<String, dynamic>> cachesdata= [];
//   List<Cache> chaches = [];
//   bool Progressing = false;
//   FirebaseManager firebaseManager = FirebaseManager();
//
//
//   AccountCache({required this.email,
//                 required this.cachesdata}){
//    for(Map<String , dynamic> i in cachesdata){
//      if(i["category"] == "user"){
//      chaches.add(UserCaches(category: i["category"], data: i["data"] , type: i["type"] , ));}
//
//      else if (i["category"] == "self"){chaches.add(SelfCaches(category: i["category"], data: i["data"]));}
//
//      else{chaches.add(ChatCaches(i["type"] , i["id"] , i["email"],category: i["category"], data: i["data"] ));}
//    }
//   }
//
//   Cache GetFtoA(){
//     return chaches[0];
//   }
//
//   void DeleteFtoA(){
//     chaches.removeAt(0);
//   }
//
//   void AddChache(Cache cache, Account account){
//     chaches.add(cache);
//     if(!Progressing ){
//       print("Here");
//       Processing(account );
//     }
//
//
//   }
//
//   Future<void> Processing(Account account )async {
//     Progressing = true;
//
//     while (chaches.isNotEmpty) {
//
//       print("It is going");
//       //await Future.delayed(Duration(milliseconds: 100)); // Adjust the delay as needed
//
//       await GetFtoA().Processing(account, firebaseManager, email);
//       DeleteFtoA();
//     }
//
//     Progressing = false;
//   }
//
//   Map<String, dynamic> toMap() {
//     return {
//       'email': email,
//       'caches': chaches.map((cache) => cache.toMap()).toList(),
//     };
//   }
// }
//
// abstract class Cache {
//   final String category;
//   final Map<String,dynamic> data;
//
//   Cache({required this.category,
//   required this.data});
//
//   Map<String, dynamic> toMap() {
//     return {
//       'category': category,
//       'data': data,
//     };
//   }
//
//   Future<void> Processing(Account account ,FirebaseManager firebaseManager , String email);
// }
//
// class UserCaches extends Cache{
//   final String type ;
//   UserCaches({required super.category, required super.data , required this.type});
//
//   @override
//   Map<String, dynamic> toMap() {
//     Map<String, dynamic> superMap = super.toMap();
//     superMap['type'] = type;
//     return superMap;
//   }
//
//   @override
//   Future<void> Processing(Account account ,FirebaseManager firebaseManager , String email)async {
//     firebaseManager.AddUser(data["email"], data["name"]).then((value) {
//       print(value);
//       if(value != null){
//       account.users.add(value!);}
//
//       else{
//         print("No user can be found");
//       }
//     });
//   }
//
// }
//
// class SelfCaches extends Cache {
//   SelfCaches({
//     required String category,
//     required Map<String, dynamic> data,
//   }) : super(category: category, data: data);
//
//   @override
//   Future<void> Processing(Account account, FirebaseManager firebaseManager , String email) async {
//     await firebaseManager.UpdateSelfInfo(data,email );
//   }
// }
//
// class ChatCaches extends Cache{
//   final String type;
//   final String id;
//   final String email;
//   ChatCaches(this.type, this.id, this.email, {required super.category, required super.data});
//
//   @override
//   Map<String, dynamic> toMap() {
//     Map<String, dynamic> superMap = super.toMap();
//     superMap['type'] = type;
//     superMap['id'] = id;
//     superMap['email'] = email;
//     return superMap;
//   }
//
//   @override
//   Future<void> Processing(Account account, FirebaseManager firebaseManager ,String selfemail) async {
//     if(type == "append"){
//       firebaseManager.AddChat(email, selfemail, {"type" : type , "id" : id , "data" : data});
//     }
//     else{
//       firebaseManager.DeleteChat(email, selfemail, id);
//     }
//   }
//
// }
class AccountCache{
  final String email;
  List<dynamic> cachesdata= [];
  List<Cache> chaches = [];
  bool Progressing = false;
  FirebaseManager firebaseManager = FirebaseManager();
  Account? account;


  AccountCache({required this.email,
    required this.cachesdata,
  required this.account}){
    for(Map<String , dynamic> i in cachesdata){
      if(i["category"] == "user"){
        chaches.add(UserCaches(category: i["category"], data: i["data"] , type: i["type"] ,chat: i["chat"] ));}

      else if (i["category"] == "self"){chaches.add(SelfCaches(category: i["category"], data: i["data"]));}

      else{chaches.add(ChatCaches(i["type"] , i["id"] , i["email"],category: i["category"], data: i["data"] ));}
    }
  }

  Cache GetFtoA(){
    return chaches[0];
  }

  void DeleteFtoA(){
    chaches.removeAt(0);
  }

  AddChache(Cache cache , Function() callback) async{
    print("Add chache $Progressing");
    chaches.add(cache);
    if(!Progressing ){
      print("Here");
      await Processing(account! ,callback );
    }


  }

  Future<void> Processing(Account account ,Function() callback)async {
    Progressing = true;

    while (chaches.isNotEmpty) {

      print("It is going");
      //await Future.delayed(Duration(milliseconds: 100)); // Adjust the delay as needed

      await GetFtoA().Processing(account, firebaseManager, email , callback);
      DeleteFtoA();
    }

    Progressing = false;
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'caches': chaches.map((cache) => cache.toMap()).toList(),
    };
  }
}

abstract class Cache {
  final String category;
  final Map<String,dynamic> data;

  Cache({required this.category,
    required this.data});

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'data': data,
    };
  }

  Future<void> Processing(Account account ,FirebaseManager firebaseManager , String email ,Function() callback);
}

class UserCaches extends Cache{
  final String type ;
  final List<Map<String,dynamic>> chat;
  UserCaches({required super.category, required super.data , required this.type , required this.chat});

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> superMap = super.toMap();
    superMap['type'] = type;
    return superMap;
  }

  @override
  Future<void> Processing(Account account ,FirebaseManager firebaseManager , String email ,Function() callback)async {
    ChatUser? newUser = null;
    newUser = await firebaseManager.AddUser(data["email"], data["name"], chat);

    if (newUser != null) {
      account.users.add(newUser);
      callback();
    }


    else {
      print("No user can be found");
    }
  }


}

class SelfCaches extends Cache {
  SelfCaches({
    required String category,
    required Map<String, dynamic> data,
  }) : super(category: category, data: data);

  @override
  Future<void> Processing(Account account, FirebaseManager firebaseManager , String email ,Function() callback) async {
    await firebaseManager.UpdateSelfInfo(data,email );
    callback();
  }
}

class ChatCaches extends Cache{
  final String type;
  final String id;
  final String email;
  ChatCaches(this.type, this.id, this.email, {required super.category, required super.data});

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> superMap = super.toMap();
    superMap['type'] = type;
    superMap['id'] = id;
    superMap['email'] = email;
    return superMap;
  }

  @override
  Future<void> Processing(Account account, FirebaseManager firebaseManager ,String selfemail ,Function() callback) async {
    await firebaseManager.AddChat(email, selfemail, {"type" : type , "id" : id , "data" : data});
    callback();
  }

}