class Statistics {
  int difficulty;
  int totalgames;
  int gameswon;
  String besttime;

  Statistics(this.difficulty, this.totalgames, this.gameswon, this.besttime);

  Statistics.fromJson(Map<String, dynamic> json)
      : difficulty = json['difficulty'],
        totalgames = json['totalgames'],
        gameswon = json['gameswon'],
        besttime = json['besttime'] //.toString().substring(1, 5);
  ;
  
  Map<String, dynamic> toJson() => {
        '"difficulty"': difficulty,
        '"totalgames"': totalgames,
        '"gameswon"': gameswon,
        '"besttime"': '"$besttime"',
      };

  String toString() {
    return 'difficulty: $difficulty, totalgames: $totalgames, gameswon: $gameswon, besttime: $besttime, ';
  }
}
