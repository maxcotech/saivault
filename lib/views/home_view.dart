import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:get/get.dart';
import 'package:saivault/controllers/home_controller.dart';
import 'package:saivault/views/password_manager_view.dart';

class HomeView extends GetView<HomeController>{
  HomeView({Key key, this.title}) : super(key: key);

  final String title;

  final List<Widget> pages = <Widget>[
      PasswordManagerView(),
      Container(),
      Container(),
  ];

  @override 
  Widget build(BuildContext context){
    return GetBuilder(builder:(HomeController control)=>Scaffold(
      body:this.pages.elementAt(controller.currentIndex),
      bottomNavigationBar: _bottomBar(),
    ));
  }
  BottomNavigationBar _bottomBar(){
    return BottomNavigationBar(
      currentIndex:controller.currentIndex,
      items:_bottomBarItems(),
      onTap:controller.setCurrentIndex
    );
  }
  List<BottomNavigationBarItem> _bottomBarItems(){
    return <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: Icon(LineIcons.lock),
        label: 'Passwords'
      ),
      BottomNavigationBarItem(
        icon: Icon(LineIcons.folder),
        label: 'Files'
      ),
      BottomNavigationBarItem(
        icon: Icon(LineIcons.gears),
        label: 'Settings'
      )
    ];
  }
}