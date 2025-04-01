import 'package:fymemos/mark/ast/node.dart';
import 'package:fymemos/mark/parser/base_parser.dart';
import 'package:fymemos/mark/parser/tokenizer/tokenizer.dart';

class ImageParser implements InlineParser {
  @override
  (int, BaseNode?) match(List<Token> tokens) {
    List<Token> matchedTokens = tokens.getFirstLine();
    if (matchedTokens.length < 5) {
      return (0, null);
    }
    if (matchedTokens[0].type != exclamationMark) {
      return (0, null);
    }
    if (matchedTokens[1].type != leftSquareBracket) {
      return (0, null);
    }
    int cursor = 2;
    List<Token> altToken = [];
    while (cursor < matchedTokens.length - 2) {
      if (matchedTokens[cursor].type == rightSquareBracket) {
        break;
      }
      altToken.add(matchedTokens[cursor]);
      cursor++;
    }
    if (matchedTokens[cursor + 1].type != leftParenthesis) {
      return (0, null);
    }
    cursor += 2;
    List<Token> urlToken = [];
    bool matched = false;
    while (cursor < matchedTokens.length) {
      if (matchedTokens[cursor].type == space) {
        return (0, null);
      }
      if (matchedTokens[cursor].type == rightParenthesis) {
        matched = true;
        break;
      }
      urlToken.add(matchedTokens[cursor]);
      cursor++;
    }
    if (!matched || urlToken.isEmpty) {
      return (0, null);
    }

    return (
      5 + urlToken.length + altToken.length,
      ImageNode(urlToken.stringify(), altToken.stringify()),
    );
  }
}
