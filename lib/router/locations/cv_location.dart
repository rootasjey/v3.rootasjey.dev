import 'package:beamer/beamer.dart';
import 'package:flutter/widgets.dart';
import 'package:rootasjey/screens/cv_page.dart';

class CVLocation extends BeamLocation<BeamState> {
  static const String route = "/cv";

  @override
  List<Pattern> get pathPatterns => [route];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      const BeamPage(
        child: CVPage(),
        key: ValueKey(route),
        title: 'CV',
        type: BeamPageType.fadeTransition,
      ),
    ];
  }
}
