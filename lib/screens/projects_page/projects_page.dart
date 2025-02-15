import 'package:beamer/beamer.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_solidart/flutter_solidart.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:loggy/loggy.dart';
import 'package:rootasjey/components/loading_view.dart';
import 'package:rootasjey/globals/constants.dart';
import 'package:rootasjey/globals/utils.dart';
import 'package:rootasjey/router/locations/home_location.dart';
import 'package:rootasjey/screens/projects_page/create_project_page.dart';
import 'package:rootasjey/screens/projects_page/projects_page_body.dart';
import 'package:rootasjey/screens/projects_page/projects_page_empty_view.dart';
import 'package:rootasjey/types/alias/firestore/document_change_map.dart';
import 'package:rootasjey/types/alias/firestore/query_doc_snap_map.dart';
import 'package:rootasjey/types/alias/firestore/query_map.dart';
import 'package:rootasjey/types/alias/firestore/query_snap_map.dart';
import 'package:rootasjey/types/alias/firestore/query_snapshot_stream_subscription.dart';
import 'package:rootasjey/types/alias/json_alias.dart';
import 'package:rootasjey/types/enums/enum_project_item_action.dart';
import 'package:rootasjey/types/enums/enum_signal_id.dart';
import 'package:rootasjey/types/project/project.dart';
import 'package:rootasjey/types/user/user_firestore.dart';
import 'package:rootasjey/types/user/user_rights.dart';

/// A page widget showing projects.
class ProjectsPage extends StatefulWidget {
  const ProjectsPage({
    super.key,
    this.onGoHome,
    this.onGoBack,
  });

  /// Callback to go back to the previous page.
  final void Function()? onGoBack;

  /// Callback to go back to the home page.
  final void Function()? onGoHome;

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> with UiLoggy {
  /// True if there're more projects to fetch.
  bool _hasNext = true;

  /// True if the page is fetching projects.
  bool _loading = false;

  /// True if we're try to create a new project.
  bool _creating = false;

  /// If true, show a specific UI to create a project.
  bool _showCreatePage = false;

  /// Accent color for border and title.
  Color _accentColor = Colors.blue;

  /// Last document fetched from Firestore.
  DocumentSnapshot? _lastDocument;

  /// Maximum projects fetch per page.
  final int _limit = 10;

  /// Project list. This is the main page content.
  final List<Project> _projects = [];

  /// Allow to go forward or backward with the keyboard keys.
  final SwiperController _swipeController = SwiperController();

  /// Listens to projects' updates.
  QuerySnapshotStreamSubscription? _projectSubscription;

  /// Firestore collection name.
  final String _collectionName = "projects";

  @override
  void initState() {
    super.initState();
    _accentColor = Constants.colors.getRandomBackground();
    fetchProjects();
  }

  @override
  void dispose() {
    _swipeController.dispose();
    _projectSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Signal<UserFirestore> signalUserFirestore =
        context.get(EnumSignalId.userFirestore);
    final UserRights userRights = signalUserFirestore.value.rights;
    final bool canManageProjects = userRights.managePosts;

    final bool isMobileSize = Utils.graphic.isMobileSize(context);
    final Size windowSize = MediaQuery.of(context).size;

    if (_showCreatePage) {
      return CreateProjectPage(
        isMobileSize: isMobileSize,
        onCancel: () => setState(() => _showCreatePage = false),
        onSubmit: (String name, String summary) {
          _showCreatePage = false;
          tryCreateProject(name: name, summary: summary);
        },
      );
    }

    if (_creating) {
      return LoadingView.scaffold(
        message: _creating
            ? "${"project.creating".tr()}..."
            : "${"projects.loading_featured".tr()}...",
      );
    }

    if (_projects.isEmpty) {
      return ProjectsPageEmptyView(
        isMobileSize: isMobileSize,
        canCreate: canManageProjects,
        fab: fab(show: canManageProjects),
        onShowCreatePage: onShowCreate,
        onCancel: onCancel,
      );
    }

    return ProjectsPageBody(
      accentColor: _accentColor,
      isMobileSize: isMobileSize,
      canManage: canManageProjects,
      onGoHome: widget.onGoHome,
      onGoBack: widget.onGoBack,
      fab: fab(show: canManageProjects),
      onTapProject: onTapProject,
      projects: _projects,
      windowSize: windowSize,
    );
  }

  Widget fab({required bool show}) {
    if (!show) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.only(right: 12.0, bottom: 12.0),
      child: FloatingActionButton.extended(
        backgroundColor: _accentColor,
        onPressed: onShowCreate,
        shape: const StadiumBorder(),
        icon: const Icon(TablerIcons.plus, size: 16.0),
        label: Text(
          "project_create".tr(),
          style: Utils.calligraphy.body4(
            textStyle: const TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  void onShowCreate() {
    setState(() => _showCreatePage = true);
  }

  /// Make a API request call to create a new document in Firestore
  /// and suitable files in Storage.
  void tryCreateProject({
    required String name,
    required String summary,
  }) async {
    final Signal<UserFirestore> signalUserFirestore =
        context.get(EnumSignalId.userFirestore);

    final String userId = signalUserFirestore.value.id;
    if (userId.isEmpty) return;
    setState(() => _creating = true);

    try {
      // final DocumentMap projectSnapshot =
      //     await FirebaseFirestore.instance.collection("projects").add({
      //   "language": "en",
      //   "name": name,
      //   "summary": summary,
      //   "user_id": userId,
      // });

      setState(() => _creating = false);

      if (!mounted) {
        return;
      }
    } on Exception catch (error) {
      loggy.error(error);
      setState(() {
        _creating = false;
      });
    }
  }

  void fetchProjects() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _projects.clear();
    });

    try {
      final QueryMap query = getFirestoreQuery();
      listenToProjectEvents(query);

      final QuerySnapMap snapshot = await query.get();

      if (snapshot.size == 0) {
        if (!mounted) return;
        setState(() {
          _hasNext = false;
          _loading = false;
        });

        return;
      }

      for (final QueryDocSnapMap doc in snapshot.docs) {
        final Json map = doc.data();
        map["id"] = doc.id;

        _projects.add(Project.fromMap(map));
      }

      if (!mounted) return;
      setState(() {
        _loading = false;
        _lastDocument = snapshot.docs.last;
        _hasNext = _limit == snapshot.size;
      });
    } catch (error) {
      loggy.error(error);
    }
  }

  void fetchMoreProjects() async {
    final DocumentSnapshot? lastDocument = _lastDocument;
    if (!_hasNext || _loading || lastDocument == null) {
      return;
    }

    if (!mounted) return;
    setState(() => _loading = true);

    try {
      final QueryMap query = getFirestoreQuery();
      listenToProjectEvents(query);

      final QuerySnapMap snapshot = await query.get();

      if (snapshot.size == 0) {
        if (!mounted) return;
        setState(() {
          _hasNext = false;
          _loading = false;
        });

        return;
      }

      for (final QueryDocSnapMap doc in snapshot.docs) {
        final Json data = doc.data();
        data["id"] = doc.id;
        _projects.add(Project.fromMap(data));
      }

      if (!mounted) return;
      setState(() {
        _loading = false;
        _lastDocument = snapshot.docs.last;
        _hasNext = _limit == snapshot.size;
      });
    } catch (error) {
      loggy.error(error);
    }
  }

  void onTapProject(Project project) {}

  /// Return the query to listen changes to.
  QueryMap getFirestoreQuery() {
    final DocumentSnapshot? lastDocument = _lastDocument;

    final Signal<UserFirestore> signalUserFirestore =
        context.get(EnumSignalId.userFirestore);

    final String userId = signalUserFirestore.value.id;

    if (userId.isEmpty) {
      if (lastDocument == null) {
        return FirebaseFirestore.instance
            .collection(_collectionName)
            .where("visibility", isEqualTo: "public")
            .orderBy("updated_at", descending: true)
            .limit(_limit);
      }

      return FirebaseFirestore.instance
          .collection(_collectionName)
          .where("visibility", isEqualTo: "public")
          .orderBy("updated_at", descending: true)
          .endAtDocument(lastDocument);
    }

    if (lastDocument == null) {
      return FirebaseFirestore.instance
          .collection(_collectionName)
          .where("user_id", isEqualTo: userId)
          .orderBy("updated_at", descending: true)
          .limit(_limit);
    }

    return FirebaseFirestore.instance
        .collection(_collectionName)
        .where("user_id", isEqualTo: userId)
        .orderBy("updated_at", descending: true)
        .endAtDocument(lastDocument);
  }

  void listenToProjectEvents(QueryMap? query) {
    if (query == null) {
      return;
    }

    _projectSubscription?.cancel();
    _projectSubscription = query.snapshots().skip(1).listen(
      (snapshot) {
        for (DocumentChangeMap documentChange in snapshot.docChanges) {
          switch (documentChange.type) {
            case DocumentChangeType.added:
              onAddStreamingProject(documentChange);
              break;
            case DocumentChangeType.modified:
              onUpdateStreamingProject(documentChange);
              break;
            case DocumentChangeType.removed:
              onRemoveStreamingProject(documentChange);
              break;
          }
        }
      },
      onError: (error) {
        loggy.error(error);
      },
    );
  }

  /// Fire when a new document has been created in Firestore.
  /// Add the corresponding document in the UI.
  void onAddStreamingProject(DocumentChangeMap documentChange) {
    final Json? data = documentChange.doc.data();

    if (data == null) {
      return;
    }

    setState(() {
      data["id"] = documentChange.doc.id;
      final Project project = Project.fromMap(data);
      _projects.insert(0, project);
    });
  }

  /// Fire when a new document has been updated in Firestore.
  /// Update the corresponding document in the UI.
  void onUpdateStreamingProject(DocumentChangeMap documentChange) async {
    try {
      final Json? data = documentChange.doc.data();
      if (data == null) {
        return;
      }

      final int index = _projects.indexWhere(
        (Project p) => p.id == documentChange.doc.id,
      );

      data["id"] = documentChange.doc.id;
      final updatedProject = Project.fromMap(data);

      if (!mounted) return;
      setState(() {
        _projects.removeAt(index);
        _projects.insert(index, updatedProject);
      });
    } on Exception catch (error) {
      loggy.error(
        "The document with the id ${documentChange.doc.id} "
        "doesn't exist in the project list.",
      );

      loggy.error(error);
    }
  }

  /// Fire when a new document has been delete from Firestore.
  /// Delete the corresponding document from the UI.
  void onRemoveStreamingProject(DocumentChangeMap documentChange) {
    if (!mounted) return;
    setState(() {
      _projects.removeWhere(
        (project) => project.id == documentChange.doc.id,
      );
    });
  }

  void onPopupMenuItemSelected(
    EnumProjectItemAction action,
    int index,
    Project project,
  ) {
    switch (action) {
      case EnumProjectItemAction.delete:
        tryDeleteProject(
          index: index,
          project: project,
        );
        break;
      default:
    }
  }

  void tryDeleteProject({
    required int index,
    required Project project,
  }) async {
    setState((() {
      _projects.removeAt(index);
    }));

    try {
      await FirebaseFirestore.instance
          .collection(_collectionName)
          .doc(project.id)
          .delete();

      if (!mounted) {
        return;
      }
    } catch (error) {
      loggy.error(error);

      setState(() {
        _projects.insert(index, project);
      });
    }
  }

  void onCancel() {
    if (Beamer.of(context).beamingHistory.isNotEmpty) {
      Beamer.of(context).beamBack();
      return;
    }

    Beamer.of(context, root: true).beamToNamed(HomeLocation.route);
  }

  void onNextProject() {
    _swipeController.next();
  }

  void onPreviousProject() {
    _swipeController.previous();
  }
}
