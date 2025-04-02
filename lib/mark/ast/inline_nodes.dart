part of 'node.dart';

abstract class BaseInlineNode extends BaseNode {}

class TextNode extends BaseInlineNode {
  final String content;
  TextNode(this.content);
  @override
  NodeType getType() {
    return NodeType.TEXT;
  }

  @override
  String toString() {
    return content;
  }

  factory TextNode.fromJson(Map<String, dynamic> json) {
    return TextNode(json['content']);
  }

  TextNode copyWith({String? content}) {
    return TextNode(content ?? this.content);
  }
}

class BoldNode extends BaseInlineNode {
  final List<BaseNode> children;
  final String symbol;
  BoldNode(this.children, {this.symbol = "*"});
  @override
  NodeType getType() {
    return NodeType.BOLD;
  }

  @override
  String toString() {
    return "${symbol * 2}${children.join("")}${symbol * 2}";
  }

  factory BoldNode.fromJson(Map<String, dynamic> json) {
    return BoldNode(
      (json['children'] as List).map((i) => BaseNode.fromJson(i)).toList(),
    );
  }
}

class ItalicNode extends BaseInlineNode {
  final List<BaseNode> children;
  final String symbol;
  ItalicNode(this.children, {this.symbol = "*"});
  @override
  NodeType getType() {
    return NodeType.ITALIC;
  }

  @override
  String toString() {
    return "$symbol${children.join("")}$symbol";
  }

  factory ItalicNode.fromJson(Map<String, dynamic> json) {
    //server return a string instead of a list of children
    return ItalicNode([TextNode(json['content'])], symbol: json['symbol']);
  }
}

class BoldItalicNode extends BaseInlineNode {
  final String content;
  final String symbol;
  BoldItalicNode(this.content, {this.symbol = "*"});
  @override
  NodeType getType() {
    return NodeType.BOLD_ITALIC;
  }

  @override
  String toString() {
    return "${symbol * 3}${content}${symbol * 3}";
  }
}

class InlineCodeNode extends BaseInlineNode {
  final String content;
  InlineCodeNode(this.content);
  @override
  NodeType getType() {
    return NodeType.CODE;
  }

  @override
  String toString() {
    return "`$content`";
  }

  factory InlineCodeNode.fromJson(Map<String, dynamic> json) {
    return InlineCodeNode(json['content']);
  }
}

class ImageNode extends BaseInlineNode {
  final String url;
  final String alt;

  ImageNode(this.url, this.alt);
  @override
  NodeType getType() {
    return NodeType.IMAGE;
  }

  @override
  String toString() {
    return "![$alt]($url)";
  }

  factory ImageNode.fromJson(Map<String, dynamic> json) {
    return ImageNode(json['url'], json['altText']);
  }
}

class LinkNode extends BaseInlineNode {
  final String url;
  final List<BaseNode> content;

  LinkNode(this.url, this.content);
  @override
  NodeType getType() {
    return NodeType.LINK;
  }

  @override
  String toString() {
    return "[${content.join("")}]($url)";
  }

  factory LinkNode.fromJson(Map<String, dynamic> json) {
    return LinkNode(
      json['url'],
      (json['content'] as List).map((i) => BaseNode.fromJson(i)).toList(),
    );
  }
}

class AutoLink extends BaseInlineNode {
  final String url;
  bool isRawText;
  AutoLink(this.url, this.isRawText);
  @override
  NodeType getType() {
    return NodeType.AUTO_LINK;
  }

  @override
  String toString() {
    return isRawText ? url : "<$url>";
  }

  factory AutoLink.fromJson(Map<String, dynamic> json) {
    return AutoLink(json['url'], json['isRawText']);
  }
}

class Tag extends BaseInlineNode {
  final String tag;
  Tag(this.tag);

  @override
  NodeType getType() {
    return NodeType.TAG;
  }

  @override
  String toString() {
    return "#$tag";
  }

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(json['content']);
  }
}

class Strikethrough extends BaseInlineNode {
  final String content;
  Strikethrough(this.content);

  @override
  NodeType getType() {
    return NodeType.STRIKETHROUGH;
  }

  @override
  String toString() {
    return "~~$content~~";
  }

  factory Strikethrough.fromJson(Map<String, dynamic> json) {
    return Strikethrough(json['content']);
  }
}

class EscapingCharacter extends BaseInlineNode {
  final String symbol;
  EscapingCharacter(this.symbol);
  @override
  NodeType getType() {
    return NodeType.ESCAPING_CHARACTER;
  }

  @override
  String toString() {
    return "\\$symbol";
  }

  factory EscapingCharacter.fromJson(Map<String, dynamic> json) {
    return EscapingCharacter(json['content']);
  }
}

class MathInline extends BaseInlineNode {
  final String content;
  MathInline(this.content);
  @override
  NodeType getType() {
    return NodeType.MATH;
  }

  @override
  String toString() {
    return "\$${content}\$";
  }

  factory MathInline.fromJson(Map<String, dynamic> json) {
    return MathInline(json['content']);
  }
}

class Highlight extends BaseInlineNode {
  final String content;
  Highlight(this.content);
  @override
  NodeType getType() {
    return NodeType.HIGHLIGHT;
  }

  @override
  String toString() {
    return "==$content==";
  }

  factory Highlight.fromJson(Map<String, dynamic> json) {
    return Highlight(json['content']);
  }
}

class Subscript extends BaseInlineNode {
  final String content;
  Subscript(this.content);
  @override
  NodeType getType() {
    return NodeType.SUBSCRIPT;
  }

  @override
  String toString() {
    return "~$content~";
  }

  factory Subscript.fromJson(Map<String, dynamic> json) {
    return Subscript(json['content']);
  }
}

class Superscript extends BaseInlineNode {
  final String content;
  Superscript(this.content);
  @override
  NodeType getType() {
    return NodeType.SUPERSCRIPT;
  }

  @override
  String toString() {
    return "^$content^";
  }

  factory Superscript.fromJson(Map<String, dynamic> json) {
    return Superscript(json['content']);
  }
}

class ReferencedContent extends BaseInlineNode {
  final String resourceName;
  final String? params;
  ReferencedContent(this.resourceName, this.params);
  @override
  NodeType getType() {
    return NodeType.REFERENCED_CONTENT;
  }

  @override
  String toString() {
    String p = params ?? "";
    if (p != "") {
      p = "?$p";
    }
    return "[[$resourceName$p]]";
  }

  factory ReferencedContent.fromJson(Map<String, dynamic> json) {
    return ReferencedContent(json['resourceName'], json['params']);
  }
}

class Spoiler extends BaseInlineNode {
  final String content;
  Spoiler(this.content);
  @override
  NodeType getType() {
    return NodeType.SPOILER;
  }

  @override
  String toString() {
    return "||$content||";
  }

  factory Spoiler.fromJson(Map<String, dynamic> json) {
    return Spoiler(json['content']);
  }
}

class HTMLElement extends BaseInlineNode {
  final String tagName;
  final Map<String, String> attributes;
  HTMLElement(this.tagName, this.attributes);

  @override
  NodeType getType() {
    return NodeType.HTML_ELEMENT;
  }

  @override
  String toString() {
    String attrs = attributes.entries
        .map((e) => "${e.key}=\"${e.value}\"")
        .join(" ");
    if (attrs != "") {
      attrs = " $attrs";
    }
    return "<$tagName$attrs>";
  }
}
