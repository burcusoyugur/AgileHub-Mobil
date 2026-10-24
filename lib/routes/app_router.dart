import 'package:go_router/go_router.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/projects_screen.dart';
import '../screens/project_detail_screen.dart';
import '../screens/task_board_screen.dart';
import '../screens/task_detail_screen.dart';
import '../screens/task_form_screen.dart';
import '../screens/my_tasks_screen.dart';
import '../screens/sprint_summary_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
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
      builder: (context, state) => ProjectDetailScreen(
        projectId: state.pathParameters['projectId']!,
      ),
    ),
    GoRoute(
      path: '/projects/:projectId/board',
      builder: (context, state) => TaskBoardScreen(
        projectId: state.pathParameters['projectId']!,
      ),
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
      builder: (context, state) => TaskFormScreen(
        projectId: state.pathParameters['projectId']!,
      ),
    ),
    GoRoute(
      path: '/my-tasks',
      builder: (context, state) => const MyTasksScreen(),
    ),
    GoRoute(
      path: '/projects/:projectId/sprint-summary',
      builder: (context, state) => SprintSummaryScreen(
        projectId: state.pathParameters['projectId']!,
      ),
    ),
  ],
);
