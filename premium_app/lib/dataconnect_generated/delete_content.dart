part of 'generated.dart';

class DeleteContentVariablesBuilder {
  String id;

  final FirebaseDataConnect _dataConnect;
  DeleteContentVariablesBuilder(this._dataConnect, {required  this.id,});
  Deserializer<DeleteContentData> dataDeserializer = (dynamic json)  => DeleteContentData.fromJson(jsonDecode(json));
  Serializer<DeleteContentVariables> varsSerializer = (DeleteContentVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<DeleteContentData, DeleteContentVariables>> execute() {
    return ref().execute();
  }

  MutationRef<DeleteContentData, DeleteContentVariables> ref() {
    DeleteContentVariables vars= DeleteContentVariables(id: id,);
    return _dataConnect.mutation("DeleteContent", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class DeleteContentContentDelete {
  final String id;
  DeleteContentContentDelete.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final DeleteContentContentDelete otherTyped = other as DeleteContentContentDelete;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  DeleteContentContentDelete({
    required this.id,
  });
}

@immutable
class DeleteContentData {
  final DeleteContentContentDelete? content_delete;
  DeleteContentData.fromJson(dynamic json):
  
  content_delete = json['content_delete'] == null ? null : DeleteContentContentDelete.fromJson(json['content_delete']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final DeleteContentData otherTyped = other as DeleteContentData;
    return content_delete == otherTyped.content_delete;
    
  }
  @override
  int get hashCode => content_delete.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (content_delete != null) {
      json['content_delete'] = content_delete!.toJson();
    }
    return json;
  }

  DeleteContentData({
    this.content_delete,
  });
}

@immutable
class DeleteContentVariables {
  final String id;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  DeleteContentVariables.fromJson(Map<String, dynamic> json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final DeleteContentVariables otherTyped = other as DeleteContentVariables;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  DeleteContentVariables({
    required this.id,
  });
}

