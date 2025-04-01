import 'package:fymemos/mark/ast/node.dart';
import 'package:fymemos/mark/parser/base_parser.dart';
import 'package:fymemos/mark/parser/tokenizer/tokenizer.dart';

class HighlightParser extends BaseTwoSymbolInlineParser {
  @override
  TokenType get symbol => equalSign;

  @override
  BaseNode createNode(String content) {
    return Highlight(content);
  }
}
