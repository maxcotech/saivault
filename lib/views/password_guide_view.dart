import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PasswordGuideView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Password Manager Guide')), body: _body());
  }

  Widget _body() {
    return SingleChildScrollView(
        padding: EdgeInsets.only(left: 15, right: 15, top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Saving a password or secret key',
                style: Get.theme.textTheme.subtitle2),
            SizedBox(height: 20),
            Text('''
          With this feature you can save your passwords, 
          secret keys and texts that should be kept personal.

          To get started, click on the floating action button located at the bottom right of the screen.
          The App will navigate to add password page where you can create a unique password and label.''', 
          textAlign: TextAlign.center, softWrap: false,
          overflow:TextOverflow.visible,
          style:TextStyle(

          )),
          ],
        ));
  }
}
