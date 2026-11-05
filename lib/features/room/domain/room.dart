class Room {
  const Room({required this.code, required this.memberCount});

  final String code;
  final int memberCount;

  factory Room.fromMap(String code, Map<String, dynamic> data) =>
      Room(code: code, memberCount: (data['memberCount'] as num?)?.toInt() ?? 0);

  String get title => 'Room #$code';
}

String membersLabel(int count) => '$count ${count == 1 ? 'member' : 'members'}';
