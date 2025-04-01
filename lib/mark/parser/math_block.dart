import 'package:fymemos/mark/ast/node.dart';
import 'package:fymemos/mark/parser/base_parser.dart';
import 'package:fymemos/mark/parser/tokenizer/tokenizer.dart';

class MathBlockParser implements BlockParser {
  @override
  (int, BaseNode?) match(List<Token> tokens) {
    List<List<Token>> rows = tokens.split(newLine);
    if (rows.length < 3) {
      return (0, null);
    }
    List<Token> firstRow = rows[0];
    if (firstRow.length != 2) {
      return (0, null);
    }
    if (firstRow[0].type != dollarSign || firstRow[1].type != dollarSign) {
      return (0, null);
    }

    List<List<Token>> contentRows = [];
    bool matched = false;
    for (int i = 1; i < rows.length; i++) {
      if (rows[i].length == 2 &&
          rows[i][0].type == dollarSign &&
          rows[i][1].type == dollarSign) {
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
    return (3 + contentTokens.length + 3, MathBlock(contentTokens.stringify()));
  }
}
