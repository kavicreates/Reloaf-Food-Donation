import 'package:flutter/material.dart';

class CustomerHome extends StatelessWidget {
   CustomerHome({super.key});
  final requiredcontroller=TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("OrphanageHome"),backgroundColor: Colors.yellow,),
      body: Column(
        children: [
          Text("Required food for"),
          TextField(
            controller: requiredcontroller,
            decoration: const InputDecoration(labelText: "0"),
            keyboardType: TextInputType.number,
          ),
          Text("$requiredcontroller"),
        ],
      ),
    );
  }
}
