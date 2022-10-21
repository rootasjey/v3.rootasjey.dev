import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rootasjey/components/upload_panel/upload_card_item.dart';
import 'package:rootasjey/globals/app_state.dart';
import 'package:rootasjey/globals/utilities.dart';
import 'package:rootasjey/types/custom_upload_task.dart';

/// Body of `UploadPanel`.
class UploadPanelBody extends ConsumerWidget {
  const UploadPanelBody({
    Key? key,
    required this.expanded,
    required this.uploadTaskList,
    this.onToggleExpanded,
    this.isMobileSize = false,
  }) : super(key: key);

  /// The panel has its maximum size if true. Otherwise the window is minized.
  final bool expanded;

  /// If true, this widget adapts its layout to small screens.
  final bool isMobileSize;

  /// List of upload tasks.
  final List<CustomUploadTask> uploadTaskList;

  /// Callback event to expand or minimize upload panel.
  final void Function()? onToggleExpanded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!expanded) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 8.0,
            ),
            child: Text(
              "downloads".tr(),
              style: Utilities.fonts.body(
                fontSize: 24.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Divider(
            thickness: 1.5,
            color: Colors.black12,
            height: 20.0,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: uploadTaskList.map((CustomUploadTask customUploadTask) {
              return UploadCardItem(
                customUploadTask: customUploadTask,
                alternativeTheme: isMobileSize,
                onTap: () {},
                onCancel: () {
                  final int bytesTransferred =
                      customUploadTask.task?.snapshot.bytesTransferred ?? 0;

                  ref
                      .read(AppState.uploadBytesTransferredProvider.notifier)
                      .remove(bytesTransferred);
                  ref
                      .read(AppState.uploadTaskListProvider.notifier)
                      .cancel(customUploadTask);
                },
                onDone: () {
                  final int totalBytes =
                      customUploadTask.task?.snapshot.totalBytes ?? 0;

                  ref
                      .read(AppState.uploadBytesTransferredProvider.notifier)
                      .remove(totalBytes);
                  ref
                      .read(AppState.uploadTaskListProvider.notifier)
                      .removeDone(customUploadTask);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
