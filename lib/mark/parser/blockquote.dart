import 'package:fymemos/mark/ast/node.dart';
import 'package:fymemos/mark/parser/base_parser.dart';
import 'package:fymemos/mark/parser/paragraph.dart';
import 'package:fymemos/mark/parser/parser.dart';
import 'package:fymemos/mark/parser/tokenizer/tokenizer.dart';

class BlockquoteParser implements BlockParser {
  @override
  (int, BaseNode?) match(List<Token> tokens) {
    List<List<Token>> rows = tokens.split(newLine);
    List<List<Token>> contentRows = [];

    for (var row in rows) {
      if (row.length < 2 ||
          row[0].type != greaterThan ||
          row[1].type != space) {
        break;
      }
      contentRows.add(row);
    }
    if (contentRows.isEmpty) {
      return (0, null);
    }
    List<BaseNode> children = [];
    int size = 0;
    for (int i = 0; i < contentRows.length; i++) {
      List<Token> contentTokens = contentRows[i].sublist(2);
      BaseNode node;
      if (contentTokens.isEmpty) {
        node = Paragraph([TextNode(" ")]);
      } else {
        List<BaseNode>? nodes = parseBlockWithParsers(contentTokens, [
          BlockquoteParser(),
          ParagraphParser(),
        ]);
        if (nodes == null || nodes.length != 1) {
          return EmptyPaseResult;
        }

        node = nodes[0];
      }
      children.add(node);
      size += contentRows[i].length;
      if (i != contentRows.length - 1) {
        size++; //newLIne
      }
    }
    if (children.isEmpty) {
      return EmptyPaseResult;
    }
    return (size, Blockquote(children));
  }
}
