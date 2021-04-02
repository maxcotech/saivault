import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saivault/controllers/guide_view_controller.dart';
import 'package:saivault/widgets/bad_widget.dart';

class PasswordGuideView extends StatelessWidget {
 final controller = Get.put(GuideViewController());
  final String savePassGuide = 
"With this feature you can save your passwords,"
"secret keys and texts that should be kept personal.\n\n"
"To get started, click on the floating action button located at the bottom right of the screen."
"The App will navigate to 'Add Password Page' where you can create a unique password and label.";

  final String generatePassGuide = 
"In the password manager page, to use the password generator,"
"open the generator bottom sheet by clicking on the key icon button in the nav bar."
"The generator has the UI components necessary to configure the nature of generated password.\n\n"
"Once you have generated preferred password, you can copy the password by clicking the copy icon button,"
"You can save the password or generate a new one via the buttons at the base of the bottom sheet.";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Password Manager Guide')), body: GetBuilder(
          init:GuideViewController(),
          builder:(control){
            return _body();
          }));
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
            Text(savePassGuide,
              textAlign:TextAlign.justify,
              style:Get.theme.textTheme.bodyText2.copyWith(
              color:Get.theme.textTheme.bodyText1.color.withOpacity(0.6)
            )),
            
            SizedBox(height: 20),
            BadWidget(completer:controller.completer, bads: controller.bads),
            Text("Generating Password",style: Get.theme.textTheme.subtitle2.copyWith(fontSize:18)),
            SizedBox(height:10),
            Text(generatePassGuide,
              textAlign:TextAlign.justify,
              style:Get.theme.textTheme.bodyText2.copyWith(
              color:Get.theme.textTheme.bodyText1.color.withOpacity(0.6)
            )),
            BadWidget(completer:controller.completer2, bads: controller.bads2),

          ],
        ));
  }
}
