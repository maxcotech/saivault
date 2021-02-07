import 'dart:io';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

mixin FileExtension{
  Widget getFileTypeIcon(FileSystemEntity entity,{String path}){
    if(entity is Directory){
      return Icon(Icons.folder);
    }
    else if(entity is File){
      File file = entity;
      if(this.isImage(file.path)){
        if(file.existsSync()){
          return CircleAvatar(backgroundImage:FileImage(file,scale:2),radius:23);
        }else{
          return CircleAvatar(child:Icon(Icons.image),radius:23);
        }
      }
      if(this.isVideo(file.path)){
        return CircleAvatar(child:Icon(Icons.videocam),radius:23);
      }
      if(this.isDocument(file.path)){
        return CircleAvatar(child:Icon(LineIcons.book),radius:23);
      }
      return CircleAvatar(child:Icon(LineIcons.file),radius:23);
    }else{
      if(path != null){
        if(this.isVideo(path)){
      return CircleAvatar(child:Icon(Icons.videocam),radius:23);
      }
      if(this.isDocument(path)){
        return CircleAvatar(child:Icon(LineIcons.book),radius:23);
      }
      if(this.isImage(path)){
        return CircleAvatar(child:Icon(Icons.image_sharp),radius:23);
      }
      if(this.isFolder(path)){
        return Icon(Icons.folder);
      }
      if(this.isCompressed(path)){
        return CircleAvatar(child:Icon(LineIcons.file_zip_o),radius:23);
      }
      }
    
      return CircleAvatar(child:Icon(Icons.file_present),radius:23);
    }
  }
  bool isCompressed(String path){
    String lastPath = path.split('/').last;
    switch(lastPath){
      case 'zip':return true;
      case 'rar':return true;
      case 'jar':return true;
      default:return false;
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
  bool isFolder(String path){
    String lastPath = path.split('/').last;
    List<String> segments = lastPath.split('.');
    if(segments[0] == lastPath){
      return true;
    }else if(segments.last == "hider"){
      return true;
    }
    return false;
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