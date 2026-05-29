part of 'generated.dart';

class SyncContentUpdatesVariablesBuilder {
  Timestamp lastUpdated;

  final FirebaseDataConnect _dataConnect;
  SyncContentUpdatesVariablesBuilder(this._dataConnect, {required  this.lastUpdated,});
  Deserializer<SyncContentUpdatesData> dataDeserializer = (dynamic json)  => SyncContentUpdatesData.fromJson(jsonDecode(json));
  Serializer<SyncContentUpdatesVariables> varsSerializer = (SyncContentUpdatesVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<SyncContentUpdatesData, SyncContentUpdatesVariables>> execute({QueryFetchPolicy fetchPolicy = QueryFetchPolicy.preferCache}) {
    return ref().execute(fetchPolicy: fetchPolicy);
  }

  QueryRef<SyncContentUpdatesData, SyncContentUpdatesVariables> ref() {
    SyncContentUpdatesVariables vars= SyncContentUpdatesVariables(lastUpdated: lastUpdated,);
    return _dataConnect.query("SyncContentUpdates", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class SyncContentUpdatesContents {
  final String id;
  final String title;
  final String? sanskritText;
  final String? hindiText;
  final String? englishText;
  final String? englishTranslation;
  final String category;
  final String? description;
  final String? contentText;
  final List<String>? tags;
  final EnumValue<ContentStatus> status;
  final String? author;
  final AnyValue? mediaLinks;
  final String? audioUrl;
  final List<String>? imageUrls;
  final List<String>? videoUrls;
  final String slug;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  SyncContentUpdatesContents.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  title = nativeFromJson<String>(json['title']),
  sanskritText = json['sanskritText'] == null ? null : nativeFromJson<String>(json['sanskritText']),
  hindiText = json['hindiText'] == null ? null : nativeFromJson<String>(json['hindiText']),
  englishText = json['englishText'] == null ? null : nativeFromJson<String>(json['englishText']),
  englishTranslation = json['englishTranslation'] == null ? null : nativeFromJson<String>(json['englishTranslation']),
  category = nativeFromJson<String>(json['category']),
  description = json['description'] == null ? null : nativeFromJson<String>(json['description']),
  contentText = json['contentText'] == null ? null : nativeFromJson<String>(json['contentText']),
  tags = json['tags'] == null ? null : (json['tags'] as List<dynamic>)
        .map((e) => nativeFromJson<String>(e))
        .toList(),
  status = contentStatusDeserializer(json['status']),
  author = json['author'] == null ? null : nativeFromJson<String>(json['author']),
  mediaLinks = json['mediaLinks'] == null ? null : AnyValue.fromJson(json['mediaLinks']),
  audioUrl = json['audioUrl'] == null ? null : nativeFromJson<String>(json['audioUrl']),
  imageUrls = json['imageUrls'] == null ? null : (json['imageUrls'] as List<dynamic>)
        .map((e) => nativeFromJson<String>(e))
        .toList(),
  videoUrls = json['videoUrls'] == null ? null : (json['videoUrls'] as List<dynamic>)
        .map((e) => nativeFromJson<String>(e))
        .toList(),
  slug = nativeFromJson<String>(json['slug']),
  createdAt = Timestamp.fromJson(json['createdAt']),
  updatedAt = Timestamp.fromJson(json['updatedAt']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final SyncContentUpdatesContents otherTyped = other as SyncContentUpdatesContents;
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
    slug == otherTyped.slug && 
    createdAt == otherTyped.createdAt && 
    updatedAt == otherTyped.updatedAt;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, title.hashCode, sanskritText.hashCode, hindiText.hashCode, englishText.hashCode, englishTranslation.hashCode, category.hashCode, description.hashCode, contentText.hashCode, tags.hashCode, status.hashCode, author.hashCode, mediaLinks.hashCode, audioUrl.hashCode, imageUrls.hashCode, videoUrls.hashCode, slug.hashCode, createdAt.hashCode, updatedAt.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['title'] = nativeToJson<String>(title);
    if (sanskritText != null) {
      json['sanskritText'] = nativeToJson<String?>(sanskritText);
    }
    if (hindiText != null) {
      json['hindiText'] = nativeToJson<String?>(hindiText);
    }
    if (englishText != null) {
      json['englishText'] = nativeToJson<String?>(englishText);
    }
    if (englishTranslation != null) {
      json['englishTranslation'] = nativeToJson<String?>(englishTranslation);
    }
    json['category'] = nativeToJson<String>(category);
    if (description != null) {
      json['description'] = nativeToJson<String?>(description);
    }
    if (contentText != null) {
      json['contentText'] = nativeToJson<String?>(contentText);
    }
    if (tags != null) {
      json['tags'] = tags?.map((e) => nativeToJson<String>(e)).toList();
    }
    json['status'] = 
    contentStatusSerializer(status)
    ;
    if (author != null) {
      json['author'] = nativeToJson<String?>(author);
    }
    if (mediaLinks != null) {
      json['mediaLinks'] = mediaLinks!.toJson();
    }
    if (audioUrl != null) {
      json['audioUrl'] = nativeToJson<String?>(audioUrl);
    }
    if (imageUrls != null) {
      json['imageUrls'] = imageUrls?.map((e) => nativeToJson<String>(e)).toList();
    }
    if (videoUrls != null) {
      json['videoUrls'] = videoUrls?.map((e) => nativeToJson<String>(e)).toList();
    }
    json['slug'] = nativeToJson<String>(slug);
    json['createdAt'] = createdAt.toJson();
    json['updatedAt'] = updatedAt.toJson();
    return json;
  }

  SyncContentUpdatesContents({
    required this.id,
    required this.title,
    this.sanskritText,
    this.hindiText,
    this.englishText,
    this.englishTranslation,
    required this.category,
    this.description,
    this.contentText,
    this.tags,
    required this.status,
    this.author,
    this.mediaLinks,
    this.audioUrl,
    this.imageUrls,
    this.videoUrls,
    required this.slug,
    required this.createdAt,
    required this.updatedAt,
  });
}

@immutable
class SyncContentUpdatesData {
  final List<SyncContentUpdatesContents> contents;
  SyncContentUpdatesData.fromJson(dynamic json):
  
  contents = (json['contents'] as List<dynamic>)
        .map((e) => SyncContentUpdatesContents.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final SyncContentUpdatesData otherTyped = other as SyncContentUpdatesData;
    return contents == otherTyped.contents;
    
  }
  @override
  int get hashCode => contents.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['contents'] = contents.map((e) => e.toJson()).toList();
    return json;
  }

  SyncContentUpdatesData({
    required this.contents,
  });
}

@immutable
class SyncContentUpdatesVariables {
  final Timestamp lastUpdated;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  SyncContentUpdatesVariables.fromJson(Map<String, dynamic> json):
  
  lastUpdated = Timestamp.fromJson(json['lastUpdated']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final SyncContentUpdatesVariables otherTyped = other as SyncContentUpdatesVariables;
    return lastUpdated == otherTyped.lastUpdated;
    
  }
  @override
  int get hashCode => lastUpdated.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['lastUpdated'] = lastUpdated.toJson();
    return json;
  }

  SyncContentUpdatesVariables({
    required this.lastUpdated,
  });
}

