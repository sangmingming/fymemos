import 'package:fymemos/mark/ast/node.dart';
import 'package:fymemos/mark/parser/base_parser.dart';
import 'package:fymemos/mark/parser/tokenizer/tokenizer.dart';

class StrikethroughParser extends BaseTwoSymbolInlineParser {
  @override
  TokenType get symbol => tilde;

  @override
  BaseNode createNode(String content) {
    return Strikethrough(content);
  }
}
