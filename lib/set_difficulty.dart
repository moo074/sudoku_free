import 'dart:async';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:sudoku_free/initial_values.dart';
import 'package:sudoku_free/remove_ads.dart';
import 'package:sudoku_free/tile_manager.dart';
import 'package:sudoku_free/ad_manager.dart';
import 'package:sudoku_free/statistics.dart';
import 'package:sudoku_free/stat_storage.dart';

import 'package:firebase_admob/firebase_admob.dart';

class SetDifficulty extends StatefulWidget {
  final String _title;

  SetDifficulty(this._title);

  @override
  State<StatefulWidget> createState() {
    return _SetDifficultyState();
  }
}

class _SetDifficultyState extends State<SetDifficulty> {
  bool hasData = false;
  Statistics _statEasy;
  Statistics _statMedium;
  Statistics _statHard;
  Statistics _statMaster;

  //admob
  BannerAd _bannerAd;

  //IAP
  final InAppPurchaseConnection _connection = InAppPurchaseConnection.instance;
  RemoveAds _removeAds;
  bool _isRemoveAdsPurchased = false;
  ProductDetails _productDetails;

  _getStatAlls() {
    StatsStorage.readFileName('stats_easy', 0).then((value) => setState(() {
          _statEasy = value;
          print('stats_easy');
        }));

    StatsStorage.readFileName('stats_intermediate', 1)
        .then((value) => setState(() {
              _statMedium = value;
              print('stats_intermediate');
            }));

    StatsStorage.readFileName('stats_expert', 2).then((value) => setState(() {
          _statHard = value;
          print('stats_expert');
        }));

    StatsStorage.readFileName('stats_master', 3).then((value) => setState(() {
          _statMaster = value;
          print('stats_master');
        }));
  }

  @override
  void initState() {
    _getStatAlls();

    //IAP
    _removeAdsDetails();

    super.initState();

    if (_isRemoveAdsPurchased == false) {
      AdManager.showBannerAd();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder<void>(
            future: _isRemoveAdsPurchased ? null : _initAdMob(),
            builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
              hasData = snapshot.hasData;

              if (snapshot.hasError) {
                print(snapshot.error);
              }

              return Scaffold(
                  appBar: AppBar(
                    title: Text(widget._title,
                        style: TextStyle(
                            color: Colors.green[900],
                            fontWeight: FontWeight.bold)),
                    backgroundColor: Colors.lightGreen,
                  ),
                  body: Center(
                    child: hasData
                        ? _content()
                        : SizedBox(
                            child: CircularProgressIndicator(),
                            width: 48,
                            height: 48,
                          ),
                  ));
            }));
  }

  @override
  void dispose() {
    // COMPLETE: Dispose BannerAd object
    _bannerAd?.dispose();

    //IAP
    _removeAds.dispose();

    super.dispose();
  }

  ListView _content() {
    return ListView(
      //mainAxisSize: MainAxisSize.min,
      //mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Center(
            child: Text("Play Difficulty:",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ))),
        _buttons(context, 'Beginner', Difficulty.easy, _statEasy),
        _buttons(context, 'Intermediate', Difficulty.medium, _statMedium),
        _buttons(context, 'Expert', Difficulty.hard, _statHard),
        _buttons(context, 'Master', Difficulty.master, _statMaster),
        SizedBox(
          height: 100,
        ),
        SizedBox(),
        MaterialButton(child: Text('Change Color'), onPressed: null),
        _purchaseRemoveAds(),
      ],
    );
  }

  ListTile _buttons(BuildContext context, String text, Difficulty difficulty,
      Statistics statistics) {
    return ListTile(
      key: Key('SetDifficulty_' + text),
      onTap: () {
        _navigateSelection(context, difficulty);
        setState(() {});
      },
      title: _difficultyDetails(text, difficulty, statistics),
    );
  }

  Container _difficultyDetails(
      String text, Difficulty difficulty, Statistics statistics) {
    print('_difficultyDetails ');
    Statistics stat =
        statistics != null ? statistics : new Statistics(0, 0, 0, "--:--");
    print(stat.toString());

    return Container(
        color: Colors.lightGreen[200],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(children: [
              Text(text,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              Text('No of Games Won: ', style: TextStyle(fontSize: 15)),
              Text(stat.gameswon.toString(), style: TextStyle(fontSize: 17)),
              SizedBox(
                width: 20,
              ),
              Text('Total No of Games: ', style: TextStyle(fontSize: 15)),
              Text(stat.totalgames.toString(), style: TextStyle(fontSize: 17)),
            ]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              Text('Best Time: ', style: TextStyle(fontSize: 15)),
              Text(stat.besttime.toString(), style: TextStyle(fontSize: 17)),
              SizedBox(
                width: 70,
              ),
              SizedBox(
                width: 70,
              ),
              SizedBox(
                width: 70,
              ),
            ]),
          ],
        ));
  }

  _navigateSelection(BuildContext context, Difficulty difficulty) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => TileManager(difficulty, widget._title)),
    ).then((value) => _refresh());
  }

  void _refresh() {
    print('_refresh');
    _getStatAlls();
    if (!_isRemoveAdsPurchased) AdManager.showBannerAd();
  }

  Future<void> _initAdMob() {
    return FirebaseAdMob.instance.initialize(appId: AdManager.appId);
  }

  _removeAdsDetails() {
    _removeAds = new RemoveAds(_connection);

    // Map<String, PurchaseDetails> purchases = _removeAds.purchases;

    // if (purchases != null) {
    //   purchases.forEach((key, value) {
    //     if (value.productID == RemoveAds.removeAdsProdID) {
    //       _isRemoveAdsPurchased = true;
    //     }
    //   });
    // }

    _removeAds.productDetailResponse
        .then((ProductDetailsResponse value) => setState(() {
              if (value.error != null) {
                print(value.error.message);
              }

              if (value.productDetails.length > 0) {
                _productDetails = value.productDetails
                    .firstWhere((e) => e.id == RemoveAds.removeAdsProdID);
              }
            }));
    //_productDetails = _removeAds.productList
    //    .firstWhere((e) => e.id == RemoveAds.removeAdsProdID);
  }

  MaterialButton _purchaseRemoveAds() {
    if (!_isRemoveAdsPurchased) {
      if (_productDetails != null) {
        return MaterialButton(
            child: Text('Remove Ads for ' + _productDetails.price.toString()),
            onPressed: () {
              PurchaseParam purchaseParam = PurchaseParam(
                  productDetails: _productDetails,
                  applicationUserName: null,
                  sandboxTesting: true);
              if (_productDetails.id == RemoveAds.removeAdsProdID) {
                _connection.buyNonConsumable(purchaseParam: purchaseParam);
              } else {
                print('Another product id: $_productDetails.id');
              }
            });
      }
    }

    return MaterialButton(onPressed: null);
  }
}
