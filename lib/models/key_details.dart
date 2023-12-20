import 'package:json_annotation/json_annotation.dart';

part 'key_details.g.dart';

@JsonSerializable()
class KeyDetails {
  final String pubKeyX;
  final String pubKeyY;
  final int requiredShares;
  final int threshold;
  final int totalShares;
  final String? shareDescriptions;

  KeyDetails({
    required this.pubKeyX,
    required this.pubKeyY,
    required this.requiredShares,
    required this.threshold,
    required this.totalShares,
    this.shareDescriptions,
  });
  factory KeyDetails.fromJson(Map<String, dynamic> json) =>
      _$KeyDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$KeyDetailsToJson(this);
}
