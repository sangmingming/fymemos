import 'package:fymemos/mark/ast/node.dart';
import 'package:fymemos/mark/parser/tokenizer/tokenizer.dart';

const (int, BaseNode?) EmptyPaseResult = (0, null);

abstract interface class BaseParser {
  (int, BaseNode?) match(List<Token> tokens);
}

abstract interface class InlineParser extends BaseParser {}

abstract interface class BlockParser extends BaseParser {}

abstract class BaseOneSymbolInlineParser<T extends BaseNode>
    implements InlineParser {
  TokenType get symbol;
  bool get unescaped;

  T createNode(String content);

  @override
  (int, BaseNode?) match(List<Token> tokens) {
    List<Token> matchedTokens = tokens.getFirstLine();
    if (matchedTokens.length < 3) {
      return (0, null);
    }
    if (matchedTokens[0].type != symbol) {
      return (0, null);
    }
    int nextBacktickIndex =
        unescaped
            ? matchedTokens.sublist(1).findUnescaped(symbol)
            : matchedTokens.sublist(1).find(symbol);
    if (nextBacktickIndex == -1) {
      return (0, null);
    }
    matchedTokens = matchedTokens.sublist(0, 1 + nextBacktickIndex + 1);
    List<Token> contentTokens = matchedTokens.sublist(
      1,
      matchedTokens.length - 1,
    );
    if (contentTokens.isEmpty) {
      return (0, null);
    }
    return (matchedTokens.length, createNode(contentTokens.stringify()));
  }
}

abstract class BaseTwoSymbolInlineParser<T extends BaseNode>
    implements InlineParser {
  TokenType get symbol;

  T createNode(String content);

  (int, BaseNode?) match(List<Token> tokens) {
    List<Token> matchedTokens = tokens.getFirstLine();
    if (matchedTokens.length < 5) {
      return (0, null);
    }
    List<Token> prefixTokens = matchedTokens.sublist(0, 2);
    if (prefixTokens[0].type != prefixTokens[1].type) {
      return (0, null);
    }
    TokenType prefixType = prefixTokens[0].type;
    if (prefixType != symbol) {
      return (0, null);
    }
    int cursor = 2;
    bool matched = false;
    while (cursor < matchedTokens.length - 1) {
      Token currentToken = matchedTokens[cursor];
      Token nextToken = matchedTokens[cursor + 1];
      if (currentToken.type == newLine || nextToken.type == newLine) {
        return (0, null);
      }
      if (currentToken.type == prefixType && nextToken.type == prefixType) {
        matched = true;
        matchedTokens = matchedTokens.sublist(0, cursor + 2);
        break;
      }

      cursor++;
    }
    if (!matched) {
      return (0, null);
    }
    int size = matchedTokens.length;
    String content = matchedTokens.sublist(2, size - 2).stringify();
    return (size, createNode(content));
  }
}
