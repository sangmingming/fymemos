import 'package:fymemos/mark/ast/node.dart';
import 'package:fymemos/mark/parser/base_parser.dart';
import 'package:fymemos/mark/parser/tokenizer/tokenizer.dart';

class BoldItalicParser implements InlineParser {
  @override
  (int, BaseNode?) match(List<Token> tokens) {
    List<Token> matchedTokens = tokens.getFirstLine();
    if (matchedTokens.length < 7) {
      return (0, null);
    }
    List<Token> prefixTokens = matchedTokens.sublist(0, 3);
    if (prefixTokens[0].type != prefixTokens[1].type ||
        prefixTokens[0].type != prefixTokens[2].type ||
        prefixTokens[1].type != prefixTokens[2].type) {
      return (0, null);
    }
    TokenType prefixType = prefixTokens[0].type;
    if (prefixType != asterisk) {
      return (0, null);
    }
    int cursor = 3;
    bool matched = false;
    while (cursor < matchedTokens.length - 2) {
      var token = matchedTokens[cursor];
      var nextToken = matchedTokens[cursor + 1];
      var endToken = matchedTokens[cursor + 2];
      if (token.type == newLine ||
          nextToken.type == newLine ||
          endToken.type == newLine) {
        return (0, null);
      }
      if (token.type == prefixType &&
          nextToken.type == prefixType &&
          endToken.type == prefixType) {
        matchedTokens = matchedTokens.sublist(0, cursor + 3);
        matched = true;
        break;
      }
      cursor++;
    }
    print("mach: $matched");
    if (!matched) {
      return (0, null);
    }
    int size = matchedTokens.length;
    List<Token> contentTokens = matchedTokens.sublist(3, size - 3);
    if (contentTokens.isEmpty) {
      return (0, null);
    }
    return (
      size,
      BoldItalicNode(contentTokens.stringify(), symbol: prefixTokens[0].type),
    );
  }
}
