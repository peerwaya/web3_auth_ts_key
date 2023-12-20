import 'package:json_annotation/json_annotation.dart';

part 'reconstruction_details.g.dart';

@JsonSerializable()
class ReconstructionDetails {
  final String key;
  final List<String> seedPhrase;
  final List<String> allKeys;

  ReconstructionDetails({
    required this.key,
    required this.seedPhrase,
    required this.allKeys,
  });
  factory ReconstructionDetails.fromJson(Map<String, dynamic> json) =>
      _$ReconstructionDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$ReconstructionDetailsToJson(this);
}
