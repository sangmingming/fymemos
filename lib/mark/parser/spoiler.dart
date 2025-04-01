import 'package:fymemos/mark/ast/node.dart';
import 'package:fymemos/mark/parser/base_parser.dart';
import 'package:fymemos/mark/parser/tokenizer/tokenizer.dart';

class SpoilerParser extends BaseTwoSymbolInlineParser {
  @override
  TokenType get symbol => pipe;

  @override
  BaseNode createNode(String content) {
    return Spoiler(content);
  }
}
