import 'package:fymemos/mark/ast/node.dart';
import 'package:fymemos/mark/parser/base_parser.dart';
import 'package:fymemos/mark/parser/tokenizer/tokenizer.dart';

class ReferencedContentParser implements InlineParser {
  @override
  (int, BaseNode?) match(List<Token> tokens) {
    List<Token> matchedTokens = tokens.getFirstLine();
    if (matchedTokens.length < 5) {
      return (0, null);
    }
    if (matchedTokens[0].type != leftSquareBracket ||
        matchedTokens[1].type != leftSquareBracket) {
      return (0, null);
    }
    bool matched = false;
    List<Token> contentTokens = [];

    for (int i = 2; i < matchedTokens.length - 1; i++) {
      if (matchedTokens[i].type == rightSquareBracket &&
          matchedTokens[i + 1].type == rightSquareBracket &&
          i == matchedTokens.length - 2) {
        matched = true;
        break;
      }
      contentTokens.add(matchedTokens[i]);
    }

    if (!matched) {
      return (0, null);
    }

    String content = contentTokens.stringify();
    String params = "";
    int questionMarkIndex = contentTokens.findUnescaped(questionMark);
    if (questionMarkIndex > 0) {
      params = contentTokens.sublist(questionMarkIndex + 1).stringify();
      content = contentTokens.sublist(0, questionMarkIndex).stringify();
    }
    return (contentTokens.length + 4, EmbeddedContent(content, params));
  }
}
