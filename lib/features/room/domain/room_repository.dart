import '../../identity/domain/identity.dart';
import 'room.dart';

abstract interface class RoomRepository {
  /// Server-checked lookup. `null` = no such room. Throws AppException when offline.
  Future<Room?> fetchRoom(String code);

  /// Creates a room with a free random 6-digit code.
  Future<Room> createRoom();

  /// Registers [identity] as a member (member document + memberCount + 1).
  Future<void> joinRoom(String code, Identity identity);

  /// Live room document (member count).
  Stream<Room> watchRoom(String code);
}
