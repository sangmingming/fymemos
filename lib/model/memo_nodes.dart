// ignore: constant_identifier_names
import 'package:flutter/material.dart';

enum NodeType {
  PARAGRAPH,
  TAG,
  TEXT,
  AUTO_LINK,
  LINE_BREAK,
  HORIZONTAL_RULE,
  TASK_LIST_ITEM,
  LIST,
  BOLD,
  ITALIC,
  STRIKETHROUGH,
  HEADING,
  CODE_BLOCK,
  LINK,
  EMBEDDED_CONTENT,
}

extension NodeTypeExtension on NodeType {
  static NodeType fromString(String type) {
    return NodeType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => throw Exception('Unknown node type: $type'),
    );
  }
}

class Node {
  final NodeType type;
  final dynamic node;

  Node({required this.type, required this.node});

  factory Node.fromJson(Map<String, dynamic> json) {
    NodeType type = NodeTypeExtension.fromString(json['type']);
    switch (type) {
      case NodeType.PARAGRAPH:
        return Node(
          type: type,
          node: ParagraphNode.fromJson(json['paragraphNode']),
        );
      case NodeType.LIST:
        return Node(type: type, node: ListNode.fromJson(json['listNode']));
      case NodeType.TAG:
        return Node(type: type, node: TagNode.fromJson(json['tagNode']));
      case NodeType.TEXT:
        return Node(type: type, node: TextNode.fromJson(json['textNode']));
      case NodeType.AUTO_LINK:
        return Node(
          type: type,
          node: AutoLinkNode.fromJson(json['autoLinkNode']),
        );
      case NodeType.LINE_BREAK:
        return Node(
          type: type,
          node: LineBreakNode.fromJson(json['lineBreakNode']),
        );
      case NodeType.HORIZONTAL_RULE:
        return Node(
          type: type,
          node: HorizontalRuleNode.fromJson(json['horizontalRuleNode']),
        );
      case NodeType.TASK_LIST_ITEM:
        return Node(
          type: type,
          node: TaskListItemNode.fromJson(json['taskListItemNode']),
        );
      case NodeType.BOLD:
        return Node(type: type, node: BoldNode.fromJson(json['boldNode']));
      case NodeType.ITALIC:
        return Node(type: type, node: ItalicNode.fromJson(json['italicNode']));
      case NodeType.STRIKETHROUGH:
        return Node(
          type: type,
          node: StrikethroughNode.fromJson(json['strikethroughNode']),
        );
      case NodeType.HEADING:
        return Node(
          type: type,
          node: HeadingNode.fromJson(json['headingNode']),
        );
      case NodeType.CODE_BLOCK:
        return Node(
          type: type,
          node: CodeBlockNode.fromJson(json['codeBlockNode']),
        );
      case NodeType.LINK:
        return Node(type: type, node: LinkNode.fromJson(json['linkNode']));
      case NodeType.EMBEDDED_CONTENT:
        return Node(
          type: type,
          node: EmbeddedContentNode.fromJson(json['embeddedContentNode']),
        );
      default:
        throw Exception('Unknown node type');
    }
  }
}

class LinkNode {
  final String url;
  final String text;

  LinkNode({required this.url, required this.text});

  factory LinkNode.fromJson(Map<String, dynamic> json) {
    return LinkNode(url: json['url'], text: json['text']);
  }
}

class EmbeddedContentNode {
  final String resourceName;
  final String params;

  EmbeddedContentNode({required this.resourceName, required this.params});

  factory EmbeddedContentNode.fromJson(Map<String, dynamic> json) {
    return EmbeddedContentNode(
      resourceName: json['resourceName'],
      params: json['params'],
    );
  }
}

class HeadingNode {
  final int level;
  final List<Node> children;

  HeadingNode({required this.level, required this.children});

  factory HeadingNode.fromJson(Map<String, dynamic> json) {
    return HeadingNode(
      level: json['level'],
      children:
          (json['children'] as List).map((i) => Node.fromJson(i)).toList(),
    );
  }
}

class CodeBlockNode {
  final String language;
  final String content;

  CodeBlockNode({required this.language, required this.content});

  factory CodeBlockNode.fromJson(Map<String, dynamic> json) {
    return CodeBlockNode(language: json['language'], content: json['content']);
  }
}

class ParagraphNode {
  final List<Node> children;

  ParagraphNode({required this.children});

  factory ParagraphNode.fromJson(Map<String, dynamic> json) {
    return ParagraphNode(
      children:
          (json['children'] as List).map((i) => Node.fromJson(i)).toList(),
    );
  }
}

class ListNode {
  final String kind;
  final int indent;
  final List<Node> children;

  ListNode({required this.kind, required this.indent, required this.children});

  factory ListNode.fromJson(Map<String, dynamic> json) {
    return ListNode(
      kind: json['kind'],
      indent: json['indent'],
      children:
          (json['children'] as List).map((i) => Node.fromJson(i)).toList(),
    );
  }
}

class TagNode extends BaseTextNode {
  TagNode({required super.content});

  factory TagNode.fromJson(Map<String, dynamic> json) {
    return TagNode(content: json['content']);
  }
}

class TextNode extends BaseTextNode {
  TextNode({required super.content});

  factory TextNode.fromJson(Map<String, dynamic> json) {
    return TextNode(content: json['content']);
  }
}

class ItalicNode extends BaseTextNode {
  ItalicNode({required super.content});

  factory ItalicNode.fromJson(Map<String, dynamic> json) {
    return ItalicNode(content: json['content']);
  }
}

class BoldNode extends BaseTextNode {
  BoldNode({required super.content});

  factory BoldNode.fromJson(Map<String, dynamic> json) {
    return BoldNode(content: json['content']);
  }
}

class StrikethroughNode extends BaseTextNode {
  StrikethroughNode({required super.content});

  factory StrikethroughNode.fromJson(Map<String, dynamic> json) {
    return StrikethroughNode(content: json['content']);
  }
}

class BaseTextNode {
  final String content;

  BaseTextNode({required this.content});
}

class AutoLinkNode {
  final String url;
  final bool isRawText;

  AutoLinkNode({required this.url, required this.isRawText});

  factory AutoLinkNode.fromJson(Map<String, dynamic> json) {
    return AutoLinkNode(url: json['url'], isRawText: json['isRawText']);
  }
}

class LineBreakNode {
  LineBreakNode();

  factory LineBreakNode.fromJson(Map<String, dynamic> json) {
    return LineBreakNode();
  }
}

class HorizontalRuleNode {
  final String symbol;

  HorizontalRuleNode({required this.symbol});

  factory HorizontalRuleNode.fromJson(Map<String, dynamic> json) {
    return HorizontalRuleNode(symbol: json['symbol']);
  }
}

class TaskListItemNode {
  final String symbol;
  final int indent;
  final bool complete;
  final List<Node> children;

  TaskListItemNode({
    required this.symbol,
    required this.indent,
    required this.complete,
    required this.children,
  });

  factory TaskListItemNode.fromJson(Map<String, dynamic> json) {
    return TaskListItemNode(
      symbol: json['symbol'],
      indent: json['indent'],
      complete: json['complete'],
      children:
          (json['children'] as List).map((i) => Node.fromJson(i)).toList(),
    );
  }
}
