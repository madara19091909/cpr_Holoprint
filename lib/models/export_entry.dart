class ExportEntry {
  const ExportEntry({
    required this.id,
    required this.fileName,
    required this.createdAt,
    required this.bytes,
  });

  final String id;
  final String fileName;
  final DateTime createdAt;
  final int bytes;

  Map<String, Object> toJson() => {
        'id': id,
        'fileName': fileName,
        'createdAt': createdAt.toIso8601String(),
        'bytes': bytes,
      };

  factory ExportEntry.fromJson(Map<String, dynamic> json) {
    return ExportEntry(
      id: json['id'] as String? ?? '',
      fileName: json['fileName'] as String? ?? 'CPR-Holoprint.mcpack',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      bytes: (json['bytes'] as num?)?.toInt() ?? 0,
    );
  }
}
