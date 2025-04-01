import 'package:fymemos/mark/ast/node.dart';
import 'package:fymemos/mark/parser/base_parser.dart';
import 'package:fymemos/mark/parser/tokenizer/tokenizer.dart';

class TextParser implements InlineParser {
  @override
  (int, BaseNode?) match(List<Token> tokens) {
    if (tokens.isEmpty) {
      return (0, null);
    }
    return (1, TextNode(tokens[0].value));
  }
}
