import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

mixin FileExtension{
  final double avatarSize = 20;
  Widget getFileTypeIcon(FileSystemEntity entity,{String path}){
    if(entity is Directory){
      return CircleAvatar(child:Icon(Icons.folder),radius:avatarSize);
    }
    else if(entity is File){
      File file = entity;
      if(this.isImage(file.path)){
        if(file.existsSync()){
          return CircleAvatar(backgroundImage:FileImage(file,scale:2),radius:avatarSize);
        }else{
          return CircleAvatar(child:Icon(Icons.image),radius:avatarSize);
        }
      }
      if(this.isVideo(file.path)){
        return CircleAvatar(child:Icon(Icons.videocam),radius:avatarSize);
      }
      if(this.isDocument(file.path)){
        return CircleAvatar(child:Icon(LineIcons.book),radius:avatarSize);
      }
      if(this.isSpreadsheet(file.path)){
        return CircleAvatar(child:Icon(Icons.table_view));
      }
      if(this.isMusic(file.path)){
        return CircleAvatar(child:Icon(Icons.music_note));
      }
      if(this.isCompressed(file.path)){
        return CircleAvatar(child:Icon(LineIcons.file_zip_o),radius:avatarSize);
      }
      if(this.isHtml(file.path)){
        return CircleAvatar(child:Icon(LineIcons.html5),radius:avatarSize);
      }
      if(this.isPresentation(file.path)){
        return CircleAvatar(child:Icon(LineIcons.file_powerpoint_o),radius:avatarSize);
      }
      return CircleAvatar(child:Icon(LineIcons.file),radius:avatarSize);
    }else{
      if(path != null){
        if(this.isVideo(path)){
      return CircleAvatar(child:Icon(Icons.videocam),radius:avatarSize);
      }
      if(this.isDocument(path)){
        return CircleAvatar(child:Icon(LineIcons.book),radius:avatarSize);
      }
      if(this.isImage(path)){
        return CircleAvatar(child:Icon(Icons.image_sharp),radius:avatarSize);
      }
      if(this.isFolder(path)){
        return CircleAvatar(child:Icon(Icons.folder),radius:avatarSize);
      }
      if(this.isSpreadsheet(path)){
        return CircleAvatar(child:Icon(Icons.table_view));
      }
      if(this.isMusic(path)){
        return CircleAvatar(child:Icon(Icons.music_note));
      }
      if(this.isCompressed(path)){
        return CircleAvatar(child:Icon(LineIcons.file_zip_o),radius:avatarSize);
      }
      if(this.isHtml(path)){
        return CircleAvatar(child:Icon(LineIcons.html5),radius:avatarSize);
      }
      if(this.isPresentation(path)){
        return CircleAvatar(child:Icon(LineIcons.file_powerpoint_o),radius:avatarSize);
      }
      }
    
      return CircleAvatar(child:Icon(Icons.file_present),radius:avatarSize);
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
      case 'odt':return true;
      default: return false;
    }
  }
  bool isHtml(String path){
    String extension = path.split('.').last;
    switch(extension){
      case 'html':return true;
      case 'htm': return true;
      case 'xhtml': return true;
      case 'xml':return true;
      default: return false;
    }
  }
  bool isPresentation(String path){
    String extension = path.split('.').last;
    switch(extension){
      case 'ppt':return true;
      case 'pptx':return true;
      default: return false;
    }
  }
  bool isSpreadsheet(String path){
    String extension = path.split('.').last;
    switch(extension){
      case 'ods':return true;
      case 'xls':return true;
      case 'xlsx':return true;
      default: return false;
    }
  }
  bool isMusic(String path){
    String extension = path.split('.').last;
    switch(extension){
      case 'mp3':return true;
      case 'flac':return true;
      case 'm4a':return true;
      case 'wav':return true;
      case 'wma':return true;
      case 'aac':return true;
      default: return false;
    }
  }

}