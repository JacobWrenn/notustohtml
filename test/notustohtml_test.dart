import 'package:test/test.dart';
import 'package:notustohtml/notustohtml.dart';
import 'package:notus/notus.dart';

void main() {
  final converter = NotusHtmlCodec();

  group('Encode', () {
    group('Basic text', () {
      test("Plain paragraph", () {
        final NotusDocument doc = NotusDocument.fromJson([
          {"insert": "Hello World!\n"}
        ]);

        expect(converter.encode(doc.toDelta()), "Hello World!<br><br>");
      });

      test("Bold paragraph", () {
        final NotusDocument doc = NotusDocument.fromJson([
          {
            "insert": "Hello World!\n",
            "attributes": {"b": true}
          }
        ]);

        expect(converter.encode(doc.toDelta()),
            "<strong>Hello World!</strong><br><br>");
      });

      test("Underline paragraph", () {
        final NotusDocument doc = NotusDocument.fromJson([
          {
            "insert": "Hello World!\n",
            "attributes": {"u": true}
          }
        ]);

        expect(converter.encode(doc.toDelta()), "<u>Hello World!</u><br><br>");
      });

      test("Strikethrough paragraph", () {
        final NotusDocument doc = NotusDocument.fromJson([
          {
            "insert": "Hello World!\n",
            "attributes": {"s": true}
          }
        ]);

        expect(
            converter.encode(doc.toDelta()), "<del>Hello World!</del><br><br>");
      });

      test("Italic paragraph", () {
        final NotusDocument doc = NotusDocument.fromJson([
          {
            "insert": "Hello World!\n",
            "attributes": {"i": true}
          }
        ]);

        expect(
            converter.encode(doc.toDelta()), "<em>Hello World!</em><br><br>");
      });

      test("Bold and Italic paragraph", () {
        final NotusDocument doc = NotusDocument.fromJson([
          {
            "insert": "Hello World!\n",
            "attributes": {"i": true, "b": true}
          }
        ]);

        expect(converter.encode(doc.toDelta()),
            "<em><strong>Hello World!</em></strong><br><br>");
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

        expect(
            converter.encode(doc.toDelta()), "<h1>Hello World!</h1><br><br>");
      });

      test("2", () {
        final NotusDocument doc = NotusDocument.fromJson([
          {"insert": "Hello World!"},
          {
            "insert": "\n",
            "attributes": {"heading": 2}
          }
        ]);

        expect(
            converter.encode(doc.toDelta()), "<h2>Hello World!</h2><br><br>");
      });

      test("3", () {
        final NotusDocument doc = NotusDocument.fromJson([
          {"insert": "Hello World!"},
          {
            "insert": "\n",
            "attributes": {"heading": 3}
          }
        ]);

        expect(
            converter.encode(doc.toDelta()), "<h3>Hello World!</h3><br><br>");
      });

      test("In list", () {
        final NotusDocument doc = NotusDocument.fromJson([
          {"insert": "Hello World!"},
          {
            "insert": "\n",
            "attributes": {"block": "ul", "heading": 1},
          }
        ]);

        expect(converter.encode(doc.toDelta()),
            "<ul><li><h1>Hello World!</h1></li></ul><br><br>");
      });
    });

    group('Blocks', () {
      test("Paragraph Element", () {
        final String html = "Hello World!<br><br>";
        final NotusDocument doc = NotusDocument.fromJson([
          {
            "insert": "Hello World!",
          },
          {
            "insert": "\n",
            "attributes": {},
          }
        ]);

        expect(converter.encode(doc.toDelta()), html);
      });

      test("Quote", () {
        final NotusDocument doc = NotusDocument.fromJson([
          {"insert": "Hello World!"},
          {
            "insert": "\n",
            "attributes": {"block": "quote"}
          }
        ]);

        expect(converter.encode(doc.toDelta()),
            "<blockquote>Hello World!</blockquote><br><br>");
      });
      test("Code", () {
        final NotusDocument doc = NotusDocument.fromJson([
          {"insert": "Hello World!"},
          {
            "insert": "\n",
            "attributes": {"block": "code"}
          }
        ]);

        expect(converter.encode(doc.toDelta()),
            "<br><code>Hello World!</code><br><br><br>");
      });
      test("Ordered list", () {
        final NotusDocument doc = NotusDocument.fromJson([
          {"insert": "Hello World!"},
          {
            "insert": "\n",
            "attributes": {"block": "ol"}
          }
        ]);

        expect(converter.encode(doc.toDelta()),
            "<ol><li>Hello World!</li></ol><br><br>");
      });
      test("List with bold", () {
        final NotusDocument doc = NotusDocument.fromJson([
          {
            "insert": "Hello World!",
            "attributes": {"b": true}
          },
          {
            "insert": "\n",
            "attributes": {"block": "ol"}
          }
        ]);

        expect(converter.encode(doc.toDelta()),
            "<ol><li><strong>Hello World!</strong></li></ol><br><br>");
      });
      test("Unordered list", () {
        final NotusDocument doc = NotusDocument.fromJson([
          {"insert": "Hello World!"},
          {
            "insert": "\n",
            "attributes": {"block": "ul"}
          },
          {"insert": "Hello World!"},
          {
            "insert": "\n",
            "attributes": {"block": "ul"}
          }
        ]);

        expect(converter.encode(doc.toDelta()),
            "<ul><li>Hello World!</li><li>Hello World!</li></ul><br><br>");
      });
    });

    group('Embeds', () {
      test("Image", () {
        final NotusDocument doc = NotusDocument()
          ..insert(0, "test text")
          ..insert(0, BlockEmbed.image("http://fake.link/image.png"))
          ..insert(0, "test text");

        expect(converter.encode(doc.toDelta()),
            "test text<br><br><img src=\"http://fake.link/image.png\"><br><br>test text<br><br>");
      });
      test("Line", () {
        final NotusDocument doc = NotusDocument()
          ..insert(0, BlockEmbed.horizontalRule);

        expect(converter.encode(doc.toDelta()), "<hr><br><br>");
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

        expect(converter.encode(doc.toDelta()),
            "<a href=\"http://fake.link\">Hello World!</a><br><br>");
      });

      test("Italic", () {
        final NotusDocument doc = NotusDocument.fromJson([
          {
            "insert": "Hello World!",
            "attributes": {"a": "http://fake.link", "i": true},
          },
          {"insert": "\n"}
        ]);

        expect(converter.encode(doc.toDelta()),
            "<a href=\"http://fake.link\"><em>Hello World!</em></a><br><br>");
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

        expect(converter.encode(doc.toDelta()),
            "<ul><li><a href=\"http://fake.link\">Hello World!</a></li></ul><br><br>");
      });
    });
  });

  group('Decode', () {
    group('Basic text', () {
      test('Plain paragraph', () {
        final String html = "Hello World!<br><br>";
        final NotusDocument doc = NotusDocument.fromJson([
          {"insert": "Hello World!\n"}
        ]);

        expect(converter.decode(html), doc.toDelta());
      });

      test("Bold paragraph", () {
        final String html = "<strong>Hello World!</strong><br><br>";
        final NotusDocument doc = NotusDocument.fromJson([
          {
            "insert": "Hello World!\n",
            "attributes": {"b": true}
          }
        ]);

        expect(converter.decode(html), doc.toDelta());
      });

      test("Underline paragraph", () {
        final String html = "<u>Hello World!</u><br><br>";
        final NotusDocument doc = NotusDocument.fromJson([
          {
            "insert": "Hello World!\n",
            "attributes": {"u": true}
          }
        ]);

        expect(converter.decode(html), doc.toDelta());
      });

      test("Strikethrough paragraph", () {
        final String html = "<del>Hello World!</del><br><br>";
        final NotusDocument doc = NotusDocument.fromJson([
          {
            "insert": "Hello World!\n",
            "attributes": {"s": true}
          }
        ]);

        expect(converter.decode(html), doc.toDelta());
      });

      test("Italic paragraph", () {
        final String html = "<em>Hello World!</em><br><br>";
        final NotusDocument doc = NotusDocument.fromJson([
          {
            "insert": "Hello World!\n",
            "attributes": {"i": true}
          }
        ]);

        expect(converter.decode(html), doc.toDelta());
      });

      test("Bold and Italic paragraph", () {
        final String html = "<em><strong>Hello World!</em></strong><br><br>";
        final NotusDocument doc = NotusDocument.fromJson([
          {
            "insert": "Hello World!\n",
            "attributes": {"i": true, "b": true}
          }
        ]);

        expect(converter.decode(html), doc.toDelta());
      });
    });

    group('Headings', () {
      test("1", () {
        final String html = "<h1>Hello World!</h1><br><br>";
        final NotusDocument doc = NotusDocument.fromJson([
          {"insert": "Hello World!"},
          {
            "insert": "\n",
            "attributes": {"heading": 1}
          }
        ]);

        expect(converter.decode(html), doc.toDelta());
      });

      test("2", () {
        final String html = "<h2>Hello World!</h2><br><br>";
        final NotusDocument doc = NotusDocument.fromJson([
          {"insert": "Hello World!"},
          {
            "insert": "\n",
            "attributes": {"heading": 2}
          }
        ]);

        expect(converter.decode(html), doc.toDelta());
      });

      test("3", () {
        final String html = "<h3>Hello World!</h3><br><br>";
        final NotusDocument doc = NotusDocument.fromJson([
          {"insert": "Hello World!"},
          {
            "insert": "\n",
            "attributes": {"heading": 3}
          }
        ]);

        expect(converter.decode(html), doc.toDelta());
      });

      test("In list", () {
        final String html = "<ul><li><h1>Hello World!</h1></li></ul>";
        final NotusDocument doc = NotusDocument.fromJson([
          {"insert": "Hello World!"},
          {
            "insert": "\n",
            "attributes": {"block": "ul", "heading": 1},
          }
        ]);

        expect(converter.decode(html), doc.toDelta());
      });
    });

    group('Blocks', () {
      test("Paragraph Element", () {
        final String html = "<p>Hello World!</p>";
        final NotusDocument doc = NotusDocument.fromJson([
          {
            "insert": "Hello World!",
          },
          {
            "insert": "\n",
            "attributes": {},
          }
        ]);

        expect(converter.decode(html), doc.toDelta());
      });
      test("Paragraph Element with children elements", () {
        final String html =
            "<p>Hello World!<a href=\"http://fake.link\">Hello World!</a> Another hello world!</p>";
        final NotusDocument doc = NotusDocument.fromJson([
          {
            "insert": "Hello World!",
          },
          {
            "insert": "Hello World!",
            "attributes": {"a": "http://fake.link"},
          },
          {
            "insert": " Another hello world!",
          },
          {
            "insert": "\n",
            "attributes": {},
          }
        ]);

        expect(converter.decode(html), doc.toDelta());
      });
      test("Multiples paragraps with children", () {
        final String html =
            "<p>Hello World!<a href=\"http://fake.link\">Hello World!</a> Another hello world!</p><p>Hello World!<a href=\"http://fake.link\">Hello World!</a> Another hello world!</p>";
        final NotusDocument doc = NotusDocument.fromJson([
          {
            "insert": "Hello World!",
          },
          {
            "insert": "Hello World!",
            "attributes": {"a": "http://fake.link"},
          },
          {
            "insert": " Another hello world!",
          },
          {
            "insert": "\n",
            "attributes": {},
          },
          {
            "insert": "Hello World!",
          },
          {
            "insert": "Hello World!",
            "attributes": {"a": "http://fake.link"},
          },
          {
            "insert": " Another hello world!",
          },
          {
            "insert": "\n",
            "attributes": {},
          }
        ]);

        expect(converter.decode(html), doc.toDelta());
      });
      test("Quote", () {
        final String html = "<blockquote>Hello World!</blockquote><br><br>";
        final NotusDocument doc = NotusDocument.fromJson([
          {"insert": "Hello World!"},
          {
            "insert": "\n",
            "attributes": {"block": "quote"}
          }
        ]);

        expect(converter.decode(html), doc.toDelta());
      });
      test("Code", () {
        final String html = "<code>Hello World!</code><br><br>";
        final NotusDocument doc = NotusDocument.fromJson([
          {"insert": "Hello World!"},
          {
            "insert": "\n",
            "attributes": {"block": "code"}
          }
        ]);

        expect(converter.decode(html), doc.toDelta());
      });
      test("Ordered list", () {
        final String html = "<ol><li>Hello World!</li></ol><br><br>";
        final NotusDocument doc = NotusDocument.fromJson([
          {"insert": "Hello World!"},
          {
            "insert": "\n",
            "attributes": {"block": "ol"}
          }
        ]);

        expect(converter.decode(html), doc.toDelta());
      });
      test("List with bold", () {
        final String html =
            "<ol><li><strong>Hello World!</strong></li></ol><br><br>";
        final NotusDocument doc = NotusDocument.fromJson([
          {
            "insert": "Hello World!",
            "attributes": {"b": true}
          },
          {
            "insert": "\n",
            "attributes": {"block": "ol"}
          }
        ]);

        expect(converter.decode(html), doc.toDelta());
      });
      test("Unordered list", () {
        final String html =
            "<ul><li>Hello World!</li><li>Hello World!</li></ul><br><br>";
        final NotusDocument doc = NotusDocument.fromJson([
          {"insert": "Hello World!"},
          {
            "insert": "\n",
            "attributes": {"block": "ul"}
          },
          {"insert": "Hello World!"},
          {
            "insert": "\n",
            "attributes": {"block": "ul"}
          }
        ]);

        expect(converter.decode(html), doc.toDelta());
      });
    });

    group('Embeds', () {
      test("Image", () {
        final String html = "<img src=\"http://fake.link/image.png\"><br><br>";
        NotusDocument doc = NotusDocument.fromJson([
          {"insert": "\n"}
        ]);
        doc.insert(0, BlockEmbed.image("http://fake.link/image.png"));

        expect(converter.decode(html), doc.toDelta());
      });
      test("Line", () {
        final String html = "<hr><br><br>";
        NotusDocument doc = NotusDocument.fromJson([
          {"insert": "\n"}
        ]);
        doc.insert(0, BlockEmbed.horizontalRule);

        expect(converter.decode(html), doc.toDelta());
      });
    });

    group('Links', () {
      test("Plain", () {
        final String html =
            "<a href=\"http://fake.link\">Hello World!</a><br><br>";
        final NotusDocument doc = NotusDocument.fromJson([
          {
            "insert": "Hello World!",
            "attributes": {"a": "http://fake.link"},
          },
          {"insert": "\n"}
        ]);

        expect(converter.decode(html), doc.toDelta());
      });

      test("Italic", () {
        final String html =
            "<a href=\"http://fake.link\"><em>Hello World!</em></a><br><br>";
        final NotusDocument doc = NotusDocument.fromJson([
          {
            "insert": "Hello World!",
            "attributes": {"a": "http://fake.link", "i": true},
          },
          {"insert": "\n"}
        ]);

        expect(converter.decode(html), doc.toDelta());
      });

      test("In list", () {
        final String html =
            "<ul><li><a href=\"http://fake.link\">Hello World!</a></li></ul>";
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

        expect(converter.decode(html), doc.toDelta());
      });
    });
  });
}
