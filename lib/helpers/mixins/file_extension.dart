import 'dart:io';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

mixin FileExtension{
  Widget getFileTypeIcon(FileSystemEntity entity){
    if(entity is Directory){
      return Icon(Icons.folder);
    }
    else if(entity is File){
      File file = entity;
      if(this.isImage(file.path)){
        if(file.existsSync()){
          return Image.file(file,width:40,height:40);
        }else{
          return Icon(Icons.image);
        }
      }
      if(this.isVideo(file.path)){
        return Icon(Icons.videocam);
      }
      if(this.isDocument(file.path)){
        return Icon(LineIcons.book);
      }
      return Icon(LineIcons.file);
    }else{
      return Icon(Icons.link);
    }
  }
  FileSystemEntity generateEntityFromPathSync(String path){
    if(Directory(path).existsSync()){
      return Directory(path);
    }
    else if(File(path).existsSync()){
      return File(path);
    }
    else{
      return null;
    }
  }
  bool isImage(String path){
    String extension = path.split('.').last;
    switch(extension){
      case 'jpg':return true;
      case 'webp':return true;
      case 'gif':return true;
      case 'png':return true;
      case 'jpeg':return true;
      default: return false;
    }
  }
  bool isVideo(String path){
    String extension = path.split('.').last;
    switch(extension){
      case 'mpeg':return true;
      case 'mp4':return true;
      case 'mkv':return true;
      case '3gp':return true;
      case 'webm':return true;
      default: return false;
    }
  }
  bool isDocument(String path){
    String extension = path.split('.').last;
    switch(extension){
      case 'txt':return true;
      case 'pdf':return true;
      case 'doc':return true;
      case 'docx':return true;
      case 'html':return true;
      default: return false;
    }
  }

}