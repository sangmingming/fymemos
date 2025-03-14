import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fymemos/model/memo_nodes.dart';
import 'package:fymemos/widgets/embedded_memo.dart';
import 'package:url_launcher/url_launcher.dart';

class NodeRenderer extends StatelessWidget {
  final Node node;

  const NodeRenderer({required this.node});

  @override
  Widget build(BuildContext context) {
    return _renderNode(node, context);
  }

  Widget _renderNode(Node node, BuildContext context) {
    switch (node.type) {
      case NodeType.PARAGRAPH:
        return _renderParagraphNode(node.node as ParagraphNode, context);
      case NodeType.LIST:
        return _renderListNode(node.node as ListNode, context);
      case NodeType.LINE_BREAK:
        return _renderLineBreakNode(node.node as LineBreakNode, context);
      case NodeType.HORIZONTAL_RULE:
        return _renderHorizontalRuleNode(
          node.node as HorizontalRuleNode,
          context,
        );
      case NodeType.TASK_LIST_ITEM:
        return _renderTaskListItemNode(node.node as TaskListItemNode, context);
      case NodeType.HEADING:
        return _renderHeadingNode(node.node as HeadingNode, context);
      case NodeType.CODE_BLOCK:
        return _renderCodeBlockNode(node.node as CodeBlockNode, context);
      case NodeType.EMBEDDED_CONTENT:
        return _renderEmbeddedContentNode(
          node.node as EmbeddedContentNode,
          context,
        );
      default:
        throw Exception('Unknown node type: ${node.type}');
    }
  }

  InlineSpan _renderChildNode(Node node, BuildContext context) {
    switch (node.type) {
      case NodeType.TAG:
        return _renderTagNode(node.node as TagNode, context);
      case NodeType.TEXT:
        return _renderTextNode(node.node as TextNode, context);
      case NodeType.AUTO_LINK:
        return _renderAutoLinkNode(node.node as AutoLinkNode, context);
      case NodeType.BOLD:
        return _renderBoldNode(node.node as BoldNode, context);
      case NodeType.ITALIC:
        return _renderItalicNode(node.node as ItalicNode, context);
      case NodeType.STRIKETHROUGH:
        return _renderStrikethroughNode(
          node.node as StrikethroughNode,
          context,
        );
      case NodeType.LINK:
        return _renderLinkNode(node.node as LinkNode, context);
      default:
        throw Exception('Unknown node type: ${node.type}');
    }
  }

  Widget _renderEmbeddedContentNode(
    EmbeddedContentNode node,
    BuildContext context,
  ) {
    return EmbeddedMemoItem(memoResourceName: node.resourceName);
  }

  Widget _renderHeadingNode(HeadingNode node, BuildContext context) {
    late TextStyle textStyle;
    final them = Theme.of(context).textTheme;
    switch (node.level) {
      case 1:
        textStyle = them.displayLarge!;
        break;
      case 2:
        textStyle = them.displayMedium!;
        break;
      case 3:
        textStyle = them.displaySmall!;
        break;
      case 4:
        textStyle = them.headlineLarge!;
        break;
      case 5:
        textStyle = them.headlineMedium!;
        break;
      default:
        textStyle = them.headlineSmall!;
        break;
    }
    return RichText(
      text: TextSpan(
        children:
            node.children
                .map((child) => _renderChildNode(child, context))
                .toList(),
        style: textStyle,
      ),
    );
  }

  Widget _renderCodeBlockNode(CodeBlockNode node, BuildContext context) {
    return Text(node.content, style: Theme.of(context).textTheme.bodyMedium);
  }

  Widget _renderParagraphNode(ParagraphNode node, BuildContext context) {
    return RichText(
      text: TextSpan(
        children:
            node.children
                .map((child) => _renderChildNode(child, context))
                .toList(),
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }

  Widget _renderListNode(ListNode node, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          node.children.map((child) => NodeRenderer(node: child)).toList(),
    );
  }

  InlineSpan _renderTagNode(TagNode node, BuildContext context) {
    return WidgetSpan(
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed("/tags/${node.content}");
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          margin: EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '#${node.content}',
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
        ),
      ),
    );
  }

  TextSpan _renderTextNode(TextNode node, BuildContext context) {
    return TextSpan(text: node.content);
  }

  TextSpan _renderBoldNode(BaseTextNode node, BuildContext context) {
    return TextSpan(
      text: node.content,
      style: TextStyle(fontWeight: FontWeight.bold),
    );
  }

  TextSpan _renderItalicNode(BaseTextNode node, BuildContext context) {
    return TextSpan(
      text: node.content,
      style: TextStyle(fontStyle: FontStyle.italic),
    );
  }

  TextSpan _renderStrikethroughNode(BaseTextNode node, BuildContext context) {
    return TextSpan(
      text: node.content,
      style: TextStyle(decoration: TextDecoration.lineThrough),
    );
  }

  TextSpan _renderAutoLinkNode(AutoLinkNode node, BuildContext context) {
    return TextSpan(
      text: node.url,
      style: TextStyle(color: Theme.of(context).primaryColor),
      recognizer:
          TapGestureRecognizer()
            ..onTap = () {
              launchUrl(Uri.parse(node.url));
            },
    );
  }

  TextSpan _renderLinkNode(LinkNode node, BuildContext context) {
    return TextSpan(
      text: node.text,
      style: TextStyle(color: Theme.of(context).primaryColor),
      recognizer:
          TapGestureRecognizer()
            ..onTap = () {
              launchUrl(Uri.parse(node.url));
            },
    );
  }

  Widget _renderLineBreakNode(LineBreakNode node, BuildContext context) {
    return SizedBox(height: 6);
  }

  Widget _renderHorizontalRuleNode(
    HorizontalRuleNode node,
    BuildContext context,
  ) {
    return Divider();
  }

  Widget _renderTaskListItemNode(TaskListItemNode node, BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: node.complete,
          onChanged: (bool? value) {
            // Handle checkbox change
          },
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              children:
                  node.children
                      .map((child) => _renderChildNode(child, context))
                      .toList(),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
      ],
    );
  }
}
