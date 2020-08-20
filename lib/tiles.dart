import 'package:flutter/material.dart';

import 'tile.dart';

class Tiles extends StatelessWidget {
  final List<Tile> tiles;
  final Function tapped;
  final bool pencilStatus;

  Tiles(this.tiles, this.tapped, this.pencilStatus);

  BoxDecoration myBoxDecoration(int x, int y) {
    return BoxDecoration(
      border: Border(
        left: BorderSide(color: Colors.green[900], width: (x == 0 ? 2.0 : 1.0)),
        top: BorderSide(color: Colors.green[900], width: (y == 0 ? 2.0 : 1.0)),
        right: BorderSide(
            color: Colors.green[900], width: ((x + 1) % 3 == 0 ? 2.0 : 0.0)),
        bottom: BorderSide(
            color: Colors.green[900], width: ((y + 1) % 3 == 0 ? 2.0 : 0.0)),
      ),
    );
  }

  TextStyle myStyle(Color textcolor) {
    return TextStyle(
      fontSize: 30.0,
      fontWeight: FontWeight.bold,
      color: textcolor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        //key: Key('Tiles_Container'),
        //decoration: myBoxDecoration(1, 2),
        margin: EdgeInsets.all(10.0),
        //height: 400.00,
        child: GridView.count(            
          key: Key('Tiles_Grid'),
            crossAxisCount: 9,
            shrinkWrap: true,
            children: tiles
                .map((element) => Container(
                    decoration: myBoxDecoration(element.x, element.y),
                    margin: EdgeInsets.all(0.0),
                    padding: EdgeInsets.all(0.0),
                    width: 15,
                    height: 16,
                    child: MaterialButton(
                      padding: EdgeInsets.all(0.0),
                      child: element.value == ''
                          ? _pencilValues(element)
                          : Text(element.value,
                              style: myStyle(element.value != element.correctValue ? Colors.red : element.textcolor)),
                      onPressed: () {
                        tapped(element);
                      },
                      color: element.color,
                    )))
                .toList()));
  }

  Container _pencilValues(Tile element) {
    return Container(
      padding: EdgeInsets.all(0.0),
      margin: EdgeInsets.all(0.0),      
      height: 50,
      child: GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          //childAspectRatio: 3 / 2,
          mainAxisSpacing: 0.5,
          padding: EdgeInsets.all(0.0),
          children: element.values
              .map((item) =>
                  Center(child: Text(item, style: TextStyle(fontSize: 14))))
              .toList()),
    );
  }
}
