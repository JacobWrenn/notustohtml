import 'package:test/test.dart';
import 'package:notustohtml/notustohtml.dart';
import 'package:notus/notus.dart';

void main() {
  final NotusConverter converter = NotusConverter();

  group('Basic text', () {
    test("Plain paragraph", () {
      final NotusDocument doc = NotusDocument.fromJson([
        {"insert": "Hello World!\n"}
      ]);

      expect(converter.getHTML(doc), "Hello World!<br/><br/>");
    });

    test("Bold paragraph", () {
      final NotusDocument doc = NotusDocument.fromJson([
        {
          "insert": "Hello World!\n",
          "attributes": {"b": true}
        }
      ]);

      expect(converter.getHTML(doc), "<strong>Hello World!<br/><br/></strong>");
    });

    test("Italic paragraph", () {
      final NotusDocument doc = NotusDocument.fromJson([
        {
          "insert": "Hello World!\n",
          "attributes": {"i": true}
        }
      ]);

      expect(converter.getHTML(doc), "<em>Hello World!<br/><br/></em>");
    });

    test("Bold and Italic paragraph", () {
      final NotusDocument doc = NotusDocument.fromJson([
        {
          "insert": "Hello World!\n",
          "attributes": {"i": true, "b": true}
        }
      ]);

      expect(converter.getHTML(doc),
          "<strong><em>Hello World!<br/><br/></em></strong>");
    });
  });

  group('Headings', () {
    test("1", () {
      final NotusDocument doc = NotusDocument.fromJson([
        {"insert": "Hello World!"},
        {
          "insert": "\n",
          "attributes": {"heading": 1}
        }
      ]);

      expect(converter.getHTML(doc), "<h1>Hello World!<br/></h1>");
    });

    test("2", () {
      final NotusDocument doc = NotusDocument.fromJson([
        {"insert": "Hello World!"},
        {
          "insert": "\n",
          "attributes": {"heading": 2}
        }
      ]);

      expect(converter.getHTML(doc), "<h2>Hello World!<br/></h2>");
    });

    test("3", () {
      final NotusDocument doc = NotusDocument.fromJson([
        {"insert": "Hello World!"},
        {
          "insert": "\n",
          "attributes": {"heading": 3}
        }
      ]);

      expect(converter.getHTML(doc), "<h3>Hello World!<br/></h3>");
    });

    test("Don't match text followed by new line", () {
      final NotusDocument doc = NotusDocument.fromJson([
        {"insert": "Hello World!"},
        {"insert": "\n"}
      ]);

      expect(converter.getHTML(doc), "Hello World!<br/><br/>");
    });
  });

  group('Blocks', () {
    test("Quote", () {
      final NotusDocument doc = NotusDocument.fromJson([
        {"insert": "Hello World!"},
        {
          "insert": "\n",
          "attributes": {"block": "quote"}
        }
      ]);

      expect(
          converter.getHTML(doc), "<blockquote>Hello World!<br/></blockquote>");
    });
    test("Code", () {
      final NotusDocument doc = NotusDocument.fromJson([
        {"insert": "Hello World!"},
        {
          "insert": "\n",
          "attributes": {"block": "code"}
        }
      ]);

      expect(converter.getHTML(doc), "<code>Hello World!<br/></code>");
    });
    test("Ordered list", () {
      final NotusDocument doc = NotusDocument.fromJson([
        {"insert": "Hello World!"},
        {
          "insert": "\n",
          "attributes": {"block": "ol"}
        }
      ]);

      expect(converter.getHTML(doc), "<ol><li>Hello World!<br/></li></ol>");
    });
    test("Unordered list", () {
      final NotusDocument doc = NotusDocument.fromJson([
        {"insert": "Hello World!"},
        {
          "insert": "\n",
          "attributes": {"block": "ul"}
        }
      ]);

      expect(converter.getHTML(doc), "<ul><li>Hello World!<br/></li></ul>");
    });
  });

  group('Embeds', () {
    test("Image", () {
      final NotusDocument doc = NotusDocument.fromJson([
        {
          "insert": "",
          "attributes": {
            "embed": {
              "type": "image",
              "source": "http://fake.link/image.png",
            },
          },
        },
        {"insert": "\n"}
      ]);

      expect(converter.getHTML(doc),
          "<img src=\"http://fake.link/image.png\"><br/><br/>");
    });
    test("Line", () {
      final NotusDocument doc = NotusDocument.fromJson([
        {
          "insert": "",
          "attributes": {
            "embed": {
              "type": "hr",
            },
          },
        },
        {"insert": "\n"}
      ]);

      expect(converter.getHTML(doc), "<hr><br/>");
    });
  });

  group('Links', () {
    test("Plain", () {
      final NotusDocument doc = NotusDocument.fromJson([
        {
          "insert": "Hello World!",
          "attributes": {"a": "http://fake.link"},
        },
        {"insert": "\n"}
      ]);

      expect(converter.getHTML(doc),
          "<a href=\"http://fake.link\">Hello World!</a><br/><br/>");
    });

    test("Italic", () {
      final NotusDocument doc = NotusDocument.fromJson([
        {
          "insert": "Hello World!",
          "attributes": {"a": "http://fake.link", "i": true},
        },
        {"insert": "\n"}
      ]);

      expect(converter.getHTML(doc),
          "<em><a href=\"http://fake.link\">Hello World!</a></em><br/><br/>");
    });

    test("In list", () {
      final NotusDocument doc = NotusDocument.fromJson([
        {
          "insert": "Hello World!",
          "attributes": {"a": "http://fake.link"},
        },
        {
          "insert": "\n",
          "attributes": {"block": "ul"},
        }
      ]);

      expect(converter.getHTML(doc),
          "<ul><li><a href=\"http://fake.link\">Hello World!<br/></a></li></ul>");
    });
  });
}
