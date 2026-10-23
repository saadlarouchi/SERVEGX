import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../models/api_models.dart';
import '../models/notification_models.dart';

enum UserStatus { active, blocked }

class UserItem {
  final String id;
  final String name;
  final String email;
  final String role;
  final UserStatus status;
  final String lastLogin;

  UserItem({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.status = UserStatus.active,
    required this.lastLogin,
  });

  UserItem copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    UserStatus? status,
    String? lastLogin,
  }) {
    return UserItem(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      status: status ?? this.status,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}

class MockDataStore {
  static final MockDataStore _instance = MockDataStore._internal();
  factory MockDataStore() => _instance;
  static MockDataStore get instance => _instance;

  // ─────────────────────────────────────────
  // STATIC AUTH DATA
  // ─────────────────────────────────────────
  final List<UserResponse> users = [
    UserResponse(
      id: '1',
      name: 'Administrateur',
      email: 'admin@sysmonitor.com',
      role: 'admin',
    ),
    UserResponse(
      id: '2',
      name: 'Alice Dupont',
      email: 'alice@sysmonitor.com',
      role: 'user',
    ),
  ];

  final Map<String, String> passwords = {
    'admin@sysmonitor.com': 'admin123',
    'alice@sysmonitor.com': 'password',
  };

  // ─────────────────────────────────────────
  // USER MANAGEMENT DATA
  // ─────────────────────────────────────────
  final ValueNotifier<List<UserItem>> managedUsers =
      ValueNotifier<List<UserItem>>([
        UserItem(
          id: '1',
          name: 'Saad Larouchi',
          email: 'saad@example.com',
          role: 'Admin',
          status: UserStatus.active,
          lastLogin: 'Il y a 2 min',
        ),
        UserItem(
          id: '2',
          name: 'Marwa Benali',
          email: 'marwa@example.com',
          role: 'Utilisateur',
          status: UserStatus.active,
          lastLogin: 'Il y a 1h',
        ),
        UserItem(
          id: '3',
          name: 'Youssef El Alami',
          email: 'youssef@example.com',
          role: 'Utilisateur',
          status: UserStatus.active,
          lastLogin: 'Il y a 3h',
        ),
        UserItem(
          id: '4',
          name: 'Fatima Zahra',
          email: 'fatima@example.com',
          role: 'Utilisateur',
          status: UserStatus.blocked,
          lastLogin: 'Il y a 2j',
        ),
        UserItem(
          id: '5',
          name: 'Admin Système',
          email: 'admin@sysmonitor.com',
          role: 'Admin',
          status: UserStatus.active,
          lastLogin: 'Il y a 5 min',
        ),
        UserItem(
          id: '6',
          name: 'Test User',
          email: 'test@example.com',
          role: 'Utilisateur',
          status: UserStatus.blocked,
          lastLogin: 'Il y a 7j',
        ),
        UserItem(
          id: '7',
          name: 'Karim Mansouri',
          email: 'karim@example.com',
          role: 'Utilisateur',
          status: UserStatus.active,
          lastLogin: 'Aujourd\'hui',
        ),
        UserItem(
          id: '8',
          name: 'Leila Haddad',
          email: 'leila@example.com',
          role: 'Utilisateur',
          status: UserStatus.active,
          lastLogin: 'Hier',
        ),
      ]);

  // ─────────────────────────────────────────
  // REACTIVE STATE (ValueNotifiers for UI)
  // ─────────────────────────────────────────
  final ValueNotifier<List<ServerModel>> servers =
      ValueNotifier<List<ServerModel>>([
        // Europe (eu-west-1) - 12 servers
        ServerModel(
          id: 'srv-1',
          name: 'api-prod-01',
          ipAddress: '10.0.0.11',
          statusRaw: 'online',
          cpuUsage: 42.0,
          ramUsage: 62.0,
          diskUsage: 48.0,
          os: 'Ubuntu 22.04 LTS',
          location: 'Frankfurt',
          region: 'eu-west-1',
          project: 'Core API',
          uptimeHours: 3240,
        ),
        ServerModel(
          id: 'srv-2',
          name: 'api-prod-02',
          ipAddress: '10.0.0.12',
          statusRaw: 'online',
          cpuUsage: 38.0,
          ramUsage: 59.0,
          diskUsage: 47.0,
          os: 'Ubuntu 22.04 LTS',
          location: 'Frankfurt',
          region: 'eu-west-1',
          project: 'Core API',
          uptimeHours: 3210,
        ),
        ServerModel(
          id: 'srv-3',
          name: 'edge-prod-04',
          ipAddress: '10.0.0.14',
          statusRaw: 'online',
          cpuUsage: 35.0,
          ramUsage: 48.0,
          diskUsage: 38.0,
          os: 'Debian 12',
          location: 'Dublin',
          region: 'eu-west-1',
          project: 'Edge Gateway',
          uptimeHours: 2150,
        ),
        ServerModel(
          id: 'srv-4',
          name: 'edge-prod-05',
          ipAddress: '10.0.0.15',
          statusRaw: 'online',
          cpuUsage: 31.0,
          ramUsage: 46.0,
          diskUsage: 36.0,
          os: 'Debian 12',
          location: 'Dublin',
          region: 'eu-west-1',
          project: 'Edge Gateway',
          uptimeHours: 2150,
        ),
        ServerModel(
          id: 'srv-5',
          name: 'ingress-gw-01',
          ipAddress: '10.0.0.5',
          statusRaw: 'online',
          cpuUsage: 49.0,
          ramUsage: 52.0,
          diskUsage: 41.0,
          os: 'Alpine Linux',
          location: 'Frankfurt',
          region: 'eu-west-1',
          project: 'Edge Gateway',
          uptimeHours: 4100,
        ),
        ServerModel(
          id: 'srv-6',
          name: 'ingress-gw-02',
          ipAddress: '10.0.0.6',
          statusRaw: 'online',
          cpuUsage: 45.0,
          ramUsage: 50.0,
          diskUsage: 39.0,
          os: 'Alpine Linux',
          location: 'Frankfurt',
          region: 'eu-west-1',
          project: 'Edge Gateway',
          uptimeHours: 4100,
        ),
        ServerModel(
          id: 'srv-7',
          name: 'auth-service-01',
          ipAddress: '10.0.0.21',
          statusRaw: 'online',
          cpuUsage: 28.0,
          ramUsage: 44.0,
          diskUsage: 32.0,
          os: 'Ubuntu 22.04 LTS',
          location: 'Frankfurt',
          region: 'eu-west-1',
          project: 'Core API',
          uptimeHours: 2890,
        ),
        ServerModel(
          id: 'srv-8',
          name: 'auth-service-02',
          ipAddress: '10.0.0.22',
          statusRaw: 'online',
          cpuUsage: 25.0,
          ramUsage: 42.0,
          diskUsage: 31.0,
          os: 'Ubuntu 22.04 LTS',
          location: 'Frankfurt',
          region: 'eu-west-1',
          project: 'Core API',
          uptimeHours: 2890,
        ),
        ServerModel(
          id: 'srv-9',
          name: 'billing-api-01',
          ipAddress: '10.0.0.31',
          statusRaw: 'online',
          cpuUsage: 34.0,
          ramUsage: 58.0,
          diskUsage: 50.0,
          os: 'Ubuntu 22.04 LTS',
          location: 'Dublin',
          region: 'eu-west-1',
          project: 'Core API',
          uptimeHours: 1980,
        ),
        ServerModel(
          id: 'srv-10',
          name: 'billing-api-02',
          ipAddress: '10.0.0.32',
          statusRaw: 'online',
          cpuUsage: 30.0,
          ramUsage: 55.0,
          diskUsage: 49.0,
          os: 'Ubuntu 22.04 LTS',
          location: 'Dublin',
          region: 'eu-west-1',
          project: 'Core API',
          uptimeHours: 1980,
        ),
        ServerModel(
          id: 'srv-11',
          name: 'backup-node-01',
          ipAddress: '10.0.0.81',
          statusRaw: 'online',
          cpuUsage: 18.0,
          ramUsage: 36.0,
          diskUsage: 74.0,
          os: 'Debian 12',
          location: 'Frankfurt',
          region: 'eu-west-1',
          project: 'Core API',
          uptimeHours: 5400,
        ),
        ServerModel(
          id: 'srv-12',
          name: 'metrics-agent-01',
          ipAddress: '10.0.0.91',
          statusRaw: 'online',
          cpuUsage: 22.0,
          ramUsage: 38.0,
          diskUsage: 42.0,
          os: 'Debian 12',
          location: 'Dublin',
          region: 'eu-west-1',
          project: 'Core API',
          uptimeHours: 5400,
        ),

        // North America (us-east-1) - 8 servers
        ServerModel(
          id: 'srv-13',
          name: 'db-prod-01',
          ipAddress: '10.0.1.21',
          statusRaw: 'critical',
          cpuUsage: 94.0,
          ramUsage: 88.0,
          diskUsage: 85.0,
          os: 'Ubuntu 22.04 LTS',
          location: 'N. Virginia',
          region: 'us-east-1',
          project: 'Core API',
          uptimeHours: 1420,
        ),
        ServerModel(
          id: 'srv-14',
          name: 'db-prod-02',
          ipAddress: '10.0.1.22',
          statusRaw: 'online',
          cpuUsage: 58.0,
          ramUsage: 76.0,
          diskUsage: 82.0,
          os: 'Ubuntu 22.04 LTS',
          location: 'N. Virginia',
          region: 'us-east-1',
          project: 'Core API',
          uptimeHours: 1420,
        ),
        ServerModel(
          id: 'srv-15',
          name: 'worker-prod-03',
          ipAddress: '10.0.1.33',
          statusRaw: 'warning',
          cpuUsage: 67.0,
          ramUsage: 91.0,
          diskUsage: 87.0,
          os: 'Debian 12',
          location: 'Ohio',
          region: 'us-east-1',
          project: 'Worker Pool',
          uptimeHours: 890,
        ),
        ServerModel(
          id: 'srv-16',
          name: 'worker-prod-04',
          ipAddress: '10.0.1.34',
          statusRaw: 'online',
          cpuUsage: 54.0,
          ramUsage: 72.0,
          diskUsage: 68.0,
          os: 'Debian 12',
          location: 'Ohio',
          region: 'us-east-1',
          project: 'Worker Pool',
          uptimeHours: 890,
        ),
        ServerModel(
          id: 'srv-17',
          name: 'worker-prod-05',
          ipAddress: '10.0.1.35',
          statusRaw: 'online',
          cpuUsage: 48.0,
          ramUsage: 69.0,
          diskUsage: 64.0,
          os: 'Debian 12',
          location: 'Ohio',
          region: 'us-east-1',
          project: 'Worker Pool',
          uptimeHours: 890,
        ),
        ServerModel(
          id: 'srv-18',
          name: 'queue-rabbit-01',
          ipAddress: '10.0.1.41',
          statusRaw: 'online',
          cpuUsage: 36.0,
          ramUsage: 64.0,
          diskUsage: 55.0,
          os: 'Ubuntu 22.04 LTS',
          location: 'N. Virginia',
          region: 'us-east-1',
          project: 'Worker Pool',
          uptimeHours: 2310,
        ),
        ServerModel(
          id: 'srv-19',
          name: 'search-es-01',
          ipAddress: '10.0.1.51',
          statusRaw: 'online',
          cpuUsage: 62.0,
          ramUsage: 82.0,
          diskUsage: 78.0,
          os: 'Ubuntu 22.04 LTS',
          location: 'N. Virginia',
          region: 'us-east-1',
          project: 'Core API',
          uptimeHours: 3100,
        ),
        ServerModel(
          id: 'srv-20',
          name: 'search-es-02',
          ipAddress: '10.0.1.52',
          statusRaw: 'online',
          cpuUsage: 59.0,
          ramUsage: 80.0,
          diskUsage: 77.0,
          os: 'Ubuntu 22.04 LTS',
          location: 'N. Virginia',
          region: 'us-east-1',
          project: 'Core API',
          uptimeHours: 3100,
        ),

        // Asia Pacific (ap-south-1) - 4 servers
        ServerModel(
          id: 'srv-21',
          name: 'cache-redis-01',
          ipAddress: '10.0.2.10',
          statusRaw: 'online',
          cpuUsage: 28.0,
          ramUsage: 54.0,
          diskUsage: 32.0,
          os: 'Alpine Linux',
          location: 'Mumbai',
          region: 'ap-south-1',
          project: 'Analytics Engine',
          uptimeHours: 1840,
        ),
        ServerModel(
          id: 'srv-22',
          name: 'cache-redis-02',
          ipAddress: '10.0.2.11',
          statusRaw: 'online',
          cpuUsage: 26.0,
          ramUsage: 51.0,
          diskUsage: 31.0,
          os: 'Alpine Linux',
          location: 'Mumbai',
          region: 'ap-south-1',
          project: 'Analytics Engine',
          uptimeHours: 1840,
        ),
        ServerModel(
          id: 'srv-23',
          name: 'analytics-agg-01',
          ipAddress: '10.0.2.21',
          statusRaw: 'online',
          cpuUsage: 45.0,
          ramUsage: 68.0,
          diskUsage: 58.0,
          os: 'Debian 12',
          location: 'Mumbai',
          region: 'ap-south-1',
          project: 'Analytics Engine',
          uptimeHours: 1220,
        ),
        ServerModel(
          id: 'srv-24',
          name: 'analytics-agg-02',
          ipAddress: '10.0.2.22',
          statusRaw: 'online',
          cpuUsage: 41.0,
          ramUsage: 65.0,
          diskUsage: 56.0,
          os: 'Debian 12',
          location: 'Mumbai',
          region: 'ap-south-1',
          project: 'Analytics Engine',
          uptimeHours: 1220,
        ),
      ]);

  final ValueNotifier<List<ProjectModel>> projects =
      ValueNotifier<List<ProjectModel>>([
        ProjectModel(
          id: 'prj-1',
          name: 'Core API',
          description: 'Primary customer-facing microservices architecture',
          environment: 'Production',
          status: 'Running',
          health: 'Degraded',
          version: 'v2.8.4',
          lastDeployment: '18 min ago by Maya Chen',
          serverId: 'srv-13',
          server: ServerInfo(id: 'srv-13', name: 'db-prod-01'),
        ),
        ProjectModel(
          id: 'prj-2',
          name: 'Worker Pool',
          description: 'Asynchronous event consumer and ETL pipeline',
          environment: 'Production',
          status: 'Running',
          health: 'Degraded',
          version: 'v1.9.0',
          lastDeployment: '3 hours ago by Jordan Lee',
          serverId: 'srv-15',
          server: ServerInfo(id: 'srv-15', name: 'worker-prod-03'),
        ),
        ProjectModel(
          id: 'prj-3',
          name: 'Edge Gateway',
          description: 'Global TLS termination, edge caching, and routing',
          environment: 'Production',
          status: 'Running',
          health: 'Healthy',
          version: 'v3.1.2',
          lastDeployment: 'Yesterday by Alex Rivera',
          serverId: 'srv-3',
          server: ServerInfo(id: 'srv-3', name: 'edge-prod-04'),
        ),
        ProjectModel(
          id: 'prj-4',
          name: 'Analytics Engine',
          description: 'Real-time telemetry aggregation and indexing',
          environment: 'Staging',
          status: 'Running',
          health: 'Healthy',
          version: 'v1.5.2',
          lastDeployment: '2 days ago by Youssef El Alami',
          serverId: 'srv-21',
          server: ServerInfo(id: 'srv-21', name: 'cache-redis-01'),
        ),
      ]);

  final ValueNotifier<List<AlertModel>> alerts =
      ValueNotifier<List<AlertModel>>([
        AlertModel(
          id: 'ALT-1042',
          title: 'CPU usage above 90%',
          description:
              'CPU has exceeded 90% for more than 5 minutes. Current: 94%.',
          typeRaw: 'critical',
          date: '14:30',
          status: 'Firing',
          server: 'db-prod-01',
          project: 'Core API',
          currentValue: 94.0,
          threshold: 90.0,
          condition: 'cpu.usage > 90% for 5m',
          assignedTo: 'Unassigned',
          notified: '#infra-alerts, on-call@acme.io',
          region: 'us-east-1',
          metricHistory: [74.0, 76.0, 78.0, 81.0, 84.0, 89.0, 92.5, 94.0],
        ),
        AlertModel(
          id: 'ALT-1043',
          title: 'Memory usage above 90%',
          description:
              'Memory pressure is elevated. 14.6 GB of 16 GB currently in use.',
          typeRaw: 'warning',
          date: '14:18',
          status: 'Firing',
          server: 'worker-prod-03',
          project: 'Worker Pool',
          currentValue: 91.2,
          threshold: 90.0,
          condition: 'mem.usage > 90% for 3m',
          assignedTo: 'Jordan Lee',
          notified: '#infra-alerts',
          region: 'us-east-1',
          metricHistory: [68.0, 72.0, 78.0, 82.0, 86.0, 88.0, 90.5, 91.2],
        ),
        AlertModel(
          id: 'ALT-1044',
          title: 'Disk usage above 85%',
          description: 'Volume /var/data is at 87% capacity. 26 GB remaining.',
          typeRaw: 'warning',
          date: '13:58',
          status: 'Acknowledged',
          server: 'worker-prod-03',
          project: 'Worker Pool',
          currentValue: 87.0,
          threshold: 85.0,
          condition: 'disk.usage > 85% on /var/data',
          assignedTo: 'Maya Chen',
          notified: '#infra-alerts',
          region: 'us-east-1',
          metricHistory: [80.0, 81.0, 82.0, 83.5, 84.8, 86.0, 86.5, 87.0],
        ),
        AlertModel(
          id: 'ALT-1040',
          title: 'Response time above 500 ms',
          description: 'api-prod-02 · Resolved at 12:46 · lasted 8 minutes',
          typeRaw: 'warning',
          date: '12:46',
          status: 'Resolved',
          server: 'api-prod-02',
          project: 'Core API',
          currentValue: 420.0,
          threshold: 500.0,
          condition: 'http.response_time > 500ms',
          assignedTo: 'Automated',
          notified: '#infra-alerts',
          region: 'eu-west-1',
          metricHistory: [540.0, 520.0, 480.0, 450.0, 420.0],
        ),
      ]);

  final ValueNotifier<List<LogModel>> logs = ValueNotifier<List<LogModel>>([
    LogModel(
      id: 'log-101',
      timestamp: '14:32:06.814',
      levelRaw: 'ERROR',
      sourceRaw: 'SERVER',
      message: 'Query execution exceeded timeout of 5000ms',
      relatedServer: 'db-prod-01',
      relatedProject: 'Core API',
      service: 'postgresql',
      traceId: 'a8f2c91e4d06',
      durationMs: 5014,
      database: 'acme_production',
      sourceFile: '/var/log/postgresql.log',
      rawJson: '{"timestamp":"2026-10-23T14:32:06.814Z","level":"ERROR","server":"db-prod-01","service":"postgresql","trace_id":"a8f2c91e4d06","duration_ms":5014,"database":"acme_production","query":"SELECT * FROM orders WHERE status = \'processing\' ORDER BY created_at DESC LIMIT 500"}',
    ),
    LogModel(
      id: 'log-102',
      timestamp: '14:32:05.201',
      levelRaw: 'WARN',
      sourceRaw: 'SERVER',
      message: 'Connection pool nearing capacity: 92/100',
      relatedServer: 'db-prod-01',
      relatedProject: 'Core API',
      service: 'postgresql',
      traceId: 'b71a4f028e12',
      durationMs: 120,
      database: 'acme_production',
      sourceFile: '/var/log/postgresql.log',
      rawJson: '{"timestamp":"2026-10-23T14:32:05.201Z","level":"WARN","server":"db-prod-01","pool_active":92,"pool_max":100}',
    ),
    LogModel(
      id: 'log-103',
      timestamp: '14:31:58.630',
      levelRaw: 'ERROR',
      sourceRaw: 'SERVER',
      message: 'Query execution exceeded timeout of 5000ms',
      relatedServer: 'db-prod-01',
      relatedProject: 'Core API',
      service: 'postgresql',
      traceId: 'c90e2b419d88',
      durationMs: 5008,
      database: 'acme_production',
      sourceFile: '/var/log/postgresql.log',
    ),
    LogModel(
      id: 'log-104',
      timestamp: '14:31:52.109',
      levelRaw: 'WARN',
      sourceRaw: 'SERVER',
      message: 'CPU usage elevated: 94.2% over last 60s',
      relatedServer: 'db-prod-01',
      relatedProject: 'Core API',
      service: 'postgresql',
      traceId: 'd33c89a01f74',
      durationMs: 45,
      database: 'acme_production',
      sourceFile: '/var/log/system.log',
    ),
    LogModel(
      id: 'log-105',
      timestamp: '14:31:48.447',
      levelRaw: 'ERROR',
      sourceRaw: 'SERVER',
      message: 'Failed to acquire connection within 3000ms',
      relatedServer: 'db-prod-01',
      relatedProject: 'Core API',
      service: 'postgresql',
      traceId: 'e45b12c87a99',
      durationMs: 3002,
      database: 'acme_production',
      sourceFile: '/var/log/postgresql.log',
    ),
    LogModel(
      id: 'log-106',
      timestamp: '14:31:42.318',
      levelRaw: 'WARN',
      sourceRaw: 'SERVER',
      message: 'Slow query detected: duration 2841ms',
      relatedServer: 'db-prod-01',
      relatedProject: 'Core API',
      service: 'postgresql',
      traceId: 'f67d45e90a21',
      durationMs: 2841,
      database: 'acme_production',
      sourceFile: '/var/log/postgresql.log',
    ),
    LogModel(
      id: 'log-107',
      timestamp: '14:31:38.052',
      levelRaw: 'WARN',
      sourceRaw: 'SERVER',
      message: 'Checkpoint taking longer than expected',
      relatedServer: 'db-prod-01',
      relatedProject: 'Core API',
      service: 'postgresql',
      traceId: 'a12c89e34b56',
      durationMs: 4120,
      database: 'acme_production',
      sourceFile: '/var/log/postgresql.log',
    ),
    LogModel(
      id: 'log-108',
      timestamp: '14:31:30.804',
      levelRaw: 'ERROR',
      sourceRaw: 'SERVER',
      message: 'Query execution exceeded timeout of 5000ms',
      relatedServer: 'db-prod-01',
      relatedProject: 'Core API',
      service: 'postgresql',
      traceId: 'b89f23d45c11',
      durationMs: 5012,
      database: 'acme_production',
      sourceFile: '/var/log/postgresql.log',
    ),
    LogModel(
      id: 'log-109',
      timestamp: '14:31:24.112',
      levelRaw: 'WARN',
      sourceRaw: 'SERVER',
      message: 'Connection pool nearing capacity: 89/100',
      relatedServer: 'db-prod-01',
      relatedProject: 'Core API',
      service: 'postgresql',
      traceId: 'c45e78a12d33',
      durationMs: 95,
      database: 'acme_production',
      sourceFile: '/var/log/postgresql.log',
    ),
    LogModel(
      id: 'log-110',
      timestamp: '14:31:18.763',
      levelRaw: 'WARN',
      sourceRaw: 'SERVER',
      message: 'Slow query detected: duration 3102ms',
      relatedServer: 'db-prod-01',
      relatedProject: 'Core API',
      service: 'postgresql',
      traceId: 'd78b90c23e44',
      durationMs: 3102,
      database: 'acme_production',
      sourceFile: '/var/log/postgresql.log',
    ),
  ]);

  final ValueNotifier<List<NotificationModel>> notifications =
      ValueNotifier<List<NotificationModel>>([
        NotificationModel(
          id: 'notif-1',
          title: 'High CPU on db-prod-01',
          message: 'Core API · CPU reached 94.0% exceeding 90% threshold',
          severity: 'CRITICAL',
          timestamp: '2 min ago',
          source: 'ALERT',
        ),
        NotificationModel(
          id: 'notif-2',
          title: 'Core API deployment completed',
          message: 'v2.8.4 deployed successfully by Maya Chen',
          severity: 'SUCCESS',
          timestamp: '18 min ago',
          source: 'PROJECT',
        ),
        NotificationModel(
          id: 'notif-3',
          title: 'edge-prod-04 connected',
          message: 'Edge Gateway · Instance synchronized with telemetry hub',
          severity: 'INFO',
          timestamp: '42 min ago',
          source: 'SERVER',
        ),
        NotificationModel(
          id: 'notif-4',
          title: 'Daily backup completed',
          message:
              '24 of 24 servers snapshotted successfully to S3 cold storage',
          severity: 'SUCCESS',
          timestamp: '1 hour ago',
          source: 'SYSTEM',
        ),
      ]);

  final StreamController<GlobalEvent> _eventController =
      StreamController<GlobalEvent>.broadcast();
  Stream<GlobalEvent> get globalEvents => _eventController.stream;

  final ValueNotifier<MetricsModel> dashboardMetrics =
      ValueNotifier<MetricsModel>(
        MetricsModel(
          cpuUsage: 42.8,
          ramUsage: 62.1,
          diskUsage: 54.0,
          runningProcesses: 450,
          ramUsedGb: 159.0,
          ramTotalGb: 256.0,
          diskUsedGb: 1104.0,
          diskTotalGb: 2048.0,
        ),
      );

  final double _ramTotal = 128.0;
  double _currentDiskUsed = 1024.0;
  final double _diskTotal = 2048.0;
  int _currentProcesses = 450;
  Timer? _simulationTimer;
  final Random _random = Random();

  MockDataStore._internal() {
    _startSimulation();
  }

  void _startSimulation() {
    _simulationTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _evolveState();
    });
  }

  void stopSimulation() {
    _simulationTimer?.cancel();
  }

  void pushEvent(GlobalEvent event) {
    _eventController.add(event);

    final nowStr = DateFormat('HH:mm:ss').format(DateTime.now());
    NotificationModel notif;

    if (event is ServerCreatedEvent) {
      notif = NotificationModel(
        id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
        title: 'Nouveau serveur',
        message: 'Le serveur ${event.serverName} a été créé.',
        severity: 'SUCCESS',
        timestamp: nowStr,
        source: 'SERVER',
      );
    } else if (event is ServerStartedEvent) {
      notif = NotificationModel(
        id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
        title: 'Serveur démarré',
        message: 'Le serveur ${event.serverName} est maintenant en ligne.',
        severity: 'SUCCESS',
        timestamp: nowStr,
        source: 'SERVER',
      );
    } else if (event is ServerRestartedEvent) {
      notif = NotificationModel(
        id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
        title: 'Redémarrage',
        message: 'Le serveur ${event.serverName} a été redémarré.',
        severity: 'INFO',
        timestamp: nowStr,
        source: 'SERVER',
      );
    } else if (event is ServerStoppedEvent) {
      notif = NotificationModel(
        id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
        title: 'Serveur arrêté',
        message: 'Le serveur ${event.serverName} a été arrêté.',
        severity: 'WARNING',
        timestamp: nowStr,
        source: 'SERVER',
      );
    } else if (event is ServerDeletedEvent) {
      notif = NotificationModel(
        id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
        title: 'Serveur supprimé',
        message: 'Le serveur ${event.serverName} a été supprimé.',
        severity: 'WARNING',
        timestamp: nowStr,
        source: 'SERVER',
      );
    } else if (event is ServerErrorEvent) {
      notif = NotificationModel(
        id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
        title: 'Erreur Serveur',
        message:
            'Le serveur ${event.serverName} a rencontré une erreur : ${event.reason}',
        severity: 'CRITICAL',
        timestamp: nowStr,
        source: 'SERVER',
      );
    } else if (event is AlertCreatedEvent) {
      notif = NotificationModel(
        id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
        title: 'Nouvelle alerte',
        message: event.title,
        severity: 'CRITICAL',
        timestamp: nowStr,
        source: 'ALERT',
      );
    } else if (event is AlertUpdatedEvent) {
      notif = NotificationModel(
        id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
        title: 'Alerte mise à jour',
        message: '${event.title} est maintenant ${event.status}.',
        severity: 'INFO',
        timestamp: nowStr,
        source: 'ALERT',
      );
    } else if (event is ProjectDeployedEvent) {
      notif = NotificationModel(
        id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
        title: 'Projet déployé',
        message: 'Le projet ${event.projectName} a été déployé.',
        severity: 'SUCCESS',
        timestamp: nowStr,
        source: 'PROJECT',
      );
    } else if (event is ProjectDeploymentFailedEvent) {
      notif = NotificationModel(
        id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
        title: 'Échec du déploiement',
        message: 'Le déploiement du projet ${event.projectName} a échoué.',
        severity: 'CRITICAL',
        timestamp: nowStr,
        source: 'PROJECT',
      );
    } else if (event is UserLoggedInEvent) {
      notif = NotificationModel(
        id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
        title: 'Connexion',
        message: 'L\'utilisateur ${event.email} s\'est connecté.',
        severity: 'INFO',
        timestamp: nowStr,
        source: 'AUTH',
      );
    } else if (event is UserRegisteredEvent) {
      notif = NotificationModel(
        id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
        title: 'Nouvel Utilisateur',
        message: 'L\'utilisateur ${event.email} s\'est inscrit.',
        severity: 'SUCCESS',
        timestamp: nowStr,
        source: 'AUTH',
      );
    } else if (event is UserLoggedOutEvent) {
      notif = NotificationModel(
        id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
        title: 'Déconnexion',
        message: 'L\'utilisateur ${event.email} s\'est déconnecté.',
        severity: 'INFO',
        timestamp: nowStr,
        source: 'AUTH',
      );
    } else {
      notif = NotificationModel(
        id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
        title: 'Notification système',
        message: 'Événement système enregistré',
        severity: 'INFO',
        timestamp: nowStr,
        source: 'SYSTEM',
      );
    }

    final currentNotifs = List<NotificationModel>.from(notifications.value);
    currentNotifs.insert(0, notif);
    if (currentNotifs.length > 100) {
      currentNotifs.removeLast();
    }
    notifications.value = currentNotifs;
  }

  void _evolveState() {
    final currentTime = DateFormat('HH:mm:ss').format(DateTime.now());

    // 1. Evolve Servers
    final updatedServers = servers.value.map((server) {
      if (server.statusRaw == 'online') {
        final rand = _random.nextDouble();
        if (rand < 0.02) {
          addLog(
            'INFO',
            'SERVER',
            'Redémarrage spontané du serveur ${server.name}',
            server: server.name,
          );
          pushEvent(
            ServerRestartedEvent(serverId: server.id, serverName: server.name),
          );
          return server.copyWith(
            statusRaw: 'restarting',
            cpuUsage: 0.0,
            ramUsage: 0.0,
          );
        } else if (rand < 0.03) {
          addLog(
            'WARNING',
            'SERVER',
            'Arrêt spontané du serveur ${server.name}',
            server: server.name,
          );
          pushEvent(
            ServerStoppedEvent(serverId: server.id, serverName: server.name),
          );
          return server.copyWith(
            statusRaw: 'stopped',
            cpuUsage: 0.0,
            ramUsage: 0.0,
          );
        } else {
          final isDb = server.name.toLowerCase().contains('db');
          final isWeb = server.name.toLowerCase().contains('web');
          final isWorker =
              server.name.toLowerCase().contains('worker') ||
              server.name.toLowerCase().contains('job');
          final isCache =
              server.name.toLowerCase().contains('cache') ||
              server.name.toLowerCase().contains('redis');

          double cpuBase = server.cpuUsage;
          double ramBase = server.ramUsage;

          if (isDb) {
            cpuBase = (cpuBase + _random.nextDouble() * 6 - 3).clamp(
              10.0,
              100.0,
            );
            ramBase = (ramBase + _random.nextDouble() * 4 - 1).clamp(
              40.0,
              100.0,
            );
          } else if (isWeb) {
            cpuBase = (cpuBase + _random.nextDouble() * 15 - 7.5).clamp(
              5.0,
              100.0,
            );
            ramBase = (ramBase + _random.nextDouble() * 5 - 2.5).clamp(
              20.0,
              100.0,
            );
          } else if (isWorker) {
            cpuBase = (cpuBase + _random.nextDouble() * 8 - 2).clamp(
              40.0,
              100.0,
            );
            ramBase = (ramBase + _random.nextDouble() * 4 - 2).clamp(
              15.0,
              100.0,
            );
          } else if (isCache) {
            cpuBase = (cpuBase + _random.nextDouble() * 2 - 1).clamp(
              2.0,
              100.0,
            );
            ramBase = (ramBase + _random.nextDouble() * 2 - 0.5).clamp(
              60.0,
              100.0,
            );
          } else {
            cpuBase = (cpuBase + _random.nextDouble() * 10 - 5).clamp(
              5.0,
              100.0,
            );
            ramBase = (ramBase + _random.nextDouble() * 4 - 2).clamp(
              10.0,
              100.0,
            );
          }

          if ((cpuBase > 96.0 || ramBase > 96.0) &&
              _random.nextDouble() > 0.8) {
            addLog(
              'ERROR',
              'SERVER',
              'Surcharge critique, panne du serveur ${server.name}',
              server: server.name,
            );
            pushEvent(
              ServerErrorEvent(
                serverId: server.id,
                serverName: server.name,
                reason:
                    'Surcharge critique (CPU: ${cpuBase.toInt()}%, RAM: ${ramBase.toInt()}%)',
              ),
            );
            return server.copyWith(
              statusRaw: 'error',
              cpuUsage: cpuBase,
              ramUsage: ramBase,
            );
          } else {
            return server.copyWith(cpuUsage: cpuBase, ramUsage: ramBase);
          }
        }
      } else if (server.statusRaw == 'error' || server.statusRaw == 'stopped') {
        if (_random.nextDouble() < 0.15) {
          addLog(
            'SUCCESS',
            'SERVER',
            'Le serveur ${server.name} est à nouveau en ligne',
            server: server.name,
          );
          pushEvent(
            ServerStartedEvent(serverId: server.id, serverName: server.name),
          );
          return server.copyWith(
            statusRaw: 'online',
            cpuUsage: 15.0,
            ramUsage: 25.0,
          );
        }
        return server;
      } else if (server.statusRaw == 'restarting') {
        addLog(
          'SUCCESS',
          'SERVER',
          'Le serveur ${server.name} a terminé de redémarrer',
          server: server.name,
        );
        pushEvent(
          ServerStartedEvent(serverId: server.id, serverName: server.name),
        );
        return server.copyWith(
          statusRaw: 'online',
          cpuUsage: 15.0,
          ramUsage: 25.0,
        );
      }
      return server;
    }).toList();

    servers.value = updatedServers;

    // 2. Evolve Projects
    final updatedProjects = projects.value.map((project) {
      final srv = servers.value.firstWhere(
        (s) => s.id == project.serverId,
        orElse: () => ServerModel(id: '', name: '', ipAddress: ''),
      );

      if (srv.id.isNotEmpty) {
        if (srv.statusRaw == 'offline' ||
            srv.statusRaw == 'error' ||
            srv.statusRaw == 'stopped') {
          return project.copyWith(health: 'Offline', status: 'Stopped');
        } else if (srv.statusRaw == 'restarting') {
          return project.copyWith(health: 'Degraded', status: 'Deploying');
        } else {
          if (project.status == 'Deploying') {
            if (_random.nextDouble() < 0.4) {
              if (_random.nextDouble() < 0.8) {
                addLog(
                  'SUCCESS',
                  'PROJECT',
                  'Déploiement réussi pour ${project.name}',
                  project: project.name,
                );
                pushEvent(
                  ProjectDeployedEvent(
                    projectId: project.id,
                    projectName: project.name,
                  ),
                );
                return project.copyWith(health: 'Healthy', status: 'Running');
              } else {
                addLog(
                  'ERROR',
                  'PROJECT',
                  'Échec du déploiement pour ${project.name}',
                  project: project.name,
                );
                pushEvent(
                  ProjectDeploymentFailedEvent(
                    projectId: project.id,
                    projectName: project.name,
                  ),
                );
                return project.copyWith(health: 'Degraded', status: 'Failed');
              }
            }
          } else if (project.status == 'Failed') {
            if (_random.nextDouble() < 0.2) {
              addLog(
                'INFO',
                'PROJECT',
                'Redéploiement automatique de ${project.name}',
                project: project.name,
              );
              return project.copyWith(status: 'Deploying');
            }
          } else {
            if (_random.nextDouble() < 0.05) {
              addLog(
                'INFO',
                'PROJECT',
                'Déploiement automatique déclenché pour ${project.name}',
                project: project.name,
              );
              return project.copyWith(status: 'Deploying');
            } else {
              return project.copyWith(health: 'Healthy', status: 'Running');
            }
          }
        }
      }
      return project;
    }).toList();

    projects.value = updatedProjects;

    // 3. Compute Metrics
    final onlineServers = servers.value
        .where((s) => s.statusRaw == 'online')
        .toList();
    final avgCpu = onlineServers.isNotEmpty
        ? onlineServers.map((s) => s.cpuUsage).reduce((a, b) => a + b) /
              onlineServers.length
        : 0.0;
    final avgRam = onlineServers.isNotEmpty
        ? onlineServers.map((s) => s.ramUsage).reduce((a, b) => a + b) /
              onlineServers.length
        : 0.0;
    final currentRamUsed = (avgRam / 100.0) * _ramTotal;

    _currentDiskUsed = (_currentDiskUsed + (_random.nextDouble() * 0.5)).clamp(
      500.0,
      1950.0,
    );
    final diskUsage = (_currentDiskUsed / _diskTotal) * 100.0;
    _currentProcesses = (_currentProcesses + _random.nextInt(21) - 10).clamp(
      300,
      800,
    );

    dashboardMetrics.value = MetricsModel(
      cpuUsage: avgCpu,
      ramUsage: avgRam,
      diskUsage: diskUsage,
      runningProcesses: _currentProcesses,
      ramUsedGb: currentRamUsed,
      ramTotalGb: _ramTotal,
      diskUsedGb: _currentDiskUsed,
      diskTotalGb: _diskTotal,
    );

    // 4. Alert Reconciliation
    var newAlerts = List<AlertModel>.from(alerts.value);

    for (final server in servers.value) {
      final cpuId = 'auto-cpu-${server.id}';
      if (server.cpuUsage > 90.0) {
        if (!newAlerts.any((a) => a.id == cpuId)) {
          newAlerts.insert(
            0,
            AlertModel(
              id: cpuId,
              title: 'Surcharge CPU',
              description:
                  'Le CPU de ${server.name} est à ${server.cpuUsage.toInt()}%',
              typeRaw: 'critical',
              date: currentTime,
              status: 'Active',
              server: server.name,
            ),
          );
          addLog(
            'WARNING',
            'ALERT',
            'Surcharge CPU sur ${server.name}',
            server: server.name,
          );
          pushEvent(
            AlertCreatedEvent(
              alertId: cpuId,
              title: 'Surcharge CPU sur ${server.name}',
            ),
          );
        }
      } else {
        final existingIndex = newAlerts.indexWhere((a) => a.id == cpuId);
        if (existingIndex != -1) {
          final existing = newAlerts[existingIndex];
          addLog(
            'SUCCESS',
            'ALERT',
            'Problème CPU résolu sur ${server.name}',
            server: server.name,
          );
          pushEvent(
            AlertUpdatedEvent(
              alertId: cpuId,
              title: existing.title,
              status: 'Resolved',
            ),
          );
          newAlerts.removeAt(existingIndex);
        }
      }

      final ramId = 'auto-ram-${server.id}';
      if (server.ramUsage > 90.0) {
        if (!newAlerts.any((a) => a.id == ramId)) {
          newAlerts.insert(
            0,
            AlertModel(
              id: ramId,
              title: 'Surcharge Mémoire',
              description:
                  'La RAM de ${server.name} est à ${server.ramUsage.toInt()}%',
              typeRaw: 'warning',
              date: currentTime,
              status: 'Active',
              server: server.name,
            ),
          );
          addLog(
            'WARNING',
            'ALERT',
            'Surcharge RAM sur ${server.name}',
            server: server.name,
          );
          pushEvent(
            AlertCreatedEvent(
              alertId: ramId,
              title: 'Surcharge RAM sur ${server.name}',
            ),
          );
        }
      } else {
        final existingIndex = newAlerts.indexWhere((a) => a.id == ramId);
        if (existingIndex != -1) {
          final existing = newAlerts[existingIndex];
          addLog(
            'SUCCESS',
            'ALERT',
            'Problème Mémoire résolu sur ${server.name}',
            server: server.name,
          );
          pushEvent(
            AlertUpdatedEvent(
              alertId: ramId,
              title: existing.title,
              status: 'Resolved',
            ),
          );
          newAlerts.removeAt(existingIndex);
        }
      }

      final offlineId = 'auto-off-${server.id}';
      if (server.statusRaw == 'offline' || server.statusRaw == 'error') {
        if (!newAlerts.any((a) => a.id == offlineId)) {
          newAlerts.insert(
            0,
            AlertModel(
              id: offlineId,
              title: 'Serveur Injoignable',
              description: 'Le serveur ${server.name} est ${server.statusRaw}',
              typeRaw: 'critical',
              date: currentTime,
              status: 'Active',
              server: server.name,
            ),
          );
          addLog(
            'ERROR',
            'ALERT',
            'Serveur Injoignable: ${server.name}',
            server: server.name,
          );
          pushEvent(
            AlertCreatedEvent(
              alertId: offlineId,
              title: 'Serveur ${server.name} Injoignable',
            ),
          );
        }
      } else {
        final existingIndex = newAlerts.indexWhere((a) => a.id == offlineId);
        if (existingIndex != -1) {
          final existing = newAlerts[existingIndex];
          addLog(
            'SUCCESS',
            'ALERT',
            'Serveur ${server.name} à nouveau joignable',
            server: server.name,
          );
          pushEvent(
            AlertUpdatedEvent(
              alertId: offlineId,
              title: existing.title,
              status: 'Resolved',
            ),
          );
          newAlerts.removeAt(existingIndex);
        }
      }
    }

    alerts.value = newAlerts;
  }

  // ─────────────────────────────────────────
  // LOGS & ALERTS MUTATIONS
  // ─────────────────────────────────────────
  void addLog(
    String level,
    String source,
    String message, {
    String? server,
    String? project,
  }) {
    final currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
    final newLog = LogModel(
      id: 'log-${DateTime.now().millisecondsSinceEpoch}-${_random.nextInt(1000)}',
      timestamp: currentTime,
      levelRaw: level,
      sourceRaw: source,
      message: message,
      relatedServer: server,
      relatedProject: project,
    );

    final currentLogs = List<LogModel>.from(logs.value);
    currentLogs.insert(0, newLog);
    if (currentLogs.length > 500) {
      currentLogs.removeLast();
    }
    logs.value = currentLogs;
  }

  void clearLogs() {
    logs.value = [];
  }

  Future<void> acknowledgeAlert(String id) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final updated = alerts.value.map((a) {
      if (a.id == id) {
        return a.copyWith(status: 'Acknowledged');
      }
      return a;
    }).toList();
    alerts.value = updated;

    final title = alerts.value
        .firstWhere(
          (a) => a.id == id,
          orElse: () => AlertModel(id: id, title: id, description: ''),
        )
        .title;
    addLog('INFO', 'ALERT', 'Alerte acquittée: $title');
    pushEvent(
      AlertUpdatedEvent(alertId: id, title: title, status: 'Acknowledged'),
    );
  }

  Future<void> resolveAlert(String id) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final updated = alerts.value.map((a) {
      if (a.id == id) {
        return a.copyWith(status: 'Resolved');
      }
      return a;
    }).toList();
    alerts.value = updated;

    final title = alerts.value
        .firstWhere(
          (a) => a.id == id,
          orElse: () => AlertModel(id: id, title: id, description: ''),
        )
        .title;
    addLog('SUCCESS', 'ALERT', 'Alerte résolue: $title');
    pushEvent(AlertUpdatedEvent(alertId: id, title: title, status: 'Resolved'));
  }

  void deleteAlert(String id) {
    final title = alerts.value
        .firstWhere(
          (a) => a.id == id,
          orElse: () => AlertModel(id: id, title: id, description: ''),
        )
        .title;
    alerts.value = alerts.value.where((a) => a.id != id).toList();
    addLog('WARNING', 'ALERT', 'Alerte supprimée: $title');
  }

  // ─────────────────────────────────────────
  // SERVER MUTATIONS
  // ─────────────────────────────────────────
  ServerModel addServer(CreateServerRequest request) {
    final newServer = ServerModel(
      id: 'srv-${DateTime.now().millisecondsSinceEpoch}',
      name: request.name,
      ipAddress: request.ipAddress,
      statusRaw: 'online',
      cpuUsage: 10.0,
      ramUsage: 20.0,
      os: request.os.isEmpty ? 'Linux' : request.os,
      location: request.location.isEmpty ? 'Unknown' : request.location,
      uptimeHours: 0,
    );

    final current = List<ServerModel>.from(servers.value);
    current.add(newServer);
    servers.value = current;

    addLog(
      'SUCCESS',
      'SERVER',
      'Nouveau serveur créé: ${request.name}',
      server: request.name,
    );
    pushEvent(
      ServerCreatedEvent(serverId: newServer.id, serverName: newServer.name),
    );
    return newServer;
  }

  void deleteServer(String id) {
    final srv = servers.value.firstWhere(
      (s) => s.id == id,
      orElse: () => ServerModel(id: id, name: id, ipAddress: ''),
    );
    final serverName = srv.name;

    servers.value = servers.value.where((s) => s.id != id).toList();
    projects.value = projects.value.where((p) => p.serverId != id).toList();

    addLog(
      'WARNING',
      'SERVER',
      'Serveur supprimé: $serverName',
      server: serverName,
    );
    pushEvent(ServerDeletedEvent(serverId: id, serverName: serverName));
  }

  void updateServerStatus(String id, String newStatus) {
    String serverName = id;
    final updated = servers.value.map((server) {
      if (server.id == id) {
        serverName = server.name;
        final isOff = ['stopped', 'error', 'maintenance'].contains(newStatus);
        return server.copyWith(
          statusRaw: newStatus,
          cpuUsage: isOff ? 0.0 : server.cpuUsage,
          ramUsage: isOff ? 0.0 : server.ramUsage,
        );
      }
      return server;
    }).toList();

    servers.value = updated;

    final logLevel = newStatus == 'error'
        ? 'ERROR'
        : (newStatus == 'maintenance' ? 'WARNING' : 'INFO');
    addLog(
      logLevel,
      'SERVER',
      'Le serveur $serverName est passé en \'$newStatus\'',
      server: serverName,
    );

    if (newStatus == 'error' || newStatus == 'offline') {
      pushEvent(
        ServerErrorEvent(
          serverId: id,
          serverName: serverName,
          reason: 'État: $newStatus',
        ),
      );
    } else if (newStatus == 'online') {
      pushEvent(ServerStartedEvent(serverId: id, serverName: serverName));
    } else if (newStatus == 'restarting') {
      pushEvent(ServerRestartedEvent(serverId: id, serverName: serverName));
    } else if (newStatus == 'stopped') {
      pushEvent(ServerStoppedEvent(serverId: id, serverName: serverName));
    }
  }

  // ─────────────────────────────────────────
  // PROJECT MUTATIONS
  // ─────────────────────────────────────────
  ProjectModel addProject(CreateProjectRequest request) {
    ServerInfo? srvInfo;
    if (request.serverId != null) {
      final s = servers.value.firstWhere(
        (srv) => srv.id == request.serverId,
        orElse: () => ServerModel(id: '', name: '', ipAddress: ''),
      );
      if (s.id.isNotEmpty) {
        srvInfo = ServerInfo(id: s.id, name: s.name);
      }
    }

    final newProject = ProjectModel(
      id: 'prj-${DateTime.now().millisecondsSinceEpoch}',
      name: request.name,
      description: request.description,
      environment: 'Production',
      status: 'Deploying',
      health: 'Healthy',
      version: '1.0.0',
      lastDeployment: 'À l\'instant',
      serverId: request.serverId,
      server: srvInfo,
    );

    final current = List<ProjectModel>.from(projects.value);
    current.add(newProject);
    projects.value = current;

    addLog(
      'SUCCESS',
      'PROJECT',
      'Nouveau projet créé: ${request.name}',
      project: request.name,
    );
    return newProject;
  }

  void deleteProject(String id) {
    final prj = projects.value.firstWhere(
      (p) => p.id == id,
      orElse: () => ProjectModel(id: id, name: id),
    );
    final projectName = prj.name;

    projects.value = projects.value.where((p) => p.id != id).toList();
    addLog(
      'WARNING',
      'PROJECT',
      'Projet supprimé: $projectName',
      project: projectName,
    );
  }

  void setProjectStatus(String id, String newStatus) {
    projects.value = projects.value.map((p) {
      if (p.id == id) {
        return p.copyWith(status: newStatus);
      }
      return p;
    }).toList();
  }

  Future<void> deployProject(String id) async {
    final prj = projects.value.firstWhere(
      (p) => p.id == id,
      orElse: () => ProjectModel(id: id, name: id),
    );
    final projectName = prj.name;

    addLog(
      'INFO',
      'PROJECT',
      'Déploiement initié pour le projet $projectName',
      project: projectName,
    );
    setProjectStatus(id, 'Deploying');

    await Future.delayed(Duration(milliseconds: 2000 + _random.nextInt(3000)));

    if (_random.nextDouble() > 0.2) {
      setProjectStatus(id, 'Running');
      pushEvent(ProjectDeployedEvent(projectId: id, projectName: projectName));
      addLog(
        'SUCCESS',
        'PROJECT',
        'Projet $projectName déployé avec succès',
        project: projectName,
      );
    } else {
      setProjectStatus(id, 'Failed');
      pushEvent(
        ProjectDeploymentFailedEvent(projectId: id, projectName: projectName),
      );
      addLog(
        'ERROR',
        'PROJECT',
        'Échec du déploiement du projet $projectName',
        project: projectName,
      );
    }
  }

  Future<void> restartProject(String id) async {
    final prj = projects.value.firstWhere(
      (p) => p.id == id,
      orElse: () => ProjectModel(id: id, name: id),
    );
    setProjectStatus(id, 'Restarting');
    await Future.delayed(const Duration(milliseconds: 1500));
    setProjectStatus(id, 'Running');
    addLog(
      'INFO',
      'PROJECT',
      'Projet ${prj.name} redémarré',
      project: prj.name,
    );
  }

  Future<void> stopProject(String id) async {
    final prj = projects.value.firstWhere(
      (p) => p.id == id,
      orElse: () => ProjectModel(id: id, name: id),
    );
    setProjectStatus(id, 'Stopping');
    await Future.delayed(const Duration(milliseconds: 1000));
    setProjectStatus(id, 'Stopped');
    addLog(
      'WARNING',
      'PROJECT',
      'Projet ${prj.name} arrêté',
      project: prj.name,
    );
  }

  // ─────────────────────────────────────────
  // ADMIN SIMULATION TRIGGERS
  // ─────────────────────────────────────────
  void simulateCpuSpike() {
    final online = servers.value.where((s) => s.statusRaw == 'online').toList();
    if (online.isNotEmpty) {
      final target = online[_random.nextInt(online.length)];
      servers.value = servers.value.map((s) {
        if (s.id == target.id) {
          return s.copyWith(cpuUsage: 99.0);
        }
        return s;
      }).toList();
      addLog(
        'WARNING',
        'SYSTEM',
        'Simulation de pic CPU déclenchée sur ${target.name}',
      );
    }
  }

  void simulateServerFailure() {
    final online = servers.value.where((s) => s.statusRaw == 'online').toList();
    if (online.isNotEmpty) {
      final target = online[_random.nextInt(online.length)];
      updateServerStatus(target.id, 'error');
      addLog(
        'ERROR',
        'SYSTEM',
        'Simulation de panne serveur déclenchée sur ${target.name}',
      );
    }
  }

  Future<void> simulateDeploymentFailure() async {
    final running = projects.value.where((p) => p.status == 'Running').toList();
    if (running.isNotEmpty) {
      final target = running[_random.nextInt(running.length)];
      addLog(
        'WARNING',
        'SYSTEM',
        'Simulation d\'échec de déploiement déclenchée sur ${target.name}',
      );
      setProjectStatus(target.id, 'Deploying');
      await Future.delayed(const Duration(milliseconds: 2000));
      setProjectStatus(target.id, 'Failed');
      pushEvent(
        ProjectDeploymentFailedEvent(
          projectId: target.id,
          projectName: target.name,
        ),
      );
      addLog(
        'ERROR',
        'PROJECT',
        'Échec du déploiement du projet ${target.name}',
        project: target.name,
      );
    }
  }

  // ─────────────────────────────────────────
  // NOTIFICATIONS MUTATIONS
  // ─────────────────────────────────────────
  void markNotificationAsRead(String id) {
    notifications.value = notifications.value.map((n) {
      if (n.id == id) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();
  }

  void markAllNotificationsAsRead() {
    notifications.value = notifications.value
        .map((n) => n.copyWith(isRead: true))
        .toList();
  }

  void deleteNotification(String id) {
    notifications.value = notifications.value.where((n) => n.id != id).toList();
  }

  void clearNotifications() {
    notifications.value = [];
    addLog('INFO', 'SYSTEM', 'Toutes les notifications ont été effacées');
  }

  // ─────────────────────────────────────────
  // USER MANAGEMENT ACTIONS
  // ─────────────────────────────────────────
  void toggleBlockUser(String id) {
    managedUsers.value = managedUsers.value.map((u) {
      if (u.id == id) {
        final newStatus = u.status == UserStatus.active
            ? UserStatus.blocked
            : UserStatus.active;
        addLog(
          'INFO',
          'AUTH',
          'Statut utilisateur ${u.email} modifié en $newStatus',
        );
        return u.copyWith(status: newStatus);
      }
      return u;
    }).toList();
  }

  void deleteManagedUser(String id) {
    final u = managedUsers.value.firstWhere(
      (x) => x.id == id,
      orElse: () =>
          UserItem(id: id, name: id, email: id, role: '', lastLogin: ''),
    );
    managedUsers.value = managedUsers.value.where((x) => x.id != id).toList();
    addLog('WARNING', 'AUTH', 'Utilisateur supprimé: ${u.email}');
  }

  void addManagedUser(String name, String email, String role) {
    final newUser = UserItem(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      role: role,
      status: UserStatus.active,
      lastLogin: 'À l\'instant',
    );
    final current = List<UserItem>.from(managedUsers.value);
    current.insert(0, newUser);
    managedUsers.value = current;

    users.add(
      UserResponse(
        id: newUser.id,
        name: name,
        email: email,
        role: role.toLowerCase(),
      ),
    );
    passwords[email] = 'password123';

    addLog('SUCCESS', 'AUTH', 'Nouvel utilisateur créé: $email');
    pushEvent(UserRegisteredEvent(email: email));
  }
}
