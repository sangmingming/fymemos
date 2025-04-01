import 'package:fymemos/mark/ast/node.dart';
import 'package:fymemos/mark/parser/base_parser.dart';
import 'package:fymemos/mark/parser/tokenizer/tokenizer.dart';

class EscapingCharacterParser implements InlineParser {
  @override
  (int, BaseNode?) match(List<Token> tokens) {
    if (tokens.length < 2) return (0, null);
    if (tokens[0].type != backslash) {
      return (0, null);
    }
    if (tokens[1].type == newLine ||
        tokens[1].type == space ||
        tokens[1].type == text ||
        tokens[1].type == number) {
      return (0, null);
    }
    return (2, EscapingCharacter(tokens[1].value));
  }
}
