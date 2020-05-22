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

      expect(
          converter.getHTML(doc), "<strong>Hello World!<br/><br/></strong>");
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

  test("Complex example", () {
    final NotusDocument doc = NotusDocument.fromJson([
      {"insert": "Title"},
      {
        "insert": "\n",
        "attributes": {"heading": 1}
      },
      {"insert": "Normal text, "},
      {
        "insert": "bold",
        "attributes": {"b": true}
      },
      {"insert": "\n"},
      {
        "insert": "Italic link",
        "attributes": {"i": true, "a": "https://google.com"}
      },
      {"insert": "\nBullets"},
      {
        "insert": "\n",
        "attributes": {"block": "ul"}
      },
      {"insert": "More bullets"},
      {
        "insert": "\n",
        "attributes": {"block": "ul"}
      },
      {"insert": "Cool quote"},
      {
        "insert": "\n",
        "attributes": {"block": "quote"}
      },
      {"insert": "With a heading"},
      {
        "insert": "\n",
        "attributes": {"block": "quote", "heading": 2}
      },
      {"insert": "Code block"},
      {
        "insert": "\n",
        "attributes": {"block": "code"}
      },
      {"insert": "Weird line thing\n"},
      {
        "insert": "​",
        "attributes": {
          "embed": {"type": "hr"}
        }
      },
      {"insert": "\nHello image\n"},
      {
        "insert": "​",
        "attributes": {
          "embed": {
            "type": "image",
            "source":
                "http://images.google.com/images/branding/googlelogo/1x/googlelogo_color_272x92dp.png"
          }
        }
      },
      {"insert": "\n"}
    ]);
    //expect(converter.getHTML(doc), "");
  });
}
