import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider_ex/path_provider_ex.dart';
import 'package:saivault/controllers/file_storage_controller.dart';
import 'package:get/get.dart';
import 'package:saivault/widgets/empty_widget.dart';

class FileStorageView extends GetView<FileStorageController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _appBar(), body: _body());
  }

  AppBar _appBar() {
    return AppBar(
      title: Text('File Storages'),
    );
  }

  Widget _body() {
    return GetBuilder(
        init: FileStorageController(),
        builder: (control) {
          return FutureBuilder(
              future: controller.getStoragePaths(),
              builder: (BuildContext context,
                  AsyncSnapshot<List<StorageInfo>> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.data.length == 0) {
                    return EmptyWidget(
                        message: 'Could not find any file system');
                  } else {
                    return ListView.builder(
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) =>
                            ListTile(
                                leading: Icon(Icons.folder),
                                title: Text(snapshot.data[index].rootDir),
                                subtitle: Text(
                                    snapshot.data[index].availableGB > 0
                                        ? snapshot.data[index].availableGB
                                                .toString() +
                                            "GB Available"
                                        : snapshot.data[index].availableMB
                                                .toString() +
                                            "MB Available"),
                                trailing: Icon(CupertinoIcons.forward),
                                onTap: () async {
                                  await controller.browseDirectories(
                                      snapshot.data[index].rootDir);
                                }));
                  }
                } else {
                  return CircularProgressIndicator();
                }
              });
        });
  }
}
