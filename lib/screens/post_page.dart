import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as markdown;
import 'package:rootasjey/components/home_app_bar.dart';
import 'package:rootasjey/components/markdown_viewer.dart';
import 'package:rootasjey/components/sliver_loading_view.dart';
import 'package:rootasjey/state/colors.dart';
import 'package:rootasjey/types/post.dart';
import 'package:rootasjey/utils/cloud.dart';
import 'package:rootasjey/utils/keybindings.dart';
import 'package:rootasjey/utils/mesure_size.dart';
import 'package:rootasjey/utils/snack.dart';
import 'package:unicons/unicons.dart';
import 'package:supercharged/supercharged.dart';

class PostPage extends StatefulWidget {
  @required
  final String postId;

  PostPage({@PathParam() this.postId});

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  bool _isLoading = false;
  bool _isTOCVisible = false;
  bool _isFabVisible = false;

  final double _textWidth = 750.0;
  final _scrollController = ScrollController();

  FocusNode _focusNode = FocusNode();

  KeyBindings _keyBindings = KeyBindings();

  Post _post;

  String _postData = '';

  @override
  initState() {
    super.initState();

    fetchMeta();
    fetchContent();

    // Delay initialization.
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _keyBindings.init(
        scrollController: _scrollController,
        pageHeight: 100.0,
        router: context.router,
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: fab(),
      body: RawKeyboardListener(
        autofocus: true,
        focusNode: _focusNode,
        onKey: _keyBindings.onKey,
        child: NotificationListener<ScrollNotification>(
          onNotification: onNotification,
          child: Scrollbar(
            controller: _scrollController,
            child: Focus(
              descendantsAreFocusable: false,
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  appBar(),
                  body(),
                  SliverPadding(
                    padding: const EdgeInsets.only(
                      bottom: 400.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget appBar() {
    return HomeAppBar(
      automaticallyImplyLeading: true,
      title: Opacity(
        opacity: 0.6,
        child: Text(
          _post != null ? _post.title : "post".tr(),
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: stateColors.foreground,
          ),
        ),
      ),
      trailing: [
        IconButton(
          color: stateColors.foreground,
          icon: Icon(UniconsLine.bars),
          onPressed: () {
            setState(() => _isTOCVisible = !_isTOCVisible);
          },
        ),
      ],
    );
  }

  Widget body() {
    if (_isLoading) {
      return SliverLoadingView(
        title: "loading_post".tr(),
      );
    }

    final bool isNarrow = MediaQuery.of(context).size.width < 500.0;

    return SliverList(
      delegate: SliverChildListDelegate([
        Row(
          children: [
            if (!isNarrow) Spacer(),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                ),
                child: MeasureSize(
                  onChange: (size) {
                    _keyBindings.updatePageHeight(size.height);
                  },
                  child: MarkdownViewer(
                    data: _postData,
                    width: _textWidth,
                  ),
                ),
              ),
            ),
            if (!isNarrow) Spacer(),
          ],
        ),
      ]),
    );
  }

  Widget fab() {
    if (!_isFabVisible) {
      return Container();
    }

    return FloatingActionButton(
      backgroundColor: stateColors.primary,
      foregroundColor: Colors.white,
      onPressed: () => _scrollController.animateTo(
        0,
        duration: 250.milliseconds,
        curve: Curves.bounceOut,
      ),
      child: Icon(Icons.arrow_upward),
    );
  }

  void fetchMeta() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .get();

      if (!doc.exists) {
        return;
      }

      final data = doc.data();
      data['id'] = doc.id;

      setState(() {
        _post = Post.fromJSON(data);
      });
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  void fetchContent() async {
    setState(() => _isLoading = true);

    try {
      final response =
          await Cloud.fun('posts-fetch').call({'postId': widget.postId});
      final markdownData = response.data['post'];

      _postData = markdown.markdownToHtml(markdownData);

      setState(() => _isLoading = false);
    } catch (error) {
      setState(() => _isLoading = false);
      debugPrint(error.toString());

      Snack.e(
        context: context,
        message: "post_fetch_error".tr(),
      );
    }
  }

  bool onNotification(ScrollNotification notification) {
    // FAB visibility
    if (notification.metrics.pixels < 50 && _isFabVisible) {
      setState(() => _isFabVisible = false);
    } else if (notification.metrics.pixels > 50 && !_isFabVisible) {
      setState(() => _isFabVisible = true);
    }

    return false;
  }
}
