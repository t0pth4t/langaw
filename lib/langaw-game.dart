import 'dart:math';
import 'dart:ui';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:langaw/components/agile-fly.dart';
import 'package:langaw/components/backyard.dart';
import 'package:langaw/components/drooler-fly.dart';
import 'package:langaw/components/fly.dart';
import 'package:flutter/gestures.dart';
import 'package:langaw/components/house-fly.dart';
import 'package:langaw/components/hungry-fly.dart';
import 'package:langaw/components/macho-fly.dart';
import 'package:langaw/components/start-button.dart';
import 'package:langaw/view.dart';
import 'package:langaw/views/home-view.dart';
import 'package:langaw/views/lost-view.dart';

class LangawGame extends Game {
  Size screenSize;
  double tileSize;
  List<Fly> flies;
  Random rnd;
  int fliesToAdd = 0;
  Backyard background;
  View activeView = View.home;
  HomeView homeView;
  LostView lostView;

  StartButton startButton;

  LangawGame() {
    init();
  }

  void init() async {
    flies = List<Fly>();
    rnd = Random();
    resize(await Flame.util.initialDimensions());
    startButton = StartButton(this);
    background = Backyard(this);
    homeView = HomeView(this);
    lostView = LostView(this);

    spawnFly();
  }

  void spawnFly() {
    double x = rnd.nextDouble() * (screenSize.width - tileSize);
    double y = rnd.nextDouble() * (screenSize.height - tileSize);
    switch (rnd.nextInt(5)) {
      case 0:
        flies.add(HouseFly(this, x, y));
        break;
      case 1:
        flies.add(DroolerFly(this, x, y));
        break;
      case 2:
        flies.add(AgileFly(this, x, y));
        break;
      case 3:
        flies.add(MachoFly(this, x, y));
        break;
      case 4:
        flies.add(HungryFly(this, x, y));
        break;
    }
  }

  void render(Canvas canvas) {
    background.render(canvas);
    if (activeView == View.home) {
      homeView.render(canvas);
    }
    if (activeView == View.lost) {
      lostView.render(canvas);
      flies = List<Fly>();
    }

    if (activeView == View.home || activeView == View.lost) {
      startButton.render(canvas);
    }
    if (flies != null) {
      flies.forEach((Fly fly) => fly.render(canvas));
    }
  }

  void update(double t) {
    while (fliesToAdd > 0) {
      spawnFly();
      fliesToAdd--;
    }
    if (flies == null) {
      return;
    }
    flies.forEach((Fly fly) => fly.update(t));
    flies.removeWhere((Fly fly) => fly.isOffScreen);
  }

  void resize(Size size) {
    screenSize = size;
    tileSize = screenSize.width / 9;
  }

  void onTapDown(TapDownDetails d) {
    bool isHandled = false;
    if (!isHandled && startButton.rect.contains(d.globalPosition)) {
      if (activeView == View.home || activeView == View.lost) {
        startButton.onTapDown();
        isHandled = true;
        spawnFly();
      }
    }
    if (!isHandled) {
      bool didHitAFly = false;
      flies.forEach((Fly fly) {
        if (fly.flyRect.contains(d.globalPosition)) {
          fly.onTapDown();
          isHandled = true;
          didHitAFly = true;
        }
      });

      if (activeView == View.playing && !didHitAFly) {
        activeView = View.lost;
      }
    }
  }
}
