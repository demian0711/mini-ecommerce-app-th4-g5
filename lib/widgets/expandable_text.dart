import 'package:flutter/material.dart';

class ExpandableText extends StatefulWidget {
  const ExpandableText(
    this.text, {
    super.key,
    this.trimLines = 5,
    this.style,
    this.moreLabel = 'Xem thêm',
    this.lessLabel = 'Thu gọn',
  });

  final String text;
  final int trimLines;
  final TextStyle? style;
  final String moreLabel;
  final String lessLabel;

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final defaultStyle = widget.style ?? DefaultTextStyle.of(context).style;

    return LayoutBuilder(
      builder: (context, constraints) {
        final span = TextSpan(text: widget.text, style: defaultStyle);
        final painter = TextPainter(
          text: span,
          maxLines: widget.trimLines,
          textDirection: Directionality.of(context),
        )..layout(maxWidth: constraints.maxWidth);

        final exceeds = painter.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              span,
              maxLines: _expanded ? null : widget.trimLines,
              overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            ),
            if (exceeds)
              TextButton(
                onPressed: () {
                  setState(() {
                    _expanded = !_expanded;
                  });
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: Text(_expanded ? widget.lessLabel : widget.moreLabel),
              ),
          ],
        );
      },
    );
  }
}
