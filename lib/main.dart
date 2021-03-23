import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';
import 'package:delayed_display/delayed_display.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp()
    );
}



class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Misen+',
      theme: ThemeData(
        fontFamily: "Moto",
        brightness: Brightness.light,
        accentColor: Colors.purple[40],
        backgroundColor: Colors.grey[40],
        scaffoldBackgroundColor: Colors.grey[40],
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.deepPurple,
      ),
      home: MyHomePage(title: 'Choose your recipe'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  firebase_storage.FirebaseStorage storage =
  firebase_storage.FirebaseStorage.instance;
  List<String> litems = [];
  List<QueryDocumentSnapshot> DocHolder = [];
  final CollectionReference recipes = FirebaseFirestore.instance.collection('recipes');
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    final TextStyle headline2 = Theme.of(context).textTheme.headline6!;
    firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance;
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    if(litems.length == 0){
        firestore.collection('recipes').get().then( (QuerySnapshot querySnapshot) => {
          querySnapshot.docs.forEach( (doc) 
          {
            print('This has triggered a list print.');
            print(doc['rec_title']);
            DocHolder.add(doc);
            litems.add(doc['rec_title'].toString());
            print(doc['ingredients']);
            print("This is ${doc['ingredients'][0]}");
            // for(var i = 0; i < doc['ingredients'].length; i++){
            //   print("Ingredient $i == ${doc['ingredient'][i]}");
            // }
            // EVENING END : Trying to access data in the above line of code so that I can print out
            // The Individual Ingredients.
            //item, measure, prep, quant, step
          }) //For Each
        });//
    }
    //ListStorageItems();
    //GetRecipeNames('recipes', firestore);
    //final mainReference = storage.ref('recipes');
    //Future <dynamic> recipes = mainReference.listAll();
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Center ( 
          child : Text(widget.title), 
        ),
      ),
      body:
        new ListView.builder (
          itemCount : litems.length,
          itemBuilder: (BuildContext context, int index) {
            return DelayedDisplay(
              delay: Duration(seconds: 2),
              child: Card (
                color : Colors.purple[80],
                child : Column (
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    InkWell(
                      highlightColor: Colors.purple[100],
                      child : ListTile(
                        tileColor: Colors.purple[80],
                        leading : Icon(Icons.eco_outlined, size: 50),
                        title: Text(litems[index]),
                      ),
                      onTap: () {
                        print("Click event on Container. ${litems[index]}");
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RecipeCard(DocHolder[index], storage)),
                        );
                      }
                    )]))
            );
          }),
      );
  } //Build Widget
} //Homepage

class RecipeCard extends StatelessWidget {
  final QueryDocumentSnapshot RecipeDoc;
  final firebase_storage.FirebaseStorage storage;

  RecipeCard(this.RecipeDoc, this.storage);

  //Map<String, dynamic> ingList = RecipeDoc['ingredients'].map();
  List<String> test_list = ["thing1", "thing2", "thing3", "thing4", "thing5"];
  
  @override
  Widget build(BuildContext context) {
    return Container (
      color: Colors.purple[50],
      child : Scaffold(
        appBar: AppBar(
          title: Text(
            RecipeDoc['rec_title'].toString()
            ),
          ),
          body: Column(
              children: <Widget>[
                Container(
                  child: Center(
                      child: new Image.asset(
                      'assets/${RecipeDoc['image'].toString()}',
                    ),
                  ),
                ),
                Text('Ingredients : ',
                  style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 40,
                  shadows: <Shadow>[ 
                    Shadow(
                      offset: Offset(2.0, 2.0),
                      blurRadius: 4.0,
                      color: Color.alphaBlend(Colors.grey, Colors.transparent)
                    )]
                  )
                ),
                Divider(
                  color: Colors.deepPurple,
                ),
                ListView.builder(
                  //scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: test_list.length,
                  itemBuilder: (BuildContext context, int index){
                    return Card(
                      color: Colors.blueGrey[50],
                      child: Text(RecipeDoc['ingredients'][index]['item']),
                      //child: Text(test_list[index]),
                    );
                  },
                )
              ]
            )
          ),
      //)
    );
  }
}


// class RecipeList extends StatelessWidget {

//   final 

//   RecipeList()
//   @override
// }