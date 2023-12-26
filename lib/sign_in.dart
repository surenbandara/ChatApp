import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'firebase/firbase_auth.dart';
import 'main.dart';

class SignIn extends StatelessWidget {

  const SignIn({Key? key}) : super(key: key);


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Journal',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const SignInPage(),
    );
  }
}

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});


  @override
  State<SignInPage> createState() => _SignInPage();
}
class _SignInPage extends State<SignInPage> {
  bool signInLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Image.asset(
          'assest/splash_image.png',
          height: 30, // Adjust the width based on your ratio
          fit: BoxFit.cover,
        ),

      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[ signInLoading ? const SpinKitFadingCircle(
            color: Colors.black, // Set the color of the bubbles
            size: 50.0, // Set the size of the spinner
          ):
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

                print("dgdfgdf");
                signInLoading = true;
                setState(() {
                });

                Firebase_auth firebaseAuth = Firebase_auth();
                firebaseAuth.SignInWIthEmailProv().then((_) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MyHomePage(title: "The Journal")),
                  );
                });

                signInLoading = false;
                setState(() {
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
  }
}


