part of 'generated.dart';

class UpsertContentVariablesBuilder {
  String id;
  String title;
  Optional<String> _sanskritText = Optional.optional(nativeFromJson, nativeToJson);
  Optional<String> _hindiText = Optional.optional(nativeFromJson, nativeToJson);
  Optional<String> _englishText = Optional.optional(nativeFromJson, nativeToJson);
  Optional<String> _englishTranslation = Optional.optional(nativeFromJson, nativeToJson);
  String category;
  Optional<String> _description = Optional.optional(nativeFromJson, nativeToJson);
  Optional<String> _contentText = Optional.optional(nativeFromJson, nativeToJson);
  Optional<List<String>> _tags = Optional.optional(listDeserializer(nativeFromJson), listSerializer(nativeToJson));
  Optional<ContentStatus> _status = Optional.optional((data) => ContentStatus.values.byName(data), enumSerializer);
  Optional<String> _author = Optional.optional(nativeFromJson, nativeToJson);
  Optional<AnyValue> _mediaLinks = Optional.optional(AnyValue.fromJson, defaultSerializer);
  Optional<String> _audioUrl = Optional.optional(nativeFromJson, nativeToJson);
  Optional<List<String>> _imageUrls = Optional.optional(listDeserializer(nativeFromJson), listSerializer(nativeToJson));
  Optional<List<String>> _videoUrls = Optional.optional(listDeserializer(nativeFromJson), listSerializer(nativeToJson));
  String slug;

  final FirebaseDataConnect _dataConnect;  UpsertContentVariablesBuilder sanskritText(String? t) {
   _sanskritText.value = t;
   return this;
  }
  UpsertContentVariablesBuilder hindiText(String? t) {
   _hindiText.value = t;
   return this;
  }
  UpsertContentVariablesBuilder englishText(String? t) {
   _englishText.value = t;
   return this;
  }
  UpsertContentVariablesBuilder englishTranslation(String? t) {
   _englishTranslation.value = t;
   return this;
  }
  UpsertContentVariablesBuilder description(String? t) {
   _description.value = t;
   return this;
  }
  UpsertContentVariablesBuilder contentText(String? t) {
   _contentText.value = t;
   return this;
  }
  UpsertContentVariablesBuilder tags(List<String>? t) {
   _tags.value = t;
   return this;
  }
  UpsertContentVariablesBuilder status(ContentStatus? t) {
   _status.value = t;
   return this;
  }
  UpsertContentVariablesBuilder author(String? t) {
   _author.value = t;
   return this;
  }
  UpsertContentVariablesBuilder mediaLinks(AnyValue? t) {
   _mediaLinks.value = t;
   return this;
  }
  UpsertContentVariablesBuilder audioUrl(String? t) {
   _audioUrl.value = t;
   return this;
  }
  UpsertContentVariablesBuilder imageUrls(List<String>? t) {
   _imageUrls.value = t;
   return this;
  }
  UpsertContentVariablesBuilder videoUrls(List<String>? t) {
   _videoUrls.value = t;
   return this;
  }

  UpsertContentVariablesBuilder(this._dataConnect, {required  this.id,required  this.title,required  this.category,required  this.slug,});
  Deserializer<UpsertContentData> dataDeserializer = (dynamic json)  => UpsertContentData.fromJson(jsonDecode(json));
  Serializer<UpsertContentVariables> varsSerializer = (UpsertContentVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<UpsertContentData, UpsertContentVariables>> execute() {
    return ref().execute();
  }

  MutationRef<UpsertContentData, UpsertContentVariables> ref() {
    UpsertContentVariables vars= UpsertContentVariables(id: id,title: title,sanskritText: _sanskritText,hindiText: _hindiText,englishText: _englishText,englishTranslation: _englishTranslation,category: category,description: _description,contentText: _contentText,tags: _tags,status: _status,author: _author,mediaLinks: _mediaLinks,audioUrl: _audioUrl,imageUrls: _imageUrls,videoUrls: _videoUrls,slug: slug,);
    return _dataConnect.mutation("UpsertContent", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class UpsertContentContentUpsert {
  final String id;
  UpsertContentContentUpsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpsertContentContentUpsert otherTyped = other as UpsertContentContentUpsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  UpsertContentContentUpsert({
    required this.id,
  });
}

@immutable
class UpsertContentData {
  final UpsertContentContentUpsert content_upsert;
  UpsertContentData.fromJson(dynamic json):
  
  content_upsert = UpsertContentContentUpsert.fromJson(json['content_upsert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpsertContentData otherTyped = other as UpsertContentData;
    return content_upsert == otherTyped.content_upsert;
    
  }
  @override
  int get hashCode => content_upsert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['content_upsert'] = content_upsert.toJson();
    return json;
  }

  UpsertContentData({
    required this.content_upsert,
  });
}

@immutable
class UpsertContentVariables {
  final String id;
  final String title;
  late final Optional<String>sanskritText;
  late final Optional<String>hindiText;
  late final Optional<String>englishText;
  late final Optional<String>englishTranslation;
  final String category;
  late final Optional<String>description;
  late final Optional<String>contentText;
  late final Optional<List<String>>tags;
  late final Optional<ContentStatus>status;
  late final Optional<String>author;
  late final Optional<AnyValue>mediaLinks;
  late final Optional<String>audioUrl;
  late final Optional<List<String>>imageUrls;
  late final Optional<List<String>>videoUrls;
  final String slug;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  UpsertContentVariables.fromJson(Map<String, dynamic> json):
  
  id = nativeFromJson<String>(json['id']),
  title = nativeFromJson<String>(json['title']),
  category = nativeFromJson<String>(json['category']),
  slug = nativeFromJson<String>(json['slug']) {
  
  
  
  
    sanskritText = Optional.optional(nativeFromJson, nativeToJson);
    sanskritText.value = json['sanskritText'] == null ? null : nativeFromJson<String>(json['sanskritText']);
  
  
    hindiText = Optional.optional(nativeFromJson, nativeToJson);
    hindiText.value = json['hindiText'] == null ? null : nativeFromJson<String>(json['hindiText']);
  
  
    englishText = Optional.optional(nativeFromJson, nativeToJson);
    englishText.value = json['englishText'] == null ? null : nativeFromJson<String>(json['englishText']);
  
  
    englishTranslation = Optional.optional(nativeFromJson, nativeToJson);
    englishTranslation.value = json['englishTranslation'] == null ? null : nativeFromJson<String>(json['englishTranslation']);
  
  
  
    description = Optional.optional(nativeFromJson, nativeToJson);
    description.value = json['description'] == null ? null : nativeFromJson<String>(json['description']);
  
  
    contentText = Optional.optional(nativeFromJson, nativeToJson);
    contentText.value = json['contentText'] == null ? null : nativeFromJson<String>(json['contentText']);
  
  
    tags = Optional.optional(listDeserializer(nativeFromJson), listSerializer(nativeToJson));
    tags.value = json['tags'] == null ? null : (json['tags'] as List<dynamic>)
        .map((e) => nativeFromJson<String>(e))
        .toList();
  
  
    status = Optional.optional((data) => ContentStatus.values.byName(data), enumSerializer);
    status.value = json['status'] == null ? null : ContentStatus.values.byName(json['status']);
  
  
    author = Optional.optional(nativeFromJson, nativeToJson);
    author.value = json['author'] == null ? null : nativeFromJson<String>(json['author']);
  
  
    mediaLinks = Optional.optional(AnyValue.fromJson, defaultSerializer);
    mediaLinks.value = json['mediaLinks'] == null ? null : AnyValue.fromJson(json['mediaLinks']);
  
  
    audioUrl = Optional.optional(nativeFromJson, nativeToJson);
    audioUrl.value = json['audioUrl'] == null ? null : nativeFromJson<String>(json['audioUrl']);
  
  
    imageUrls = Optional.optional(listDeserializer(nativeFromJson), listSerializer(nativeToJson));
    imageUrls.value = json['imageUrls'] == null ? null : (json['imageUrls'] as List<dynamic>)
        .map((e) => nativeFromJson<String>(e))
        .toList();
  
  
    videoUrls = Optional.optional(listDeserializer(nativeFromJson), listSerializer(nativeToJson));
    videoUrls.value = json['videoUrls'] == null ? null : (json['videoUrls'] as List<dynamic>)
        .map((e) => nativeFromJson<String>(e))
        .toList();
  
  
  }
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpsertContentVariables otherTyped = other as UpsertContentVariables;
    return id == otherTyped.id && 
    title == otherTyped.title && 
    sanskritText == otherTyped.sanskritText && 
    hindiText == otherTyped.hindiText && 
    englishText == otherTyped.englishText && 
    englishTranslation == otherTyped.englishTranslation && 
    category == otherTyped.category && 
    description == otherTyped.description && 
    contentText == otherTyped.contentText && 
    tags == otherTyped.tags && 
    status == otherTyped.status && 
    author == otherTyped.author && 
    mediaLinks == otherTyped.mediaLinks && 
    audioUrl == otherTyped.audioUrl && 
    imageUrls == otherTyped.imageUrls && 
    videoUrls == otherTyped.videoUrls && 
    slug == otherTyped.slug;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, title.hashCode, sanskritText.hashCode, hindiText.hashCode, englishText.hashCode, englishTranslation.hashCode, category.hashCode, description.hashCode, contentText.hashCode, tags.hashCode, status.hashCode, author.hashCode, mediaLinks.hashCode, audioUrl.hashCode, imageUrls.hashCode, videoUrls.hashCode, slug.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['title'] = nativeToJson<String>(title);
    if(sanskritText.state == OptionalState.set) {
      json['sanskritText'] = sanskritText.toJson();
    }
    if(hindiText.state == OptionalState.set) {
      json['hindiText'] = hindiText.toJson();
    }
    if(englishText.state == OptionalState.set) {
      json['englishText'] = englishText.toJson();
    }
    if(englishTranslation.state == OptionalState.set) {
      json['englishTranslation'] = englishTranslation.toJson();
    }
    json['category'] = nativeToJson<String>(category);
    if(description.state == OptionalState.set) {
      json['description'] = description.toJson();
    }
    if(contentText.state == OptionalState.set) {
      json['contentText'] = contentText.toJson();
    }
    if(tags.state == OptionalState.set) {
      json['tags'] = tags.toJson();
    }
    if(status.state == OptionalState.set) {
      json['status'] = status.toJson();
    }
    if(author.state == OptionalState.set) {
      json['author'] = author.toJson();
    }
    if(mediaLinks.state == OptionalState.set) {
      json['mediaLinks'] = mediaLinks.toJson();
    }
    if(audioUrl.state == OptionalState.set) {
      json['audioUrl'] = audioUrl.toJson();
    }
    if(imageUrls.state == OptionalState.set) {
      json['imageUrls'] = imageUrls.toJson();
    }
    if(videoUrls.state == OptionalState.set) {
      json['videoUrls'] = videoUrls.toJson();
    }
    json['slug'] = nativeToJson<String>(slug);
    return json;
  }

  UpsertContentVariables({
    required this.id,
    required this.title,
    required this.sanskritText,
    required this.hindiText,
    required this.englishText,
    required this.englishTranslation,
    required this.category,
    required this.description,
    required this.contentText,
    required this.tags,
    required this.status,
    required this.author,
    required this.mediaLinks,
    required this.audioUrl,
    required this.imageUrls,
    required this.videoUrls,
    required this.slug,
  });
}

