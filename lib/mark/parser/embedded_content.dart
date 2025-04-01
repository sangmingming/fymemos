import 'package:fymemos/mark/ast/node.dart';
import 'package:fymemos/mark/parser/base_parser.dart';
import 'package:fymemos/mark/parser/tokenizer/tokenizer.dart';

class EmbeddedContentParser implements BlockParser {
  @override
  (int, BaseNode?) match(List<Token> tokens) {
    List<Token> matchedTokens = tokens.getFirstLine();
    if (matchedTokens.length < 6) {
      return (0, null);
    }
    if (matchedTokens[0].type != exclamationMark ||
        matchedTokens[1].type != leftSquareBracket ||
        matchedTokens[2].type != leftSquareBracket) {
      return (0, null);
    }
    bool matched = false;

    for (int i = 0; i < matchedTokens.length - 1; i++) {
      if (matchedTokens[i].type == rightSquareBracket &&
          matchedTokens[i + 1].type == rightSquareBracket &&
          i == matchedTokens.length - 2) {
        matched = true;
        break;
      }
    }

    if (!matched) {
      return (0, null);
    }

    List<Token> contentTokens = matchedTokens.sublist(
      3,
      matchedTokens.length - 2,
    );
    String content = contentTokens.stringify();
    String params = "";
    int questionMarkIndex = contentTokens.findUnescaped(questionMark);
    if (questionMarkIndex != -1) {
      params = contentTokens.sublist(questionMarkIndex + 1).stringify();
      content = contentTokens.sublist(0, questionMarkIndex).stringify();
    }
    return (matchedTokens.length, EmbeddedContent(content, params));
  }
}
