import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Shape Shooter'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin{

  late AnimationController _controller, _controllerCircle,_controllerRotation;
  late Animation _animation, _animationCircle,_animationRotation;
  late Path _path = Path();
  bool ballThrow = false;
  int score = 0;
  int ballPenalty = 0;
  double widthRatio = 0.98;
  double halfWidthRatio = 0.49;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this,duration: Duration(milliseconds: 200));
    _controllerCircle = AnimationController(vsync: this,duration: Duration(milliseconds: 7500));
    _controllerRotation = AnimationController(vsync: this,duration: Duration(milliseconds: 1500));
    _animationCircle = Tween(begin: 1.0,end: 0.3).animate(_controllerCircle)
      ..addListener((){
        setState(() {

        });
        _controllerRotation.duration = Duration(milliseconds: (2000 * _animationCircle.value).toInt());
      });


    _animation = Tween(begin: 0.0,end: 1.0).animate(_controller)
      ..addListener((){
        setState(() {
        });
      });

    _animationRotation = Tween(begin: -3.14,end: 3.14).animate(_controllerRotation)
      ..addListener((){
        setState(() {

        });
      });


    _controllerCircle.forward();
    _controllerRotation.forward();
    _controller.addStatusListener((status) {
      if(status == AnimationStatus.completed){
        setState(() {
          ballThrow = false;
        });
      }
    });
    _controllerCircle.addStatusListener((status) {
      if(status == AnimationStatus.completed){
        _controllerCircle.reset();
        _controllerCircle.forward();
        setState(() {
          score = 0;
          ballPenalty = 0;
        });
      }
    });
    _controllerRotation.addStatusListener((status) {
      if(status == AnimationStatus.completed){
        _controllerRotation.reset();
        _controllerRotation.forward();
      }
    });


  }

  void drawPath(originX,originY,double destX,double destY){
    Path path = Path();
    path.moveTo(originX,originY);
    path.lineTo(destX,destY);
    setState(() {
      _path = path;
    });
  }

  Offset? calculate(value) {
    if(ballThrow) {
      PathMetrics pathMetrics = _path.computeMetrics();
      PathMetric pathMetric = pathMetrics.elementAt(0);
      value = pathMetric.length * value;
      Tangent? pos = pathMetric.getTangentForOffset(value);
      num ballTop = MediaQuery.of(context).size.width * halfWidthRatio + (_animationCircle.value*MediaQuery.of(context).size.width *halfWidthRatio)* sin(_animationRotation.value);
      num ballLeft = MediaQuery.of(context).size.width * halfWidthRatio  + (_animationCircle.value*MediaQuery.of(context).size.width *halfWidthRatio)* cos(_animationRotation.value);
      if((pos?.position.dy)! >= ballTop - 15 && (pos?.position.dy)! <= ballTop + 15 && (pos?.position.dx)! >= ballLeft - 15 && (pos?.position.dx)! <= ballLeft + 15){
          _controllerCircle.reset();
          _controllerCircle.forward();
          setState(() {
            ballThrow = false;
            score+=1;
            ballPenalty+=5;
          });
          _controllerCircle.duration = Duration(milliseconds: max(7500 - ballPenalty*10,2500));
          _controller.duration = Duration(milliseconds: min(200 + ballPenalty,500));

      }


      return pos?.position;
    }
    else{
      return Offset(MediaQuery.of(context).size.width *widthRatio,MediaQuery.of(context).size.height *widthRatio);
    }
  }

  List<double> calculateLineMax(centerX,centerY,posX,posY){
    List<double> coordinates = [];
    double angle = atan2(posY-centerY, posX-centerX);
    double newY = MediaQuery.of(context).size.width *halfWidthRatio + (MediaQuery.of(context).size.width *halfWidthRatio)* sin(angle);
    double newX = MediaQuery.of(context).size.width *halfWidthRatio + (MediaQuery.of(context).size.width *halfWidthRatio)* cos(angle);
    coordinates.add(newX);
    coordinates.add(newY);
    return coordinates;
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      backgroundColor: Color(0xff073b4c),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTapDown: (details) {
                if(!ballThrow) {
                  final tapPosition = details.localPosition;
                  num x = tapPosition.dx;
                  num y = tapPosition.dy;
                  // print("$x,$y");
                  num centerX = MediaQuery
                      .of(context)
                      .size
                      .width * halfWidthRatio;
                  num centerY = MediaQuery
                      .of(context)
                      .size
                      .width * halfWidthRatio;
                  // print(
                  //     (180 - atan2(centerY - y, centerX - x) * 180 / pi) % 360);
                  List<double> coords = calculateLineMax(centerX, centerY, x, y);
                  setState(() {
                    ballThrow = true;
                  });
                  drawPath(centerX, centerY, coords[0], coords[1]);
                  _controller.reset();
                  _controller.forward();
                }
              },
              child: SizedBox(
                width: MediaQuery.of(context).size.width * widthRatio,
                height: MediaQuery.of(context).size.width * widthRatio,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: Stack(
                    children: [
                      // Positioned(
                      //   top: 0,
                      //   child: CustomPaint(
                      //     painter: PathPainter(_path),
                      //   ),
                      // ),
                      Center(
                        child: Text(
                          score.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                      ),
                     Center(
                       child: Container(
                        decoration: BoxDecoration(
                            shape:BoxShape.circle, //making box to circle
                            color:Colors.transparent ,
                          border: Border.all(
                            color: Color(0xffffd166),width: 1.5,
                          ),

                        ),
                        height: _animationCircle.value*MediaQuery.of(context).size.width *widthRatio, //value from animation controller
                        width:  _animationCircle.value*MediaQuery.of(context).size.width *widthRatio, //value from animation controller
                    ),
                     ),

                      Positioned(
                        top: calculate(_animation.value)?.dy,
                        left: calculate(_animation.value)?.dx,
                        child: Container(
                          decoration: BoxDecoration(
                              color: Color(0xff06d6a0),
                              borderRadius: BorderRadius.circular(10)
                          ),
                          width: 15,
                          height: 15,
                        ),
                      ),
                      Positioned(
                        top: MediaQuery.of(context).size.width *halfWidthRatio + (_animationCircle.value*MediaQuery.of(context).size.width *halfWidthRatio)* sin(_animationRotation.value) - 15,
                        left: MediaQuery.of(context).size.width * halfWidthRatio + (_animationCircle.value*MediaQuery.of(context).size.width *halfWidthRatio) * cos(_animationRotation.value) - 15,
                        child: Container(
                          decoration: BoxDecoration(
                              color: Color(0xffef476f),
                              shape:BoxShape.circle,
                          ),
                          width: 30,
                          height: 30,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            )
          ],
        ),
      ),
    );
  }
}

class PathPainter extends CustomPainter {

  Path path;

  PathPainter(this.path);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.lightBlue.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
