# dataconnect_generated SDK

## Installation
```sh
flutter pub get firebase_data_connect
flutterfire configure
```
For more information, see [Flutter for Firebase installation documentation](https://firebase.google.com/docs/data-connect/flutter-sdk#use-core).

## Data Connect instance
Each connector creates a static class, with an instance of the `DataConnect` class that can be used to connect to your Data Connect backend and call operations.

### Connecting to the emulator

```dart
String host = 'localhost'; // or your host name
int port = 9399; // or your port number
ContentConnector.instance.dataConnect.useDataConnectEmulator(host, port);
```

You can also call queries and mutations by using the connector class.
## Queries

### GetContentById
#### Required Arguments
```dart
String id = ...;
ContentConnector.instance.getContentById(
  id: id,
).execute();
```



#### Return Type
`execute()` returns a `QueryResult<GetContentByIdData, GetContentByIdVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await ContentConnector.instance.getContentById(
  id: id,
);
GetContentByIdData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String id = ...;

final ref = ContentConnector.instance.getContentById(
  id: id,
).ref();
ref.execute();

ref.subscribe(...);
```


### GetContentBySlug
#### Required Arguments
```dart
String slug = ...;
ContentConnector.instance.getContentBySlug(
  slug: slug,
).execute();
```



#### Return Type
`execute()` returns a `QueryResult<GetContentBySlugData, GetContentBySlugVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await ContentConnector.instance.getContentBySlug(
  slug: slug,
);
GetContentBySlugData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String slug = ...;

final ref = ContentConnector.instance.getContentBySlug(
  slug: slug,
).ref();
ref.execute();

ref.subscribe(...);
```


### ListContent
#### Required Arguments
```dart
String category = ...;
ContentConnector.instance.listContent(
  category: category,
).execute();
```

#### Optional Arguments
We return a builder for each query. For ListContent, we created `ListContentBuilder`. For queries and mutations with optional parameters, we return a builder class.
The builder pattern allows Data Connect to distinguish between fields that haven't been set and fields that have been set to null. A field can be set by calling its respective setter method like below:
```dart
class ListContentVariablesBuilder {
  ...
   ListContentVariablesBuilder limit(int? t) {
   _limit.value = t;
   return this;
  }

  ...
}
ContentConnector.instance.listContent(
  category: category,
)
.limit(limit)
.execute();
```

#### Return Type
`execute()` returns a `QueryResult<ListContentData, ListContentVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await ContentConnector.instance.listContent(
  category: category,
);
ListContentData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String category = ...;

final ref = ContentConnector.instance.listContent(
  category: category,
).ref();
ref.execute();

ref.subscribe(...);
```


### ListAllContent
#### Required Arguments
```dart
// No required arguments
ContentConnector.instance.listAllContent().execute();
```

#### Optional Arguments
We return a builder for each query. For ListAllContent, we created `ListAllContentBuilder`. For queries and mutations with optional parameters, we return a builder class.
The builder pattern allows Data Connect to distinguish between fields that haven't been set and fields that have been set to null. A field can be set by calling its respective setter method like below:
```dart
class ListAllContentVariablesBuilder {
  ...
 
  ListAllContentVariablesBuilder limit(int? t) {
   _limit.value = t;
   return this;
  }

  ...
}
ContentConnector.instance.listAllContent()
.limit(limit)
.execute();
```

#### Return Type
`execute()` returns a `QueryResult<ListAllContentData, ListAllContentVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await ContentConnector.instance.listAllContent();
ListAllContentData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = ContentConnector.instance.listAllContent().ref();
ref.execute();

ref.subscribe(...);
```


### SyncContentUpdates
#### Required Arguments
```dart
Timestamp lastUpdated = ...;
ContentConnector.instance.syncContentUpdates(
  lastUpdated: lastUpdated,
).execute();
```



#### Return Type
`execute()` returns a `QueryResult<SyncContentUpdatesData, SyncContentUpdatesVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await ContentConnector.instance.syncContentUpdates(
  lastUpdated: lastUpdated,
);
SyncContentUpdatesData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
Timestamp lastUpdated = ...;

final ref = ContentConnector.instance.syncContentUpdates(
  lastUpdated: lastUpdated,
).ref();
ref.execute();

ref.subscribe(...);
```

## Mutations

### UpsertContent
#### Required Arguments
```dart
String id = ...;
String title = ...;
String category = ...;
String slug = ...;
ContentConnector.instance.upsertContent(
  id: id,
  title: title,
  category: category,
  slug: slug,
).execute();
```

#### Optional Arguments
We return a builder for each query. For UpsertContent, we created `UpsertContentBuilder`. For queries and mutations with optional parameters, we return a builder class.
The builder pattern allows Data Connect to distinguish between fields that haven't been set and fields that have been set to null. A field can be set by calling its respective setter method like below:
```dart
class UpsertContentVariablesBuilder {
  ...
   UpsertContentVariablesBuilder sanskritText(String? t) {
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

  ...
}
ContentConnector.instance.upsertContent(
  id: id,
  title: title,
  category: category,
  slug: slug,
)
.sanskritText(sanskritText)
.hindiText(hindiText)
.englishText(englishText)
.englishTranslation(englishTranslation)
.description(description)
.contentText(contentText)
.tags(tags)
.status(status)
.author(author)
.mediaLinks(mediaLinks)
.audioUrl(audioUrl)
.imageUrls(imageUrls)
.videoUrls(videoUrls)
.execute();
```

#### Return Type
`execute()` returns a `OperationResult<UpsertContentData, UpsertContentVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ContentConnector.instance.upsertContent(
  id: id,
  title: title,
  category: category,
  slug: slug,
);
UpsertContentData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String id = ...;
String title = ...;
String category = ...;
String slug = ...;

final ref = ContentConnector.instance.upsertContent(
  id: id,
  title: title,
  category: category,
  slug: slug,
).ref();
ref.execute();
```


### DeleteContent
#### Required Arguments
```dart
String id = ...;
ContentConnector.instance.deleteContent(
  id: id,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<DeleteContentData, DeleteContentVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ContentConnector.instance.deleteContent(
  id: id,
);
DeleteContentData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String id = ...;

final ref = ContentConnector.instance.deleteContent(
  id: id,
).ref();
ref.execute();
```

