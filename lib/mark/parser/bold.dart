import 'package:fymemos/mark/ast/node.dart';
import 'package:fymemos/mark/parser/base_parser.dart';
import 'package:fymemos/mark/parser/parser.dart';
import 'package:fymemos/mark/parser/text.dart';
import 'package:fymemos/mark/parser/tokenizer/tokenizer.dart';

class BoldParser implements InlineParser {
  @override
  (int, BaseNode?) match(List<Token> tokens) {
    List<Token> matchedTokens = tokens.getFirstLine();
    if (matchedTokens.length < 5) {
      return (0, null);
    }
    List<Token> prefixTokens = matchedTokens.sublist(0, 2);
    if (prefixTokens[0].type != prefixTokens[1].type) {
      return (0, null);
    }
    TokenType prefixType = prefixTokens[0].type;
    if (prefixType != asterisk && prefixType != underScore) {
      return (0, null);
    }
    int cursor = 2;
    bool matched = false;
    while (cursor < matchedTokens.length - 1) {
      Token currentToken = matchedTokens[cursor];
      Token nextToken = matchedTokens[cursor + 1];
      if (currentToken.type == newLine || nextToken.type == newLine) {
        return (0, null);
      }
      if (currentToken.type == prefixType && nextToken.type == prefixType) {
        matched = true;
        matchedTokens = matchedTokens.sublist(0, cursor + 2);
        break;
      }

      cursor++;
    }
    if (!matched) {
      return (0, null);
    }
    int size = matchedTokens.length;
    List<BaseNode>? children = parseInlineWithParsers(
      matchedTokens.sublist(2, size - 2),
      [TextParser()], //TODO add link parser
    );
    if (children == null || children.isEmpty) {
      return (0, null);
    }
    return (size, BoldNode(children, symbol: prefixType));
  }
}
