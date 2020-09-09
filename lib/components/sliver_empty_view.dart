import 'package:flutter/material.dart';

class SliverEmptyView extends StatelessWidget {
  final String title;

  SliverEmptyView({
    this.title = 'This section is empty',
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(60.0),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          Column(
            children: [
              Icon(
                Icons.do_not_disturb_alt,
                size: 50.0,
              ),

              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Opacity(
                  opacity: 0.6,
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 30.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
