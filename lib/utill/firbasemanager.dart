import 'dart:async';

import 'package:chat_application/dataclass/localmainuser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseManager{
  final db =FirebaseFirestore.instance ;

  Future<void> Initialize( String Iniemail ,Map<String,dynamic> IniSelfInfo )async {
    try{
    await db.collection(Iniemail).doc('selfinfo').set(IniSelfInfo , SetOptions(merge: true));
    await db.collection(Iniemail).doc('chats').set({} , SetOptions(merge: true));}
    catch(e){
      print("error $e");
    }

  }

  Future<bool> doesCollectionExist(String collectionName) async {
    try {
      final QuerySnapshot<Object?> result = await db
          .collection(collectionName)
          .limit(1) // Limit the query to only fetch one document
          .get();

      return result.docs.isNotEmpty;
    } catch (e) {
      // Handle any errors, e.g., permissions issues or no network connection
      print("Error checking collection existence: $e");
      return false;
    }
  }

  Future<ChatUser?> AddUser(String email ,String name , [List<Map<String, dynamic>>? chat] ) async {

    print(email);
    print(name);
    print(chat);

    bool doesexist =await doesCollectionExist(email);
    chat ??= [];
    print(doesexist);

    if(doesexist){
      final docRef = await db.collection(email).doc("selfinfo");
      DocumentSnapshot doc = await docRef.get();

      //try{
          final data = doc.data() as Map<String, dynamic>;
          ChatUser chatUser = ChatUser(email: email, name: name, image: data["photo"], publickey: data["publickey"], unreadmsg: 0, last: {"lastid": "", "lasttext": "" , "lastdate" : "" ,"lastdate" : "" }, chatsdata: chat);
          print(chatUser);
          return chatUser;
         // }
        // catch(e) {
        //       print(e);
        //       return null;}
      //       }
   } else{

    return null;}
  }

  Future<void> UpdateSelfInfo (Map<String,dynamic> data , String email) async {
    await db.collection(email).doc("selfinfo").set(data, SetOptions(merge: true));
  }

  Future<void> AddChat(String parentCollection,String childCollection , Map<String,dynamic> newData )  async {

    print("ASdd chat");
      DocumentReference docRef = db.collection(parentCollection).doc("chats");
      DocumentSnapshot docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;

        print("Paren class exist");
        if(data.containsKey(childCollection)){
          List<dynamic> updatedValue = data[childCollection];
          updatedValue.add(newData);
          await docRef.set({childCollection : updatedValue}, SetOptions(merge: true));
        }

        else{
          await docRef.set({childCollection: [newData]}, SetOptions(merge: true));
        }


      } else {

        print('Document does not exist');
      }


  }

  Future<void> DeleteChat(String parentCollection,String childCollection) async {
    try {
      print("Delete chat  $parentCollection , $childCollection");
      DocumentReference docRef = db.collection(parentCollection).doc("chats");
      DocumentSnapshot docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        print("----------Doc for $parentCollection does exist---------");
        final data = docSnapshot.data() as Map<String, dynamic>;

        if(data.containsKey(childCollection)){
          await docRef.set({childCollection : []}, SetOptions(merge: true));
        }


      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error checking collection existence: $e');
    }
  }

}