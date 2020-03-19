import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

GlobalKey<_RoseState> globalKey = GlobalKey<_RoseState>();

class RosePattern extends StatefulWidget {
  @override
  _RosePatternState createState() => _RosePatternState();
}

class _RosePatternState extends State<RosePattern> {
  double _n = 0;
  double _d = 0;
  double k = 0;
  double offset = 0;
  bool animate = false;
  bool animating = false;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.initState();
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(
      width: 512.0,
      height: 1024.0,
      allowFontScaling: true,
    )..init(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Rose Pattern',
          style: Theme.of(context).textTheme.title,
        ),
        centerTitle: true,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Visibility(
          visible: animate,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              FloatingActionButton(
                  heroTag: null,
                  backgroundColor: Colors.white,
                  child: (!animating)
                      ? Icon(
                    Icons.play_arrow,
                    color: Colors.black,
                  )
                      : Icon(
                    Icons.pause,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      animating = !animating;
                    });
                  }),
              FloatingActionButton(
                heroTag: null,
                child: Icon(
                  Icons.highlight_off,
                  color: Colors.black,
                ),
                backgroundColor: Colors.white,
                onPressed: () {
                  setState(() {
                    globalKey.currentState.clearscreen();
                  });
                },
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: ScreenUtil.instance.height / 4,
        child: Material(
          elevation: 30,
          color: Theme.of(context).primaryColor,
          child: Column(
            children: <Widget>[
              Spacer(flex: 2),
              Slider(
                min: 0,
                max: 10,
                divisions: 1000,
                activeColor: Theme.of(context).accentColor,
                inactiveColor: Colors.grey,
                onChanged: (value) {
                  setState(() {
                    _n = double.parse(value.toStringAsFixed(2));
                  });
                },
                value: _n,
              ),
              Center(
                child: Text(
                  "Numerator: $_n",
                  style: Theme.of(context).textTheme.subtitle,
                ),
              ),
              Spacer(
                flex: 1,
              ),
              Slider(
                min: 0,
                max: 10,
                divisions: 1000,
                activeColor: Theme.of(context).accentColor,
                inactiveColor: Colors.grey,
                onChanged: (value) {
                  setState(() {
                    _d = double.parse(value.toStringAsFixed(2));
                  });
                },
                value: _d,
              ),
              Center(
                child: Text(
                  "Denominator: $_d",
                  style: Theme.of(context).textTheme.subtitle,
                ),
              ),
              Spacer(),
              Slider(
                min: 0,
                max: 1,
                divisions: 100,
                activeColor: Theme.of(context).accentColor,
                inactiveColor: Colors.grey,
                onChanged: (value) {
                  setState(() {
                    offset = double.parse(value.toStringAsFixed(2));
                  });
                },
                value: offset,
              ),
              Center(
                child: Text(
                  "Offset: $offset",
                  style: Theme.of(context).textTheme.subtitle,
                ),
              ),
              Spacer(),
            ],
          ),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: <Widget>[
            Rose(
              n: _n,
              d: _d,
              offset: offset,
              animate: animate,
              animating: animating,
            ),
            Container(),
            Positioned(
              top: 5,
              left: 5,
              child: Text(
                'k ~ ${(_n / _d).toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.subtitle,
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text('Animate: '),
                  Checkbox(
                    onChanged: (_) {
                      setState(() {
                        animate = !animate;
                        if (animating) {
                          animating = (animating && animate);
                        }
                      });
                    },
                    value: animate,
                    activeColor: Colors.red,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class Rose extends StatefulWidget{
  Rose({
    Key key,
    @required double n,
    @required double d,
    @required double offset,
    @required this.animate,
    @required this.animating,
  })  : _n = n,
        _d = d,
        _offset = offset,
        super(key: key);

  final double _n;
  final double _d;
  final double _offset;
  final bool animate;
  final bool animating;

  @override
  _RoseState createState() => _RoseState();
}

class _RoseState extends State<Rose>{
  List<Offset> points = [];
  double loopi = 0;
  double r,d, n, c, transformx, transformy;
  double looplength = 0;

  void dispose() {
    super.dispose();
  }

  void clearscreen() {
    points.clear();
    looplength = 2 * d * pi;
    looplength += loopi;
  }

  nextStep() {
    if (loopi > looplength) {
      clearscreen();
      loopi = 0;
      looplength = 2 * d *pi;
    }
    setState(() {
      sleep(Duration(milliseconds: 10));
      loopi += 0.01;
      r = (MediaQuery.of(context).size.width / 2.5).roundToDouble();
      points.add(
          Offset(r * (cos((widget._n/widget._d) * loopi) + widget._offset) * cos(loopi),
          r * (cos((widget._n/widget._d) * loopi)+widget._offset) * sin(loopi))
          .translate((MediaQuery.of(context).size.width / 2).roundToDouble(),
          (MediaQuery.of(context).size.height / 3).roundToDouble()));
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.animating) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        nextStep();
      });
  }
    return CustomPaint(
      painter: RosePainter(
        widget._d,
        widget._n,
        (MediaQuery.of(context).size.width / 2).roundToDouble(),
        (MediaQuery.of(context).size.height / 3).roundToDouble(),
        (MediaQuery.of(context).size.width / 2.5).roundToDouble(),
        widget._offset,
          widget.animate,
        points
      ),
      child: Container(),
    );
  }


}

class RosePainter extends CustomPainter {
  double d, r, n, c;
  double k, transformx, transformy;
  List<Offset> points = [];
  bool animate;
  RosePainter(
      this.d, this.n, this.transformx, this.transformy, this.r, this.c, this.animate, points) {
    k = n / d;
    this.points = new List<Offset>.from(points);
  }

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = Colors.red;
    paint.strokeWidth = 2;
    if(!animate) {
      this.points.clear();
      for (double i = 0; i < 2 * d * pi; i += 0.01) {
        points.add(
            Offset(r * (cos(k * i) + c) * cos(i), r * (cos(k * i) + c) * sin(i))
                .translate(transformx, transformy));
      }
    }
    canvas.drawPoints(PointMode.polygon, points, paint);
  }

  @override
  bool shouldRepaint(RosePainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(RosePainter oldDelegate) => false;
}
