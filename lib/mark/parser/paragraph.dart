import 'package:fymemos/mark/ast/node.dart';
import 'package:fymemos/mark/parser/base_parser.dart';
import 'package:fymemos/mark/parser/parser.dart';
import 'package:fymemos/mark/parser/tokenizer/tokenizer.dart';

class ParagraphParser implements BlockParser {
  @override
  (int, BaseNode?) match(List<Token> tokens) {
    List<Token> matchedTokens = tokens.getFirstLine();
    if (matchedTokens.isEmpty) {
      return (0, null);
    }
    List<BaseNode>? children = parseInline(matchedTokens);
    if (children == null) {
      return EmptyPaseResult;
    }
    return (matchedTokens.length, Paragraph(children));
  }
}
