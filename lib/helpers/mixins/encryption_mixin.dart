import 'package:encrypt/encrypt.dart' show Key;
import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography_flutter/cryptography.dart';

mixin EncryptionMixin {
  Future<Map<String,dynamic>> encryptString(String data,Key encryptionKey,{String ivString})async{
    Nonce nonce;
    if(ivString == null){
      nonce = new Nonce.randomBytes(16);
    }else{
      nonce = Nonce(base64Url.decode(ivString).toList());
    }
    SecretKey key = SecretKey(encryptionKey.bytes.toList());
    CipherWithAppendedMac cipher = CipherWithAppendedMac(aesCbc,Hmac(sha256));
    Uint8List encrypted = await cipher.encrypt(utf8.encode(data),nonce:nonce,secretKey: key);
    return <String,dynamic>{
      'iv_string':base64Url.encode(nonce.bytes),
      'encrypted_string':base64Url.encode(encrypted.toList())
    };
  }
  Future<String> decryptString(String data,Key encryptionKey,String ivString)async{
    Nonce nonce = new Nonce(base64Url.decode(ivString).toList());
    SecretKey key = new SecretKey(encryptionKey.bytes.toList());
    CipherWithAppendedMac cipher = CipherWithAppendedMac(aesCbc,Hmac(sha256));
    Uint8List decrypted = await cipher.decrypt(base64Url.decode(data).toList(),nonce:nonce,secretKey:key);
    return utf8.decode(decrypted.toList());
  }
}