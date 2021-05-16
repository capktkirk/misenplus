import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';
import 'package:delayed_display/delayed_display.dart';


class RecipeCard extends StatelessWidget {
  final QueryDocumentSnapshot recipeDoc;
  final firebase_storage.FirebaseStorage storage;
  final int IngLength;

  RecipeCard(this.recipeDoc, this.storage, this.IngLength);
  
  @override
  Widget build(BuildContext context) {
    return Container (
      color: Colors.purple[50],
      child : Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: (){}, 
          label: const Text('Let\'s cook!'),
          icon: const Icon(Icons.timer),
        ),
        appBar: AppBar(
          title: Text(
            recipeDoc['rec_title'].toString()
            ),
          centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Card(
                  child: SizedBox(
                  width:200,
                  child: Center(
                      child: new ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset('assets/${recipeDoc['image'].toString()}'),
                    ),
                  ),
                )),
                Divider(color: Colors.deepPurple),
                Text('Before we begin...',
                  style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
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
                Text('You will need.',
                  style: TextStyle(
                    fontSize: 18,
                  )),
                Padding(padding: EdgeInsets.only(bottom:8.0)),
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(), //This makes the list-view scroll with the rest of the container.
                  shrinkWrap: true,
                  itemCount: IngLength,
                  itemBuilder: (BuildContext context, int index){
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal:15.0, vertical:5.0),
                      child: RichText(
                          text: TextSpan(children: [
                            WidgetSpan(
                              child: Icon(Icons.arrow_right_rounded, size:18),
                              ),
                            WidgetSpan(
                              child : Text("   ${recipeDoc['ingredients'][index]['quant']} ${recipeDoc['ingredients'][index]['measure']} ${recipeDoc['ingredients'][index]['item']}",
                              style: TextStyle(fontSize:18.0))),
                          ])
                        ),
                    );
                  },
                ),
              Padding(
                padding: EdgeInsets.all(35.0)
              ),
              ]
            ),
          )//)
        ),
      //)
    );
  }
}