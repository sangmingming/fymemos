import 'package:collection/collection.dart';

part 'block_nodes.dart';
part 'inline_nodes.dart';

enum NodeType {
  //Block nodes
  PARAGRAPH,
  LINE_BREAK,
  BLOCKQUOTE,
  MATH_BLOCK,
  TABLE,
  HEADING,
  CODE_BLOCK,
  HORIZONTAL_RULE,
  TASK_LIST_ITEM,
  EMBEDDED_CONTENT,
  LIST,
  UNORDERED_LIST_ITEM,
  ORDERED_LIST_ITEM,

  //Inline nodes
  TAG,
  TEXT,
  AUTO_LINK,
  BOLD,
  ITALIC,
  BOLD_ITALIC,
  STRIKETHROUGH,
  SPOILER,
  LINK,
  IMAGE,
  CODE,
  HIGHLIGHT,
  ESCAPING_CHARACTER,
  MATH,
  SUBSCRIPT,
  SUPERSCRIPT,
  REFERENCED_CONTENT,
  HTML_ELEMENT,
}

abstract class BaseNode {
  NodeType getType();

  static BaseNode fromJson(Map<String, dynamic> json) {
    NodeType type = NodeExtension.fromString(json['type']);
    switch (type) {
      case NodeType.PARAGRAPH:
        return Paragraph.fromJson(json['paragraphNode']);
      case NodeType.LIST:
        return ListBlock.fromJson(json['listNode']);
      case NodeType.TAG:
        return Tag.fromJson(json['tagNode']);
      case NodeType.TEXT:
        return TextNode.fromJson(json['textNode']);
      case NodeType.AUTO_LINK:
        return AutoLink.fromJson(json['autoLinkNode']);
      case NodeType.LINE_BREAK:
        return LineBreak.fromJson(json['lineBreakNode']);
      case NodeType.HORIZONTAL_RULE:
        return HorizontalRule.fromJson(json['horizontalRuleNode']);
      case NodeType.TASK_LIST_ITEM:
        return TaskListItem.fromJson(json['taskListItemNode']);
      case NodeType.SPOILER:
        return Spoiler.fromJson(json['spoilerNode']);
      case NodeType.UNORDERED_LIST_ITEM:
        return UnorderedListItem.fromJson(json['unorderedListItemNode']);
      case NodeType.BOLD:
        return BoldNode.fromJson(json['boldNode']);
      case NodeType.ITALIC:
        return ItalicNode.fromJson(json['italicNode']);
      case NodeType.STRIKETHROUGH:
        return Strikethrough.fromJson(json['strikethroughNode']);
      case NodeType.HEADING:
        return Heading.fromJson(json['headingNode']);
      case NodeType.CODE_BLOCK:
        return CodeBlock.fromJson(json['codeBlockNode']);
      case NodeType.LINK:
        return LinkNode.fromJson(json['linkNode']);
      case NodeType.EMBEDDED_CONTENT:
        return EmbeddedContent.fromJson(json['embeddedContentNode']);
      case NodeType.IMAGE:
        return ImageNode.fromJson(json['imageNode']);
      case NodeType.CODE:
        return InlineCodeNode.fromJson(json['codeNode']);
      case NodeType.ORDERED_LIST_ITEM:
        return OrderedListItem.fromJson(json['orderedListItemNode']);
      case NodeType.HIGHLIGHT:
        return Highlight.fromJson(json['highlightNode']);
      case NodeType.BLOCKQUOTE:
        return Blockquote.fromJson(json['blockquoteNode']);
      case NodeType.MATH_BLOCK:
        return MathBlock.fromJson(json['mathBlockNode']);
      case NodeType.ESCAPING_CHARACTER:
        return EscapingCharacter.fromJson(json['escapingCharacterNode']);
      case NodeType.MATH:
        return MathInline.fromJson(json['mathNode']);
      case NodeType.SUBSCRIPT:
        return Subscript.fromJson(json['subscriptNode']);
      case NodeType.SUPERSCRIPT:
        return Superscript.fromJson(json['superscriptNode']);
      case NodeType.REFERENCED_CONTENT:
        return ReferencedContent.fromJson(json['referencedContentNode']);
      case NodeType.TABLE:
        return TableBlock.fromJson(json['tableNode']);
      default:
        throw Exception('Unknown node type: $type');
    }
  }

  bool isBlockNode() {
    return getType() == NodeType.BLOCKQUOTE ||
        getType() == NodeType.CODE_BLOCK ||
        getType() == NodeType.EMBEDDED_CONTENT ||
        getType() == NodeType.HEADING ||
        getType() == NodeType.HORIZONTAL_RULE ||
        getType() == NodeType.LINE_BREAK ||
        getType() == NodeType.LIST ||
        getType() == NodeType.MATH_BLOCK ||
        getType() == NodeType.PARAGRAPH ||
        getType() == NodeType.TABLE ||
        getType() == NodeType.TASK_LIST_ITEM ||
        getType() == NodeType.UNORDERED_LIST_ITEM ||
        getType() == NodeType.ORDERED_LIST_ITEM;
  }
}

extension NodeExtension on NodeType {
  static NodeType fromString(String type) {
    return NodeType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => throw Exception('Unknown node type: $type'),
    );
  }
}

extension NodeTypeExtension on BaseNode {
  bool get isListItemNode {
    return getType() == NodeType.ORDERED_LIST_ITEM ||
        getType() == NodeType.UNORDERED_LIST_ITEM ||
        getType() == NodeType.TASK_LIST_ITEM;
  }

  (ListKind, int) get listItemKindAndIndent {
    if (this is OrderedListItem) {
      return (ORDERED_LIST, (this as OrderedListItem).indent);
    } else if (this is UnorderedListItem) {
      return (UNORDERED_LIST, (this as UnorderedListItem).indent);
    } else if (this is TaskListItem) {
      return (DESCRPITION_LIST, (this as TaskListItem).indent);
    } else {
      return ("", 0);
    }
  }
}
