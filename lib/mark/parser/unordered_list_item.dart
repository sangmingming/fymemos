import 'package:fymemos/mark/ast/node.dart';
import 'package:fymemos/mark/parser/base_parser.dart';
import 'package:fymemos/mark/parser/parser.dart';
import 'package:fymemos/mark/parser/tokenizer/tokenizer.dart';

class UnorderedListItemParser implements BlockParser {
  @override
  (int, BaseNode?) match(List<Token> tokens) {
    List<Token> matchedTokens = tokens.getFirstLine();
    int indent = 0;
    for (Token token in matchedTokens) {
      if (token.type == space) {
        indent++;
      } else {
        break;
      }
    }
    if (matchedTokens.length < indent + 2) {
      return (0, null);
    }
    Token symbolToken = matchedTokens[indent];
    if ((symbolToken.type != hyphen &&
            symbolToken.type != asterisk &&
            symbolToken.type != plusSign) ||
        matchedTokens[indent + 1].type != space) {
      return (0, null);
    }
    List<Token> contentTokens = matchedTokens.sublist(indent + 2);
    if (contentTokens.isEmpty) {
      return (0, null);
    }
    List<BaseNode>? children = parseInline(contentTokens);
    if (children == null) {
      return (0, null);
    }
    return (
      indent + contentTokens.length + 2,
      UnorderedListItem(children, symbolToken.type, indent: indent),
    );
  }
}
