import 'package:fymemos/mark/ast/node.dart';
import 'package:fymemos/mark/parser/base_parser.dart';
import 'package:fymemos/mark/parser/escaping_character.dart';
import 'package:fymemos/mark/parser/parser.dart';
import 'package:fymemos/mark/parser/text.dart';
import 'package:fymemos/mark/parser/tokenizer/tokenizer.dart';

class LinkParser implements InlineParser {
  @override
  (int, BaseNode?) match(List<Token> tokens) {
    List<Token> matchedTokens = tokens.getFirstLine();
    if (matchedTokens.length < 5) {
      return (0, null);
    }
    if (matchedTokens[0].type != leftSquareBracket) {
      return (0, null);
    }
    int rightSquareBracketIndex = matchedTokens.findUnescaped(
      rightSquareBracket,
    );
    if (rightSquareBracketIndex == -1) {
      return (0, null);
    }
    List<Token> contentTokens = matchedTokens.sublist(
      1,
      rightSquareBracketIndex,
    );
    if (contentTokens.length + 4 >= matchedTokens.length) {
      return (0, null);
    }
    if (matchedTokens[2 + contentTokens.length].type != leftParenthesis) {
      return (0, null);
    }
    List<Token> urlTokens = [];
    bool matched = false;
    for (Token token in matchedTokens.sublist(3 + contentTokens.length)) {
      if (token.type == space) {
        return (0, null);
      }
      if (token.type == rightParenthesis) {
        matched = true;
        break;
      }
      urlTokens.add(token);
    }
    if (!matched || urlTokens.isEmpty) {
      return (0, null);
    }
    List<BaseNode>? contentNodes = parseInlineWithParsers(contentTokens, [
      EscapingCharacterParser(),
      TextParser(),
    ]);
    if (contentNodes == null) {
      return (0, null);
    }
    return (
      4 + contentTokens.length + urlTokens.length,
      LinkNode(urlTokens.stringify(), contentNodes),
    );
  }
}
