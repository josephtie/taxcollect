import 'package:flutter_test/flutter_test.dart';
import 'package:verdentax/models/models.dart';

void main() {
  group('User', () {
    test('fromJson — payload JWT Keycloak (sub + preferred_username + realm_access)', () {
      final u = User.fromJson(<String, dynamic>{
        'sub': 'uuid-123',
        'preferred_username': 'agent',
        'given_name': 'Joseph',
        'family_name': 'Guessan',
        'realm_access': {
          'roles': ['AGENT', 'offline_access', 'default-roles-mairie', 'uma_authorization'],
        },
      });
      expect(u.id, 'uuid-123');
      expect(u.username, 'agent');
      expect(u.firstName, 'Joseph');
      expect(u.roles, ['AGENT']); // filtre les rôles techniques Keycloak
      expect(u.isAgent, isTrue);
      expect(u.isAdmin, isFalse);
    });

    test('fromJson — réponse /api/users (id + username + realmRoles)', () {
      final u = User.fromJson(<String, dynamic>{
        'id': 'u1',
        'username': 'admin',
        'email': 'admin@mairie.ci',
        'firstName': 'Patrick',
        'lastName': 'A',
        'realmRoles': ['ADMIN'],
      });
      expect(u.id, 'u1');
      expect(u.username, 'admin');
      expect(u.roles, ['ADMIN']);
      expect(u.isAdmin, isTrue);
      expect(u.isSupervisor, isTrue); // admin compte comme superviseur
    });

    test('hasRole / hasAnyRole', () {
      final u = User.fromJson(<String, dynamic>{
        'id': 'u',
        'username': 'tresor',
        'roles': ['TRESOR'],
      });
      expect(u.hasRole('TRESOR'), isTrue);
      expect(u.hasRole('AGENT'), isFalse);
      expect(u.hasAnyRole(['TRESOR', 'AGENT']), isTrue);
      expect(u.hasAnyRole(['ADMIN']), isFalse);
      expect(u.isTresor, isTrue);
    });

    test('toJson round-trip (roles via realmRoles)', () {
      final u = User.fromJson(<String, dynamic>{
        'id': 'u',
        'username': 'agent',
        'roles': ['AGENT'],
      });
      final u2 = User.fromJson(u.toJson());
      expect(u2.username, 'agent');
      expect(u2.roles, ['AGENT']);
    });
  });
}
