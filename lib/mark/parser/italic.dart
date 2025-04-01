import 'package:fymemos/mark/ast/node.dart';
import 'package:fymemos/mark/parser/base_parser.dart';
import 'package:fymemos/mark/parser/link.dart';
import 'package:fymemos/mark/parser/parser.dart';
import 'package:fymemos/mark/parser/text.dart';
import 'package:fymemos/mark/parser/tokenizer/tokenizer.dart';

class ItalicParser implements InlineParser {
  @override
  (int, BaseNode?) match(List<Token> tokens) {
    List<Token> matchedTokens = tokens.getFirstLine();
    if (matchedTokens.length < 3) {
      return (0, null);
    }
    List<Token> prefixTokens = matchedTokens.sublist(0, 1);
    TokenType prefixType = prefixTokens[0].type;
    if (prefixType != asterisk && prefixType != underScore) {
      return (0, null);
    }
    int cursor = 1;
    bool matched = false;
    while (cursor < matchedTokens.length) {
      Token currentToken = matchedTokens[cursor];
      if (currentToken.type == newLine) {
        return (0, null);
      }
      if (currentToken.type == prefixType) {
        matched = true;
        matchedTokens = matchedTokens.sublist(0, cursor + 1);
        break;
      }

      cursor++;
    }
    if (!matched) {
      return (0, null);
    }
    int size = matchedTokens.length;
    List<BaseNode>? children = parseInlineWithParsers(
      matchedTokens.sublist(1, size - 1),
      [LinkParser(), TextParser()],
    );
    if (children == null || children.isEmpty) {
      return (0, null);
    }
    return (size, ItalicNode(children, symbol: prefixType));
  }
}
