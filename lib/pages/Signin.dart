import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'LoginPage.dart';

class Signin extends StatefulWidget {
  const Signin({super.key});

  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> {

    final FirebaseAuth _auth=FirebaseAuth.instance;
    final FirebaseFirestore _firestore=FirebaseFirestore.instance;

    final TextEditingController emailController=TextEditingController();
    final TextEditingController pwController=TextEditingController();
    String role="Customer";

    Future<void> signin() async{
      try {
        UserCredential userCredentials = await _auth
            .createUserWithEmailAndPassword(email: emailController.text.trim(),
            password: pwController.text.trim());
        await _firestore.collection("users").doc(userCredentials.user!.uid).set(
            {"email": emailController.text, "password": pwController.text, "role": role});

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Created account successfully")));

        Navigator.pushReplacement( context,MaterialPageRoute(builder: (context)=>LoginPage()),);
      }catch(e){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("error: $e")));}

    }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Signin"), centerTitle: true, backgroundColor: Colors.yellow, ),
      body: Column(
        children: [
          TextField(controller: emailController, decoration: InputDecoration(labelText: "Email"),),
          TextField(controller: pwController, decoration: InputDecoration(labelText: "Password"),obscureText: true,),
          Column(
            children: [
              RadioListTile(
                  value: "Customer",
                  title: Text("Customer"),
                  groupValue: role,
                  onChanged: (value){setState(() {
                    role=value.toString();
                  });}
              ),
              RadioListTile(
                  title: Text("Restaurant"),
                  value: "Restaurant",
                  groupValue: role,
                  onChanged: (value){
                    setState(() {
                      role=value.toString();
                    });}
              ),
              RadioListTile(
                  title:Text("DeliveryPartner"),
                  value: "DeliveryPartner",
                  groupValue: role,
                  onChanged: (value){
                    setState(() {
                      role=value.toString();
                    });
                  })
            ],
          ),
          ElevatedButton(onPressed: signin, child: Text("Signin")),
          Text("Already have an account?"),
          ElevatedButton(onPressed:()=> Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=>LoginPage())), child: Text("Login"))
        
        ],
      ),
    );
  }
}
