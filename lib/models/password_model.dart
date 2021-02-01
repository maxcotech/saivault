class PasswordModel{
  int id;
  String passwordLabel, passwordValue,createdAt,initialVector;
  PasswordModel({this.id,this.passwordLabel,this.passwordValue,this.initialVector,this.createdAt});

  factory PasswordModel.fromMap(Map<String,dynamic> map){
    return PasswordModel(
      id:map['id'],
      passwordLabel:map['password_label'],
      passwordValue:map['password_value'],
      initialVector:map['initial_vector'],
      createdAt:map['created_at']
    );
  }
  Map<String,dynamic> toMap(){
    Map<String,dynamic> map = <String,dynamic>{
      'password_label':this.passwordLabel,
      'password_value':this.passwordValue,
      'initial_vector':this.initialVector,
      'created_at':this.createdAt
    };
    if(this.id != null){
      map.addEntries(<MapEntry<String,dynamic>>[MapEntry('id',this.id)]);
    }
    if(this.createdAt != null){
      map.addEntries(<MapEntry<String,dynamic>>[MapEntry('created_at',this.createdAt)]);
    }
    print(map);
    return map;
  }

}