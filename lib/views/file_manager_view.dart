import 'package:circular_check_box/circular_check_box.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:saivault/controllers/file_manager_controller.dart';
import 'package:saivault/helpers/mixins/file_extension.dart';
import 'package:saivault/models/hidden_file_model.dart';
import 'package:saivault/widgets/empty_widget.dart';
import 'package:saivault/widgets/loading_screen.dart';

class FileManagerView extends StatelessWidget with FileExtension{
  final FileManagerController controller = Get.find<FileManagerController>();
  @override 
  Widget build(BuildContext context){
    return Scaffold(
      appBar:_appBar(),
      body:GetBuilder(
      builder:(FileManagerController control)=>Stack(children:<Widget>[
        LoadingScreen(isLoading:controller.isLoading),_body()])),
      
    );
  }
  AppBar _appBar(){
    return AppBar(
      title:Text('Manage Files'),
      actions: <Widget>[
        IconButton(
          icon:Icon(Icons.folder),
          onPressed:controller.onClickAdd
          ),
        IconButton(
          icon:Icon(Icons.refresh),
          tooltip: 'Sync your records with file system.',
          onPressed:controller.onSyncFiles
        )
      ],
    );
  }
  Widget _entityList(){
    if(controller.hiddenFiles == null || controller.hiddenFiles.length == 0){
      return EmptyWidget(
        message:'You dont have any file/directory to track.',
        onClickBtn: controller.onClickAdd
      );
    }else{
      return ListView.builder(
        itemCount:controller.hiddenFiles.length,
        padding:EdgeInsets.only(bottom:48),
        itemBuilder:(BuildContext context, int index){
          HiddenFileModel item = controller.hiddenFiles[index];
          return ListTile(
            shape:Border(bottom:BorderSide(color:Colors.black)),
            leading:this.getFileTypeIcon(this.generateEntityFromPathSync(item.originalPath),path:item.originalPath),
            title:Text(item.originalPath.split('/').last),
            subtitle:controller.appService.shouldShowPathOnManager()?Text(item.originalPath):null,
            trailing:_trailingActions(item)
          );
        }
      );
    }
  }
  Widget _body(){
    return Column(children:<Widget>[
      Expanded(child:_entityList()),
      _pageActionBtns()
    ]);
  }
  Widget _trailingActions(HiddenFileModel model){
    return Row(
      mainAxisSize: MainAxisSize.min,
      children:<Widget>[
        CircularCheckBox(
          value:model.hidden == 1? true:false,
          onChanged:(bool val)async{
            await controller.onToggleHideEntity(model);
          }
          ),
        IconButton(
          tooltip: 'Remove entity from list of tracked entities',
          onPressed:()=>controller.onDeleteTrackedItem(model),
          icon:Icon(LineIcons.times)
        )
      ]
    );
  }
  Widget _pageActionBtns(){
    return Container(
      height:50,width:Get.width,
      child:Row(
        children: <Widget>[
          Expanded(
            child:Padding(
              padding:EdgeInsets.only(left:10,right:5),
              child:RaisedButton(
                onPressed:controller.onHideAllTrackedEntities,
                color:Colors.blue,
                child:Text('HIDE ALL',style:TextStyle(color:Colors.white))
              )
          )),
          Expanded(
            child:Padding(
              padding:EdgeInsets.only(right:10,left:5),
              child:RaisedButton(
                elevation: 0,
                color:Colors.transparent,
                shape:Border.all(color:Colors.blue),
                onPressed:controller.onRestoreAllTrackedEntities,
                child:Text('RESTORE ALL')
              )
          ))
        ],
      )
    );
  }
  
  
}