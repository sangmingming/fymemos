import 'package:fymemos/mark/ast/node.dart';
import 'package:fymemos/mark/parser/base_parser.dart';
import 'package:fymemos/mark/parser/parser.dart';
import 'package:fymemos/mark/parser/tokenizer/tokenizer.dart';

class TaskListItemParser implements BlockParser {
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
    if (matchedTokens.length < indent + 6) {
      return (0, null);
    }
    Token symbolToken = matchedTokens[indent];
    if (symbolToken.type != hyphen &&
        symbolToken.type != asterisk &&
        symbolToken.type != plusSign) {
      return (0, null);
    }
    if (matchedTokens[indent + 1].type != space) {
      return (0, null);
    }
    if (matchedTokens[indent + 2].type != leftSquareBracket ||
        (matchedTokens[indent + 3].type != space &&
            matchedTokens[indent + 3].type != "x") ||
        matchedTokens[indent + 4].type != rightSquareBracket) {
      return EmptyPaseResult;
    }
    if (matchedTokens[indent + 5].type != space) {
      return EmptyPaseResult;
    }

    List<Token> contentTokens = matchedTokens.sublist(indent + 6);
    if (contentTokens.isEmpty) {
      return EmptyPaseResult;
    }
    List<BaseNode>? children = parseInline(contentTokens);
    if (children == null) {
      return EmptyPaseResult;
    }
    return (
      indent + contentTokens.length + 6,
      TaskListItem(
        children,
        symbolToken.type,
        matchedTokens[indent + 3].value == "x",
        indent: indent,
      ),
    );
  }
}
