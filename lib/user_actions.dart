import 'tile.dart';

class UserAction {
  Tile tile;
  Function function;
  Object newValue;
  Object prevValue;

  UserAction(this.tile, {this.function, this.newValue, this.prevValue});
}

class UserActions {
  List<UserAction> _actions;

  UserActions() {
    _actions = new List<UserAction>();
  }

  int get count => _actions.length;
  removeLast() => _actions.removeLast();
  add(UserAction action) => _actions.add(action);
  UserAction get lastAction => _actions.last;
}
