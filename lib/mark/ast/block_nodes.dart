part of 'node.dart';

abstract class BaseBlock extends BaseNode {}

class LineBreak extends BaseBlock {
  LineBreak();
  @override
  NodeType getType() {
    return NodeType.LINE_BREAK;
  }

  @override
  String toString() {
    return "\n";
  }

  factory LineBreak.fromJson(Map<String, dynamic> json) {
    return LineBreak();
  }
}

class Paragraph extends BaseBlock {
  final List<BaseNode> children;
  Paragraph(this.children);
  @override
  NodeType getType() {
    return NodeType.PARAGRAPH;
  }

  @override
  String toString() {
    return children.join("");
  }

  factory Paragraph.fromJson(Map<String, dynamic> json) {
    return Paragraph(
      (json['children'] as List).map((i) => BaseNode.fromJson(i)).toList(),
    );
  }
}

class CodeBlock extends BaseBlock {
  final String content;
  final String language;
  CodeBlock(this.content, this.language);
  @override
  NodeType getType() {
    return NodeType.CODE_BLOCK;
  }

  @override
  String toString() {
    return "```$language\n$content\n```";
  }

  factory CodeBlock.fromJson(Map<String, dynamic> json) {
    return CodeBlock(json['content'], json['language']);
  }
}

class Heading extends BaseBlock {
  final int level;
  final List<BaseNode> children;
  Heading(this.level, this.children);
  @override
  NodeType getType() {
    return NodeType.HEADING;
  }

  @override
  String toString() {
    return "#" * level + " " + children.join("");
  }

  factory Heading.fromJson(Map<String, dynamic> json) {
    return Heading(
      json['level'],
      (json['children'] as List).map((i) => BaseNode.fromJson(i)).toList(),
    );
  }
}

class HorizontalRule extends BaseBlock {
  final String symbol;
  HorizontalRule(this.symbol);
  @override
  NodeType getType() {
    return NodeType.HORIZONTAL_RULE;
  }

  @override
  String toString() {
    return symbol * 3;
  }

  factory HorizontalRule.fromJson(Map<String, dynamic> json) {
    return HorizontalRule(json['symbol']);
  }
}

class Blockquote extends BaseBlock {
  final List<BaseNode> children;
  Blockquote(this.children);
  @override
  NodeType getType() {
    return NodeType.BLOCKQUOTE;
  }

  @override
  String toString() {
    var buff = StringBuffer();
    children.forEachIndexed((index, element) {
      buff.write("> $element");
      if (index != children.length - 1) {
        buff.write("\n");
      }
    });
    return buff.toString();
  }

  factory Blockquote.fromJson(Map<String, dynamic> json) {
    return Blockquote(
      (json['children'] as List).map((i) => BaseNode.fromJson(i)).toList(),
    );
  }
}

typedef ListKind = String;
const ListKind UNORDERED_LIST = "ul";
const ListKind ORDERED_LIST = "ol";
const ListKind DESCRPITION_LIST = "dl";

class ListBlock extends BaseBlock {
  final List<BaseNode> children;
  final ListKind kind;
  int indent;

  ListBlock(this.children, this.kind, {this.indent = 0});

  @override
  NodeType getType() {
    return NodeType.LIST;
  }

  @override
  String toString() {
    return children.join("");
  }

  factory ListBlock.fromJson(Map<String, dynamic> json) {
    return ListBlock(
      (json['children'] as List).map((i) => BaseNode.fromJson(i)).toList(),
      json['kind'],
      indent: json['indent'],
    );
  }
}

class OrderedListItem extends BaseBlock {
  final List<BaseNode> children;
  final String number;
  final int indent;
  OrderedListItem(this.children, this.number, {this.indent = 0});
  @override
  NodeType getType() {
    return NodeType.ORDERED_LIST_ITEM;
  }

  @override
  String toString() {
    final indentSpace = " " * indent;
    return "$indentSpace$number. ${children.join('')}";
  }

  factory OrderedListItem.fromJson(Map<String, dynamic> json) {
    return OrderedListItem(
      (json['children'] as List).map((i) => BaseNode.fromJson(i)).toList(),
      json['number'],
      indent: json['indent'],
    );
  }
}

class UnorderedListItem extends BaseBlock {
  final List<BaseNode> children;
  final String symbol;
  final int indent;
  UnorderedListItem(this.children, this.symbol, {this.indent = 0});
  @override
  NodeType getType() {
    return NodeType.UNORDERED_LIST_ITEM;
  }

  @override
  String toString() {
    final indentSpace = " " * indent;
    return "$indentSpace$symbol ${children.join('')}";
  }

  factory UnorderedListItem.fromJson(Map<String, dynamic> json) {
    return UnorderedListItem(
      (json['children'] as List).map((i) => BaseNode.fromJson(i)).toList(),
      json['symbol'],
      indent: json['indent'],
    );
  }
}

class TaskListItem extends BaseBlock {
  final List<BaseNode> children;
  final String symbol;
  final int indent;
  bool complete;
  TaskListItem(this.children, this.symbol, this.complete, {this.indent = 0});
  @override
  NodeType getType() {
    return NodeType.TASK_LIST_ITEM;
  }

  @override
  String toString() {
    final indentSpaces = ' ' * indent;
    return "$indentSpaces$symbol ${complete ? '[x]' : '[ ]'} ${children.join('')}";
  }

  factory TaskListItem.fromJson(Map<String, dynamic> json) {
    return TaskListItem(
      (json['children'] as List).map((i) => BaseNode.fromJson(i)).toList(),
      json['symbol'],
      json['complete'],
      indent: json['indent'],
    );
  }
}

class MathBlock extends BaseBlock {
  final String content;
  MathBlock(this.content);
  @override
  NodeType getType() {
    return NodeType.MATH_BLOCK;
  }

  @override
  String toString() {
    return "\$\$\n$content\n\$\$";
  }

  factory MathBlock.fromJson(Map<String, dynamic> json) {
    return MathBlock(json['content']);
  }
}

class TableBlock extends BaseBlock {
  final List<BaseNode> header;
  final List<List<BaseNode>> rows;
  final List<String> delimiter;
  TableBlock(this.header, this.rows, this.delimiter);
  @override
  NodeType getType() {
    return NodeType.TABLE;
  }

  @override
  String toString() {
    var buff = StringBuffer();
    buff.write("| ${header.join(" | ")} |\n");
    buff.write("| ${delimiter.join(" | ")} |\n");
    rows.forEach((row) {
      buff.write("| ${row.join(" | ")} |\n");
    });
    return buff.toString();
  }

  factory TableBlock.fromJson(Map<String, dynamic> json) {
    return TableBlock(
      (json['header'] as List).map((i) => BaseNode.fromJson(i)).toList(),
      (json['rows'] as List).map((i) {
        return ((i as Map<String, dynamic>)['cells'] as List)
            .map((j) => BaseNode.fromJson(j))
            .toList();
      }).toList(),
      (json['delimiter'] as List).map((i) => i as String).toList(),
    );
  }
}

class EmbeddedContent extends BaseBlock {
  final String resourceName;
  final String? params;
  EmbeddedContent(this.resourceName, this.params);
  @override
  NodeType getType() {
    return NodeType.EMBEDDED_CONTENT;
  }

  @override
  String toString() {
    var p = params ?? "";
    if (p.isNotEmpty) {
      p = "?$p";
    }

    return "![[$resourceName$p]]";
  }

  factory EmbeddedContent.fromJson(Map<String, dynamic> json) {
    return EmbeddedContent(json['resourceName'], json['params']);
  }
}
