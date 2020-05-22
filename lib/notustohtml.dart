library notustohtml;

import 'dart:convert';

import 'package:notus/notus.dart';

/// Class containing all the converter methods available in this package.
class NotusConverter {
  List _list;

  /// Converts the Notus document [doc] to an HTML string.
  String getHTML(NotusDocument doc) {
    _list = jsonDecode(jsonEncode(doc));

    String html = "";

    for (int i = 0; i < _list.length; i++) {
      if (i + 1 < _list.length) {
        html += _htmlFromInsert(NotusInsert.fromJSON(_list[i]),
            NotusInsert.fromJSON(_list[i + 1]), i);
      } else {
        html += _htmlFromInsert(NotusInsert.fromJSON(_list[i]), null, i);
      }

      if (html.length-5 > 0) {
        String ending = html.substring(html.length - 5);

        if (ending == "</ul>" || ending == "</ol>") {
          _placedStarter = false;
        }
      }

      if (html.length-13 > 0) {
        String ending = html.substring(html.length - 13);

        if (ending == "</blockquote>") {
          _placedQuoteStart = false;
        }
      }
    }

    return html;
  }

  bool _prevWasHeading = false;
  bool _isHeading = false;
  bool _innerHTML = true;
  bool _isList = false;
  bool _wasList = false;
  bool _wasNumberedList = false;
  bool _isLine = false;
  bool _wasLine = false;

  bool _nextWillBeList(String type, int index) {
    if (index + 3 < _list.length) {
      NotusInsert next = NotusInsert.fromJSON(_list[index + 3]);
      if (next.attributes != null && next.attributes["block"] != null) {
        return next.attributes["block"] == type;
      }
    }

    return false;
  }

  bool _placedStarter = false;
  bool _placedQuoteStart = false;
  bool _isQuote = false;
  bool _wasQuote = false;

  String _htmlFromInsert(NotusInsert insert, NotusInsert next, int index) {
    String el = _getEl(insert, next);
    String endingEl = _endingEl(insert, el);
    String first = _styleEl(insert)["first"];
    String last = _styleEl(insert)["last"];

    if (next != null && RegExp("^\n\$").hasMatch(next.insert)) {
      if (next != null &&
          next.attributes != null &&
          next.attributes["heading"] != null) {
        _isHeading = true;
        first += "<h${next.attributes["heading"]}>";
        last = "</h${next.attributes["heading"]}>" + last;
      }
    }

    if (insert.attributes != null && insert.attributes["a"] != null) {
      first += "<a href=\"${insert.attributes["a"]}\">";
      last = "</a>" + last;
    }

    String text = insert.insert;
    text = text.replaceAll(RegExp("\n"), "<br/><br/>");

    if (next != null &&
        next.attributes != null &&
        next.attributes["embed"] != null) {
      if (next.attributes["embed"]["type"] == "hr") text = insert.insert;
    }

    if (_isQuote) {
      if (_placedQuoteStart) {
        el = "";
      } else {
        _placedQuoteStart = true;
      }
      endingEl = "";
    }

    if (_isList) {
      if (_placedStarter) {
        el = "";
      } else {
        _placedStarter = true;
      }
      endingEl = "";
      text = insert.insert;
      first = "<li>" + first;
      last += "</li>";
    }

    if (!_nextWillBeList("ul", index) && _wasList) {
      _wasList = false;
      endingEl = "ul";
    }

    if (!_nextWillBeList("quote", index) && _wasQuote) {
      _wasQuote = false;
      endingEl = "blockquote";
    }

    if (!_nextWillBeList("ol", index) && _wasNumberedList) {
      _wasNumberedList = false;
      endingEl = "ol";
    }

    if (_prevWasHeading) {
      _prevWasHeading = false;
      return "";
    }

    if (_wasLine) {
      _wasLine = false;
      text = text.replaceAll(RegExp("^<br\/><br\/>"), "<br/>");
    }

    if (_isLine) {
      _isLine = false;
      _wasLine = true;
    }

    if (_isHeading) {
      _prevWasHeading = true;
      _isHeading = false;
      return "${(el != "" ? "<$el>" : "")}$first$text<br/>$last${(endingEl != "") ? "</$endingEl>" : ""}";
    }

    if (!_innerHTML) {
      _innerHTML = true;
      return "${(el != "" ? "<$el>" : "")}";
    }

    return "${(el != "" ? "<$el>" : "")}$first$text$last${(endingEl != "") ? "</$endingEl>" : ""}";
  }

  String _getEl(NotusInsert insert, NotusInsert next) {
    _isList = false;
    _isQuote = false;

    if (next != null &&
        next.attributes != null &&
        next.attributes["block"] != null) {
      _isHeading = true;

      if (next.attributes["block"] == "ol") {
        _isList = true;
        _wasNumberedList = true;
      }

      if (next.attributes["block"] == "ul") {
        _isList = true;
        _wasList = true;
      }

      if (next.attributes["block"] == "quote") {
        _isQuote = true;
        _wasQuote = true;
      }

      return (next.attributes["block"] == "quote")
          ? "blockquote"
          : next.attributes["block"];
    }

    if (insert.attributes != null && insert.attributes["embed"] != null) {
      _innerHTML = false;
      if (insert.attributes["embed"]["type"] == "hr") {
        _isLine = true;
        return "hr";
      }

      if (insert.attributes["embed"]["type"] == "image") {
        return "img src=\"${insert.attributes["embed"]["source"]}\"";
      }
    }

    return "";
  }

  String _endingEl(NotusInsert insert, String el) {
    return el;
  }

  Map _styleEl(NotusInsert insert) {
    if (insert.attributes == null) {
      return {
        "first": "",
        "last": "",
      };
    }

    String first = "";
    String last = "";

    if (insert.attributes["b"] != null) {
      first += "<strong>";
      last += "</strong>";
    }

    if (insert.attributes["i"] != null) {
      first += "<em>";
      last = "</em>" + last;
    }

    return {
      "first": first,
      "last": last,
    };
  }
}

class NotusInsert {
  final String insert;
  final Map attributes;

  NotusInsert({this.insert, this.attributes});

  factory NotusInsert.fromJSON(Map map) {
    return NotusInsert(
      insert: map["insert"],
      attributes: map["attributes"],
    );
  }
}