import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:get/get.dart';
import 'package:saivault/controllers/home_controller.dart';
import 'package:saivault/views/file_manager_view.dart';
import 'package:saivault/views/more_view.dart';
import 'package:saivault/views/password_manager_view.dart';
import 'package:saivault/views/settings_view.dart';

class HomeView extends GetView<HomeController>{
  HomeView({Key key, this.title}) : super(key: key);

  final String title;

  final List<Widget> pages = <Widget>[
      PasswordManagerView(),
      FileManagerView(),
      SettingsView(),
      MoreView()
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
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
      elevation:1,
      unselectedItemColor: Colors.grey,
      selectedItemColor: Colors.blue,
      iconSize:26,
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
        icon: Icon(Icons.folder_open_outlined),
        label: 'Files'
      ),
      BottomNavigationBarItem(
        icon: Icon(LineIcons.gears),
        label: 'Settings'
      ),
      BottomNavigationBarItem(
        icon: Icon(LineIcons.get_pocket), //Icon(Icons.more_horiz_outlined),
        label: 'More'
      )
    ];
  }
}