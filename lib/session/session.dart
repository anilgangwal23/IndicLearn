import 'package:flutter/foundation.dart';

class SessionStats extends ChangeNotifier {
  int _lives = 5;
  Duration _playtime = Duration.zero;

  int get lives => _lives;
  Duration get playtime => _playtime;
  set lives(int values) {
    _lives = values;
    notifyListeners();
  }

  void loseLife() {
    if (_lives == 0) return;
    _lives--;
    notifyListeners();
  }

  void addPlaytime(Duration elapsed) {
    _playtime += elapsed;
    notifyListeners();
  }
}
