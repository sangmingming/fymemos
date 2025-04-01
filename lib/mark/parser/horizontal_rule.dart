import 'package:fymemos/mark/ast/node.dart';
import 'package:fymemos/mark/parser/base_parser.dart';
import 'package:fymemos/mark/parser/tokenizer/tokenizer.dart';

class HorizontalRuleParser implements BlockParser {
  @override
  (int, BaseNode?) match(List<Token> tokens) {
    List<Token> matchedTokens = tokens.getFirstLine();
    if (matchedTokens.length < 3) {
      return (0, null);
    }
    if (matchedTokens.length > 3 && matchedTokens[3].type != newLine) {
      return (0, null);
    }
    if (matchedTokens[0].type != matchedTokens[1].type ||
        matchedTokens[1].type != matchedTokens[0].type ||
        matchedTokens[2].type != matchedTokens[1].type) {
      return (0, null);
    }
    if (matchedTokens[0].type != hyphen && matchedTokens[0].type != asterisk) {
      return (0, null);
    }
    return (3, HorizontalRule(matchedTokens[0].type));
  }
}
