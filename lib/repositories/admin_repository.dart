import 'package:flutter/foundation.dart';

import '../data/mock/mock_data_store.dart';

abstract class AdminRepository {
  ValueListenable<List<UserItem>> get usersListenable;
  void toggleBlockUser(String id);
  void deleteUser(String id);
  void addUser(String name, String email, String role);
  void triggerCpuSpike();
  void triggerServerFailure();
  Future<void> triggerDeploymentFailure();
}

class AdminRepositoryImpl implements AdminRepository {
  final MockDataStore mockDataStore;

  AdminRepositoryImpl({required this.mockDataStore});

  @override
  ValueListenable<List<UserItem>> get usersListenable =>
      mockDataStore.managedUsers;

  @override
  void toggleBlockUser(String id) => mockDataStore.toggleBlockUser(id);

  @override
  void deleteUser(String id) => mockDataStore.deleteManagedUser(id);

  @override
  void addUser(String name, String email, String role) =>
      mockDataStore.addManagedUser(name, email, role);

  @override
  void triggerCpuSpike() => mockDataStore.simulateCpuSpike();

  @override
  void triggerServerFailure() => mockDataStore.simulateServerFailure();

  @override
  Future<void> triggerDeploymentFailure() =>
      mockDataStore.simulateDeploymentFailure();
}
