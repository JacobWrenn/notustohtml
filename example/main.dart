import 'package:notus/notus.dart';
import 'package:notustohtml/notustohtml.dart';
import 'package:quill_delta/quill_delta.dart';

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

  Delta delta = converter.decode(html); // Zefyr compatible Delta
  NotusDocument document = NotusDocument.fromDelta(delta); // Notus document ready to be loaded into Zefyr
}
