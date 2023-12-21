package app.gotok.web3_auth_ts_key;

import android.util.Log;

import androidx.annotation.NonNull;

import com.web3auth.tkey.RuntimeError;
import com.web3auth.tkey.ThresholdKey.GenerateShareStoreResult;
import com.web3auth.tkey.ThresholdKey.KeyDetails;
import com.web3auth.tkey.ThresholdKey.KeyReconstructionDetails;
import com.web3auth.tkey.ThresholdKey.Modules.SecurityQuestionModule;
import com.web3auth.tkey.ThresholdKey.ServiceProvider;
import com.web3auth.tkey.ThresholdKey.StorageLayer;
import com.web3auth.tkey.ThresholdKey.ThresholdKey;
import com.web3auth.tkey.Version;

import org.json.JSONException;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** Web3AuthTsKeyPlugin */
public class Web3AuthTsKeyPlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private ThresholdKey thresholdKey;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    System.loadLibrary("tkey-native");
    try {
      String libversion = Version.current();
    } catch (RuntimeError e) {
      throw new RuntimeException("Not able to load tkey-native", e);
    }
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "web3_auth_ts_key");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("initialize")) {
      try {
        String postboxKey = (String) call.argument("privateKey");
        boolean enableLogging = (Boolean) call.argument("enableLogging");
        boolean manualSync = (Boolean) call.argument("manualSync");
        boolean neverInitializeNewKey = (Boolean) call.argument("neverInitializeNewKey");
        boolean includeLocalMetadataTransitions = (Boolean) call.argument("includeLocalMetadataTransitions");
        StorageLayer storageLayer = new StorageLayer(enableLogging, "https://metadata.tor.us", 2);
        ServiceProvider tkeyProvider = new ServiceProvider(enableLogging, postboxKey);
        thresholdKey = new ThresholdKey(null, null, storageLayer, tkeyProvider, null, null, enableLogging, manualSync);
        thresholdKey.initialize(null, null, neverInitializeNewKey, includeLocalMetadataTransitions, keyDetailsResult -> {
          try {
            if (keyDetailsResult instanceof com.web3auth.tkey.ThresholdKey.Common.Result.Error) {
              Exception e = ((com.web3auth.tkey.ThresholdKey.Common.Result.Error<KeyDetails>) keyDetailsResult).exception;
              Log.d("TKEY", "ERROR: " + e.getLocalizedMessage());
              e.printStackTrace();
              result.error("THRESHOLD_KEY_INITIALIZE_FAILURE", e.getMessage(), null);
            } else if (keyDetailsResult instanceof com.web3auth.tkey.ThresholdKey.Common.Result.Success) {
              KeyDetails details = ((com.web3auth.tkey.ThresholdKey.Common.Result.Success<KeyDetails>) keyDetailsResult).data;
              Log.d("TKEY", "GOT DETAILS: " + details);
              result.success(serializeKeyDetails(details));
            }
          }catch (RuntimeError | RuntimeException e) {
            Log.d("TKEY", "RUNTIME ERROR: " + e.getLocalizedMessage());
            result.error("THRESHOLD_KEY_INITIALIZE_FAILURE", e.getMessage(), null);
          }
        });
      } catch (RuntimeError | RuntimeException e) {
        result.error("THRESHOLD_KEY_INITIALIZE_FAILURE", e.getMessage(), null);
      }
    } else if (call.method.equals("reconstruct")) {
      if (thresholdKey == null) {
        result.error("THRESHOLD_KEY_RECONSTRUCTION_FAILURE", "Threshold key has not been initialized", null);
        return;
      }
      thresholdKey.reconstruct(keyResult -> {
        try {
          if (keyResult instanceof com.web3auth.tkey.ThresholdKey.Common.Result.Error) {
            Exception e = ((com.web3auth.tkey.ThresholdKey.Common.Result.Error<KeyReconstructionDetails>) keyResult).exception;
            result.error("THRESHOLD_KEY_RECONSTRUCTION_FAILURE", e.getMessage(), null);
          } else if (keyResult instanceof com.web3auth.tkey.ThresholdKey.Common.Result.Success) {
            KeyReconstructionDetails details = ((com.web3auth.tkey.ThresholdKey.Common.Result.Success<KeyReconstructionDetails>) keyResult).data;
            result.success(serializeKeyReconstructionDetails(details));
          }
        } catch (RuntimeError | RuntimeException e) {
          result.error("THRESHOLD_KEY_INITIALIZE_FAILURE", e.getMessage(), null);
        }
      });
    } else if (call.method.equals("inputShare")) {
      if (thresholdKey == null) {
        result.error("INPUT_SHARES_FAILURE", "Threshold key has not been initialized", null);
        return;
      }
      String share = (String) call.arguments();
      thresholdKey.inputShare(share, null, inputShareResult -> {
        if (inputShareResult instanceof com.web3auth.tkey.ThresholdKey.Common.Result.Error) {
          Exception e = ((com.web3auth.tkey.ThresholdKey.Common.Result.Error<Void>) inputShareResult).exception;
          result.error("INPUT_SHARES_FAILURE", e.getMessage(), null);
        } else if (inputShareResult instanceof com.web3auth.tkey.ThresholdKey.Common.Result.Success) {
          result.success(null);
        }
      });
    } else if (call.method.equals("outputShare")) {
      try {
        if (thresholdKey == null) {
          result.error("OUTPUT_SHARES_FAILURE", "Threshold key has not been initialized", null);
          return;
        }
        String index = (String) call.arguments();
        String share = thresholdKey.outputShare(index, null);
        result.success(share);
      } catch (RuntimeError | RuntimeException e) {
        result.error("OUTPUT_SHARES_FAILURE", e.getMessage(), null);
      }
    } else if (call.method.equals("getSharesIndexes")) {
      try {
        if (thresholdKey == null) {
          result.error("SHARE_INDEXES_FAILURE", "Threshold key has not been initialized", null);
          return;
        }
        List<String> shareIndexes = thresholdKey.getShareIndexes();
        result.success(shareIndexes);
      } catch (RuntimeError | JSONException e) {
        result.error("SHARE_INDEXES_FAILURE", e.getMessage(), null);
      }
    } else if (call.method.equals("generateSecurityQuestion")) {
      if (thresholdKey == null) {
        result.error("GENERATE_SECURITY_QUESTION_FAILED", "Threshold key has not been initialized", null);
        return;
      }
      String question = (String) call.argument("question");
      String answer = (String) call.argument("answer");
      SecurityQuestionModule.generateNewShare(thresholdKey, question, answer, shareResult -> {
        if (shareResult instanceof com.web3auth.tkey.ThresholdKey.Common.Result.Error) {
          Exception e = ((com.web3auth.tkey.ThresholdKey.Common.Result.Error<GenerateShareStoreResult>) shareResult).exception;
          result.error("GENERATE_SECURITY_QUESTION_FAILED", e.getMessage(), null);
        } else if (shareResult instanceof com.web3auth.tkey.ThresholdKey.Common.Result.Success) {
          try {
            GenerateShareStoreResult share = ((com.web3auth.tkey.ThresholdKey.Common.Result.Success<GenerateShareStoreResult>)shareResult).data;
            String shareIndexCreated = share.getIndex();
            result.success(shareIndexCreated);
          }catch (RuntimeError | RuntimeException e) {
            result.error("THRESHOLD_KEY_INITIALIZE_FAILURE", e.getMessage(), null);
          }
        }
      });
    } else if (call.method.equals("changeSecurityQuestion")) {
      if (thresholdKey == null) {
        result.error("GENERATE_SECURITY_QUESTION_FAILED", "Threshold key has not been initialized", null);
        return;
      }
      String question = (String) call.argument("question");
      String answer = (String) call.argument("answer");
      SecurityQuestionModule.changeSecurityQuestionAndAnswer(thresholdKey, question, answer, changeResult -> {
        if (changeResult instanceof com.web3auth.tkey.ThresholdKey.Common.Result.Error) {
          Exception e = ((com.web3auth.tkey.ThresholdKey.Common.Result.Error<Boolean>) changeResult).exception;
          result.error("CHANGE_SECURITY_QUESTION_FAILED", e.getMessage(), null);
        } else if (changeResult instanceof com.web3auth.tkey.ThresholdKey.Common.Result.Success) {
          result.success(((com.web3auth.tkey.ThresholdKey.Common.Result.Success<Boolean>)changeResult).data);
        }
      });
    } else if (call.method.equals("inputSecurityQuestionShare")) {
      if (thresholdKey == null) {
        result.error("GENERATE_SECURITY_QUESTION_FAILED", "Threshold key has not been initialized", null);
        return;
      }
      String answer = (String) call.arguments;
      SecurityQuestionModule.inputShare(thresholdKey, answer, inputResult -> {
        if (inputResult instanceof com.web3auth.tkey.ThresholdKey.Common.Result.Error) {
          Exception e = ((com.web3auth.tkey.ThresholdKey.Common.Result.Error<Boolean>) inputResult).exception;
          result.error("INPUT_SECURITY_QUESTION_SHARE_FAILED", e.getMessage(), null);
        } else if (inputResult instanceof com.web3auth.tkey.ThresholdKey.Common.Result.Success) {
          result.success(((com.web3auth.tkey.ThresholdKey.Common.Result.Success<Boolean>)inputResult).data);
        }
      });
    } else if (call.method.equals("generateNewShare")) {
      if (thresholdKey == null) {
        result.error("GENERATE_NEW_SHARE_FAILED", "Threshold key has not been initialized", null);
        return;
      }
      thresholdKey.generateNewShare(inputResult -> {
        if (inputResult instanceof com.web3auth.tkey.ThresholdKey.Common.Result.Error) {
          Exception e = ((com.web3auth.tkey.ThresholdKey.Common.Result.Error<GenerateShareStoreResult>) inputResult).exception;
          result.error("GENERATE_NEW_SHARE_FAILED", e.getMessage(), null);
        } else if (inputResult instanceof com.web3auth.tkey.ThresholdKey.Common.Result.Success) {
          try {
            GenerateShareStoreResult share = ((com.web3auth.tkey.ThresholdKey.Common.Result.Success<GenerateShareStoreResult>)inputResult).data;
            String shareIndexCreated = share.getIndex();
            result.success(shareIndexCreated);
          }catch (RuntimeError | RuntimeException e) {
            result.error("THRESHOLD_KEY_INITIALIZE_FAILURE", e.getMessage(), null);
          }
        }
      });
    }else if (call.method.equals("deleteShare")) {
      if (thresholdKey == null) {
        result.error("DELETE_SHARE_FAILED", "Threshold key has not been initialized", null);
        return;
      }
      String index = (String) call.arguments;
      thresholdKey.deleteShare(index, deleteResult -> {
        if (deleteResult instanceof com.web3auth.tkey.ThresholdKey.Common.Result.Error) {
          Exception e = ((com.web3auth.tkey.ThresholdKey.Common.Result.Error<Void>) deleteResult).exception;
          result.error("DELETE_SHARE_FAILED", e.getMessage(), null);
        } else if (deleteResult instanceof com.web3auth.tkey.ThresholdKey.Common.Result.Success) {
          result.success(null);
        }
      });
    }
    else {
      result.notImplemented();
    }
  }


  public Map<String, Object> serializeKeyDetails(KeyDetails keyDetails) throws RuntimeError{
    Map<String, Object> jsonMap = new HashMap<>();
    jsonMap.put("pubKeyX", keyDetails.getPublicKeyPoint().getX());
    jsonMap.put("pubKeyY", keyDetails.getPublicKeyPoint().getY());
    jsonMap.put("requiredShares", keyDetails.getRequiredShares());
    jsonMap.put("threshold", keyDetails.getThreshold());
    jsonMap.put("totalShares", keyDetails.getTotalShares());
    jsonMap.put("shareDescriptions", keyDetails.getShareDescriptions());
    return jsonMap;
  }

  public Map<String, Object> serializeKeyReconstructionDetails(KeyReconstructionDetails keyDetails) throws RuntimeError{
    Map<String, Object> jsonMap = new HashMap<>();
    jsonMap.put("key", keyDetails.getKey());
    jsonMap.put("seedPhrase", keyDetails.getSeedPhrase());
    jsonMap.put("allKeys", keyDetails.getAllKeys());
    return jsonMap;
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
