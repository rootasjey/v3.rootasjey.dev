import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:rootasjey/components/buttons/dark_elevated_button.dart';
import 'package:rootasjey/components/icons/app_icon.dart';
import 'package:rootasjey/globals/constants.dart';
import 'package:rootasjey/globals/utils.dart';

class CreateProjectPage extends StatefulWidget {
  const CreateProjectPage({
    super.key,
    this.onCancel,
    this.onSubmit,
    this.isMobileSize = false,
  });

  /// Adapat the ui to small screens if true.
  final bool isMobileSize;

  /// Called to dismiss this create view.
  final void Function()? onCancel;

  /// Try to create a new project with the desired values.
  final void Function(String name, String summary)? onSubmit;

  @override
  State<StatefulWidget> createState() => _CreateProjectPageState();
}

class _CreateProjectPageState extends State<CreateProjectPage> {
  /// Follow the user text input for project's name.
  final TextEditingController _nameController = TextEditingController();

  /// Follow the user text input for project's summary.
  final TextEditingController _summaryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final int randomInt = Random().nextInt(5);

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 60.0,
            left: widget.isMobileSize ? 24.0 : 60.0,
            child: const AppIcon(),
          ),
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Center(
                  child: Container(
                    width: 600.0,
                    padding: const EdgeInsets.only(
                      top: 160.0,
                      left: 12.0,
                      right: 12.0,
                      bottom: 200.0,
                    ),
                    child: Column(
                      children: [
                        header(),
                        nameInput(randomHint: randomInt),
                        summaryInput(randomHint: randomInt),
                        footerButtons(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget header() {
    return Column(
      children: [
        Icon(
          TablerIcons.layout,
          size: 42.0,
          color: Constants.colors.palette.first,
        ),
        Text(
          "project.create".tr(),
          style: Utils.calligraphy.body(
            textStyle: const TextStyle(
              fontSize: 32.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Opacity(
            opacity: 0.4,
            child: Text(
              "project.create_subtitle".tr(),
              textAlign: TextAlign.center,
              style: Utils.calligraphy.body2(
                textStyle: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget nameInput({int randomHint = 0}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 54.0,
            bottom: 8.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "project_name".tr(),
                style: Utils.calligraphy.body(
                  textStyle: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            bottom: 12.0,
          ),
          child: TextField(
            autofocus: true,
            controller: _nameController,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: "project.create.template.names.$randomHint".tr(),
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Constants.colors.palette.first,
                  width: 2.0,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withOpacity(0.4) ??
                      Colors.white12,
                  width: 2.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Constants.colors.palette.first,
                  width: 4.0,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget summaryInput({int randomHint = 0}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 16.0,
            bottom: 8.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "project_summary".tr(),
                style: Utils.calligraphy.body(
                  textStyle: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            bottom: 12.0,
          ),
          child: TextField(
            autofocus: false,
            controller: _summaryController,
            textInputAction: TextInputAction.go,
            onSubmitted: (String summary) {
              widget.onSubmit?.call(_nameController.text, summary);
            },
            decoration: InputDecoration(
              hintText: "project.create.template.summaries.$randomHint".tr(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Constants.colors.palette.elementAt(1),
                  width: 4.0,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withOpacity(0.4) ??
                      Colors.white12,
                  width: 2.0,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget footerButtonsMobile() {
    return Padding(
      padding: const EdgeInsets.only(top: 42.0),
      child: Wrap(
        spacing: 24.0,
        runSpacing: 12.0,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: TextButton(
              onPressed: () => widget.onCancel?.call(),
              style: OutlinedButton.styleFrom(
                foregroundColor: Constants.colors.palette.first,
                backgroundColor:
                    Constants.colors.palette.first.withOpacity(0.05),
                minimumSize: const Size(140.0, 56.0),
              ),
              child: Text(
                "cancel".tr(),
                style: Utils.calligraphy.body(
                  textStyle: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          DarkElevatedButton(
            onPressed: () {
              widget.onSubmit?.call(
                _nameController.text,
                _summaryController.text,
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "create".tr(),
                    style: Utils.calligraphy.body(
                      textStyle: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w700,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Icon(
                      TablerIcons.arrow_right,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget footerButtons() {
    if (widget.isMobileSize) {
      return footerButtonsMobile();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Wrap(
        spacing: 24.0,
        runSpacing: 24.0,
        children: [
          DarkElevatedButton.icon(
            iconData: TablerIcons.x,
            labelValue: "cancel".tr(),
            background: Colors.black,
            onPressed: () => widget.onCancel?.call(),
          ),
          DarkElevatedButton.large(
            onPressed: () {
              widget.onSubmit?.call(
                _nameController.text,
                _summaryController.text,
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "create".tr(),
                    style: Utils.calligraphy.body(
                      textStyle: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w700,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Icon(
                      TablerIcons.arrow_right,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
