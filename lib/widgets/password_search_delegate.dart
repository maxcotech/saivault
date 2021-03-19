import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:saivault/controllers/password_manager_controller.dart';
import 'package:saivault/models/password_model.dart';
import 'package:saivault/widgets/empty_widget.dart';
import 'package:saivault/widgets/password_widget.dart';

class PasswordSearchDelegate extends SearchDelegate{
  final controller = Get.find<PasswordManagerController>();
  @override 
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

  @override
   ThemeData appBarTheme(BuildContext context) => Get.theme.copyWith(
      primaryColor: Get.isDarkMode? Colors.black : Colors.white,
      primaryIconTheme: Get.theme.primaryIconTheme.copyWith(color: Colors.grey),
      primaryColorBrightness: Get.isDarkMode? Brightness.dark : Brightness.light,
      primaryTextTheme: Get.theme.textTheme,
    );

  @override 
  Widget buildSuggestions(BuildContext context){
    if(query.isEmpty){
      return ListView.builder(
        padding:EdgeInsets.only(bottom:55),
        itemCount:controller.savedPasswords.length,
        itemBuilder:(BuildContext context,int index) => 
          PasswordWidget(controller:controller,model:controller.savedPasswords[index],index:index)
      );
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