import 'package:fymemos/mark/ast/node.dart';
import 'package:fymemos/mark/parser/base_parser.dart';
import 'package:fymemos/mark/parser/parser.dart';
import 'package:fymemos/mark/parser/tokenizer/tokenizer.dart';

class HeadingParser implements BlockParser {
  @override
  (int, BaseNode?) match(List<Token> tokens) {
    List<Token> matchedTokens = tokens.getFirstLine();
    int spaceIndex = matchedTokens.findUnescaped(space);
    if (spaceIndex == -1) {
      return (0, null);
    }
    for (Token token in matchedTokens.sublist(0, spaceIndex)) {
      if (token.type != poundSign) {
        return (0, null);
      }
    }
    int level = spaceIndex;
    if (level > 6 || level == 0) {
      return (0, null);
    }
    List<Token> contentTokens = matchedTokens.sublist(level + 1);
    if (contentTokens.isEmpty) {
      return (0, null);
    }
    List<BaseNode>? children = parseInline(tokens);
    if (children == null) {
      return (0, null);
    }

    return (contentTokens.length + level + 1, Heading(level, children));
  }
}
