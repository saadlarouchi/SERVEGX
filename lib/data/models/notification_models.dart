sealed class GlobalEvent {
  const GlobalEvent();
}

class ServerCreatedEvent extends GlobalEvent {
  final String serverId;
  final String serverName;
  const ServerCreatedEvent({required this.serverId, required this.serverName});
}

class ServerStartedEvent extends GlobalEvent {
  final String serverId;
  final String serverName;
  const ServerStartedEvent({required this.serverId, required this.serverName});
}

class ServerRestartedEvent extends GlobalEvent {
  final String serverId;
  final String serverName;
  const ServerRestartedEvent({
    required this.serverId,
    required this.serverName,
  });
}

class ServerStoppedEvent extends GlobalEvent {
  final String serverId;
  final String serverName;
  const ServerStoppedEvent({required this.serverId, required this.serverName});
}

class ServerDeletedEvent extends GlobalEvent {
  final String serverId;
  final String serverName;
  const ServerDeletedEvent({required this.serverId, required this.serverName});
}

class ServerErrorEvent extends GlobalEvent {
  final String serverId;
  final String serverName;
  final String reason;
  String get error => reason;
  const ServerErrorEvent({
    required this.serverId,
    required this.serverName,
    required this.reason,
  });
}

class AlertCreatedEvent extends GlobalEvent {
  final String alertId;
  final String title;
  const AlertCreatedEvent({required this.alertId, required this.title});
}

class AlertUpdatedEvent extends GlobalEvent {
  final String alertId;
  final String title;
  final String status;
  const AlertUpdatedEvent({
    required this.alertId,
    required this.title,
    required this.status,
  });
}

class ProjectDeployedEvent extends GlobalEvent {
  final String projectId;
  final String projectName;
  const ProjectDeployedEvent({
    required this.projectId,
    required this.projectName,
  });
}

class ProjectDeploymentFailedEvent extends GlobalEvent {
  final String projectId;
  final String projectName;
  final String? error;
  const ProjectDeploymentFailedEvent({
    required this.projectId,
    required this.projectName,
    this.error,
  });
}

class UserLoggedInEvent extends GlobalEvent {
  final String email;
  const UserLoggedInEvent({required this.email});
}

class UserRegisteredEvent extends GlobalEvent {
  final String email;
  final String? name;
  const UserRegisteredEvent({required this.email, this.name});
}

class UserLoggedOutEvent extends GlobalEvent {
  final String email;
  const UserLoggedOutEvent({required this.email});
}

typedef ServerCreated = ServerCreatedEvent;
typedef ServerStarted = ServerStartedEvent;
typedef ServerRestarted = ServerRestartedEvent;
typedef ServerStopped = ServerStoppedEvent;
typedef ServerDeleted = ServerDeletedEvent;
typedef ServerError = ServerErrorEvent;
typedef AlertCreated = AlertCreatedEvent;
typedef AlertUpdated = AlertUpdatedEvent;
typedef ProjectDeployed = ProjectDeployedEvent;
typedef ProjectDeploymentFailed = ProjectDeploymentFailedEvent;
typedef UserLoggedIn = UserLoggedInEvent;
typedef UserRegistered = UserRegisteredEvent;
typedef UserLoggedOut = UserLoggedOutEvent;

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String severity; // "INFO", "SUCCESS", "WARNING", "CRITICAL"
  final String timestamp;
  final String source; // "SERVER", "PROJECT", "ALERT", "AUTH", "SYSTEM"
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.severity,
    required this.timestamp,
    this.source = 'SYSTEM',
    this.isRead = false,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? severity,
    String? timestamp,
    String? source,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      severity: severity ?? this.severity,
      timestamp: timestamp ?? this.timestamp,
      source: source ?? this.source,
      isRead: isRead ?? this.isRead,
    );
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      severity: json['severity'] as String? ?? 'INFO',
      timestamp: json['timestamp'] as String? ?? '',
      source: json['source'] as String? ?? 'SYSTEM',
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'message': message,
    'severity': severity,
    'timestamp': timestamp,
    'source': source,
    'isRead': isRead,
  };
}
