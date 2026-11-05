import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/projects_screen.dart';
import '../screens/project_detail_screen.dart';
import '../screens/sprint_list_screen.dart';
import '../screens/task_board_screen.dart';
import '../screens/task_detail_screen.dart';
import '../screens/task_form_screen.dart';
import '../screens/my_tasks_screen.dart';
import '../screens/sprint_summary_screen.dart';
import '../screens/splash_screen.dart';

/// Oturum durumuna göre yönlendirme yapan router'ı oluşturur.
GoRouter createRouter(AuthProvider auth) => GoRouter(
  initialLocation: '/splash',
  refreshListenable: auth,
  redirect: (context, state) {
    final location = state.matchedLocation;

    // Kayıtlı oturum kontrol edilirken bekleme ekranında kal.
    if (auth.isInitializing) {
      return location == '/splash' ? null : '/splash';
    }

    final onAuthPage = location == '/login' || location == '/register';
    if (!auth.isLoggedIn) {
      return onAuthPage ? null : '/login';
    }
    return (onAuthPage || location == '/splash') ? '/projects' : null;
  },
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/projects',
      builder: (context, state) => const ProjectsScreen(),
    ),
    GoRoute(
      path: '/projects/:projectId',
      builder: (context, state) =>
          ProjectDetailScreen(projectId: state.pathParameters['projectId']!),
    ),
    GoRoute(
      path: '/projects/:projectId/sprints',
      builder: (context, state) =>
          SprintListScreen(projectId: state.pathParameters['projectId']!),
    ),
    GoRoute(
      path: '/projects/:projectId/board',
      builder: (context, state) =>
          TaskBoardScreen(projectId: state.pathParameters['projectId']!),
    ),
    GoRoute(
      path: '/projects/:projectId/task/:taskId',
      builder: (context, state) => TaskDetailScreen(
        projectId: state.pathParameters['projectId']!,
        taskId: state.pathParameters['taskId']!,
      ),
    ),
    GoRoute(
      path: '/projects/:projectId/task/:taskId/edit',
      builder: (context, state) => TaskFormScreen(
        projectId: state.pathParameters['projectId']!,
        taskId: state.pathParameters['taskId'],
      ),
    ),
    GoRoute(
      path: '/projects/:projectId/task/new',
      builder: (context, state) =>
          TaskFormScreen(projectId: state.pathParameters['projectId']!),
    ),
    GoRoute(
      path: '/my-tasks',
      builder: (context, state) => const MyTasksScreen(),
    ),
    GoRoute(
      path: '/projects/:projectId/sprint-summary',
      builder: (context, state) =>
          SprintSummaryScreen(projectId: state.pathParameters['projectId']!),
    ),
  ],
);
