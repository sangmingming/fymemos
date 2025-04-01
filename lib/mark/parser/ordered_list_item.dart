import 'package:fymemos/mark/ast/node.dart';
import 'package:fymemos/mark/parser/base_parser.dart';
import 'package:fymemos/mark/parser/parser.dart';
import 'package:fymemos/mark/parser/tokenizer/tokenizer.dart';

class OrderedListItemParser implements BlockParser {
  @override
  (int, BaseNode?) match(List<Token> tokens) {
    List<Token> matchedTokens = tokens.getFirstLine();
    int indent = 0;
    for (Token token in matchedTokens) {
      if (token.type == space) {
        indent++;
      } else {
        break;
      }
    }
    if (matchedTokens.length < indent + 3) {
      return (0, null);
    }
    int cursor = indent;
    if (matchedTokens[cursor].type != number ||
        matchedTokens[cursor + 1].type != dot ||
        matchedTokens[cursor + 2].type != space) {
      return (0, null);
    }
    List<Token> contentTokens = matchedTokens.sublist(cursor + 3);
    if (contentTokens.isEmpty) {
      return (0, null);
    }
    List<BaseNode>? children = parseInline(contentTokens);
    if (children == null) {
      return (0, null);
    }
    return (
      indent + contentTokens.length + 3,
      OrderedListItem(children, number, indent: indent),
    );
  }
}
