import 'package:json_annotation/json_annotation.dart';

part 'threshold_params.g.dart';

@JsonSerializable()
class ThresholdParams {
  final String privateKey;
  final bool enableLogging;
  final bool manualSync;
  final bool importShare;
  final bool neverInitializeNewKey;
  final bool includeLocalMetadataTransitions;

  ThresholdParams({
    required this.privateKey,
    this.enableLogging = false,
    this.manualSync = false,
    this.importShare = false,
    this.neverInitializeNewKey = false,
    this.includeLocalMetadataTransitions = false,
  });

  factory ThresholdParams.fromJson(Map<String, dynamic> json) =>
      _$ThresholdParamsFromJson(json);

  Map<String, dynamic> toJson() => _$ThresholdParamsToJson(this);
}
