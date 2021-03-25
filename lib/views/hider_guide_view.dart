import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HiderGuideView extends StatelessWidget {

  final String trackFileGuide = 
"File Entities includes files and folders in the device.\n"
"To get started with managing access to your files, you have to add them to tracked files record.\n\n"
"To track files, browse through the file system using the file system browser provided by clicking on the folder icon in navbar.\n"
"Click on the checkboxes alongside the desired files to select them, then click on the 'OK' button at the bottom of the page to start tracking the files.";

  final String hideAndRestoreGuide = 
"To hide / restore files in the tracked record (via the file manager page), \n"
"click on the checkbox alongside the tracked file to toggle hide/restore state of the tracked file.\n\n"
"To restore all hidden entities in the record, click on 'RESTORE ALL' button and to hide all click 'HIDE ALL BUTTON'.";

 final String syncGuide = 
"Sometimes, you may delete a tracked file in your device, this doesn't erase the track records of the deleted file. \n"
"To sync the tracked files record with the current state of the file system, simply click on the sync icon button on the navbar of the file manager page.\n";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('File Manager Guide')), body: _body());
  }

  Widget _body() {
    return SingleChildScrollView(
        padding: EdgeInsets.only(left: 15, right: 15, top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Track File System Entities',
                style: Get.theme.textTheme.subtitle2.copyWith(fontSize:18)),
            SizedBox(height: 10),
            Text(trackFileGuide,style:Get.theme.textTheme.bodyText1.copyWith(
              color:Get.theme.textTheme.bodyText1.color.withOpacity(0.6)
            )),
            SizedBox(height: 20),
            Text("Hide / Restore Files",style: Get.theme.textTheme.subtitle2.copyWith(fontSize:18)),
            SizedBox(height:10),
            Text(hideAndRestoreGuide,style:Get.theme.textTheme.bodyText1.copyWith(
              color:Get.theme.textTheme.bodyText1.color.withOpacity(0.6)
            )),
            SizedBox(height: 20),
            Text("Sync with File System",style: Get.theme.textTheme.subtitle2.copyWith(fontSize:18)),
            SizedBox(height:10),
            Text(syncGuide,style:Get.theme.textTheme.bodyText1.copyWith(
              color:Get.theme.textTheme.bodyText1.color.withOpacity(0.6)
            ))
          ],
        ));
  }
}
