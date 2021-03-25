import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PasswordGuideView extends StatelessWidget {

  final String savePassGuide = 
"With this feature you can save your passwords,\n"
"secret keys and texts that should be kept personal.\n\n"
"To get started, click on the floating action button located at the bottom right of the screen.\n"
"The App will navigate to 'Add Password Page' where you can create a unique password and label.";

  final String generatePassGuide = 
"In the password manager page, to use the password generator,\n"
"open the generator bottom sheet by clicking on the key icon button in the nav bar.\n"
"The generator has the UI components necessary to configure the nature of generated password.\n\n"
"Once you have generated preferred password, you can copy the password by clicking the copy icon button,\n"
"You can save the password or generate a new one via the buttons at the base of the bottom sheet.";

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
                style: Get.theme.textTheme.subtitle2.copyWith(fontSize:18)),
            SizedBox(height: 10),
            Text(savePassGuide,style:Get.theme.textTheme.bodyText1.copyWith(
              color:Get.theme.textTheme.bodyText1.color.withOpacity(0.6)
            )),
            SizedBox(height: 20),
            Text("Generating Password",style: Get.theme.textTheme.subtitle2.copyWith(fontSize:18)),
            SizedBox(height:10),
            Text(generatePassGuide,style:Get.theme.textTheme.bodyText1.copyWith(
              color:Get.theme.textTheme.bodyText1.color.withOpacity(0.6)
            ))
          ],
        ));
  }
}
