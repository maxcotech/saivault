package com.maxcotechpro.saivault

import io.flutter.embedding.android.FlutterActivity
import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.os.Bundle
import android.content.UriPermission
import android.content.Intent
import java.io.File
import android.content.Context
import android.os.storage.StorageManager
import android.content.ActivityNotFoundException
import android.content.ContentResolver
import android.provider.DocumentsContract
import androidx.documentfile.provider.DocumentFile
import android.webkit.MimeTypeMap
import android.util.Log
import android.net.Uri

class MainActivity: FlutterActivity() {
    private val CHANNEL = "maxcotechpro.com/saivault/channel";
    private var methodChannel: MethodChannel? = null;
    val REQUEST_CODE_CREATE_FILE = 45124
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel = channel
        channel.setMethodCallHandler {
          call, result ->
          // Note: this method is invoked on the main thread.
          // TODO
          when (call.method) {
              "requestStorageAccess" -> {
                  /*this.setupSimpleStorage();
                  storage.requestStorageAccess(REQUEST_CODE_STORAGE_ACCESS);*/
                  val sdCardPath = call.argument<String>("sdcardPath");
                  takeCardUriPermission(sdCardPath!!);
                  result.success(true);
              }
              "isStoragePermissionGranted" -> {
                  val response: Boolean = isStoragePermissionGranted();
                  result.success(response);
              }
              "createDocument" -> {
                  val mimeType = call.argument<String>("mime_type");
                  val fileName = call.argument<String>("file_name");
                  val response = createDocument(fileName!!,mimeType);
                  result.success(response);
              }
              "renameDocument" -> {
                val filePath = call.argument<String>("file_path");
                val newFileName = call.argument<String>("new_file_name");
                val response = renameDocument(filePath!!,newFileName!!);
                result.success(response);
              }
              "deleteDocument" -> {
                  val docPath = call.argument<String>("doc_path");
                  //val res: Boolean? = deleteDocument(getApplicationContext(),docPath!!);
                  try{
                    if (docPath == null) throw Exception("Arguments Not found");
                    var documentFile = DocumentFile.fromTreeUri(getApplicationContext(), getUri()!!);
                    val parts = docPath.split("/");
                    for (i in parts.indices) {
                      var nextfile = documentFile?.findFile(parts[i]); 
                      if(nextfile != null){
                        documentFile = nextfile;
                      }
                    }
                    if(documentFile != null){
                      documentFile.delete();
                    }else{
                      throw Exception("File Not Found");
                    }
                  } catch (e:Exception){
                    e.printStackTrace();
                    result.error("400",e.message,e);
                  }
                  result.success(true);
              }
              else -> result.notImplemented()
          }
        }
    }
    public fun getDocumentFileByName(fileName: String):DocumentFile? {
      var documentFile = DocumentFile.fromTreeUri(getApplicationContext(),getUri()!!);
      var fileDocument = documentFile?.findFile(fileName);
      return fileDocument;
    }
    
    public fun getDocumentFileByPath(docPath: String, createPaths: Boolean = false):DocumentFile? {
        try{
            if (docPath == null) throw Exception("Arguments Not found");
            var documentFile = DocumentFile.fromTreeUri(getApplicationContext(), getUri()!!);
            val parts = docPath.split("/");
            for (i in parts.indices) {
              var nextfile = documentFile?.findFile(parts[i]); 
              if(nextfile != null){
                documentFile = nextfile;
              } else {
                if(createPaths == true){
                  documentFile = documentFile?.createDirectory(parts[i])
                }
              }
            }
            if(documentFile != null){
              return documentFile;
            }else{
              throw Exception("File Not Found");
            }
          } catch (e:Exception){
            e.printStackTrace();
            return null;
          }
    }
    public fun getDocumentParentPath(docPath: String): String {
        var pathSegs = docPath.split("/").toMutableList();
        pathSegs.removeAt(pathSegs.size - 1);
        var path = pathSegs.joinToString("/");
        return path;
    }

    public fun deleteDocument(context: Context, path: String): Boolean? {
        val uri: Uri? = Uri.parse(path);
        var result: Boolean? = false;
        if(uri != null){
           val documentFile: DocumentFile? = DocumentFile.fromSingleUri(context,uri);
           result = documentFile?.delete();
           if(result == true){
              Log.i("deleted file","deleteDocument");
           }
        }
        return result;
    }
    fun takeCardUriPermission(sdCardRootPath: String) {
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.N) {
            val sdCard = File(sdCardRootPath);
            val storageManager: StorageManager? = getSystemService(Context.STORAGE_SERVICE) as? StorageManager;
            val storageVolume = storageManager?.getStorageVolume(sdCard);
            val intent = storageVolume?.createAccessIntent(null);
            try {
              startActivityForResult(intent, 4010);
            } catch (e: ActivityNotFoundException) {
              Log.e("TUNE-IN ANDROID", "takeCardUriPermission: "+e);
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        //storage.onActivityResult(requestCode, resultCode, data)
        if (requestCode == 4010) {

            var uri: Uri? = data?.getData();
      
            grantUriPermission(getPackageName(), uri, Intent.FLAG_GRANT_WRITE_URI_PERMISSION or
                    Intent.FLAG_GRANT_READ_URI_PERMISSION);
      
            val takeFlags  = data?.getFlags()?.and(Intent.FLAG_GRANT_WRITE_URI_PERMISSION or
                    Intent.FLAG_GRANT_READ_URI_PERMISSION);
      
            getContentResolver().takePersistableUriPermission(uri!!, takeFlags!!);
            methodChannel?.invokeMethod("resolveWithSDCardUri",getUri()?.toString());
        }
        if (requestCode == REQUEST_CODE_CREATE_FILE) {
            var uri: Uri? = data?.getData();
            methodChannel?.invokeMethod("resolveWithNewFileUri",uri?.toString());
        }
    }

    public fun isStoragePermissionGranted(): Boolean {
        val uriPermissions = getContentResolver().getPersistedUriPermissions();
        if(uriPermissions.size > 0){
            return true;
        } else {
            return false;
        }
    }

    override public fun startActivityForResult(intent: Intent?,requestCode: Int){
        if(intent == null){
            super.startActivityForResult(Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
                flags = Intent.FLAG_GRANT_READ_URI_PERMISSION or 
                        Intent.FLAG_GRANT_WRITE_URI_PERMISSION or 
                        Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION
            }
            ,requestCode);
        } else {
            super.startActivityForResult(intent,requestCode);
        }
    }
    public fun getUri(): Uri? {
        val persistedUriPermissions = getContentResolver().getPersistedUriPermissions();
        if (persistedUriPermissions.size > 0) {
          val uriPermission = persistedUriPermissions.get(0);
          return uriPermission.getUri();
        }
        return null;
    }
    
    public fun getMimeType(url: String?): String? {
        var type: String? = "application/unknown";
        if(url != null) {
            val extension = MimeTypeMap.getFileExtensionFromUrl(url!!);
            if (extension != null) {
                var mime = MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension);
                if(mime != null) type = mime;
            }
            return type;
        }
        return type;
       
    }

    public fun createDocument(filePath: String,mimeType: String?): Boolean{
        var mime = if(mimeType != null) mimeType else getMimeType(filePath);
        if(filePath.contains("/")){
          var parentPath = getDocumentParentPath(filePath);
          var parentDir = getDocumentFileByPath(parentPath,true);
          var arr = filePath.split("/");
          arr = arr.toMutableList();
          var fileName = arr[arr.size - 1];
          var result = parentDir?.createFile(mime!!,fileName!!);
          return if(result == null){
              false;
          } else {
              true;
          }
        } else {
          var documentFile = DocumentFile.fromTreeUri(getApplicationContext(), getUri()!!);
          var result = documentFile?.createFile(mime!!,filePath);
          return if(result == null) false; else true;
        }
    }

    public fun renameDocument(filePath: String,newFileName: String):Boolean{
      var documentFile = if(filePath.contains("/")){
         getDocumentFileByPath(filePath);
      } else {
         getDocumentFileByName(filePath);
      }
      if(documentFile == null) return false;
      var resp = documentFile?.renameTo(newFileName);
      return if(resp == true) resp; else false;
    }
        
    override fun onSaveInstanceState(outState: Bundle) {
        //storage.onSaveInstanceState(outState)
        super.onSaveInstanceState(outState)
    }

    override fun onRestoreInstanceState(savedInstanceState: Bundle) {
        super.onRestoreInstanceState(savedInstanceState)
        //storage.onRestoreInstanceState(savedInstanceState)
    }

}
