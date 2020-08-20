import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sudoku_free/ad_manager.dart';
import 'package:sudoku_free/initial_values.dart';
import 'package:sudoku_free/tile.dart';
import 'package:sudoku_free/tile_control.dart';
import 'package:sudoku_free/tiles.dart';
import 'package:sudoku_free/user_actions.dart';
import 'package:sudoku_free/statistics.dart';
import 'package:sudoku_free/stat_storage.dart';

class TileManager extends StatefulWidget {
  final _title;
  final Difficulty _difficulty;

  TileManager(this._difficulty, this._title);

  @override
  State<StatefulWidget> createState() {
    return _TileManagerState();
  }
}

class _TileManagerState extends State<TileManager> with WidgetsBindingObserver {
  final int _mi = 40;
  List<Tile> _tiles = [];
  Tile _activeTile;
  Difficulty _difficulty;
  List<int> _numCount = [0, 0, 0, 0, 0, 0, 0, 0, 0];
  bool _pencilStatus = false;
  int _mistakeCount = 0;

  final _oneSec = const Duration(seconds: 1);
  Timer _timer;
  Stopwatch _watch;
  Duration _currentDuration = Duration.zero;

  UserActions _actions = new UserActions();
  bool _isNewChange = true;

  Statistics _statistics;
  StatsStorage _statsStorage;

  @override
  void initState() {
    _difficulty = widget._difficulty;
    _tiles = InitialValues.getTiles(_difficulty);
    _tiles[_mi].color = Colors.lightGreen;
    _activeTile = _tiles[_mi];
    _setCurrentNumCount();
    _highlightTiles(_activeTile, true);
    _watch = new Stopwatch();
    _startTimer();

    print('TM INIT');
    AdManager.hideBannerAd();

    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: Key('TileManager_Scaffold'),
      appBar: AppBar(
        title: Text(widget._title,
            style: TextStyle(
                color: Colors.green[900], fontWeight: FontWeight.bold)),
        backgroundColor: Colors.lightGreen,
      ),
      body: Column(children: [
        Tiles(_tiles, _tappedTile, _pencilStatus),
        TileControl(
            _updateTile, _numCount, _pencilUpdate, _pencilStatus, _undo),
      ]),
      bottomNavigationBar:
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Text(_difficultyText(), style: _ts()),
        Text(InitialValues.timerText(_currentDuration), style: _ts()),
        _newGameButton(),
      ]),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _watch.reset();
    WidgetsBinding.instance.removeObserver(this);
    print('tile manager dispose');
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _watch.start();
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _watch.stop();
    }
  }

//events

  void _startTimer() {
    _watch.start();
    _timer = new Timer.periodic(
      _oneSec,
      (Timer timer) => setState(
        () {
          _currentDuration = _watch.elapsed;
          if (_currentDuration.inMinutes >= 59) {
            _watch.stop();
          }
        },
      ),
    );
  }

  void _tappedTile(Tile tile) {
    // print(tile.value);
    // print(tile.correctValue);
    // print(tile.isEditable);
    setState(() {
      _highlightTiles(_activeTile, false);
      if (_activeTile.color != Colors.red[200])
        _activeTile.color = Colors.white;
      _activeTile = _tiles[tile.index];
      _highlightTiles(_activeTile, true);
    });
  }

  void _updateTile(String numValue) {
    setState(() {
      if (_tiles[_activeTile.index].isEditable) {
        if (numValue == '') {
          _eraseTileValue();
        } else if (_pencilStatus) {
          _pencilTileUpdate(numValue);
        } else {
          //update mistake count
          if (_tiles[_activeTile.index].correctValue != numValue)
            _mistakeCount = _mistakeCount + 1;
          _changeTileValue(numValue, _activeTile.value);
        }

        //all invalid
        _highlightInvalid();
      }
      //reset activetile values
      _activeTile = _tiles[_activeTile.index];
      _highlightTiles(_activeTile, true);

      //_displayWinDialog(context);
      if (_isBoardSolved()) {
        _timer.cancel();
        _updateStats(true);
        _displayWinDialog(context);
      }
    });
  }

  void _pencilUpdate() {
    setState(() {
      _pencilStatus = !_pencilStatus;
    });
  }

  void _undo() {
    setState(() {
      _isNewChange = false;
      if (_actions.count > 0) {
        UserAction action = _actions.lastAction;
        _tappedTile(action.tile);
        action.function(action.prevValue, action.newValue);
        _actions.removeLast();
      }
      //all invalid
      _highlightInvalid();
      _highlightTiles(_activeTile, true);
      _isNewChange = true;
    });
  }

  void _updateStats(bool isWin) {
    String fileName = _difficulty == Difficulty.easy
        ? 'stats_easy'
        : _difficulty == Difficulty.medium
            ? 'stats_intermediate'
            : _difficulty == Difficulty.hard ? 'stats_expert' : 'stats_master';
    print(fileName);
    _statsStorage = new StatsStorage(fileName);

    _statsStorage.readFile().then((Statistics value) => setState(() {
          print('readFile then');
          _statistics = value;

          _statistics.totalgames = _statistics.totalgames + 1;
          if (isWin) {
            _statistics.gameswon = _statistics.gameswon + 1;

            print(_statistics.besttime);
            String currentTime = InitialValues.timerText(_currentDuration);            
            if (_statistics.besttime == '--:--') {
              _statistics.besttime = currentTime;
            } else {
              DateTime oldTime = getDateValue(_statistics.besttime);
              DateTime newTime = getDateValue(currentTime);

              if (newTime.compareTo(oldTime) == -1) {
                _statistics.besttime = currentTime;
              }
            }
          }
          //write on file
          _statsStorage.writeUpdate(_statistics);
          print('_updateStats - writeUpdate');
          //do above first before page transition?
          Navigator.pop(context, false); //pop up
          Navigator.pop(context, true); //back to set difficulty
        }));
  }
//controls

  DateTime getDateValue(String time) {
    DateTime baseTime = DateTime.now();
    String baseDate =
        baseTime.toString().substring(0, baseTime.toString().indexOf(':'));

    return DateTime.parse(baseDate + time);
  }

  String _difficultyText() {
    return _difficulty == Difficulty.easy
        ? "Beginner"
        : _difficulty == Difficulty.medium ? "Intermediate" : "Expert";
  }

  TextStyle _ts() => TextStyle(color: Colors.green[800], fontSize: 20);

  _newGameButton() {
    return MaterialButton(
        minWidth: 150,
        color: Colors.lightGreen,
        disabledColor: Colors.lightGreen[200],
        onPressed: () {
          //Navigator.pop(context);
          if (_isBoardSolved())
            Navigator.pop(context);
          else
            _displayConfirmDialog(context);
        },
        child: Text(
          'New Game',
          style: TextStyle(fontSize: 20),
        ));
  }

//processes

  _eraseTileValue() {
    String prevValue = _activeTile.value;
    _addAction(_tiles[_activeTile.index], prevValue, _activeTile.valuesCopy,
        _eraseTileUndo);

    _tiles[_activeTile.index].value = '';
    _updateNumCount(prevValue, false);
    _tiles[_activeTile.index].values.clear();
  }

  _eraseTileUndo(var values, var numValue) {
    _tiles[_activeTile.index].value = numValue;
    _updateNumCount(_activeTile.value, true);
    _tiles[_activeTile.index].values = values;
  }

  _pencilTileUpdate(String numValue) {
    if (numValue != '') {
      var prevValue = _tiles[_activeTile.index].valuesCopy;
      Tile checkTile = new Tile(_activeTile.index,
          x: _activeTile.x,
          y: _activeTile.y,
          cluster: _activeTile.cluster,
          value: numValue);
      if (_isInvalid(checkTile) == false) {
        if (!_tiles[_activeTile.index].values.add(numValue)) {
          _tiles[_activeTile.index].values.remove(numValue);
        }

        if (_isNewChange) {
          var newValue = _tiles[_activeTile.index].valuesCopy;
          _addAction(_tiles[_activeTile.index], newValue, prevValue,
              _pencilUpdateUndo);
        }
      }
    }
  }

  _pencilUpdateUndo(var newValue, var prevValue) {
    _tiles[_activeTile.index].values = newValue;
  }

  _changeTileValue(String numValue, String prevValue) {
    _updateNumCount(prevValue, false);
    _tiles[_activeTile.index].value = numValue;
    _updateNumCount(numValue, true);

    _addAction(
        _tiles[_activeTile.index], numValue, prevValue, _changeTileValue);

    if (numValue == _tiles[_activeTile.index].correctValue) {
      _removePencilValue(_tiles[_activeTile.index], numValue);
    }
  }

  _removePencilValue(Tile tile, String numValue) {
    for (var item in _tiles) {
      if (item.x == tile.x ||
          item.y == tile.y ||
          item.cluster == tile.cluster) {
        item.values.remove(numValue);
      }
    }
  }

  _addAction(Tile tile, Object newValue, Object prevValue, var function) {
    if (_isNewChange) {
      _actions.add(new UserAction(tile,
          newValue: newValue, prevValue: prevValue, function: function));
    }
  }

  _updateNumCount(String value, bool isAdd) {
    int countIndex = int.tryParse(value);
    if (countIndex != null) {
      countIndex = countIndex - 1;
      _numCount[countIndex] = _numCount[countIndex] + (isAdd ? 1 : -1);
    }
  }

  _setCurrentNumCount() {
    for (var item in _tiles) {
      _updateNumCount(item.value, true);
    }
  }

  bool _isBoardSolved() {
    for (var item in _numCount) {
      if (item != 9) {
        return false;
      }
    }
    return true;
  }

  bool _isInvalid(Tile tile) {
    if (tile.value != '' && tile.value != tile.correctValue && !_pencilStatus) {
      return true;
    } else {
      for (var item in _tiles) {
        if ((item.x == tile.x && item.y != tile.y) ||
            (item.y == tile.y && item.x != tile.x) ||
            (item.y != tile.y &&
                item.x != tile.x &&
                item.cluster == tile.cluster)) {
          if (tile.value == item.value && tile.index != item.index) {
            return true;
          }
        }
      }
      return false;
    }
  }

  _highlightTiles(Tile tile, bool isActive) {
    setState(() {
      for (var item in _tiles) {
        if ((item.x == tile.x) ||
            (item.y == tile.y) ||
            (item.cluster == tile.cluster) ||
            (item.value != '' && item.value == tile.value)) {
          if (item.color != Colors.red[200])
            _tiles[item.index].color = (item.index == tile.index)
                ? Colors.lightGreen[400]
                : isActive ? Colors.lightGreen[200] : Colors.white;
        }
      }
    });
  }

  _highlightInvalid() {
    List<Tile> inValidTiles = new List<Tile>();
    for (Tile item in _tiles) {
      if (item.value != '') if (_isInvalid(item)) inValidTiles.add(item);
    }
    //make all tiles green or black
    for (Tile item in _tiles) {
      if (item.value != '')
        item.textcolor = item.isEditable ? Colors.green : Colors.black;
      _tiles[item.index].color = Colors.white;
    }

    //make all invalid red background
    for (Tile item in inValidTiles) {
      _tiles[item.index].textcolor =
          item.isEditable ? Colors.red[900] : Colors.black;
      _tiles[item.index].color = Colors.red[200];
    }
  }

//Dialogs

  _displayWinDialog(BuildContext context) {
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Center(child: Text("You Won!")),
      content: Container(
          height: 200,
          width: 200,
          child: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text("Great Job!"),
            SizedBox(height: 10),
            Text(_difficultyText()),
            SizedBox(height: 10),
            Text('No. of Mistakes: $_mistakeCount'),
            SizedBox(height: 10),
            Text('Time: ' + InitialValues.timerText(_currentDuration)),
            SizedBox(height: 10),
            MaterialButton(
                minWidth: 200,
                color: Colors.lightGreen,
                disabledColor: Colors.lightGreen[200],
                onPressed: () {
                  Navigator.pop(context, false); //pop up
                  Navigator.pop(context, false); //TileManager
                },
                child: Text('New Game')),
          ]))),
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  _displayConfirmDialog(BuildContext context) {
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      content: Container(
          height: 100,
          width: 100,
          child: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text("Abandon current game?"),
          ]))),
      actions: <Widget>[
        MaterialButton(
            minWidth: 50,
            color: Colors.lightGreen,
            disabledColor: Colors.lightGreen[200],
            onPressed: () {
              print('game abandoned');
              _watch.stop();
              _updateStats(false);
            },
            child: Text('Yes')),
        MaterialButton(
            minWidth: 50,
            color: Colors.lightGreen,
            disabledColor: Colors.lightGreen[200],
            onPressed: () {
              _watch.start();
              Navigator.pop(context, false); //pop up
            },
            child: Text('No')),
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
