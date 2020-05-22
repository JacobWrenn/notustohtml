library notustohtml;

import 'dart:convert';

import 'package:notus/notus.dart';
import 'package:notustohtml/models/notusinsert.dart';

class NotusConverter {

  String getHTML(NotusDocument doc) {
    final List list = jsonDecode(jsonEncode(doc));

    String html = "";

    for (int i = 0; i < list.length; i++) {
      if (i+1 < list.length) {
        html += _htmlFromInsert(NotusInsert.fromJSON(list[i]), NotusInsert.fromJSON(list[i+1]));
      } else {
        html += _htmlFromInsert(NotusInsert.fromJSON(list[i]), null);
      }
    }

    return html;
  }

  bool _prevWasHeading = false;
  bool _isHeading = false;

  String _htmlFromInsert(NotusInsert insert, NotusInsert next) {
    String el = _getEl(insert, next);

    String text = insert.insert;
    text = text.replaceAll(RegExp("\n"), "<br/><br/>");

    String first = _styleEl(insert)["first"];
    String last = _styleEl(insert)["last"];

    if (_prevWasHeading) {
      _prevWasHeading = false;
      return "";
    }

    if (_isHeading) {
      _prevWasHeading = true;
      _isHeading = false;
      return "${(el != "" ? "<$el>" : "")}$first$text<br/>$last${(_endingEl(insert) && el != "") ? "</$el>" : ""}";
    }

    return "${(el != "" ? "<$el>" : "")}$first$text$last${(_endingEl(insert) && el != "") ? "</$el>" : ""}";
  }

  String _getEl(NotusInsert insert, NotusInsert next) {
    if (next == null) {
      return "";
    }

    if (RegExp("^\n\$").hasMatch(next.insert)) {
      if (next.attributes != null && next.attributes["heading"] != null) {
        _isHeading = true;
        return "h${next.attributes["heading"]}";
      }
    }

    return "";
  }

  bool _endingEl(NotusInsert insert) {
    return true;
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
