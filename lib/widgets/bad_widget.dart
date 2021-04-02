import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BadWidget extends StatelessWidget{
  final Completer<BannerAd> completer;
  final BannerAd bads;
  BadWidget({@required this.completer, @required this.bads});
  @override
  Widget build(BuildContext context){
    return FutureBuilder<BannerAd>(
      future:this.completer.future,
      builder:(BuildContext context, AsyncSnapshot<BannerAd> snapshot){
        if(snapshot.hasData){
          return Container(
            alignment: Alignment.center,
            child: AdWidget(ad:snapshot.data),
            width: double.infinity,
            height: 50,
          );
        } else {
          return Container();
        }
      }

    );
  }
}
