import 'package:fymemos/mark/ast/node.dart';
import 'package:fymemos/mark/parser/base_parser.dart';
import 'package:fymemos/mark/parser/tokenizer/tokenizer.dart';

class CodeBlockParser implements BlockParser {
  @override
  (int, BaseNode?) match(List<Token> tokens) {
    List<List<Token>> rows = tokens.split(newLine);
    if (rows.length < 3) {
      return (0, null);
    }
    List<Token> firstRow = rows[0];
    if (firstRow.length < 3) {
      return (0, null);
    }
    if (firstRow[0].type != backtick ||
        firstRow[1].type != backtick ||
        firstRow[2].type != backtick) {
      return (0, null);
    }
    List<Token> languageTokens = [];
    if (firstRow.length > 3) {
      languageTokens = firstRow.sublist(3);
      List<TokenType> availableLanguageTokens = [text, number, underScore];
      for (Token token in languageTokens) {
        if (!availableLanguageTokens.contains(token.type)) {
          return (0, null);
        }
      }
    }
    List<List<Token>> contentRows = [];
    bool matched = false;
    for (int i = 1; i < rows.length; i++) {
      if (rows[i].length == 3 &&
          rows[i][0].type == backtick &&
          rows[i][1].type == backtick &&
          rows[i][2].type == backtick) {
        matched = true;
        break;
      }
      contentRows.add(rows[i]);
    }
    if (!matched) {
      return (0, null);
    }
    List<Token> contentTokens = [];
    for (int i = 0; i < contentRows.length; i++) {
      contentTokens.addAll(contentRows[i]);
      if (i != contentRows.length - 1) {
        contentTokens.add(Token(newLine, "\n"));
      }
    }
    return (
      4 + languageTokens.length + contentTokens.length + 4,
      CodeBlock(contentTokens.stringify(), languageTokens.stringify()),
    );
  }
}
