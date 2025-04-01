import 'package:fymemos/mark/ast/node.dart';
import 'package:fymemos/mark/parser/base_parser.dart';
import 'package:fymemos/mark/parser/tokenizer/tokenizer.dart';

class AutoLinkParser implements InlineParser {
  @override
  (int, BaseNode?) match(List<Token> tokens) {
    if (tokens.length < 3) {
      return (0, null);
    }
    List<Token> matchedT = tokens.getFirstLine();
    String url = "";
    bool isRawText = true;
    if (matchedT[0].type == lessThan) {
      int greaterThanIndex = matchedT.indexOf(
        matchedT.firstWhere((element) => element.type == greaterThan),
      );

      if (greaterThanIndex == -1) {
        return (0, null);
      }

      matchedT = matchedT.sublist(0, greaterThanIndex + 1);
      url = matchedT.sublist(1, matchedT.length - 1).stringify();
      isRawText = false;
    } else {
      List<Token> contentTokens = [];
      for (int i = 0; i < matchedT.length; i++) {
        if (matchedT[i].type == space) {
          break;
        }
        contentTokens.add(matchedT[i]);
      }
      if (contentTokens.isEmpty) {
        return (0, null);
      }

      matchedT = contentTokens;
      Uri? uri = Uri.tryParse(matchedT.stringify());
      if (uri == null || uri.scheme.isEmpty || uri.host.isEmpty) {
        return (0, null);
      }
      url = matchedT.stringify();
    }
    return (matchedT.length, AutoLink(url, isRawText));
  }
}
