import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:delayed_display/delayed_display.dart';
import 'widgets.dart';

class TimerStepIngredients extends StatelessWidget{
  final QueryDocumentSnapshot doc;
  final int step;
  final List tempList;
  TimerStepIngredients(this.doc, this.step, this.tempList);
  Widget build(BuildContext context){
    return SingleChildScrollView(
    child: Column(
      children: <Widget>[
        Divider(color: Colors.deepPurple),
        Text("\n${doc['cook_time']['step${step-1}']['inst']}\n", textAlign: TextAlign.center, style: TextStyle(fontSize:20.0)),
        Card(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 50, minWidth: 300, minHeight: 50),
            child: Center(
              child: Text('Preview : ' + doc['rec_title'].toString() + ' Step ' + step.toString(),
              style: TextStyle(fontSize:24.0))
            ),)
          ),
        Divider(color: Colors.deepPurple),
        Text("While the timer goes, make sure you have these items prepared and ready.",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize:18.0)),
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
                      child: Icon(Icons.arrow_right_rounded, size:20.0),
                    ),
                    WidgetSpan(
                      child: Text("${tempList[index]['quant']} ${tempList[index]['measure']}s of ${tempList[index]['prep']} ${tempList[index]['item']}",
                      style: TextStyle(fontSize:18.0),
                      textAlign: TextAlign.center)),
                  ])
              ),
            );
          },
        ),
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
    if(flag == "Start Timer"){
      return Container(
        color: Colors.purple[50],
        child : Scaffold(
          floatingActionButton: DelayedDisplay(
            delay: Duration(minutes: 1),
            child:FloatingActionButton.extended(
            onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StepTimerPicker(doc, step, timerCheck(doc, step))),
                );
            },
            label: Text(timerCheck(doc, step)),
            icon: const Icon(Icons.timer),
          ),
          ),
          appBar: AppBar(
            title: Text(
              doc['rec_title'].toString() + "Timer = " + doc['cook_time']['step'+ (step-1).toString()]['timer'].toString()
            ),
          ),
          body: Column(children: [
            TimerAnimation(doc, step-1),
            TimerStepIngredients(doc, step, stepList(doc, step)),
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


class OverlayView extends StatelessWidget{
  final QueryDocumentSnapshot doc;
  final int step;
  const OverlayView(this.doc, this.step, {Key? key,}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Row(
            children: [
              Expanded(
                child: Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Spacer(),
                          IconButton(
                            icon: Icon(Icons.close_outlined),
                            onPressed: () {
                               Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => StepTimerPicker(doc, step+1, timerCheck(doc, step))),
                              );
                            }
                          ),
                        ],
                      ),
                      Icon(
                        Icons.error_rounded,
                        color: Colors.red,
                        size: 50,
                      ),
                      SizedBox(
                        height: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class TimerAnimation extends StatelessWidget{
  final QueryDocumentSnapshot doc;
  final int step;
  TimerAnimation(this.doc, this.step);
  Widget build(BuildContext context){
    return HourGlass(doc['cook_time']['step'+step.toString()]['timer']*60);
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
          PlayAnimation<int>(
            duration: Duration(seconds: time),
            tween: IntTween(begin: time, end:0),
            builder: (context, child, value){
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                Text((value~/60).toString().padLeft(2, "0"), style: TextStyle(fontSize: 50.0)),
                Text(':', style: TextStyle(fontSize: 50.0)),
                Text((value%60).toString().padLeft(2, "0"), style: TextStyle(fontSize: 50.0))
              ],);
            }
          ),
          Column(
            children: [
              PlayAnimation<Color?>(
                duration: Duration(seconds: time),
                tween: ColorTween(begin:Colors.deepPurple, end: Colors.white),
                builder: (context, child, value){
                  return Container(
                    child: CustomPaint(
                      size: Size(100, 100),
                      painter: DrawHourGlassTop(Paint(), value as Color)
                    ),
                    // padding: EdgeInsets.all(5.0),
                    // color: value,
                    // width: 100,
                    // height: 100,
                  );
                }
              ),
              PlayAnimation<Color?>(
                duration: Duration(seconds: time),
                tween: ColorTween(begin:Colors.white, end: Colors.deepPurple),
                builder: (context, child, value){
                  return Container(
                    child: CustomPaint(
                      size: Size(100, 100),
                      painter: DrawHourGlassBot(Paint(), value as Color)
                    )
                    // padding: EdgeInsets.all(5.0),
                    // color: value,
                    // width: 100,
                    // height: 100,
                  );
                }
              )
        ],)
        ],
      ));
  }
}

class DrawHourGlassTop extends CustomPainter{
  Color color;
  Paint _paint;
  DrawHourGlassTop(this._paint, this.color){
    _paint = Paint()
    ..color = color
    ..style = PaintingStyle.fill;
  }
  @override
  void paint(Canvas canvas, Size size){
    var path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo((size.width/2), size.height);
    canvas.drawPath(path, _paint);
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
class DrawHourGlassBot extends CustomPainter{
  Color color;
  Paint _paint;
  DrawHourGlassBot(this._paint, this.color){
    _paint = Paint()
    ..color = color
    ..style = PaintingStyle.fill;
  }
  @override
  void paint(Canvas canvas, Size size){
    var path = Path();
    path.moveTo(size.width/2, 0);
    path.lineTo(0, size.width);
    path.lineTo(size.width, size.height);
    canvas.drawPath(path, _paint);
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}


// CustomPaint(
// size: Size(200, 200),
// painter: DrawTriangle()
// ),
// ),
// ),
// ),
// );
// }
// }
// class DrawTriangle extends CustomPainter {
// Paint _paint;
// DrawTriangle() {
// _paint = Paint()
// ..color = Colors.green
// ..style = PaintingStyle.fill;
// }
// @override
// void paint(Canvas canvas, Size size) {
// var path = Path();
// path.moveTo(size.width/2, 0);
// path.lineTo(0, size.height);
// path.lineTo(size.height, size.width);
// path.close();
// canvas.drawPath(path, _paint);
// }
// @override
// bool shouldRepaint(CustomPainter oldDelegate) {
// return false;
// }
// }