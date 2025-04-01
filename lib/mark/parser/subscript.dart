import 'package:fymemos/mark/ast/node.dart';
import 'package:fymemos/mark/parser/base_parser.dart';
import 'package:fymemos/mark/parser/tokenizer/tokenizer.dart';

class SubscriptParser extends BaseOneSymbolInlineParser {
  @override
  TokenType get symbol => tilde;

  @override
  bool get unescaped => false;

  @override
  BaseNode createNode(String content) {
    return Subscript(content);
  }
}
