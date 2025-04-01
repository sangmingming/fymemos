typedef TokenType = String;

// Symbol based tokens.
const TokenType underScore = "_";
const TokenType asterisk = "*";
const TokenType poundSign = "#";
const TokenType backtick = "`";
const TokenType leftSquareBracket = "[";
const TokenType rightSquareBracket = "]";
const TokenType leftParenthesis = "(";
const TokenType rightParenthesis = ")";
const TokenType exclamationMark = "!";
const TokenType questionMark = "?";
const TokenType tilde = "~";
const TokenType hyphen = "-";
const TokenType plusSign = "+";
const TokenType dot = ".";
const TokenType lessThan = "<";
const TokenType greaterThan = ">";
const TokenType dollarSign = "\$";
const TokenType equalSign = "=";
const TokenType pipe = "|";
const TokenType colon = ":";
const TokenType caret = "^";
const TokenType apostrophe = "'";
const TokenType backslash = "\\";
const TokenType slash = "/";
const TokenType newLine = "\n";
const TokenType space = " ";

// Text based tokens.
const TokenType number = "number";
const TokenType text = "";

class Token {
  TokenType type;
  String value;

  Token(this.type, this.value);
}

List<Token> tokenize(String content) {
  List<Token> tokens = [];
  for (var i = 0; i < content.length; i++) {
    var char = content[i];
    switch (char) {
      case underScore:
        tokens.add(Token(underScore, char));
      case asterisk:
        tokens.add(Token(asterisk, char));
      case poundSign:
        tokens.add(Token(poundSign, char));
      case backtick:
        tokens.add(Token(backtick, char));
      case leftSquareBracket:
        tokens.add(Token(leftSquareBracket, char));
      case rightSquareBracket:
        tokens.add(Token(rightSquareBracket, char));
      case leftParenthesis:
        tokens.add(Token(leftParenthesis, char));
      case rightParenthesis:
        tokens.add(Token(rightParenthesis, char));
      case exclamationMark:
        tokens.add(Token(exclamationMark, char));
      case questionMark:
        tokens.add(Token(questionMark, char));
      case tilde:
        tokens.add(Token(tilde, char));
      case hyphen:
        tokens.add(Token(hyphen, char));
      case plusSign:
        tokens.add(Token(plusSign, char));
      case dot:
        tokens.add(Token(dot, char));
      case lessThan:
        tokens.add(Token(lessThan, char));
      case greaterThan:
        tokens.add(Token(greaterThan, char));
      case dollarSign:
        tokens.add(Token(dollarSign, char));
      case equalSign:
        tokens.add(Token(equalSign, char));
      case pipe:
        tokens.add(Token(pipe, char));
      case colon:
        tokens.add(Token(colon, char));
      case caret:
        tokens.add(Token(caret, char));
      case apostrophe:
        tokens.add(Token(apostrophe, char));
      case backslash:
        tokens.add(Token(backslash, char));
      case slash:
        tokens.add(Token(slash, char));
      case newLine:
        tokens.add(Token(newLine, char));
      case space:
        tokens.add(Token(space, char));
        break;
      default:
        Token? preToken = tokens.lastOrNull;
        bool isNum = char.codeUnitAt(0) >= 48 && char.codeUnitAt(0) <= 57;
        if (preToken != null) {
          if ((preToken.type == number && isNum) ||
              (preToken.type == text && !isNum)) {
            preToken.value += char;
            continue;
          }
        }
        if (isNum) {
          tokens.add(Token(number, char));
        } else {
          tokens.add(Token(text, char));
        }
    }
  }
  return tokens;
}

extension TokenizerExtension on List<Token> {
  List<List<Token>> split(TokenType delimiter) {
    List<List<Token>> result = [];
    List<Token> current = [];
    for (var token in this) {
      if (token.type == delimiter) {
        result.add(current);
        current = [];
      } else {
        current.add(token);
      }
    }
    result.add(current);
    return result;
  }

  int find(TokenType target) {
    for (var i = 0; i < length; i++) {
      if (this[i].type == target) {
        return i;
      }
    }
    return -1;
  }

  int findUnescaped(TokenType target) {
    for (var i = 0; i < length; i++) {
      if (this[i].type == target &&
          (i == 0 || (i > 0 && this[i - 1].type != backslash))) {
        return i;
      }
    }
    return -1;
  }

  List<Token> getFirstLine() {
    var index = find(newLine);
    if (index == -1) {
      return this;
    }
    return sublist(0, index);
  }

  String stringify() {
    return map((e) => e.value).join("");
  }
}
