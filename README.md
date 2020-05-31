# Notus to HTML

Convert between the Notus document format and HTML.

## Overview

This project is a generic Dart package used to convert between HTML and the Notus document format. Notus documents are used by the popular [Zefyr](https://github.com/memspace/zefyr) rich text editor.

The Notus format for Zefyr utilises Deltas to represent the document. These Deltas are not compatible with other editors. The Deltas used in this converter can only be used with Notus and Zefyr.

## Usage

### Encode HTML
```dart
final converter = NotusHtmlCodec();

String html = converter.encode(myNotusDocument.toDelta()); // HTML Output
```
### Decode HTML
```dart
final converter = NotusHtmlCodec();

Delta delta = converter.decode(myHtmlString); // Zefyr compatible Delta
NotusDocument document = NotusDocument.fromDelta(delta); // Notus document ready to be loaded into Zefyr
```

## Contributing

This package was created for a personal project. Pull requests are accepted on [GitHub](https://github.com/JacobWrenn/notus_to_html) if you are interested in building upon this.
