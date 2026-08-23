class UploadResultModel {
  final String url;
  final String publicId;

  const UploadResultModel({
    required this.url,
    required this.publicId,
  });

  factory UploadResultModel.fromMap(Map<String, dynamic> map) {
    return UploadResultModel(
      url: map['url'] as String,
      publicId: map['publicId'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'publicId': publicId,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UploadResultModel &&
          runtimeType == other.runtimeType &&
          url == other.url &&
          publicId == other.publicId;

  @override
  int get hashCode => url.hashCode ^ publicId.hashCode;
}
