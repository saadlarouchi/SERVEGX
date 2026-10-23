class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String serverList = '/server_list';
  static const String serverCreate = '/server_create';
  static const String serverDetail = '/server_detail';
  static const String projectList = '/project_list';
  static const String projectCreate = '/project_create';
  static const String alerts = '/alerts';
  static const String logs = '/logs';
  static const String notifications = '/notifications';
  static const String adminDashboard = '/admin_dashboard';
  static const String users = '/users';

  static const Set<String> mainRoutes = {
    dashboard,
    serverList,
    projectList,
    alerts,
    logs,
    notifications,
    adminDashboard,
    users,
  };

  static const Set<String> bottomBarRoutes = {
    dashboard,
    serverList,
    projectList,
    alerts,
  };

  static String getTitle(String? route) {
    switch (route) {
      case dashboard:
        return 'Overview';
      case serverList:
        return 'Servers';
      case serverCreate:
        return 'New Server';
      case serverDetail:
        return 'Server Details';
      case projectList:
        return 'Projects';
      case projectCreate:
        return 'New Project';
      case alerts:
        return 'Alerts';
      case logs:
        return 'Logs explorer';
      case notifications:
        return 'Notifications';
      case adminDashboard:
        return 'Administration';
      case users:
        return 'Users & Access';
      default:
        return 'SERVEGX';
    }
  }
}
