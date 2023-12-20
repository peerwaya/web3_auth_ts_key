import Flutter
import UIKit
import tkey

public class Web3AuthTsKeyPlugin: NSObject, FlutterPlugin {
    var threshold_key: ThresholdKey!
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "web3_auth_ts_key", binaryMessenger: registrar.messenger())
    let instance = Web3AuthTsKeyPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      Task {
          switch call.method {
          case "initialize":
              guard let args = call.arguments as? [String: Any] else {
                  result(FlutterError(
                    code: "INVALID_ARGUMENTS",
                    message: "Invalid Flutter iOS plugin method arguments",
                    details: nil))
                  return
              }
              guard
                let postboxkey = args["privateKey"] as? String,
                let enableLogging = args["enableLogging"] as? Bool,
                let manualSync = args["manualSync"] as? Bool,
                let neverInitializeNewKey = args["neverInitializeNewKey"] as? Bool,
                let importShare = args["importShare"] as? Bool
              else {
                  result(FlutterError(
                    code: "THRESHOLD_KEY_INITIALIZE_FAILURE",
                    message: "Missing init arguments",
                    details: nil))
                  return
              }
              guard let storage_layer = try? StorageLayer(enable_logging: true, host_url: "https://metadata.tor.us", server_time_offset: 2) else {
                  result(FlutterError(
                    code: "THRESHOLD_KEY_INITIALIZE_FAILURE",
                    message: "Failed to create storage layer",
                    details: nil))
                  return
              }
              
              guard let service_provider = try? ServiceProvider(enable_logging: true, postbox_key: postboxkey) else {
                  result(FlutterError(
                    code: "THRESHOLD_KEY_INITIALIZE_FAILURE",
                    message: "Failed to create storage layer",
                    details: nil))
                  return
              }
              guard let thresholdKey = try? ThresholdKey(
                storage_layer: storage_layer,
                service_provider: service_provider,
                enable_logging: enableLogging,
                manual_sync: manualSync) else {
                  result(FlutterError(
                    code: "THRESHOLD_KEY_INITIALIZE_FAILURE",
                    message: "Failed to create storage layer",
                    details: nil))
                  return
              }
              
              threshold_key = thresholdKey
              guard let key_details = try? await thresholdKey.initialize(never_initialize_new_key: neverInitializeNewKey, include_local_metadata_transitions: false) else {
                  result(FlutterError(
                    code: "THRESHOLD_KEY_INITIALIZE_FAILURE",
                    message: "Failed to get key details",
                    details: nil))
                  return
              }
              result(serializeKeyDetailsToDict(key_details))
          case "reconstruct":
              guard let reconstruction_details = try? await threshold_key?.reconstruct() else {
                  result(FlutterError(
                    code: "THRESHOLD_KEY_RECONSTRUCTION_FAILURE",
                    message: "Failed to reconstruct keys",
                    details: nil))
                  return
              }
              result([
                "key": reconstruction_details.key,
                "seedPhrase": reconstruction_details.seed_phrase,
                "allKeys": reconstruction_details.all_keys,
            ])
          case "inputShare":
              guard let share = call.arguments as? String else {
                  result(FlutterError(
                    code: "INVALID_ARGUMENTS",
                    message: "Invalid Flutter iOS plugin method arguments",
                    details: nil))
                  return
              }
              do {
                  _ = try await threshold_key?.input_share(share: share, shareType: nil)
              } catch {
                  result(FlutterError(
                    code: "INPUT_SHARES_FAILURE",
                    message: "Failed to input shares",
                    details: nil))
                  return
              }
              result(())
          case "outputShare":
              guard let shareIndex = call.arguments as? String else {
                  result(FlutterError(
                    code: "INVALID_ARGUMENTS",
                    message: "Invalid Flutter iOS plugin method arguments",
                    details: nil))
                  return
              }
              do {
                  let share = try threshold_key?.output_share(shareIndex: shareIndex, shareType: nil)
                  result(share)
              } catch {
                  result(FlutterError(
                    code: "OUTPUT_SHARES_FAILURE",
                    message: "Failed to input shares",
                    details: nil))
                  return
              }
          case "getSharesIndexes":
              do {
                  let shareIndexes = try threshold_key?.get_shares_indexes();
                  result(shareIndexes)
              } catch {
                  result(FlutterError(
                    code: "SHARE_INDEXES_FAILURE",
                    message: "Failed to input shares",
                    details: nil))
                  return
              }
          case "generateSecurityQuestion":
              guard let args = call.arguments as? [String: Any] else {
                  result(FlutterError(
                    code: "INVALID_ARGUMENTS",
                    message: "Invalid Flutter iOS plugin method arguments",
                    details: nil))
                  return
              }
              guard
                let question = args["question"] as? String,
                let answer = args["answer"] as? String else {
                  result(FlutterError(
                    code: "INVALID_ARGUMENTS",
                    message: "Invalid Flutter iOS plugin method arguments",
                    details: nil))
                  return
              }
              do {
                  let share =  try await SecurityQuestionModule.generate_new_share(threshold_key: threshold_key, questions: question, answer: answer)
                  result(share.hex)
              } catch {
                  result(FlutterError(
                    code: "GENERATE_SECURITY_QUESTION_FAILED",
                    message: "Failed to input shares",
                    details: nil))
                  return
              }
          case "changeSecurityQuestion":
              guard let args = call.arguments as? [String: Any] else {
                  result(FlutterError(
                    code: "INVALID_ARGUMENTS",
                    message: "Invalid Flutter iOS plugin method arguments",
                    details: nil))
                  return
              }
              guard
                let question = args["question"] as? String,
                let answer = args["answer"] as? String else {
                  result(FlutterError(
                    code: "INVALID_ARGUMENTS",
                    message: "Invalid Flutter iOS plugin method arguments",
                    details: nil))
                  return
              }
              do {
                  let success =  try await SecurityQuestionModule.change_question_and_answer(threshold_key: threshold_key, questions: question, answer: answer)
                  result(success)
              } catch {
                  result(FlutterError(
                    code: "CHANGE_SECURITY_QUESTION_FAILED",
                    message: "Failed to input shares",
                    details: nil))
                  return
              }
          case "inputSecurityQuestionShare":
              guard let answer = call.arguments as? String else {
                  result(FlutterError(
                    code: "INVALID_ARGUMENTS",
                    message: "Invalid Flutter iOS plugin method arguments",
                    details: nil))
                  return
              }
              do {
                  let success =  try await SecurityQuestionModule.input_share(threshold_key: threshold_key, answer: answer)
                  result(success)
              } catch {
                  result(FlutterError(
                    code: "INPUT_SECURITY_QUESTION_SHARE_FAILED",
                    message: "Failed to input shares",
                    details: nil))
                  return
              }
          case "generateNewShare":
              do {
                  let share =  try await threshold_key.generate_new_share()
                  result(share.hex)
              } catch {
                  result(FlutterError(
                    code: "GENERATE_NEW_SHARE_FAILED",
                    message: "Failed to generate a new share",
                    details: nil))
                  return
              }
          case "deleteShare":              
              guard let index = call.arguments as? String else {
                  result(FlutterError(
                    code: "INVALID_ARGUMENTS",
                    message: "Invalid Flutter iOS plugin method arguments",
                    details: nil))
                  return
              }
              do {
                  let _ =  try await threshold_key.delete_share(share_index: index);
                  let key_details = try threshold_key.get_key_details()
                  result(serializeKeyDetailsToDict(key_details))
              } catch {
                  result(FlutterError(
                    code: "DELETE_SHARE_FAILED",
                    message: "Failed to delete share at index \(index)",
                    details: nil))
                  return
              }
          default:
              result(FlutterMethodNotImplemented)
          }
      }
  }
    
    func serializeKeyDetailsToDict(_ keyDetails: KeyDetails) -> [String: Any] {
        // Create a dictionary representation
        return [
            "pubKeyX": try! keyDetails.pub_key.getX(),
            "pubKeyY": try! keyDetails.pub_key.getY(),
            "requiredShares": keyDetails.required_shares,
            "threshold": keyDetails.threshold,
            "totalShares": keyDetails.total_shares,
            "shareDescriptions": keyDetails.share_descriptions
        ];
    }
}
