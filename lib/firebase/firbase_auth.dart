import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class Firebase_auth {

  final db = FirebaseFirestore.instance;

  Future<void> signOutFromGoogle() async {
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
    } catch (e) {
      print('Error during sign out: $e');
    }
  }

  Future<void> SignInWIthEmailProv() async {
    try {

      GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      print("Sign In sucess!");
    } catch (error) {
      print("Error during sign-in: $error");

    }
  }

  Future<bool> addUsers(String selfemail , String selfname, String email , String name  ) async {
    var querysnapshotself=await db.collection(selfemail).where('email', isEqualTo: email).get();
    var querysnapshotuser =await  db.collection(email).where('email', isEqualTo: selfemail).get();

    List<Map<String, String>> chats = [];

    if(querysnapshotuser.docs.isEmpty){
      db
          .collection(email)
          .doc(selfemail)
          .set({
        "name": selfname,
        "state": "active",
        "lastmessagetext": "",
        "lastmessagetime": "",
        "unreadmsg": 0 ,
        "profilepic": "",
        "chat": chats
      })
          .onError((e, _) => print("Error writing document: $e"));
    }

    if(querysnapshotself.docs.isEmpty){
      db
          .collection(selfemail)
          .doc(email)
          .set({
        "name": name,
        "state": "active",
        "lastmessagetext": "",
        "lastmessagetime": "",
        "unreadmsg": 0 ,
        "profilepic": "",
        "chat": chats
      })
          .onError((e, _) => print("Error writing document: $e"));

      return true;
    }
    else{
      return false;
    }



    }

  Future<void> addBills(String selfemail , String email ,Map<String, String> bill  ) async {
    CollectionReference usersRef = FirebaseFirestore.instance.collection(selfemail);

    // Example: Query to retrieve a user document with a specific role
    var query = FirebaseFirestore.instance.collection(selfemail).where('email', isEqualTo: email);

    // Execute the query and get the documents
    var querySnapshot = await query.get();

    // Check if any documents match the query
    if (querySnapshot.docs.isNotEmpty) {
      // Assuming only one document is expected, you can access it using the first document
      var userDocument = querySnapshot.docs.first;

      // Access the document ID (if needed)
      var documentId = userDocument.id;

      // Access the data in the document
      var userData = userDocument.data();
      print(userData);
      userData['billings'].add(bill);

      // Example: Update the 'name' field of the user
      await FirebaseFirestore.instance.collection(selfemail).doc(documentId).update({
        'billings': userData['billings'],
      });
    }}
  }







