import 'package:fymemos/mark/ast/node.dart';
import 'package:fymemos/mark/parser/base_parser.dart';
import 'package:fymemos/mark/parser/tokenizer/tokenizer.dart';

class TagParser implements InlineParser {
  @override
  (int, BaseNode?) match(List<Token> tokens) {
    List<Token> matchedTokens = tokens.getFirstLine();
    if (matchedTokens.length < 2) {
      return (0, null);
    }
    if (matchedTokens[0].type != poundSign) {
      return (0, null);
    }
    List<Token> contentTokens = [];
    for (Token token in matchedTokens.sublist(1)) {
      if (token.type == space ||
          token.type == poundSign ||
          token.type == backslash) {
        break;
      }
      contentTokens.add(token);
    }
    if (contentTokens.isEmpty) {
      return (0, null);
    }
    return (contentTokens.length + 1, Tag(contentTokens.stringify()));
  }
}
