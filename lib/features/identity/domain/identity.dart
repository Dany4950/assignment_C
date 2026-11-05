enum IdentitySource { remote, local }

/// The anonymous persona of ONE device in ONE room.
class Identity {
  const Identity({
    required this.memberId,
    required this.displayName,
    this.avatarUrl,
    this.source = IdentitySource.remote,
  });

  /// Random per room (never the auth uid), so identities cannot be linked across rooms.
  final String memberId;

  /// "Brave Badger"
  final String displayName;
  final String? avatarUrl;
  final IdentitySource source;

  /// "@BraveBadger" - how other members see the author above a message.
  String get handle => '@${displayName.replaceAll(' ', '')}';

  Map<String, dynamic> toJson() => <String, dynamic>{
        'memberId': memberId,
        'displayName': displayName,
        'avatarUrl': avatarUrl,
        'source': source.name,
      };

  factory Identity.fromJson(Map<String, dynamic> json) => Identity(
        memberId: json['memberId'] as String,
        displayName: json['displayName'] as String,
        avatarUrl: json['avatarUrl'] as String?,
        source: IdentitySource.values.firstWhere(
          (s) => s.name == json['source'],
          orElse: () => IdentitySource.remote,
        ),
      );
}
