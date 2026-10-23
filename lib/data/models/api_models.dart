// ═══════════════════════════════════════════
// AUTH MODELS
// ═══════════════════════════════════════════

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class LoginResponse {
  final String? accessToken;
  final String? token;
  final UserResponse? user;

  LoginResponse({this.accessToken, this.token, this.user});

  String? get resolvedToken => accessToken ?? token;

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['access_token'] as String?,
      token: json['token'] as String?,
      user: json['user'] != null
          ? UserResponse.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'access_token': accessToken,
    'token': token,
    'user': user?.toJson(),
  };
}

class UserResponse {
  final String? id;
  final String? name;
  final String? email;
  final String? role;

  UserResponse({this.id, this.name, this.email, this.role});

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: json['id']?.toString(),
      name: json['name'] as String?,
      email: json['email'] as String?,
      role: json['role'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role,
  };
}

class ApiErrorResponse {
  final String? message;
  final String? detail;

  ApiErrorResponse({this.message, this.detail});

  String get resolved => message ?? detail ?? 'Erreur inconnue';

  factory ApiErrorResponse.fromJson(Map<String, dynamic> json) {
    return ApiErrorResponse(
      message: json['message'] as String?,
      detail: json['detail'] as String?,
    );
  }
}

// ═══════════════════════════════════════════
// DASHBOARD & METRICS
// ═══════════════════════════════════════════

class DashboardResponse {
  final int totalServers;
  final int activeServers;
  final int totalProjects;
  final int totalAlerts;
  final int totalUsers;
  final double cpuUsage;
  final double ramUsage;
  final double diskUsage;
  final int runningProcesses;

  DashboardResponse({
    this.totalServers = 0,
    this.activeServers = 0,
    this.totalProjects = 0,
    this.totalAlerts = 0,
    this.totalUsers = 0,
    this.cpuUsage = 0.0,
    this.ramUsage = 0.0,
    this.diskUsage = 0.0,
    this.runningProcesses = 0,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      totalServers: (json['total_servers'] as num?)?.toInt() ?? 0,
      activeServers: (json['active_servers'] as num?)?.toInt() ?? 0,
      totalProjects: (json['total_projects'] as num?)?.toInt() ?? 0,
      totalAlerts: (json['total_alerts'] as num?)?.toInt() ?? 0,
      totalUsers: (json['total_users'] as num?)?.toInt() ?? 0,
      cpuUsage: (json['cpu_usage'] as num?)?.toDouble() ?? 0.0,
      ramUsage: (json['ram_usage'] as num?)?.toDouble() ?? 0.0,
      diskUsage: (json['disk_usage'] as num?)?.toDouble() ?? 0.0,
      runningProcesses: (json['running_processes'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'total_servers': totalServers,
    'active_servers': activeServers,
    'total_projects': totalProjects,
    'total_alerts': totalAlerts,
    'total_users': totalUsers,
    'cpu_usage': cpuUsage,
    'ram_usage': ramUsage,
    'disk_usage': diskUsage,
    'running_processes': runningProcesses,
  };
}

class MetricsModel {
  final double cpuUsage;
  final double ramUsage;
  final double diskUsage;
  final int runningProcesses;
  final double ramUsedGb;
  final double ramTotalGb;
  final double diskUsedGb;
  final double diskTotalGb;

  MetricsModel({
    this.cpuUsage = 0.0,
    this.ramUsage = 0.0,
    this.diskUsage = 0.0,
    this.runningProcesses = 0,
    this.ramUsedGb = 0.0,
    this.ramTotalGb = 0.0,
    this.diskUsedGb = 0.0,
    this.diskTotalGb = 0.0,
  });

  factory MetricsModel.fromJson(Map<String, dynamic> json) {
    return MetricsModel(
      cpuUsage: (json['cpu_usage'] as num?)?.toDouble() ?? 0.0,
      ramUsage: (json['ram_usage'] as num?)?.toDouble() ?? 0.0,
      diskUsage: (json['disk_usage'] as num?)?.toDouble() ?? 0.0,
      runningProcesses: (json['running_processes'] as num?)?.toInt() ?? 0,
      ramUsedGb: (json['ram_used_gb'] as num?)?.toDouble() ?? 0.0,
      ramTotalGb: (json['ram_total_gb'] as num?)?.toDouble() ?? 0.0,
      diskUsedGb: (json['disk_used_gb'] as num?)?.toDouble() ?? 0.0,
      diskTotalGb: (json['disk_total_gb'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'cpu_usage': cpuUsage,
    'ram_usage': ramUsage,
    'disk_usage': diskUsage,
    'running_processes': runningProcesses,
    'ram_used_gb': ramUsedGb,
    'ram_total_gb': ramTotalGb,
    'disk_used_gb': diskUsedGb,
    'disk_total_gb': diskTotalGb,
  };

  MetricsModel copyWith({
    double? cpuUsage,
    double? ramUsage,
    double? diskUsage,
    int? runningProcesses,
    double? ramUsedGb,
    double? ramTotalGb,
    double? diskUsedGb,
    double? diskTotalGb,
  }) {
    return MetricsModel(
      cpuUsage: cpuUsage ?? this.cpuUsage,
      ramUsage: ramUsage ?? this.ramUsage,
      diskUsage: diskUsage ?? this.diskUsage,
      runningProcesses: runningProcesses ?? this.runningProcesses,
      ramUsedGb: ramUsedGb ?? this.ramUsedGb,
      ramTotalGb: ramTotalGb ?? this.ramTotalGb,
      diskUsedGb: diskUsedGb ?? this.diskUsedGb,
      diskTotalGb: diskTotalGb ?? this.diskTotalGb,
    );
  }
}

// ═══════════════════════════════════════════
// SERVERS
// ═══════════════════════════════════════════

enum ServerStatus { online, stopped, restarting, unknown }

class ServerModel {
  final String id;
  final String name;
  final String ipAddress;
  final String statusRaw;
  final double cpuUsage;
  final double ramUsage;
  final String os;
  final String location;
  final int uptimeHours;
  final String region;
  final String project;
  final double diskUsage;
  final String agentVersion;

  ServerModel({
    required this.id,
    required this.name,
    required this.ipAddress,
    this.statusRaw = 'unknown',
    this.cpuUsage = 0.0,
    this.ramUsage = 0.0,
    this.os = '',
    this.location = '',
    this.uptimeHours = 0,
    this.region = 'eu-west-1',
    this.project = 'Core API',
    this.diskUsage = 50.0,
    this.agentVersion = 'v2.4.1',
  });

  ServerStatus get status {
    switch (statusRaw.toLowerCase()) {
      case 'online':
      case 'active':
      case 'running':
      case 'healthy':
        return ServerStatus.online;
      case 'stopped':
      case 'offline':
        return ServerStatus.stopped;
      case 'restarting':
        return ServerStatus.restarting;
      default:
        return ServerStatus.unknown;
    }
  }

  factory ServerModel.fromJson(Map<String, dynamic> json) {
    return ServerModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      ipAddress: json['ip_address'] as String? ?? '',
      statusRaw: json['status'] as String? ?? 'unknown',
      cpuUsage: (json['cpu_usage'] as num?)?.toDouble() ?? 0.0,
      ramUsage: (json['ram_usage'] as num?)?.toDouble() ?? 0.0,
      os: json['os'] as String? ?? '',
      location: json['location'] as String? ?? '',
      uptimeHours: (json['uptime_hours'] as num?)?.toInt() ?? 0,
      region: json['region'] as String? ?? 'eu-west-1',
      project: json['project'] as String? ?? 'Core API',
      diskUsage: (json['disk_usage'] as num?)?.toDouble() ?? 50.0,
      agentVersion: json['agent_version'] as String? ?? 'v2.4.1',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'ip_address': ipAddress,
    'status': statusRaw,
    'cpu_usage': cpuUsage,
    'ram_usage': ramUsage,
    'os': os,
    'location': location,
    'uptime_hours': uptimeHours,
    'region': region,
    'project': project,
    'disk_usage': diskUsage,
    'agent_version': agentVersion,
  };

  ServerModel copyWith({
    String? id,
    String? name,
    String? ipAddress,
    String? statusRaw,
    double? cpuUsage,
    double? ramUsage,
    String? os,
    String? location,
    int? uptimeHours,
    String? region,
    String? project,
    double? diskUsage,
    String? agentVersion,
  }) {
    return ServerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      ipAddress: ipAddress ?? this.ipAddress,
      statusRaw: statusRaw ?? this.statusRaw,
      cpuUsage: cpuUsage ?? this.cpuUsage,
      ramUsage: ramUsage ?? this.ramUsage,
      os: os ?? this.os,
      location: location ?? this.location,
      uptimeHours: uptimeHours ?? this.uptimeHours,
      region: region ?? this.region,
      project: project ?? this.project,
      diskUsage: diskUsage ?? this.diskUsage,
      agentVersion: agentVersion ?? this.agentVersion,
    );
  }
}

class CreateServerRequest {
  final String name;
  final String ipAddress;
  final String os;
  final String location;

  CreateServerRequest({
    required this.name,
    required this.ipAddress,
    this.os = '',
    this.location = '',
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'ip_address': ipAddress,
    'os': os,
    'location': location,
  };
}

// ═══════════════════════════════════════════
// PROJECTS
// ═══════════════════════════════════════════

class ServerInfo {
  final String id;
  final String name;

  ServerInfo({required this.id, required this.name});

  factory ServerInfo.fromJson(Map<String, dynamic> json) {
    return ServerInfo(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class ServerDropdownItem {
  final String id;
  final String name;

  ServerDropdownItem({required this.id, required this.name});
}

class ProjectModel {
  final String id;
  final String name;
  final String? description;
  final String environment;
  final String status;
  final String health;
  final String version;
  final String lastDeployment;
  final String? serverId;
  final ServerInfo? server;

  String? get serverName => server?.name;

  ProjectModel({
    required this.id,
    required this.name,
    this.description,
    this.environment = 'Production',
    this.status = 'Running',
    this.health = 'Healthy',
    this.version = '1.0.0',
    this.lastDeployment = 'Il y a 2 jours',
    this.serverId,
    this.server,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      environment: json['environment'] as String? ?? 'Production',
      status: json['status'] as String? ?? 'Running',
      health: json['health'] as String? ?? 'Healthy',
      version: json['version'] as String? ?? '1.0.0',
      lastDeployment: json['last_deployment'] as String? ?? 'Il y a 2 jours',
      serverId: json['server_id'] as String?,
      server: json['server'] != null
          ? ServerInfo.fromJson(json['server'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'environment': environment,
    'status': status,
    'health': health,
    'version': version,
    'last_deployment': lastDeployment,
    'server_id': serverId,
    'server': server?.toJson(),
  };

  ProjectModel copyWith({
    String? id,
    String? name,
    String? description,
    String? environment,
    String? status,
    String? health,
    String? version,
    String? lastDeployment,
    String? serverId,
    ServerInfo? server,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      environment: environment ?? this.environment,
      status: status ?? this.status,
      health: health ?? this.health,
      version: version ?? this.version,
      lastDeployment: lastDeployment ?? this.lastDeployment,
      serverId: serverId ?? this.serverId,
      server: server ?? this.server,
    );
  }
}

class CreateProjectRequest {
  final String name;
  final String? description;
  final String? serverId;

  CreateProjectRequest({required this.name, this.description, this.serverId});

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'server_id': serverId,
  };
}

// ═══════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════

enum AlertType { critical, warning, info }

class AlertModel {
  final String id;
  final String title;
  final String description;
  final String typeRaw;
  final String date;
  final String status;
  final String? server;
  final String? project;
  final double currentValue;
  final double threshold;
  final String condition;
  final String assignedTo;
  final String notified;
  final String region;
  final List<double> metricHistory;

  AlertModel({
    required this.id,
    required this.title,
    required this.description,
    this.typeRaw = 'info',
    this.date = '',
    this.status = 'Active',
    this.server,
    this.project,
    this.currentValue = 90.0,
    this.threshold = 90.0,
    this.condition = '',
    this.assignedTo = 'Unassigned',
    this.notified = '#infra-alerts, on-call@acme.io',
    this.region = 'us-east-1',
    this.metricHistory = const [72.0, 74.0, 78.0, 82.0, 85.0, 89.0, 92.0, 94.0],
  });

  bool get isResolved => status.toLowerCase() == 'resolved';
  bool get isAcknowledged => status.toLowerCase() == 'acknowledged';
  bool get isFiring =>
      status.toLowerCase() == 'active' || status.toLowerCase() == 'firing';

  String get message => description;
  String? get serverName => server;
  String get createdAt => date;

  AlertType get type {
    switch (typeRaw.toLowerCase()) {
      case 'critical':
        return AlertType.critical;
      case 'warning':
        return AlertType.warning;
      default:
        return AlertType.info;
    }
  }

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      typeRaw: json['type'] as String? ?? 'info',
      date: json['date'] as String? ?? '',
      status: json['status'] as String? ?? 'Active',
      server: json['server'] as String?,
      project: json['project'] as String?,
      currentValue: (json['current_value'] as num?)?.toDouble() ?? 90.0,
      threshold: (json['threshold'] as num?)?.toDouble() ?? 90.0,
      condition: json['condition'] as String? ?? '',
      assignedTo: json['assigned_to'] as String? ?? 'Unassigned',
      notified: json['notified'] as String? ?? '#infra-alerts, on-call@acme.io',
      region: json['region'] as String? ?? 'us-east-1',
      metricHistory:
          (json['metric_history'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [72.0, 74.0, 78.0, 82.0, 85.0, 89.0, 92.0, 94.0],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'type': typeRaw,
    'date': date,
    'status': status,
    'server': server,
    'project': project,
    'current_value': currentValue,
    'threshold': threshold,
    'condition': condition,
    'assigned_to': assignedTo,
    'notified': notified,
    'region': region,
    'metric_history': metricHistory,
  };

  AlertModel copyWith({
    String? id,
    String? title,
    String? description,
    String? typeRaw,
    String? date,
    String? status,
    String? server,
    String? project,
    double? currentValue,
    double? threshold,
    String? condition,
    String? assignedTo,
    String? notified,
    String? region,
    List<double>? metricHistory,
  }) {
    return AlertModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      typeRaw: typeRaw ?? this.typeRaw,
      date: date ?? this.date,
      status: status ?? this.status,
      server: server ?? this.server,
      project: project ?? this.project,
      currentValue: currentValue ?? this.currentValue,
      threshold: threshold ?? this.threshold,
      condition: condition ?? this.condition,
      assignedTo: assignedTo ?? this.assignedTo,
      notified: notified ?? this.notified,
      region: region ?? this.region,
      metricHistory: metricHistory ?? this.metricHistory,
    );
  }
}

// ═══════════════════════════════════════════
// LOGS
// ═══════════════════════════════════════════

enum LogLevel {
  info('Info'),
  warning('Warning'),
  error('Erreur'),
  success('Success');

  final String label;
  const LogLevel(this.label);
}

enum LogSource {
  server('Server'),
  project('Project'),
  auth('Auth'),
  alert('Alert'),
  system('System');

  final String label;
  const LogSource(this.label);
}

class LogModel {
  final String id;
  final String timestamp;
  final String levelRaw;
  final String sourceRaw;
  final String message;
  final String? relatedServer;
  final String? relatedProject;
  final String service;
  final String traceId;
  final int durationMs;
  final String database;
  final String sourceFile;
  final String rawJson;

  LogModel({
    required this.id,
    required this.timestamp,
    required this.levelRaw,
    required this.sourceRaw,
    required this.message,
    this.relatedServer,
    this.relatedProject,
    this.service = 'postgresql',
    this.traceId = 'a8f2c91e4d06',
    this.durationMs = 5014,
    this.database = 'acme_production',
    this.sourceFile = '/var/log/postgresql.log',
    this.rawJson = '',
  });

  LogLevel get level {
    switch (levelRaw.toUpperCase()) {
      case 'WARNING':
      case 'WARN':
        return LogLevel.warning;
      case 'ERROR':
        return LogLevel.error;
      case 'SUCCESS':
        return LogLevel.success;
      default:
        return LogLevel.info;
    }
  }

  LogSource get source {
    switch (sourceRaw.toUpperCase()) {
      case 'SERVER':
        return LogSource.server;
      case 'PROJECT':
        return LogSource.project;
      case 'AUTH':
        return LogSource.auth;
      case 'ALERT':
        return LogSource.alert;
      default:
        return LogSource.system;
    }
  }

  factory LogModel.fromJson(Map<String, dynamic> json) {
    return LogModel(
      id: json['id']?.toString() ?? '',
      timestamp: json['timestamp'] as String? ?? '',
      levelRaw: json['levelRaw'] as String? ?? 'INFO',
      sourceRaw: json['sourceRaw'] as String? ?? 'SYSTEM',
      message: json['message'] as String? ?? '',
      relatedServer: json['relatedServer'] as String?,
      relatedProject: json['relatedProject'] as String?,
      service: json['service'] as String? ?? 'postgresql',
      traceId: json['traceId'] as String? ?? 'a8f2c91e4d06',
      durationMs: (json['durationMs'] as num?)?.toInt() ?? 5014,
      database: json['database'] as String? ?? 'acme_production',
      sourceFile: json['sourceFile'] as String? ?? '/var/log/postgresql.log',
      rawJson: json['rawJson'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp,
    'levelRaw': levelRaw,
    'sourceRaw': sourceRaw,
    'message': message,
    'relatedServer': relatedServer,
    'relatedProject': relatedProject,
    'service': service,
    'traceId': traceId,
    'durationMs': durationMs,
    'database': database,
    'sourceFile': sourceFile,
    'rawJson': rawJson,
  };
}
