import '../../../features/auth/domain/entities/user_entity.dart';

enum SessionStatus { unknown, unauthenticated, newUser, authenticated }

class SessionState {
  final SessionStatus status;
  final UserEntity? user;
  const SessionState({required this.status, this.user});
}
