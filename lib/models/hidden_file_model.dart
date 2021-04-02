
class HiddenFileModel{
  String hiddenPath,originalPath,initialVector,createdAt,fileIv;
  int id,hidden;

  HiddenFileModel({
    this.hiddenPath,this.originalPath,this.initialVector,this.createdAt,this.hidden,this.id,this.fileIv});
  factory HiddenFileModel.fromMap(Map<String,dynamic> map){
    return HiddenFileModel(
      id:map['id'],hidden:map['hidden'],
      hiddenPath:map['hidden_path'],
      originalPath:map['original_path'],
      initialVector: map['initial_vector'],
      createdAt: map['created_at'],
      fileIv: map['file_iv']
    );
  }
  
  Map<String,dynamic> toMap(){
    return <String,dynamic>{
      'hidden':this.hidden,
      'hidden_path':this.hiddenPath,
      'original_path':this.originalPath,
      'initial_vector':this.initialVector,
      'file_iv':this.fileIv,
      'created_at': this.createdAt
    };
  }
}