import 'package:flutter/material.dart';

class TileControl extends StatelessWidget {
  final Function updateTile;
  final List<int> numCount;
  final Function pencilUpdate;
  final Function undo;
  final bool pencilStatus;

  TileControl(
      this.updateTile, this.numCount, this.pencilUpdate, this.pencilStatus, this.undo);

  bool _isDisabled(String value) {
    return numCount[(int.parse(value)) - 1] == 9;
  }

  String numCountValue(String value) {
    return numCount[(int.parse(value)) - 1].toString();
  }

  final TextStyle ts = new TextStyle(
    fontSize: 30.0,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  MaterialButton tileButton(String value) {
    return MaterialButton(
      key: Key('TileControl_' + value),
      minWidth: 50.0,
      padding: EdgeInsets.all(0.0),
      color: pencilStatus ? Colors.grey : Colors.lightGreen,
      onPressed: _isDisabled(value)
          ? null
          : () {
              updateTile(value);
            },
      child: Container(
        child: pencilStatus
            ? Text(value, style: ts)
            : Stack(
                children: <Widget>[
                  Text(value, style: ts),
                  Positioned(
                      top: -7.0,
                      right: -11.0,
                      child: Text(
                        numCountValue(value),
                        style: TextStyle(fontSize: 16),
                      ))
                ],
                overflow: Overflow.visible,
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //bottom buttons
    List<MaterialButton> numButtons1 = new List<MaterialButton>();
    for (var i = 1; i <= 9; i++) {
      numButtons1.add(tileButton(i.toString()));
    }

    //pencil
    numButtons1.add(MaterialButton(      
      key: Key('TileControl_Pencil'),
      minWidth: 50.0,
      color: pencilStatus ? Colors.grey : Colors.lightGreen,
      padding: EdgeInsets.all(0.0),
      child: new Image.asset(
        'images/pencil.png',
        width: 30,
      ),
      onPressed: () {
        pencilUpdate();
      },
    ));

    //eraser
    numButtons1.add(MaterialButton(   
      key: Key('TileControl_Eraser'),
      minWidth: 50.0,
      color: Colors.lightGreen,
      padding: EdgeInsets.all(0.0),
      child: //Icon(Icons.),
      new Image.asset(
        'images/eraser.png',
        width: 30,
      ),
      onPressed: () {
        updateTile('');
      },
    ));

    //undo
    numButtons1.add(MaterialButton(
      key: Key('TileControl_Undo'),
      minWidth: 50.0,
      color: Colors.lightGreen,
      padding: EdgeInsets.all(0.0),      
      child: Icon(Icons.undo, size: 40, ),
      //  new Image.asset(
      //   'images/undo.png',
      //   width: 30,
      //),
      onPressed: () {
        undo();
      },
    ));

    return Container(
        margin: EdgeInsets.all(3),
        //height: 130,
        child: GridView.count(
          key: Key('TileControl_Grid'),
          crossAxisCount: 6,
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
          shrinkWrap: true,
          children: numButtons1,
        ));
  }
}
