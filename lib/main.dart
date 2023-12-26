import 'package:chat_application/chat_page.dart';
import 'package:chat_application/dataclass/localcacheuser.dart';
import 'package:chat_application/dataclass/localmainuser.dart';
import 'package:chat_application/sign_in.dart';
import 'package:chat_application/utill/endercryptor.dart';
import 'package:chat_application/utill/firbasemanager.dart';
import 'package:chat_application/utill/keyidgen.dart';
import 'package:chat_application/utill/localdbmanager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'firebase_options.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'firebase/firbase_auth.dart';
import 'package:pointycastle/api.dart' as crypto;
import 'dart:ui' as ui;

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Firebase_auth firebaseAuth = Firebase_auth();

  User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) {

      runApp(const SignIn());
      FlutterNativeSplash.remove();

  } else {
    runApp(const MyApp());
    FlutterNativeSplash.remove();
  }

}

class MyApp extends StatelessWidget {

  const MyApp({Key? key}) : super(key: key);


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Journal',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const MyHomePage(title: "The Journal" ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title });


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  late String selfEmail , MainDBName ,CacheDBName ;
  late LocalDBManager mainDBManager,cacheDBManager ;
  Account? account = null;
  late AccountCache accountCache;

  KeyIdGenerator keyIdGenerator = KeyIdGenerator();
  EnDeCryptor enDeCryptor = EnDeCryptor();
  FirebaseManager firebaseManager = FirebaseManager();

  late crypto.PublicKey publikey;
  late crypto.PrivateKey privateKey ;

  List<String> useremails=[];

  GlobalKey<ChatPageState> chatPageKey = GlobalKey();

  var db = FirebaseFirestore.instance;

  ImageProvider? image = null ;

  //Account account = Account(email: "surenbandara7@gmail", selfinfo: {"ds":"fd"}, users: [ChatUser(email: "dss", name: "fdsf", image: "fdf", publickey: "dsfds", unreadmsg: 0, last: {"df":"dsd"}, chats: [Chatday(day: "fdsfsd", chats: [Chat(text: "fd", id: "fg", date: "fdsf", time: "ds")])])]);

  var requests = [];
  Map<String, dynamic> tickets = {"loading" : true , "tickets" : []};

  late String pro ;


  Future<void> restore() async {
    try {
      await mainDBManager.deleteFile();
      await cacheDBManager.deleteFile();

    } catch (e) {
      print("An error occurred: $e");
      // Handle errors as needed
    }
  }

  Future<void> saveLocal() async{
    await mainDBManager.saveObject(account!.toMap());
    await cacheDBManager.saveObject(accountCache.toMap());
  }

  void updateWidget() {
    print("update widthe");
    saveLocal();
    setState(() {
    });
  }

  void Inititalizer() async{
    //await restore();

    Map<String,dynamic>? mainDB =  await mainDBManager.readObject();
    Map<String,dynamic>? cacheDB =  await cacheDBManager.readObject();

    if(mainDB != null){
      // publikey = mainDB?["selfinfo"]["publickey"] as RSAPublicKey;
      // privateKey = mainDB?["selfinfo"]["privatekey"] as RSAPrivateKey;

      //publikey = mainDB?["selfinfo"]["publickey"];
      //privateKey = mainDB?["selfinfo"]["privatekey"];

      account = Account(email: mainDB?["email"] ,selfinfo: mainDB?["selfinfo"] , usersdata:mainDB?["users"] );

      for(Map<String ,dynamic> i  in mainDB?["users"]){
        useremails.add(i["email"]);
      }

      await firebaseManager.Initialize(selfEmail, mainDB?["selfinfo"]);
    }

    else{
      String image = await enDeCryptor.imageToBase64(FirebaseAuth.instance.currentUser?.photoURL ?? "Unknown",);

      crypto.AsymmetricKeyPair<crypto.PublicKey, crypto.PrivateKey> keyPair = keyIdGenerator.generateRSAkeyPair();
      // publikey = keyPair.publicKey as RSAPublicKey;
      // privateKey = keyPair.privateKey as RSAPrivateKey;

      account = Account(email: selfEmail,
          selfinfo: {"photo" : image, "publickey" : "pubkey" , "privatekey" : "prikey"} ,
          usersdata: []);

      await firebaseManager.Initialize(selfEmail, {"photo" : image, "publickey" : "pubkey"});

    }

    image = (enDeCryptor.imageFromBase64(account?.selfinfo["photo"]).image) ;

    updateWidget();

    if(cacheDB != null){
      accountCache = AccountCache(email: cacheDB?["email"],account: account, cachesdata: (cacheDB?["caches"] as List<dynamic>?)!.cast<Map<String, dynamic>>() );}
   else{
      accountCache = AccountCache(email: selfEmail , account: account, cachesdata: [] );
    }

    accountCache.Processing(account! , updateWidget);

   /////////////////////////////////////////////////////////////////////

    final docRef = db.collection(selfEmail).doc("chats");
    docRef.snapshots().listen(
          (DocumentSnapshot docSnapshot) async {
        if (docSnapshot.exists) {
          Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
          print(data);
          if (data != null && data is Map<String, dynamic>) {
            List<String> keys = data.keys.toList();

            for (String key in keys) {
              for (Map<String,dynamic> value in data[key] ) {
                if (value["type"] == "delete") {
                  ChatUser? user = account?.users.firstWhere((user) =>
                  user.email == key, orElse: null);

                  if (user != null) {
                    user.deleteChat(value["data"]["date"], value["id"]);
                  }
                }

                else {
                  ChatUser? user = null;

                  if (account?.users?.isNotEmpty == true) {
                    user = account!.users.firstWhere(
                          (ChatUser user) => user.email == key
                    );
                  }

                  if (user != null) {
                    user.addChat(value["data"]["date"], value["data"], "false");
                  }
                  else {
                    value["data"]["self"] = "false";
                    await accountCache.AddChache(UserCaches(category: "user",
                        data: {"email": key, "name": key , }, chat: [{"day": value["data"]["date"] , "chats" :[value["data"]]}] ,
                        type: "append"), updateWidget);


                  }
                }



              }
              await firebaseManager.DeleteChat(selfEmail, key);
            }
          } else {
            print("Document data is null or not of type Map<String, dynamic>");
          }

          chatPageKey.currentState?.updateWidget();
          updateWidget();
        }
        else {
          print("Document does not exist");
        }
      },
      onError: (error) {
        // Handle error here
        print("Error: $error");
      },
    );
  }

  @override
  void initState() {
    super.initState();
    tickets["loading"] = true;

    selfEmail =  FirebaseAuth.instance.currentUser?.email ?? "unknown";
    MainDBName = "${selfEmail.split(".")[0]}MainDB";
    CacheDBName = "${selfEmail.split(".")[0]}CacheDB";

    mainDBManager = LocalDBManager(fileName: MainDBName);
    cacheDBManager = LocalDBManager(fileName: CacheDBName);


    Inititalizer();


    tickets["loading"] = false;

  }

  @override
  void dispose(){
    super.dispose();
    saveLocal();
  }


  Widget getRequestIcon(String isAccepted, String isSelfSender , String isSelfReciver ,String isDeleted) {
    if (isAccepted == "true") {
      return const Icon(
        Icons.check_circle,
        size: 15,
        color: Colors.green,
      );
    } else {
      if (isDeleted == "true"){
        return const Icon(
          Icons.no_accounts_rounded,
          size: 15,
          color: Colors.amber,
        );

      }
      else {
        return const Icon(
          Icons.pending_actions,
          size: 15,
          color: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if( FirebaseAuth.instance.currentUser == null){
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
          actions: [],
          title: Image.asset(
            'assest/splash_image.png',
            height: 30, // Adjust the width based on your ratio
            fit: BoxFit.cover,
          ),


        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                "Sign in to stay with The Journal !"
                ,style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w500
              ), ),
              SizedBox(height: 10),

              ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Colors.indigo),
                onPressed: () {
                  Firebase_auth firebaseAuth = Firebase_auth();
                  firebaseAuth.SignInWIthEmailProv().then((_) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => MyHomePage(title: "The Journal")),
                    );
                  });
                },
                child: const Text('Sign In' ,
                  style: TextStyle(
                    color: Colors.white,

                  ),),
              ),
            ],
          ),
        ),
      );
    }else{

      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
          title: Image.asset(
            'assest/splash_image.png',
            height: 30, // Adjust the width based on your ratio
            fit: BoxFit.cover,
          ),

          actions: [
            Row(
              children: [

                IconButton(
                  icon: Icon(Icons.restore),
                  onPressed: () {
                    restore();
                  },
                ),
                GestureDetector(
                  onTap: () {
                    _showOptions(context);
                  },
                  child:
                  account != null || image != null
                      ? CircleAvatar(
                    backgroundImage: image,
                  )
                      : CircleAvatar(
                    backgroundColor: Colors.grey, // Set a background color for the CircleAvatar
                    child: SpinKitFadingCircle(
                      color: Colors.white, // Set the color of the spinner
                      size: 30.0, // Set the size of the spinner
                    ),
                  ),

                ),
                const SizedBox(width: 16),

              ],
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
                    child: Container(
                        child :
                        tickets["loading"]
                            ? const Center(
                          child: SpinKitFadingCircle(
                            color: Colors.black, // Set the color of the bubbles
                            size: 50.0, // Set the size of the spinner
                          ),
                        ) : account == null
                            ?
                        const Center(
                          child: SpinKitFadingCircle(
                            color: Colors.black, // Set the color of the bubbles
                            size: 50.0, // Set the size of the spinner
                          ),
                        )
                        :
                        account!.users.isEmpty
                            ? const Center(
                          child: Text(
                            'No Friends',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ):
                        ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: account!.users.length,
                          itemBuilder: (context, index) {
                            String name = account!.users[index].name ;
                            String email = account!.users[index].email;
                            String image = account!.users[index].image;
                            int unreadmsg = account!.users[index].unreadmsg;
                            Map<String,dynamic> last = account!.users[index].last;

                            return InkWell(
                              onTap: () async {

                                var newData = await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => ChatPageStatefulWidget(chatUser: account!.users[index], enDeCryptor: enDeCryptor,
                                    keyIdGenerator: keyIdGenerator, accountCache: accountCache, key: chatPageKey,
                                    privatekey : account!.selfinfo["privatekey"] , selfemail: selfEmail, )),
                                );
                                // Check if newData is not null, and refresh the page
                                print(newData);
                                updateWidget();
                              },
                              child: Card(
                                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                color: Colors.white, // Change the color as needed
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        backgroundImage: (enDeCryptor.imageFromBase64(image).image) as ImageProvider,
                                      ),

                                      //getRequestIcon(isAccepted ,isSelfSender , isSelfReciver ,isDeleted),


                                      SizedBox(width: 6),
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            name,
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),

                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                    )
                ),
              ],
            ),
          ),
        ),

        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            //await restore();

            //print(account?.users);
            // String useremail = selfEmail;
            // String id = keyIdGenerator.generateUniqueId(useremail, selfEmail);
            // Chat chat = Chat(text: "Hi", id: id , date: DateTime.now().toString() , time: DateTime.now().toString() , self : "true");
            // accountCache.AddChache(ChatCaches("append", id, useremail, category: "chat", data: chat.toMap()), account!);
            // print(account.getUsers()[0].email);
            // accountCache.AddChache( SelfCaches(category : "self" , data : {"photo":"Newone1"}), account);
            // accountCache.AddChache( SelfCaches(category : "self" , data : {"photo":"Newone2"}), account);
            // accountCache.AddChache( SelfCaches(category : "self" , data : {"photo":"Newone3"}), account);
            // accountCache.AddChache( SelfCaches(category : "self" , data : {"photo":"Newone4"}), account);
            //
            // accountCache.AddChache( UserCaches(category : "user" , type : "append" , data : {"email":"bandarasuren99721@gmail.com" , "name" : "suren" }), account);



            // FirebaseManager firebaseManager = FirebaseManager();
            // firebaseManager.AddChat("surenbandara7@gmail.com", "selfEmail" , {"Test":"test"});
            //
            // -------------------------------------------------
            // print(account.users[0].name);
            //
            // ChatUser chatUser = account.getUsers()[0];
            // KeyIdGenerator keyIdGenerator = KeyIdGenerator();
            // chatUser.setName("rtytr");
            //
            // // Generate an RSA key pair
            // crypto.AsymmetricKeyPair<crypto.PublicKey, crypto.PrivateKey>
            // keyPair =
            // keyIdGenerator.generateRSAkeyPair(keyIdGenerator.exampleSecureRandom());
            //
            // final myPublic = keyPair.publicKey as RSAPublicKey;
            // final myPrivate = keyPair.privateKey as RSAPrivateKey;
            //
            // // Create a string
            // String myString = "Hefgdfdgfdgfdg"
            //     "fdgfgfgdfdgfdgfdgfdgdfgfdgdfgfdgfdgfdg"
            //     "fdgfdgfdgfgdfdgfdgfgdfdgfgdfdggfdgfdgfdgfdggggggggggfdddddddddddddddddddddddd"
            //     "gffgdgdfgfdgddfgdffdgfdgfdgfdgdfgdfgdfgdfgfdgdfdgfdgfdgggdgfgdfgfgfddfgfdg"
            //     "gfdfdgfdgfdgdgffdgfdggfdfdgfdgfdgfdgfdgfdgfdgfdgfdgfdgllo, World!"
            //     "k854I0D73NkiIW9hfTl6e5vM2tsuGII44GZ1r1iE1UTlGrm0ql5mYBWQagVBDluM/Jc5h4ScEbGKvO7e6T5SHfw3+mJ4m6jnnH9P5/9Ob30qViZkdoMqphp7BmNDZN8nfKgLnhq/6JtNSl0E3otRh8HZCKpwGm2wneb8u6DJryLqvZO/BQu/qOwr58GJ5z8v0srmS8kVNT20OPT+mb2oO98dsPeIK+NBrOvx/Zq5PuIB5C2L64aBjhlVTH09LOJ39G2xksW8sW22xVyyhM6r6gFFbt3ByN6ROHvQdMLZ/CtwHlDiCpfeHaSM2CG77b/RH64DKwUUgYoyiM5Tg6zJmw==";
            //
            // String encrypted  = keyIdGenerator.rsaEncryptString(myPublic , myString);
            // String decrypted = keyIdGenerator.rsaDecryptString(myPrivate , encrypted);
            //
            // print(encrypted );
            // print(decrypted);
            _showEditor(context);
          },
          label: const Text(
            "Add Friend",
            style: TextStyle(
              color: Colors.white70, // Set the desired text color
            ),
          ),
          icon: const Icon(Icons.message_rounded, color: Colors.white),
          backgroundColor: Colors.blue, // Set the desired background color
        ),
        // This trailing comma makes auto-formatting nicer for build methods.

      );}
  }


  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(

          mainAxisSize: MainAxisSize.min,
          children: <Widget>[

            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Sign Out'),
              onTap: () async {
                // Handle sign out option
                Navigator.pop(context);

                Firebase_auth firebaseAuth = Firebase_auth();
                firebaseAuth.signOutFromGoogle().then((value) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const SignInPage()),
                  );
                });


              },
            ),
          ],
        );


      },
    );
  }

  void _showEditor(BuildContext context) {
    final emailFocusNode = FocusNode();
    final emailController = TextEditingController();
    final nameController = TextEditingController();

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
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            "Add Friend",
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center, // Center-align the text
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: emailController,
                focusNode: emailFocusNode,
                decoration: InputDecoration(
                  hintText: 'Email',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Name',
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      final city = <String, String>{
                        "name": "Los Angeles",
                        "state": "CA",
                        "country": "USA"
                      };
                      db
                          .collection("surenbandara7@gmail.com")
                          .doc("LA")
                          .set(city)
                          .onError((e, _) => print("Error writing document: $e"));

                      // Validate email format
                      RegExp emailRegExp = RegExp(
                          r'^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                      bool isEmailValid =
                      emailRegExp.hasMatch(emailController.text);

                      if (emailController.text.isEmpty ||
                          nameController.text.isEmpty) {
                        // Show a required message if any field is empty
                        showErrorDialog('Both email and name are required.');
                      } else if (!isEmailValid) {
                        // Show an invalid email format message
                        showErrorDialog('Please enter a valid email address.');
                      }
                      else if(emailController.text == FirebaseAuth.instance.currentUser?.email ) {
                        showErrorDialog('Please enter friend email not yours');
                      }else {
                        Navigator.pop(context);

                        setState(() {
                          tickets["loading"] = true;
                        });
                        var name = nameController.text;
                        var email = emailController.text;

                        accountCache.AddChache(UserCaches(category: "user", data: {"email" : email , "name" :name}, chat: [], type: "append") ,updateWidget);
                        setState(() {
                          tickets["loading"] = false;
                        });

                        nameController.text = '';
                        emailController.text = '';
                        // You can perform additional actions with the request data
                      }
                    },
                    style: ElevatedButton.styleFrom(primary: Colors.indigo),
                    child: const Text('Add',
                        style: TextStyle(
                          color: Colors.white,

                        )),
                  ),
                  ElevatedButton(
                    onPressed: () {

                      nameController.text = '';
                      emailController.text = '';
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


}





