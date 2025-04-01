import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:fymemos/mark/ast/node.dart';
import 'package:fymemos/mark/parser/parser.dart';

void _printNodes(List<BaseNode> nodes) {
  nodes.forEach((element) {
    print(element.getType().name + "" + element.toString());
  });
}

void main() {
  test("Parse text", () {
    List<BaseNode>? nodes = parse("xx");
    expect(nodes != null, true);
    expect(nodes!.length, 1);
    expect(nodes!.first is Paragraph, true);
    Paragraph n = nodes.first as Paragraph;
    expect(n.children.length, 1);
    expect(n.children.first is TextNode, true);
    TextNode t = n.children.first as TextNode;
    expect(t.content, "xx");
  });

  test("LineBreak", () {
    List<BaseNode>? nodes = parse("xx\nab");
    expect(nodes != null, true);
    _printNodes(nodes!);
    expect(nodes!.length, 4);
    expect(nodes!.first is Paragraph, true);
    Paragraph n = nodes.first as Paragraph;
    expect(n.children.length, 1);
    expect(n.children.first is TextNode, true);
    TextNode t = n.children.first as TextNode;
    expect(t.content, "xx");
  });

  test("AutoLink", () {
    List<BaseNode>? nodes = parse(
      "https://www.baidu.com\n<https://www.google.com>",
    );
    expect(nodes != null, true);
    expect(nodes!.length, 4);
    expect(nodes!.first is Paragraph, true);
    Paragraph n = nodes.first as Paragraph;
    expect(n.children.length, 1);
    expect(n.children.first is AutoLink, true);
    AutoLink t = n.children.first as AutoLink;
    expect(t.isRawText, true);
    expect(t.url, "https://www.baidu.com");

    expect(nodes[3] is Paragraph, true);
    Paragraph n1 = nodes[3] as Paragraph;
    n1.children.forEach((element) {
      print(element);
    });
    expect(n1.children.length, 1);
    expect(n1.children.first is AutoLink, true);
    AutoLink t2 = n1.children.first as AutoLink;
    expect(t2.isRawText, false);
    expect(t2.url, "https://www.google.com");
  });

  test("Subscript Superscript", () {
    List<BaseNode>? nodes = parse("~sub~ ^sup^");
    expect(nodes != null, true);
    expect(nodes!.length, 1);
    expect(nodes!.first is Paragraph, true);
    Paragraph n = nodes.first as Paragraph;
    expect(n.children.length, 3);
    expect(n.children.first is Subscript, true);
    Subscript t = n.children.first as Subscript;
    expect(t.content, "sub");
  });

  test("Embedded Content", () {
    List<BaseNode>? nodes = parse("![[xxxyyy?bcd]]");
    expect(nodes != null, true);
    expect(nodes!.length, 1);
    expect(nodes!.first is EmbeddedContent, true);
    EmbeddedContent n = nodes.first as EmbeddedContent;
    expect(n.resourceName, "xxxyyy");
    expect(n.params, "bcd");
  });

  test("HorizontalRule test", () {
    List<BaseNode>? nodes = parse("xx\n---");
    expect(nodes != null, true);
    expect(nodes!.length, 4);
    expect(nodes[3] is HorizontalRule, true);
  });

  test("Heading test", () {
    List<BaseNode>? nodes = parse("# xx");
    expect(nodes != null, true);
    expect(nodes!.length, 1);
    expect(nodes!.first is Heading, true);
    expect((nodes!.first as Heading).level, 1);
  });

  test("inline code test", () {
    List<BaseNode>? nodes = parse("x`y=12`is");
    expect(nodes != null, true);
    expect(nodes!.length, 1);
    expect(nodes!.first is Paragraph, true);
    Paragraph n = nodes.first as Paragraph;
    expect(n.children.length, 3);
    expect(n.children[1] is InlineCodeNode, true);
    InlineCodeNode code = n.children[1] as InlineCodeNode;
    expect(code.content, "y=12");
  });

  test("BoldItalic test", () {
    List<BaseNode>? nodes = parse("***xy***");
    expect(nodes != null, true);
    expect(nodes!.length, 1);
    expect(nodes!.first is Paragraph, true);
    Paragraph n = nodes.first as Paragraph;
    expect(n.children.length, 1);
    n.children.forEach((element) {
      print(element);
    });
    expect(n.children[0] is BoldItalicNode, true);
    BoldItalicNode code = n.children[0] as BoldItalicNode;
    expect(code.content, "xy");
  });

  test("Italic test", () {
    List<BaseNode>? nodes = parse("*xy*");
    expect(nodes != null, true);
    expect(nodes!.length, 1);
    expect(nodes!.first is Paragraph, true);
    Paragraph n = nodes.first as Paragraph;
    expect(n.children.length, 1);
    n.children.forEach((element) {
      print(element);
    });
    expect(n.children[0] is ItalicNode, true);
    ItalicNode code = n.children[0] as ItalicNode;
    expect(code.children.length, 1);
    TextNode text = code.children.first as TextNode;
    expect(text.content, "xy");
  });

  test("Bold test", () {
    List<BaseNode>? nodes = parse("**xy**");
    expect(nodes != null, true);
    expect(nodes!.length, 1);
    expect(nodes!.first is Paragraph, true);
    Paragraph n = nodes.first as Paragraph;
    expect(n.children.length, 1);
    n.children.forEach((element) {
      print(element);
    });
    expect(n.children[0] is BoldNode, true);
    BoldNode code = n.children[0] as BoldNode;
    expect(code.children.length, 1);
    TextNode text = code.children.first as TextNode;
    expect(text.content, "xy");
  });

  test("Image test", () {
    List<BaseNode>? nodes = parse("![xxx](https://www.google.com)");
    expect(nodes != null, true);
    expect(nodes!.length, 1);
    expect(nodes!.first is Paragraph, true);
    Paragraph n = nodes.first as Paragraph;
    expect(n.children.length, 1);
    n.children.forEach((element) {
      print(element);
    });
    expect(n.children[0] is ImageNode, true);
    ImageNode code = n.children[0] as ImageNode;
    expect(code.url, "https://www.google.com");
    expect(code.alt, "xxx");
  });

  test("Math test", () {
    List<BaseNode>? nodes = parse("\$xxx\$");
    expect(nodes != null, true);
    expect(nodes!.length, 1);
    expect(nodes!.first is Paragraph, true);
    Paragraph n = nodes.first as Paragraph;
    expect(n.children.length, 1);
    n.children.forEach((element) {
      print(element);
    });
    expect(n.children[0] is MathInline, true);
    MathInline code = n.children[0] as MathInline;
    expect(code.content, "xxx");
  });

  test("Tag test", () {
    List<BaseNode>? nodes = parse("\$xxx\$#tagx");
    expect(nodes != null, true);
    expect(nodes!.length, 1);
    expect(nodes!.first is Paragraph, true);
    Paragraph n = nodes.first as Paragraph;
    expect(n.children.length, 2);
    n.children.forEach((element) {
      print(element);
    });
    expect(n.children[1] is Tag, true);
    Tag code = n.children[1] as Tag;
    expect(code.tag, "tagx");
  });

  test("Parse List", () {
    List<BaseNode>? nodes = parse("+ item1 \n+ item2 \n+ item3 ");
    expect(nodes != null, true);
    nodes!.forEach((element) {
      print(element.getType().name + "" + element.toString());
    });
    expect(nodes!.length, 1);
    expect(nodes!.first is ListBlock, true);
  });

  test("Blockquote test", () {
    List<BaseNode>? nodes = parse("> hcbuco\n> ok");
    expect(nodes != null, true);
    expect(nodes!.length, 1);
    expect(nodes!.first is Blockquote, true);
    Blockquote n = nodes.first as Blockquote;
    expect(n.children.length, 2);
    n.children.forEach((element) {
      print(element);
    });

    Paragraph text = n.children.first as Paragraph;
    //expect(text.content, "hcbuco");
  });

  test("CodeBlock test", () {
    List<BaseNode>? nodes = parse("```xyz\nabc\nbcd\n```");
    expect(nodes != null, true);
    expect(nodes!.length, 1);
    expect(nodes!.first is CodeBlock, true);
    CodeBlock n = nodes.first as CodeBlock;
    expect(n.language, "xyz");
    expect(n.content, "abc\nbcd");
  });
}
