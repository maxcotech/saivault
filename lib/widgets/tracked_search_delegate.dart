import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:saivault/controllers/file_manager_controller.dart';
import 'package:saivault/helpers/mixins/file_extension.dart';
import 'package:saivault/models/hidden_file_model.dart';
import 'package:saivault/widgets/empty_widget.dart';

class TrackedSearchDelegate extends SearchDelegate with FileExtension{
  final FileManagerController controller = Get.find<FileManagerController>();

  List<Widget> buildActions(BuildContext context){
    return <Widget>[
      IconButton(
        icon:Icon(LineIcons.close),
        onPressed:(){
          query = "";
        }
      )
    ];
  }
  @override 
  Widget buildLeading(BuildContext context){
    return IconButton(
      icon:Icon(LineIcons.arrow_left),
      onPressed:(){
        Navigator.pop(context);
      }
      );
  }
  @override
  Widget buildResults(BuildContext context){
    return Container();
  }
  Widget _trailingActions(HiddenFileModel model){
    return Row(
      mainAxisSize: MainAxisSize.min,
      children:<Widget>[
        Checkbox(
          value:model.hidden == 1? true:false,
          onChanged:(bool val){

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

  @override 
  Widget buildSuggestions(BuildContext context){
    if(query.isEmpty){
      return ListView.builder(
        padding:EdgeInsets.only(bottom:55),
        itemCount:controller.hiddenFiles.length,
        itemBuilder:(BuildContext context,int index){
          HiddenFileModel item = controller.hiddenFiles[index];
          return ListTile(
            leading:this.getFileTypeIcon(this.generateEntityFromPathSync(item.originalPath)),
            title:Text(item.originalPath.split('/').last),
            trailing:_trailingActions(item)
          );
        });
    }else{
      return FutureBuilder<List<PasswordModel>>(
        future:controller.searchPasswords(query),
        builder:(BuildContext context, AsyncSnapshot<List<PasswordModel>> snapshot){
          if(snapshot.hasData){
            if(snapshot.data.length == 0){
              return EmptyWidget();
            }
            return ListView.builder(
              padding:EdgeInsets.only(bottom:55),
              itemCount:snapshot.data.length,
              itemBuilder:(BuildContext context,int index) => 
                PasswordWidget(controller:controller,model:snapshot.data[index],index:index)
            
            );
          }else{
            return EmptyWidget();
          }
        }
      );
    }

  }
}