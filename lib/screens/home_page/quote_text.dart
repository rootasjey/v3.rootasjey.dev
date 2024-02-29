import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rootasjey/globals/constants.dart';
import 'package:rootasjey/globals/utils.dart';

class QuoteText extends StatefulWidget {
  const QuoteText({
    super.key,
    required this.quoteText,
    this.author = "",
    this.reference = "",
  });

  final String quoteText;
  final String author;
  final String reference;

  @override
  State<QuoteText> createState() => _QuoteTextState();
}

class _QuoteTextState extends State<QuoteText> {
  Color _shadowColor = Colors.transparent;

  @override
  Widget build(BuildContext context) {
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    final String authorText = widget.author.isNotEmpty ? widget.author : "";
    final String referenceText =
        widget.author.isNotEmpty ? widget.reference : "";
    final String secondHyphen =
        authorText.isNotEmpty && referenceText.isNotEmpty ? " - " : "";
    final String metaText = authorText.isEmpty && referenceText.isEmpty
        ? ""
        : "\n — $authorText$secondHyphen$referenceText";

    return InkWell(
      hoverColor: Colors.transparent,
      splashColor: _shadowColor,
      borderRadius: BorderRadius.circular(12.0),
      onHover: (bool isHit) {
        setState(() {
          _shadowColor = isHit
              ? Constants.colors.getRandomBackground()
              : Colors.transparent;
        });
      },
      onTap: () {
        Clipboard.setData(
          ClipboardData(text: widget.quoteText),
        );

        Utils.graphic.showSnackbar(
          context,
          message: "Copied to clipboard!",
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: widget.quoteText,
                style: TextStyle(
                  shadows: [
                    Shadow(
                      color: _shadowColor,
                      offset: const Offset(4, 4),
                      blurRadius: 2.0,
                    ),
                  ],
                ),
              ),
              TextSpan(
                text: metaText,
                style: Utils.calligraphy.body4(
                  textStyle: TextStyle(
                    fontSize: 24.0,
                    color: foregroundColor?.withOpacity(0.4),
                  ),
                ),
              ),
            ],
          ),
          style: Utils.calligraphy.body4(
            textStyle: TextStyle(
              fontSize: 54.0,
              fontWeight: FontWeight.w400,
              color: foregroundColor?.withOpacity(0.8),
            ),
          ),
        ),
      ),
    );
  }
}
