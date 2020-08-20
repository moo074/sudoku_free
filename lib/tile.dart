import 'dart:collection';
import 'dart:ui';

class Tile {
  int index;
  int x;
  int y;
  int cluster;
  String value;
  String correctValue;
  Color color;
  Color textcolor;
  bool isEditable;
  HashSet<String> values;

  Tile(this.index, {this.x, this.y, this.cluster, this.value, this.correctValue, this.isEditable,
      this.color, this.textcolor, this.values});
 
  HashSet<String> get valuesCopy => new HashSet<String>.from(values);
}
