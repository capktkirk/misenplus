import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';

class StepIngredients extends StatelessWidget{
  final QueryDocumentSnapshot doc;
  final int step;
  final List tempList;
  StepIngredients(this.doc, this.step, this.tempList);
  Widget build(BuildContext context){
    return SingleChildScrollView(
    child: Column(
      children: <Widget>[
        Card(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 100, minWidth: 300, minHeight: 50),
            child: Center(
              child: Text(doc['rec_title'].toString() + ' Step ' + step.toString(),
              style: TextStyle(fontSize:24.0))
            ),)
          ),
        Divider(color: Colors.deepPurple),
        ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: tempList.length,
          itemBuilder: (BuildContext context, int index){
            return Padding(
              padding: EdgeInsets.symmetric(horizontal:15.0, vertical:5.0),
              child: RichText(
                text: TextSpan(
                  children: [
                    WidgetSpan(
                      child: Icon(Icons.arrow_right_rounded, size:12.0),
                    ),
                    WidgetSpan(
                      child: Text("${tempList[index]['quant']} ${tempList[index]['measure']}'s of ${tempList[index]['prep']} ${tempList[index]['item']}",
                      style: TextStyle(fontSize:18.0),
                      textAlign: TextAlign.center)),
                  ])
              ),
            );
          },
        ),
        Divider(color: Colors.deepPurple),
        Text("Once all above items are prepared.\n", textAlign: TextAlign.center),
        Divider(color: Colors.deepPurple),
        Center( child : Text("\n${doc['cook_time']['step${step}']['inst']}\n", textAlign: TextAlign.center, style: TextStyle(fontSize:20.0))),
      ]
    )
  );
  }
}

class StepTimerPicker extends StatelessWidget {
  final QueryDocumentSnapshot doc;
  final int step;
  final String flag;
  StepTimerPicker(this.doc, this.step, this.flag);
  @override
  Widget build(BuildContext context){
    if(flag == "Start Timer"){ //Flag 1 means a timer is present.
      return Container(
        color: Colors.purple[50],
        child : Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StepTimerPicker(doc, step, timerCheck(doc, step))),
                );
            },
            label: Text(timerCheck(doc, step)),
            icon: const Icon(Icons.timer),
          ),
          appBar: AppBar(
            title: Text(
              doc['rec_title'].toString() + "Timer Partition"
            ),
          ),
          body: Column(children: [
            StepIngredients(doc, step, stepList(doc, step)),
            TimerAnimation(doc, step)
          ]),
        )
      );
    }
    else{
    return Container(
      color: Colors.purple[50],
      child : Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => StepTimerPicker(doc, step+1, timerCheck(doc, step))),
              );
          },
          label: Text(timerCheck(doc, step)),
          icon: const Icon(Icons.timer),
        ),
        appBar: AppBar(
          title: Text(
            doc['rec_title'].toString()
          ),
        ),
        body: StepIngredients(doc, step, stepList(doc, step)),
      )
    );
    }
  }
}

class RecipeCard extends StatelessWidget {
  final QueryDocumentSnapshot recipeDoc;
  final firebase_storage.FirebaseStorage storage;
  final int IngLength;
  RecipeCard(this.recipeDoc, this.storage, this.IngLength);
  
  final int stepNum = 1;
  @override
  Widget build(BuildContext context) {
    return Container (
      color: Colors.purple[50],
      child : Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Steps(recipeDoc, stepNum)),
              );
          }, 
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

class Steps extends StatelessWidget {
  final QueryDocumentSnapshot recipeDoc;
  final int stepNum;
  Steps(this.recipeDoc, this.stepNum);
  @override
  Widget build(BuildContext context){
    return Container(
      color: Colors.purple[50],
      child : Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => StepTimerPicker(recipeDoc, stepNum+1, timerCheck(recipeDoc, stepNum))),
              );
          },
          label: Text(timerCheck(recipeDoc, stepNum)),
          icon: const Icon(Icons.timer),
        ),
        appBar: AppBar(
          title: Text(
            recipeDoc['rec_title'].toString()
          ),
        ),
        body: new StepIngredients(recipeDoc, stepNum, stepList(recipeDoc, stepNum)),
      )
    );
  }
}

class Step extends StatelessWidget {
  final QueryDocumentSnapshot recipeDoc;
  final int stepNum;
  Step (this.recipeDoc, this.stepNum);
  @override
  Widget build(BuildContext context){
    return Container(
      color: Colors.purple[50],
      child : Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Step(recipeDoc, stepNum+1)),
              );
          },
          label: Text(timerCheck(recipeDoc, stepNum)),
          icon: const Icon(Icons.timer),
        ),
        appBar: AppBar(
          title: Text(
            recipeDoc['rec_title'].toString()
          ),
        ),
        body: StepIngredients(recipeDoc, stepNum, stepList(recipeDoc, stepNum)),
      )
    );
  }
}

String timerCheck(QueryDocumentSnapshot doc, int step){
  String text = "step" + step.toString();
  String ret_str = "Next Step!";
  if(doc['cook_time'][text]['timer'] > 0){
    ret_str = "Start Timer";
  }
  return ret_str;
}

List stepList(QueryDocumentSnapshot doc, int step){
  List stepIng = [];
  for(int i = 0; i < doc['ingredients'].length; i++){
    if(doc['ingredients'][i]['step'] == step){
      stepIng.add(doc['ingredients'][i]);
    }
  }
  return stepIng;
}

class TimerAnimation extends StatelessWidget{
  final QueryDocumentSnapshot doc;
  final int step;
  TimerAnimation(this.doc, this.step);
  Widget build(BuildContext context){
    return HourGlass(doc['cook_time']['step'+step.toString()]['timer']);
  }
}

int getTime(QueryDocumentSnapshot doc, int step){
  return doc['cook_time']['step'+step.toString()]['timer'];
}

class HourGlass extends StatelessWidget{
  final int time;
  HourGlass(this.time);
  Widget build(BuildContext context){
    return Container(
      child: Column(
        children: [
          PlayAnimation<Color?>(
            duration: Duration(seconds: 15),
            tween: ColorTween(begin:Colors.deepPurple, end: Colors.white),
            builder: (context, child, value){
              return Container(
                color: value,
                width: 100,
                height: 100,
              );
            }
          ),
          PlayAnimation<Color?>(
            duration: Duration(seconds: 15),
            tween: ColorTween(begin:Colors.white, end: Colors.deepPurple),
            builder: (context, child, value){
              return Container(
                color: value,
                width: 100,
                height: 100,
              );
            }
          )
    ],));
  }
}