import 'package:fymemos/mark/ast/node.dart';
import 'package:fymemos/mark/parser/base_parser.dart';
import 'package:fymemos/mark/parser/tokenizer/tokenizer.dart';

class LineBreakParser implements BlockParser {
  @override
  (int, BaseNode?) match(List<Token> tokens) {
    if (tokens.isEmpty) {
      return (0, null);
    }
    if (tokens[0].type != newLine) {
      return (0, null);
    }
    if (tokens.length > 1 && tokens[1].type == newLine) {
      print("LineBreakParser");
    }
    return (1, LineBreak());
  }
}
