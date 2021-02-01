class KeyModel{
  String keyValue,keyLabel,createdAt;
  int id;
  KeyModel({this.keyValue,this.keyLabel,this.createdAt,this.id});
  factory KeyModel.fromMap(Map<String,dynamic> map){
    return KeyModel(
      keyValue:map['key_value'],
      keyLabel:map['key_label'],
      createdAt:map['created_at'],
      id:map['id']
    );
  }
  Map<String,dynamic> toMap(){
    return <String,dynamic>{
      'key_value':this.keyValue,
      'key_label':this.keyLabel,
      'created_at':this.createdAt,
    };
  }
}