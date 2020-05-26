import 'package:notus/notus.dart';
import 'package:notustohtml/notustohtml.dart';

void main() {
  final converter = NotusHtmlCodec();

  // Replace with the document you have take from the Zefyr editor
  final doc = NotusDocument.fromJson(
    [
      {
        "insert": "Hello World!",
      },
      {
        "insert": "\n",
        "attributes": {
          "heading": 1,
        },
      },
    ],
  );

  String html = converter.encode(doc.toDelta());
  print(html); // The HTML representation of the Notus document
}
