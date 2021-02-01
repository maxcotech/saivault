import 'package:saivault/models/password_model.dart';

List<PasswordModel> serializeListToPasswordModels(dynamic results){
    List<PasswordModel> passwordModels = new List<PasswordModel>();
    results.forEach((item){
      passwordModels.add(PasswordModel.fromMap(item));
    });
    return passwordModels;
  }