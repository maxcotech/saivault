import 'package:flutter/services.dart';
import 'package:saivault/helpers/mixins/path_mixin.dart';
import 'package:saivault/widgets/dialog.dart';

class StorageChannelService with PathMixin{
   MethodChannel channel = new MethodChannel("maxcotechpro.com/saivault/channel");
   StorageChannelService(){
     channel.setMethodCallHandler(methodCallHandler);
   }
   Future<bool> requestStorageAccess(String sdcard) async {
     try{
       bool result = await channel.invokeMethod('requestStorageAccess',<String,dynamic>{'sdcardPath':sdcard});
       return result;
     }
     on PlatformException catch(e){
       print(e.toString());
       getDialog(message:"Failed to grant write access to storage device.",status:Status.error);
       return false;
     }
   }
   Future<bool> isStoragePermissionGranted() async {
     try{
       bool result = await channel.invokeMethod('isStoragePermissionGranted');
       return result;
     }
     on PlatformException catch(e){
       print(e.toString());
       getDialog(message:'Failed to check if write permission is granted',status:Status.error);
       return false;
     }
   }
   Future<bool> deleteDocument(String path) async {
     try{
       bool result = await channel.invokeMethod('deleteDocument',<String,dynamic>{'doc_path':path});
       return result;
     }
     on PlatformException catch(e){
       print(e.toString());
       getDialog(message:'PlatformException: Failed to delete file system entity on path '+path,status:Status.error);
       return false;
     }
   }
   void onResolveWithSDCardUri(String sdcard){
     print("resolved with path "+sdcard);
   }
   Future<bool> createDocument(String path,{String mimeType}) async {
     try{
       Map<String,dynamic> payload = <String,dynamic>{'file_name':path};
       if(mimeType != null) payload['mime_type'] = mimeType;
       bool result = await channel.invokeMethod('createDocument',payload);
       return result;
     }
     on PlatformException catch(e){
       print(e.toString());
       return false;
     }
   }

   Future<dynamic> methodCallHandler(MethodCall call)async{
      switch(call.method){
        case 'resolveWithSDCardUri': this.onResolveWithSDCardUri(call.arguments as String);break;
        default: throw MissingPluginException('notImplemented');
      }
   }
}