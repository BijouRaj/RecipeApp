import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MaterialApp(
    title: 'Recipe App',
    home: RecipeScreen(),
    debugShowCheckedModeBanner: false, // Remove debug banner
  ));
}

class RecipeScreen extends StatefulWidget {
  @override
  _RecipeScreenState createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State
    with AutomaticKeepAliveClientMixin { // Add AutomaticKeepAliveClientMixin to prevent rebuilding on scroll

  TextEditingController _ingredientsController = TextEditingController();
  TextEditingController _servingsController = TextEditingController();
  String _recipeResponse = '';

  Future<void> _fetchRecipe() async {
    String ingredients = _ingredientsController.text;
    String servings = _servingsController.text;

    // Replace 'http://your-flask-server-url' with the actual URL of your Flask server
    Uri apiUrl = Uri.parse('http://127.0.0.1:5000/generate-response');

    // Make sure to handle errors and exceptions here
    try {
      var response = await http.post(
        apiUrl,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'ingredients': ingredients,
          'servings': servings,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _recipeResponse = json.decode(response.body)['response'];
        });
      } else {
        // Handle error response
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network or other errors
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Call super build method
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "WHO'S HUNGRY?",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 40.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView( // Enable scrolling
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextField(
                controller: _ingredientsController,
                decoration: InputDecoration(
                  labelText: "What's in the fridge?",
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _servingsController,
                decoration: InputDecoration(
                  labelText: 'How many mouths to feed?',
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _fetchRecipe,
                child: Text('Let\'s Cook!'),
              ),
              SizedBox(height: 16.0),
              _recipeResponse.isNotEmpty
                  ? Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Container(
                        padding: EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.grey[200],
                        ),
                        child: Center(
                          child: Text(
                            'Recipe Response:\n$_recipeResponse',
                            style: TextStyle(fontSize: 16.0),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true; // Return true to prevent the widget from rebuilding on scroll
}
