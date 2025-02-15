import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:rootasjey/components/application_bar.dart';
import 'package:rootasjey/components/buttons/dark_elevated_button.dart';
import 'package:rootasjey/globals/utils.dart';

class ProjectsPageEmptyView extends StatelessWidget {
  const ProjectsPageEmptyView({
    super.key,
    required this.fab,
    this.canCreate = false,
    this.isMobileSize = false,
    this.onShowCreatePage,
    this.onCancel,
  });

  /// True if the current authenticated user can create projects.
  final bool canCreate;

  /// True if the screen size is mobile.
  final bool isMobileSize;

  /// Callback fired to show create page.
  final void Function()? onShowCreatePage;

  /// Callback fired to go back to the previous page or home location.
  final void Function()? onCancel;

  /// Page floating action button showing creation button if available.
  final Widget fab;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: fab,
      body: CustomScrollView(slivers: [
        const ApplicationBar(),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 200.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  "assets/animations/skull_bats.json",
                  width: 200.0,
                  height: 200.0,
                  repeat: true,
                ),
                Text(
                  canCreate
                      ? "project_empty_create".tr()
                      : "project_empty".tr(),
                  style: Utils.calligraphy.body2(
                    textStyle: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (canCreate)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: DarkElevatedButton(
                      onPressed: canCreate ? onShowCreatePage : null,
                      child: Text("project.create".tr()),
                    ),
                  ),
                if (!canCreate)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: DarkElevatedButton(
                      onPressed: onCancel,
                      child: Text("back".tr()),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
