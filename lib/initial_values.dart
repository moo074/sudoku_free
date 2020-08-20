import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sudoku_free/tile.dart';

enum Difficulty { easy, medium, hard, master }

class InitialValues {
  static List<Tile> getTiles(Difficulty difficulty) {
    int col = 9;
    int row = 9;

    //create 2 dime array
    List<List<int>> twoDList =
        List.generate(row, (i) => List(col), growable: false);

    //fill up array
    _fillUpList(twoDList, 0, 0);
    _fillUpList(twoDList, 3, 3);
    _fillUpList(twoDList, 6, 6);

    //solveSudoku
    _solveSudoku(twoDList);

    //get index to be left blank
    HashSet<int> blankTiles = _getBlankIndexNos(difficulty);

    //convert to tiles list
    return _convertToTiles(twoDList, blankTiles);
  }

  static void _fillUpList(var twoDList, int x, int y) {
    HashSet nums = new HashSet();

    for (int i = y; i <= y + 2; i++) {
      for (int j = x; j <= x + 2; j++) {
        twoDList[j][i] = _getNextNum(nums, 10, 8);
      }
    }
  }

  static List<Tile> _convertToTiles(var twoDList, HashSet<int> blankTiles) {
    List<Tile> tiles = new List<Tile>();
    int idx = 0;
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (blankTiles.contains(idx)) {
          tiles.add(new Tile(idx,
              x: j,
              y: i,
              cluster: getClusterNo(j, i),
              value: '',
              correctValue: twoDList[j][i].toString(),
              isEditable: true,
              color: Colors.white,
              textcolor: Colors.green[900],
              values: new HashSet<String>()));
        } else {
          tiles.add(new Tile(idx,
              x: j,
              y: i,
              cluster: getClusterNo(j, i),
              value: twoDList[j][i].toString(),
              correctValue: twoDList[j][i].toString(),
              isEditable: false,
              color: Colors.white,
              textcolor: Colors.grey[900],
              values: new HashSet<String>()));
        }
        idx++;
      }
    }
    return tiles;
  }

  static int getClusterNo(int x, int y) {
    int cluster = 0;
    if (x <= 2) {
      if (y <= 2)
        cluster = 1;
      else if (y <= 5)
        cluster = 2;
      else
        cluster = 3;
    } else if (x <= 5) {
      if (y <= 2)
        cluster = 4;
      else if (y <= 5)
        cluster = 5;
      else
        cluster = 6;
    } else {
      if (y <= 2)
        cluster = 7;
      else if (y <= 5)
        cluster = 8;
      else
        cluster = 9;
    }
    return cluster;
  }

  static int _getNextNum(HashSet nums, int max, int count) {
    //must end if max number is met already
    if (nums.length > count) return 0;

    var rand = new Random();
    int n = rand.nextInt(max);

    //must redraw if 0 and if only 1 - 9 is being produced
    if (n == 0 && count == 8) {
      n = _getNextNum(nums, max, count);
    } else {
      if (nums.add(n)) {
        return n;
      } else {
        n = _getNextNum(nums, max, count);
      }
    }
    return n;
  }

  static void _solveSudoku(var board) {
    _helper(board);
  }

  static bool _helper(var board) {
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (board[i][j] != null) {
          continue;
        }

        for (int k = 1; k <= 9; k++) {
          if (_isValid(board, i, j, k)) {
            board[i][j] = k;
            if (_helper(board)) {
              return true;
            }
            board[i][j] = null;
          }
        }
        return false;
      }
    }

    return true; //return true if all cells are checked
  }

  // Returns false if given 3 x 3 block contains num.
  static bool _unUsedInBox(var board, int rowStart, int colStart, int no) {
    for (int i = rowStart; i <= rowStart + 2; i++)
      for (int j = colStart; j <= colStart + 2; j++)
        if (board[i][j] == no) return false;

    return true;
  }

  static int getStartIndex(int idx) {
    int i = idx;
    if (idx > 5)
      i = 6;
    else if (idx > 2)
      i = 3;
    else
      i = 0;

    return i;
  }

  static bool _isValid(var board, int row, int col, int c) {
    for (int i = 0; i < 9; i++) {
      if (board[i][col] != null && board[i][col] == c) {
        return false;
      }

      if (board[row][i] != null && board[row][i] == c) {
        return false;
      }
    }

    int r = getStartIndex(row);
    int co = getStartIndex(col);
    return _unUsedInBox(board, r, co, c);
  }

  static HashSet _getBlankIndexNos(Difficulty diff) {
    HashSet<int> nums = new HashSet<int>();

    for (var i = 0; i < 50; i++) {
      _getNextNum(nums, 80,
          diff == Difficulty.easy ? 35 : diff == Difficulty.medium ? 45 : diff == Difficulty.hard ? 60 : 70);
    }

    return nums;
  }

  static String twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }

  static String timerText(Duration currentDuration) {
    return "${twoDigits(currentDuration.inMinutes.remainder(60))}:${twoDigits(currentDuration.inSeconds.remainder(60))}";
  }

}
