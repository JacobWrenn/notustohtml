library notustohtml;

import 'dart:convert';

import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:notus/notus.dart';
import 'package:quill_delta/quill_delta.dart';

class NotusHtmlCodec extends Codec<Delta, String> {
  const NotusHtmlCodec();

  @override
  Converter<String, Delta> get decoder => _NotusHtmlDecoder();

  @override
  Converter<Delta, String> get encoder => _NotusHtmlEncoder();
}

class _NotusHtmlEncoder extends Converter<Delta, String> {
  static const kBold = 'strong';
  static const kItalic = 'em';
  static final kSimpleBlocks = <NotusAttribute, String>{
    NotusAttribute.bq: 'blockquote',
    NotusAttribute.ul: 'ul',
    NotusAttribute.ol: 'ol',
  };

  @override
  String convert(Delta input) {
    final iterator = DeltaIterator(input);
    final buffer = StringBuffer();
    final lineBuffer = StringBuffer();
    NotusAttribute<String> currentBlockStyle;
    var currentInlineStyle = NotusStyle();
    var currentBlockLines = [];

    void _handleBlock(NotusAttribute<String> blockStyle) {
      if (currentBlockLines.isEmpty) {
        return; // Empty block
      }

      if (blockStyle == null) {
        buffer.write(currentBlockLines.join('\n\n'));
        buffer.writeln();
      } else if (blockStyle == NotusAttribute.code) {
        _writeAttribute(buffer, blockStyle);
        buffer.write(currentBlockLines.join('\n'));
        _writeAttribute(buffer, blockStyle, close: true);
        buffer.writeln();
      } else if (blockStyle == NotusAttribute.bq) {
        _writeAttribute(buffer, blockStyle);
        buffer.write(currentBlockLines.join('\n'));
        _writeAttribute(buffer, blockStyle, close: true);
        buffer.writeln();
      } else if (blockStyle == NotusAttribute.ol ||
          blockStyle == NotusAttribute.ul) {
        _writeAttribute(buffer, blockStyle);
        buffer.write("<li>");
        buffer.write(currentBlockLines.join('</li><li>'));
        buffer.write("</li>");
        _writeAttribute(buffer, blockStyle, close: true);
        buffer.writeln();
      } else {
        for (var line in currentBlockLines) {
          _writeBlockTag(buffer, blockStyle);
          buffer.write(line);
          buffer.writeln();
        }
      }
      buffer.writeln();
    }

    void _handleSpan(String text, Map<String, dynamic> attributes) {
      final style = NotusStyle.fromJson(attributes);
      currentInlineStyle =
          _writeInline(lineBuffer, text, style, currentInlineStyle);
    }

    void _handleLine(Map<String, dynamic> attributes) {
      final style = NotusStyle.fromJson(attributes);
      final lineBlock = style.get(NotusAttribute.block);
      if (lineBlock == currentBlockStyle) {
        currentBlockLines.add(_writeLine(lineBuffer.toString(), style));
      } else {
        _handleBlock(currentBlockStyle);
        currentBlockLines.clear();
        currentBlockLines.add(_writeLine(lineBuffer.toString(), style));

        currentBlockStyle = lineBlock;
      }
      lineBuffer.clear();
    }

    while (iterator.hasNext) {
      final op = iterator.next();
      final lf = op.data.indexOf('\n');
      if (lf == -1) {
        _handleSpan(op.data, op.attributes);
      } else {
        var span = StringBuffer();
        for (var i = 0; i < op.data.length; i++) {
          if (op.data.codeUnitAt(i) == 0x0A) {
            if (span.isNotEmpty) {
              // Write the span if it's not empty.
              _handleSpan(span.toString(), op.attributes);
            }
            // Close any open inline styles.
            _handleSpan('', null);
            _handleLine(op.attributes);
            span.clear();
          } else {
            span.writeCharCode(op.data.codeUnitAt(i));
          }
        }
        // Remaining span
        if (span.isNotEmpty) {
          _handleSpan(span.toString(), op.attributes);
        }
      }
    }
    _handleBlock(currentBlockStyle); // Close the last block
    return buffer.toString().replaceAll("\n", "<br>");
  }

  String _writeLine(String text, NotusStyle style) {
    var buffer = StringBuffer();
    // Open heading
    if (style.contains(NotusAttribute.heading)) {
      _writeAttribute(buffer, style.get<int>(NotusAttribute.heading));
    }
    // Write the text itself
    buffer.write(text);
    // Close the heading
    if (style.contains(NotusAttribute.heading)) {
      _writeAttribute(buffer, style.get<int>(NotusAttribute.heading),
          close: true);
    }
    return buffer.toString();
  }

  String _trimRight(StringBuffer buffer) {
    var text = buffer.toString();
    if (!text.endsWith(' ')) return '';
    final result = text.trimRight();
    buffer.clear();
    buffer.write(result);
    return ' ' * (text.length - result.length);
  }

  NotusStyle _writeInline(StringBuffer buffer, String text, NotusStyle style,
      NotusStyle currentStyle) {
    NotusAttribute wasA;
    // First close any current styles if needed
    for (var value in currentStyle.values) {
      if (value.scope == NotusAttributeScope.line) continue;
      if (value.key == "a") {
        wasA = value;
        continue;
      }
      if (style.containsSame(value)) continue;
      final padding = _trimRight(buffer);
      _writeAttribute(buffer, value, close: true);
      if (padding.isNotEmpty) buffer.write(padding);
    }
    if (wasA != null) {
      _writeAttribute(buffer, wasA, close: true);
    }
    // Now open any new styles.
    for (var value in style.values) {
      if (value.scope == NotusAttributeScope.line) continue;
      if (currentStyle.containsSame(value)) continue;
      final originalText = text;
      text = text.trimLeft();
      final padding = ' ' * (originalText.length - text.length);
      if (padding.isNotEmpty) buffer.write(padding);
      _writeAttribute(buffer, value);
    }
    // Write the text itself
    buffer.write(text);
    return style;
  }

  void _writeAttribute(StringBuffer buffer, NotusAttribute attribute,
      {bool close = false}) {
    if (attribute == NotusAttribute.bold) {
      _writeBoldTag(buffer, close: close);
    } else if (attribute == NotusAttribute.italic) {
      _writeItalicTag(buffer, close: close);
    } else if (attribute.key == NotusAttribute.link.key) {
      _writeLinkTag(buffer, attribute as NotusAttribute<String>, close: close);
    } else if (attribute.key == NotusAttribute.heading.key) {
      _writeHeadingTag(buffer, attribute as NotusAttribute<int>, close: close);
    } else if (attribute.key == NotusAttribute.block.key) {
      _writeBlockTag(buffer, attribute as NotusAttribute<String>, close: close);
    } else if (attribute.key == NotusAttribute.embed.key) {
      _writeEmbedTag(buffer, attribute as EmbedAttribute, close: close);
    } else {
      throw ArgumentError('Cannot handle $attribute');
    }
  }

  void _writeBoldTag(StringBuffer buffer, {bool close = false}) {
    buffer.write(!close ? "<$kBold>" : "</$kBold>");
  }

  void _writeItalicTag(StringBuffer buffer, {bool close = false}) {
    buffer.write(!close ? "<$kItalic>" : "</$kItalic>");
  }

  void _writeLinkTag(StringBuffer buffer, NotusAttribute<String> link,
      {bool close = false}) {
    if (close) {
      buffer.write('</a>');
    } else {
      buffer.write('<a href="${link.value}">');
    }
  }

  void _writeHeadingTag(StringBuffer buffer, NotusAttribute<int> heading,
      {bool close = false}) {
    var level = heading.value;
    buffer.write(!close ? "<h$level>" : "</h$level>");
  }

  void _writeBlockTag(StringBuffer buffer, NotusAttribute<String> block,
      {bool close = false}) {
    if (block == NotusAttribute.code) {
      if (!close) {
        buffer.write('\n<code>');
      } else {
        buffer.write('</code>\n');
      }
    } else {
      if (!close) {
        buffer.write('<${kSimpleBlocks[block]}>');
      } else {
        buffer.write('</${kSimpleBlocks[block]}>');
      }
    }
  }

  void _writeEmbedTag(StringBuffer buffer, EmbedAttribute embed,
      {bool close = false}) {
    if (close) return;
    if (embed.type == EmbedType.horizontalRule) {
      buffer.write("<hr>");
    } else if (embed.type == EmbedType.image) {
      buffer.write('<img src="${embed.value["source"]}">');
    }
  }
}

class _NotusHtmlDecoder extends Converter<String, Delta> {
  @override
  Delta convert(String input) {
    Delta delta = Delta();
    Document html = parse(input);

    html.body.nodes.asMap().forEach((index, node) {
      var next;
      if (index + 1 < html.body.nodes.length) next = html.body.nodes[index + 1];
      delta = _parseNode(node, delta, next);
    });

    return delta;
  }

  Delta _parseNode(node, Delta delta, next, {inList, inBlock}) {
    if (node.runtimeType == Element) {
      Element element = node;
      if (element.localName == "ul") {
        element.children.forEach((child) {
          delta = _parseElement(
              child, delta, _supportedElements[child.localName],
              listType: "ul", next: next, inList: inList, inBlock: inBlock);
          return delta;
        });
      }
      if (element.localName == "ol") {
        element.children.forEach((child) {
          delta = _parseElement(
              child, delta, _supportedElements[child.localName],
              listType: "ol", next: next, inList: inList, inBlock: inBlock);
          return delta;
        });
      }
      if (_supportedElements[element.localName] == null) {
        return delta;
      }
      delta =
          _parseElement(element, delta, _supportedElements[element.localName], next: next, inList: inList, inBlock: inBlock);
      return delta;
    } else {
      Text text = node;
      if (next != null &&
          next.runtimeType == Element &&
          next.localName == "br") {
        delta..insert(text.text + "\n");
      } else {
        delta..insert(text.text);
      }
      return delta;
    }
  }

  Delta _parseElement(Element element, Delta delta, String type,
      {Map<String, dynamic> attributes, String listType, next, inList, inBlock}) {
    if (type == "block") {
      Map<String, dynamic> blockAttributes = {};
      if (inBlock != null) blockAttributes = inBlock;
      if (element.localName == "h1") {
        blockAttributes["heading"] = 1;
      }
      if (element.localName == "h2") {
        blockAttributes["heading"] = 2;
      }
      if (element.localName == "h3") {
        blockAttributes["heading"] = 3;
      }
      if (element.localName == "blockquote") {
        blockAttributes["block"] = "quote";
      }
      if (element.localName == "code") {
        blockAttributes["block"] = "code";
      }
      if (element.localName == "li") {
        blockAttributes["block"] = listType;
      }
      element.nodes.asMap().forEach((index, node) {
        var next;
        if (index + 1 < element.nodes.length) next = element.nodes[index + 1];
        delta = _parseNode(node, delta, next, inList: element.localName == "li", inBlock: blockAttributes);
      });
      if (inBlock == null) {
        delta..insert("\n", blockAttributes);
      }
      return delta;
    } else if (type == "embed") {
      Map<String, dynamic> embedAttributes = {};
      if (element.localName == "img") {
        embedAttributes["embed"] = {
          "type": "image",
          "source": element.attributes["src"],
        };
      }
      if (element.localName == "hr") {
        embedAttributes["embed"] = {
          "type": "hr",
        };
      }
      List json = jsonDecode(jsonEncode(delta.toJson()));
      json.add({"insert": "", "attributes": embedAttributes});
      delta = Delta.fromJson(json);
      delta..insert("\n");
      return delta;
    } else {
      if (attributes == null) attributes = {};
      if (element.localName == "em") {
        attributes["i"] = true;
      }
      if (element.localName == "strong") {
        attributes["b"] = true;
      }
      if (element.localName == "a") {
        attributes["a"] = element.attributes["href"];
      }
      if (element.children.isEmpty) {
        if (attributes["a"] != null) {
          delta..insert(element.text, attributes);
          if (inList == null || (inList != null && !inList)) delta..insert("\n");
        } else {
          if (next != null &&
              next.runtimeType == Element &&
              next.localName == "br") {
            delta..insert(element.text + "\n", attributes);
          } else {
            delta..insert(element.text, attributes);
          }
        }
      } else {
        element.children.forEach((element) {
          if (_supportedElements[element.localName] == null) {
            return;
          }
          delta = _parseElement(
              element, delta, _supportedElements[element.localName],
              attributes: attributes, next: next);
        });
      }
      return delta;
    }
  }

  Map<String, String> _supportedElements = {
    "li": "block",
    "blockquote": "block",
    "code": "block",
    "h1": "block",
    "h2": "block",
    "h3": "block",
    "div": "block",
    "em": "inline",
    "strong": "inline",
    "a": "inline",
    "p": "inline",
    "img": "embed",
    "hr": "embed",
  };
}
