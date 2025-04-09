import 'package:flutter/material.dart';
import 'package:fymemos/mark/ast/node.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:fymemos/utils/strings.dart';
import 'package:fymemos/widgets/embedded_memo.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class MemoContent extends StatelessWidget {
  final List<BaseNode> nodes;
  final Function onCheckClicked;
  const MemoContent({
    super.key,
    required this.nodes,
    required this.onCheckClicked,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...nodes.map((node) {
          return _NodeRenderer(node: node, onCheckClicked: onCheckClicked);
        }),
      ],
    );
  }
}

class _NodeRenderer extends StatelessWidget {
  final BaseNode node;
  final Function? onCheckClicked;

  const _NodeRenderer({required this.node, this.onCheckClicked});

  @override
  Widget build(BuildContext context) {
    return _renderNode(node, context);
  }

  Widget _renderNode(BaseNode node, BuildContext context) {
    switch (node.getType()) {
      case NodeType.PARAGRAPH:
        return _renderParagraphNode(node as Paragraph, context);
      case NodeType.LIST:
        return _renderListNode(node as ListBlock, context);
      case NodeType.LINE_BREAK:
        return _renderLineBreakNode(node as LineBreak, context);
      case NodeType.HORIZONTAL_RULE:
        return _renderHorizontalRuleNode(node as HorizontalRule, context);
      case NodeType.HEADING:
        return _renderHeadingNode(node as Heading, context);
      case NodeType.CODE_BLOCK:
        return _renderCodeBlockNode(node as CodeBlock, context);
      case NodeType.EMBEDDED_CONTENT:
        return _renderEmbeddedContentNode(node as EmbeddedContent, context);
      case NodeType.UNORDERED_LIST_ITEM:
        return _renderUnorderedListItemNode(node as UnorderedListItem, context);
      case NodeType.ORDERED_LIST_ITEM:
        return _renderOrderedListItemNode(node as OrderedListItem, context);
      case NodeType.TASK_LIST_ITEM:
        return _renderTaskListItemNode(node as TaskListItem, context);
      case NodeType.IMAGE:
        return _renderImageNode(node as ImageNode, context);
      case NodeType.BLOCKQUOTE:
        return _renderBlockquoteNode(node as Blockquote, context);
      case NodeType.MATH_BLOCK:
        return _renderMathBlockNode(node as MathBlock, context);
      case NodeType.TABLE:
        return _renderTableBlockNode(node as TableBlock, context);
      default:
        throw Exception('unsupport node type: ${node.getType()}');
    }
  }

  Widget _renderTableBlockNode(TableBlock node, BuildContext context) {
    return Table(
      border: TableBorder.all(color: Theme.of(context).dividerColor, width: 2),
      columnWidths: _calculateColumnWidths(node),
      children: [
        // 渲染表头
        TableRow(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
          ),
          children:
              node.header
                  .map(
                    (cell) => _renderTableCell(cell, context, isHeader: true),
                  )
                  .toList(),
        ),
        // 渲染表格内容
        ...node.rows.map(
          (row) => TableRow(
            children:
                row.map((cell) => _renderTableCell(cell, context)).toList(),
          ),
        ),
      ],
    );
  }

  Map<int, TableColumnWidth> _calculateColumnWidths(TableBlock node) {
    final columnWidths = <int, TableColumnWidth>{};
    for (var i = 0; i < node.header.length; i++) {
      columnWidths[i] = const FlexColumnWidth();
    }
    return columnWidths;
  }

  Widget _renderTableCell(
    BaseNode cell,
    BuildContext context, {
    bool isHeader = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: DefaultTextStyle(
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_renderNode(cell, context)],
        ),
      ),
    );
  }

  InlineSpan _renderChildNode(BaseNode node, BuildContext context) {
    switch (node.getType()) {
      case NodeType.TAG:
        return _renderTagNode(node as Tag, context);
      case NodeType.TEXT:
        return _renderTextNode(node as TextNode, context);
      case NodeType.AUTO_LINK:
        return _renderAutoLinkNode(node as AutoLink, context);
      case NodeType.BOLD:
        return _renderBoldNode(node as BoldNode, context);
      case NodeType.ITALIC:
        return _renderItalicNode(node as ItalicNode, context);
      case NodeType.BOLD_ITALIC:
        return _renderBoldItalicNode(node as BoldItalicNode, context);
      case NodeType.STRIKETHROUGH:
        return _renderStrikethroughNode(node as Strikethrough, context);
      case NodeType.IMAGE:
        return WidgetSpan(child: _renderImageNode(node as ImageNode, context));
      case NodeType.LINK:
        return _renderLinkNode(node as LinkNode, context);
      case NodeType.SPOILER:
        return _renderSpoilerNode(node as Spoiler, context);
      case NodeType.CODE:
        return _renderInlineCodeNode(node as InlineCodeNode, context);
      case NodeType.HIGHLIGHT:
        return _renderHighlightNode(node as Highlight, context);
      case NodeType.SUBSCRIPT:
        return _renderSubscriptNode(node as Subscript, context);
      case NodeType.SUPERSCRIPT:
        return _renderSuperscriptNode(node as Superscript, context);
      case NodeType.MATH:
        return _renderMathNode(node as MathInline, context);
      case NodeType.ESCAPING_CHARACTER:
        return _renderEscapingCharacterNode(node as EscapingCharacter, context);
      case NodeType.REFERENCED_CONTENT:
        return _renderReferencedContentNode(node as ReferencedContent, context);
      default:
        {
          print("unsupport node type: ${node.getType()}");
          throw Exception('Unknown node type: ${node}');
        }
    }
  }

  Widget _renderMathBlockNode(MathBlock node, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
      ),
      child: Text(node.content, style: Theme.of(context).textTheme.bodyLarge),
    );
  }

  InlineSpan _renderReferencedContentNode(
    ReferencedContent node,
    BuildContext context,
  ) {
    return TextSpan(
      text: "📝${node.resourceName}",
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.primary,
      ),
      recognizer:
          TapGestureRecognizer()
            ..onTap = () {
              context.push('/memos/${node.resourceName.id}');
            },
    );
  }

  InlineSpan _renderEscapingCharacterNode(
    EscapingCharacter node,
    BuildContext context,
  ) {
    return TextSpan(
      text: node.symbol,
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }

  InlineSpan _renderMathNode(MathInline node, BuildContext context) {
    return TextSpan(
      text: node.content,
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }

  InlineSpan _renderSubscriptNode(Subscript node, BuildContext context) {
    return WidgetSpan(
      child: Transform.translate(
        offset: Offset(0, 6),
        child: Text(
          node.content,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 0.75,
          ),
        ),
      ),
    );
  }

  // 添加上标渲染方法
  InlineSpan _renderSuperscriptNode(Superscript node, BuildContext context) {
    return WidgetSpan(
      child: Transform.translate(
        offset: Offset(0, -6),
        child: Text(
          node.content,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 0.75,
          ),
        ),
      ),
    );
  }

  InlineSpan _renderHighlightNode(Highlight node, BuildContext context) {
    return TextSpan(
      text: node.content,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        backgroundColor:
            Theme.of(context).brightness == Brightness.light
                ? Colors.yellow[300]!.withAlpha(160)
                : Colors.yellow[600]!.withAlpha(80),
      ),
    );
  }

  InlineSpan _renderInlineCodeNode(InlineCodeNode node, BuildContext context) {
    return TextSpan(
      text: ' ${node.content} ',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        backgroundColor: Colors.grey[400],
        fontFamily: 'monospace',
      ),
    );
  }

  Widget _renderBlockquoteNode(Blockquote node, BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiaryContainer,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  node.children
                      .map((child) => _renderNode(child, context))
                      .toList(),
            ),
          ),
          Icon(
            Icons.format_quote,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ],
      ),
    );
  }

  Widget _renderImageNode(ImageNode node, BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: CachedNetworkImage(imageUrl: node.url),
    );
  }

  InlineSpan _renderSpoilerNode(Spoiler node, BuildContext context) {
    return WidgetSpan(child: _SpoilerText(text: node.content));
  }

  Widget _renderEmbeddedContentNode(
    EmbeddedContent node,
    BuildContext context,
  ) {
    return EmbeddedMemoItem(memoResourceName: node.resourceName);
  }

  Widget _renderHeadingNode(Heading node, BuildContext context) {
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

  Widget _renderCodeBlockNode(CodeBlock node, BuildContext context) {
    return Text(node.content, style: Theme.of(context).textTheme.bodyMedium);
  }

  Widget _renderParagraphNode(Paragraph node, BuildContext context) {
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

  Widget _renderListNode(ListBlock node, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          node.children
              .map(
                (child) =>
                    _NodeRenderer(node: child, onCheckClicked: onCheckClicked),
              )
              .toList(),
    );
  }

  InlineSpan _renderTagNode(Tag node, BuildContext context) {
    return WidgetSpan(
      child: GestureDetector(
        onTap: () {
          context.go("/tags/${node.tag}");
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          margin: EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.inversePrimary,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '#${node.tag}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      ),
    );
  }

  TextSpan _renderTextNode(TextNode node, BuildContext context) {
    return TextSpan(text: node.content);
  }

  TextSpan _renderBoldNode(BoldNode node, BuildContext context) {
    return TextSpan(
      style: TextStyle(fontWeight: FontWeight.bold),
      children:
          node.children
              .map((child) => _renderChildNode(child, context))
              .toList(),
    );
  }

  TextSpan _renderItalicNode(ItalicNode node, BuildContext context) {
    return TextSpan(
      style: TextStyle(fontStyle: FontStyle.italic),
      children:
          node.children
              .map((child) => _renderChildNode(child, context))
              .toList(),
    );
  }

  TextSpan _renderBoldItalicNode(BoldItalicNode node, BuildContext context) {
    return TextSpan(
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontStyle: FontStyle.italic,
      ),
      text: node.content,
    );
  }

  TextSpan _renderStrikethroughNode(Strikethrough node, BuildContext context) {
    return TextSpan(
      text: node.content,
      style: TextStyle(decoration: TextDecoration.lineThrough),
    );
  }

  TextSpan _renderAutoLinkNode(AutoLink node, BuildContext context) {
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
      children:
          node.content
              .map((child) => _renderChildNode(child, context))
              .toList(),
      style: TextStyle(color: Theme.of(context).primaryColor),
      recognizer:
          TapGestureRecognizer()
            ..onTap = () {
              launchUrl(Uri.parse(node.url));
            },
    );
  }

  Widget _renderLineBreakNode(LineBreak node, BuildContext context) {
    return SizedBox(height: 6);
  }

  Widget _renderHorizontalRuleNode(HorizontalRule node, BuildContext context) {
    return Divider();
  }

  Widget _renderTaskListItemNode(TaskListItem node, BuildContext context) {
    final textStyle =
        !node.complete
            ? Theme.of(context).textTheme.bodyLarge
            : Theme.of(context).textTheme.bodyLarge?.copyWith(
              decoration: TextDecoration.lineThrough,
            );
    return Row(
      children: [
        Checkbox(
          value: node.complete,
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onChanged: (bool? value) {
            node.complete = value ?? node.complete;
            onCheckClicked?.call();
          },
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              children:
                  node.children
                      .map((child) => _renderChildNode(child, context))
                      .toList(),
              style: textStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _renderListItemNode(
    BuildContext context,
    String symbol,
    List<BaseNode> children,
  ) {
    return Row(
      children: [
        Expanded(
          child: RichText(
            text: TextSpan(
              children: <InlineSpan>[
                TextSpan(
                  text: symbol,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                ...children.map((child) => _renderChildNode(child, context)),
              ],
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
      ],
    );
  }

  Widget _renderUnorderedListItemNode(
    UnorderedListItem node,
    BuildContext context,
  ) {
    return _renderListItemNode(context, "• ", node.children);
  }

  Widget _renderOrderedListItemNode(
    OrderedListItem node,
    BuildContext context,
  ) {
    return _renderListItemNode(context, "${node.number}. ", node.children);
  }
}

class _SpoilerText extends StatefulWidget {
  final String text;
  const _SpoilerText({required this.text});
  @override
  _SpoilerTextState createState() => _SpoilerTextState();
}

class _SpoilerTextState extends State<_SpoilerText> {
  bool _isVisible = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isVisible = !_isVisible;
        });
      },
      child: Text(
        widget.text,
        style: TextStyle(
          color: _isVisible ? Colors.black : Colors.grey,
          backgroundColor: _isVisible ? Colors.transparent : Colors.grey,
        ),
      ),
    );
  }
}
