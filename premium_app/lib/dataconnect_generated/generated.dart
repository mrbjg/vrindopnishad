library dataconnect_generated;
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

part 'upsert_content.dart';

part 'delete_content.dart';

part 'get_content_by_id.dart';

part 'get_content_by_slug.dart';

part 'list_content.dart';

part 'list_all_content.dart';

part 'sync_content_updates.dart';



  enum ContentStatus {
    
      DRAFT,
    
      PUBLISHED,
    
      ARCHIVED,
    
  }
  
  String contentStatusSerializer(EnumValue<ContentStatus> e) {
    return e.stringValue;
  }
  EnumValue<ContentStatus> contentStatusDeserializer(dynamic data) {
    switch (data) {
      
      case 'DRAFT':
        return const Known(ContentStatus.DRAFT);
      
      case 'PUBLISHED':
        return const Known(ContentStatus.PUBLISHED);
      
      case 'ARCHIVED':
        return const Known(ContentStatus.ARCHIVED);
      
      default:
        return Unknown(data);
    }
  }
  



String enumSerializer(Enum e) {
  return e.name;
}



/// A sealed class representing either a known enum value or an unknown string value.
@immutable
sealed class EnumValue<T extends Enum> {
  const EnumValue();

  

  /// The string representation of the value.
  String get stringValue;
  @override
  String toString() {
    return "EnumValue($stringValue)";
  }
}

/// Represents a known, valid enum value.
class Known<T extends Enum> extends EnumValue<T> {
  /// The actual enum value.
  final T value;

  const Known(this.value);

  @override
  String get stringValue => value.name;

  @override
  String toString() {
    return "Known($stringValue)";
  }
}
/// Represents an unknown or unrecognized enum value.
class Unknown extends EnumValue<Never> {
  /// The raw string value that couldn't be mapped to a known enum.
  @override
  final String stringValue;

  const Unknown(this.stringValue);
  @override
  String toString() {
    return "Unknown($stringValue)";
  }
}

class ContentConnector {
  
  
  UpsertContentVariablesBuilder upsertContent ({required String id, required String title, required String category, required String slug, }) {
    return UpsertContentVariablesBuilder(dataConnect, id: id,title: title,category: category,slug: slug,);
  }
  
  
  DeleteContentVariablesBuilder deleteContent ({required String id, }) {
    return DeleteContentVariablesBuilder(dataConnect, id: id,);
  }
  
  
  GetContentByIdVariablesBuilder getContentById ({required String id, }) {
    return GetContentByIdVariablesBuilder(dataConnect, id: id,);
  }
  
  
  GetContentBySlugVariablesBuilder getContentBySlug ({required String slug, }) {
    return GetContentBySlugVariablesBuilder(dataConnect, slug: slug,);
  }
  
  
  ListContentVariablesBuilder listContent ({required String category, }) {
    return ListContentVariablesBuilder(dataConnect, category: category,);
  }
  
  
  ListAllContentVariablesBuilder listAllContent () {
    return ListAllContentVariablesBuilder(dataConnect, );
  }
  
  
  SyncContentUpdatesVariablesBuilder syncContentUpdates ({required Timestamp lastUpdated, }) {
    return SyncContentUpdatesVariablesBuilder(dataConnect, lastUpdated: lastUpdated,);
  }
  

  static ConnectorConfig connectorConfig = ConnectorConfig(
    'us-east4',
    'content',
    'vrindavaani',
  );

  ContentConnector({required this.dataConnect});
  static ContentConnector get instance {
    
    CacheSettings cacheSettings = CacheSettings(
      maxAge: Duration(milliseconds:0),
      storage: CacheStorage.persistent,
    );
    
    return ContentConnector(
        dataConnect: FirebaseDataConnect.instanceFor(
            connectorConfig: connectorConfig,
            
            cacheSettings: cacheSettings,
            
            sdkType: CallerSDKType.generated));
  }

  FirebaseDataConnect dataConnect;
}
