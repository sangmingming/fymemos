import 'package:fymemos/mark/ast/node.dart';
import 'package:fymemos/mark/parser/auto_link.dart';
import 'package:fymemos/mark/parser/base_parser.dart';
import 'package:fymemos/mark/parser/blockquote.dart';
import 'package:fymemos/mark/parser/bold.dart';
import 'package:fymemos/mark/parser/bold_italic.dart';
import 'package:fymemos/mark/parser/code.dart';
import 'package:fymemos/mark/parser/code_block.dart';
import 'package:fymemos/mark/parser/embedded_content.dart';
import 'package:fymemos/mark/parser/escaping_character.dart';
import 'package:fymemos/mark/parser/heading.dart';
import 'package:fymemos/mark/parser/highlight.dart';
import 'package:fymemos/mark/parser/horizontal_rule.dart';
import 'package:fymemos/mark/parser/image.dart';
import 'package:fymemos/mark/parser/italic.dart';
import 'package:fymemos/mark/parser/line_break.dart';
import 'package:fymemos/mark/parser/link.dart';
import 'package:fymemos/mark/parser/math.dart';
import 'package:fymemos/mark/parser/math_block.dart';
import 'package:fymemos/mark/parser/ordered_list_item.dart';
import 'package:fymemos/mark/parser/paragraph.dart';
import 'package:fymemos/mark/parser/referenced_content.dart';
import 'package:fymemos/mark/parser/spoiler.dart';
import 'package:fymemos/mark/parser/strikethrough.dart';
import 'package:fymemos/mark/parser/subscript.dart';
import 'package:fymemos/mark/parser/superscript.dart';
import 'package:fymemos/mark/parser/tag.dart';
import 'package:fymemos/mark/parser/task_list_item.dart';
import 'package:fymemos/mark/parser/text.dart';
import 'package:fymemos/mark/parser/tokenizer/tokenizer.dart';
import 'package:fymemos/mark/parser/unordered_list_item.dart';

List<BlockParser> defaultBlockParsers = List.unmodifiable([
  CodeBlockParser(),
  //TableParser(),
  HorizontalRuleParser(),
  HeadingParser(),
  BlockquoteParser(),
  OrderedListItemParser(),
  TaskListItemParser(),
  UnorderedListItemParser(),
  MathBlockParser(),
  EmbeddedContentParser(),
  ParagraphParser(),
  LineBreakParser(),
]);

List<BaseParser> defaultInlineParsers = List.unmodifiable([
  EscapingCharacterParser(),
  BoldItalicParser(),
  ImageParser(),
  LinkParser(),
  AutoLinkParser(),
  BoldParser(),
  ItalicParser(),
  SpoilerParser(),
  HighlightParser(),
  CodeParser(),
  SubscriptParser(),
  SuperscriptParser(),
  MathParser(),
  ReferencedContentParser(),
  TagParser(),
  StrikethroughParser(),
  LineBreakParser(),
  TextParser(),
]);

List<BaseNode>? parse(String markdown) {
  List<Token> tokens = tokenize(markdown);
  return parseBlock(tokens);
}

List<BaseNode>? parseBlock(List<Token> tokens) {
  return parseBlockWithParsers(tokens, defaultBlockParsers);
}

List<BaseNode>? parseBlockWithParsers(
  List<Token> tokens,
  List<BlockParser> parsers,
) {
  List<BaseNode> nodes = [];
  while (tokens.isNotEmpty) {
    for (BlockParser parser in parsers) {
      int size;
      BaseNode? node;
      (size, node) = parser.match(tokens);
      if (size != 0 && node != null) {
        tokens = tokens.sublist(size);
        nodes.add(node);
        break;
      }
    }
  }
  return _mergeListItemNodes(nodes);
}

List<BaseNode>? parseInline(List<Token> tokens) {
  return parseInlineWithParsers(tokens, defaultInlineParsers);
}

List<BaseNode>? parseInlineWithParsers(
  List<Token> tokens,
  List<BaseParser> parsers,
) {
  List<BaseNode> nodes = [];
  while (tokens.isNotEmpty) {
    for (BaseParser parser in parsers) {
      int size;
      BaseNode? node;
      (size, node) = parser.match(tokens);
      if (size != 0 && node != null) {
        tokens = tokens.sublist(size);
        nodes.add(node);
        break;
      }
    }
  }
  return _mergeTextNodes(nodes);
}

List<BaseNode>? _mergeTextNodes(List<BaseNode> nodes) {
  if (nodes.isEmpty) {
    return nodes;
  }
  List<BaseNode> newNodes = [nodes[0]];
  for (int i = 1; i < nodes.length; i++) {
    if (nodes[i].getType() == NodeType.TEXT &&
        newNodes.last.getType() == NodeType.TEXT) {
      newNodes[newNodes.length - 1] = TextNode(
        (newNodes.last as TextNode).content + (nodes[i] as TextNode).content,
      );
    } else {
      newNodes.add(nodes[i]);
    }
  }
  return newNodes;
}

List<BaseNode> _mergeListItemNodes(List<BaseNode> nodes) {
  List<BaseNode> result = [];
  List<ListBlock> stack = [];
  for (BaseNode node in nodes) {
    if (node is LineBreak) {
      if (stack.isNotEmpty && result.isNotEmpty && result.last is ListBlock) {
        stack.last.children.add(node);
      } else {
        result.add(node);
      }
      continue;
    }
    if (node.isListItemNode) {
      int itemIndent;
      ListKind kind;
      (kind, itemIndent) = node.listItemKindAndIndent;
      //create a new list node if the stack is empty or the current item should be a child of the last item.
      if (stack.isEmpty ||
          (kind != stack.last.kind || itemIndent > stack.last.indent)) {
        ListBlock l = ListBlock([node], kind, indent: itemIndent);
        //Add the new List to the stack or the result
        if (stack.isNotEmpty && itemIndent > stack.last.indent) {
          stack.last.children.add(l);
        } else {
          result.add(l);
        }
        stack.add(l);
      } else {
        //POP the stack until the current item should be a sibing of the last item
        while (stack.isNotEmpty &&
            (kind != stack.last.kind || itemIndent < stack.last.indent)) {
          stack = stack.sublist(0, stack.length - 1);
        }
        //Add the current item to the last List node in the stack or result
        if (stack.isNotEmpty) {
          stack.last.children.add(node);
        } else {
          result.add(node);
        }
      }
    } else {
      result.add(node);
      stack.clear();
    }
  }
  return result;
}
