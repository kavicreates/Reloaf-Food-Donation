import 'package:flutter/material.dart';

class CustomerHome extends StatelessWidget {
  CustomerHome({super.key});

  // Controller to handle text input
  final TextEditingController requiredController = TextEditingController();

  // Function to navigate to the next screen
  void _onSubmit(BuildContext context) {
    String requiredFoodAmount = requiredController.text; // Get the text input
    if (requiredFoodAmount.isNotEmpty) {
      // Navigate to the next screen with the required food amount
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NextPage(requiredFoodAmount: requiredFoodAmount),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Orphanage Home"),
        backgroundColor: Colors.yellow,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Required food for", style: TextStyle(fontSize: 22)),
            const SizedBox(height: 20),
            // TextField to input required food amount
            TextField(
              controller: requiredController,
              decoration: const InputDecoration(
                labelText: "Enter required food amount",
                hintText: "0",
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            // Displaying the entered value (dynamic text)
            Text(
              "Required Food: ${requiredController.text}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Button to submit the entered amount and navigate to next screen
            ElevatedButton(
              onPressed: () => _onSubmit(context),
              child: Text("Submit and Proceed"),
            ),
          ],
        ),
      ),
    );
  }
}

class NextPage extends StatelessWidget {
  final String requiredFoodAmount;

  // Constructor to receive required food amount
  NextPage({super.key, required this.requiredFoodAmount});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Next Page"),
        backgroundColor: Colors.yellow,
      ),
      body: Center(
        child: Text(
          "Required Food Amount: $requiredFoodAmount",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
