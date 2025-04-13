import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Homes/OrphanageHome.dart';
import '../Homes/DeliveryPartnerHome.dart';
import '../Homes/RestaurantHome.dart';
import '../pages/Signin.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});


  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth=FirebaseAuth.instance;
  final FirebaseFirestore _firestore=FirebaseFirestore.instance;

  final TextEditingController emailController= TextEditingController();
  final TextEditingController pwController=TextEditingController();

  Future<void> login() async{
    try{
      UserCredential userCredential=await _auth.signInWithEmailAndPassword(email: emailController.text, password: pwController.text);
      DocumentSnapshot userDoc=await _firestore.collection("users").doc(userCredential.user!.uid).get();
      String role=userDoc["role"];

      Widget homePage;
      if(role=="Customer"){
        homePage=CustomerHome();
      }
      else if(role=="DeliveryPartner"){
        homePage=DeliveryPartnerHome();
      }
      else {
        homePage=RestaurantHome();
      }

      Navigator.pushReplacement(context, MaterialPageRoute(builder:(context)=>homePage ));


    }catch(e){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("error")));}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:Text("Login"),backgroundColor: Colors.yellow, centerTitle: true),
      body: Column(
        children: [
          TextField(controller: emailController,decoration: InputDecoration(labelText: "Email"),),
          TextField(controller: pwController,decoration: InputDecoration(labelText: "Password"),),
          ElevatedButton(onPressed: login, child: Text("Login")),
          Text("Dont have an account?"),
          ElevatedButton(onPressed:()=>{ Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Signin()))},child: Text("Signin"),),

        ],
      ),
    );
  }
}

// this piece of shit want working ciz the permission was not given in the rules of firestore
