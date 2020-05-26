# Notus to HTML

Convert the Notus document format to an HTML representation.

## Overview

This project is a generic Dart package used to get an HTML output from the Notus document format. Notus documents are used by the popular [Zefyr](https://github.com/memspace/zefyr) rich text editor.

## Usage

```dart
final converter = NotusHtmlCodec();

String html = converter.encode(myNotusDocument.toDelta()); // HTML Output
```

## Contributing

This package was created for a personal project. Pull requests are accepted on [GitHub](https://github.com/JacobWrenn/notus_to_html) if you are interested in building upon this.
