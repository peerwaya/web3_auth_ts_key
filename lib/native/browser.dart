import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:web3_auth_ts_key/web3_auth_ts_key.dart';
import 'package:web3_auth_ts_key/web3_auth_ts_key_platform_interface.dart';

const kDefaultUninitializedError =
    'Uninitialized Error. Please call init first.';

const kInvalidArgumentErr = 'Invalid Argument';

class BrowserNative extends Web3AuthTsKeyPlatform {
  late InitializeParams params;
  HeadlessInAppWebView? headlessWebView;

  @override
  Future<void> init(InitializeParams params,
      {InitProgressCallback? progressCallback}) async {
    this.params = params;
    final webview = headlessWebView ??
        await initJsEngine(
            params.webInitialUrl ?? 'https://dev.web.gotok.app/tkey.html');
    await webview.webViewController.callAsyncJavaScript(functionBody: '''
          var initParams = JSON.parse(params);
          const serviceProvider = new ServiceProviderSfa.SfaServiceProvider({
            web3AuthOptions: {
              clientId: initParams.web3AuthClientId,
              enableLogging: initParams.enableLogging,
              web3AuthNetwork: initParams.network,
            },
            postboxKey: initParams.postboxKey,
            enableLogging: initParams.enableLogging,
          });
          const chainConfig = {
            chainId: initParams.chainConfig.chainId,
            rpcTarget: initParams.chainConfig.rpcTarget,
            chainNamespace: initParams.chainConfig.chainNamespace,
            blockExplorer: initParams.chainConfig.blockExplorer,
            displayName: initParams.chainConfig.displayName,
            ticker: initParams.chainConfig.ticker,
            tickerName: initParams.chainConfig.tickerName,
          };
          window.thresholdKey = new Core.default({
            enableLogging: true,
            serviceProvider: serviceProvider,
            manualSync: initParams.manualSync,
            storageLayer: new StorageLayerTorus.TorusStorageLayer({
              hostUrl: "https://metadata.tor.us",
              enableLogging: initParams.enableLogging,
            }),
            modules: {
              securityQuestions: new SecurityQuestions.SecurityQuestionsModule(),
            },
          });
          const privateKeyProvider = new SolanaProvider.SolanaPrivateKeyProvider({
            config: {
              chainConfig,
            },
          });
          await serviceProvider.init(privateKeyProvider);
''', arguments: {'params': jsonEncode(params.toJson())});
    headlessWebView = webview;
  }

  @override
  Future<String> getPostBoxKey() async {
    assert(headlessWebView != null, kDefaultUninitializedError);
    final postBoxResult = await headlessWebView!.webViewController
        .callAsyncJavaScript(functionBody: '''
            var initParams = JSON.parse(params);
            const oauthShare = await window.thresholdKey.serviceProvider.connect({
              verifier: initParams.verifierName,
              verifierId: initParams.verifierId,
              idToken: initParams.idToken,
            });
            const hex = await oauthShare.toString("hex");
            return hex;
        ''', arguments: {'params': jsonEncode(params.toJson())});
    if (postBoxResult == null) {
      throw Exception(kInvalidArgumentErr);
    }
    if (postBoxResult.error != null) {
      throw Exception(postBoxResult.error);
    }
    return postBoxResult.value;
  }

  @override
  Future<KeyDetails> initializeTsKey([String? privateKey]) async {
    assert(headlessWebView != null, kDefaultUninitializedError);
    final keyDetailsResult = await headlessWebView!.webViewController
        .callAsyncJavaScript(functionBody: '''
        await window.thresholdKey.initialize();
        return JSON.stringify(window.thresholdKey.getKeyDetails());
    ''');
    if (keyDetailsResult == null) {
      throw Exception(kInvalidArgumentErr);
    }
    if (keyDetailsResult.error != null) {
      throw Exception(keyDetailsResult.error);
    }
    return keyDetailResultToJson(keyDetailsResult.value);
  }

  @override
  Future<ReconstructionDetails> reconstruct() async {
    assert(headlessWebView != null, kDefaultUninitializedError);
    final reconstructionDetailsResult = await headlessWebView!.webViewController
        .callAsyncJavaScript(functionBody: '''
        const reconstructionDetails = await window.thresholdKey.reconstructKey();
        return JSON.stringify(reconstructionDetails);
    ''');
    if (reconstructionDetailsResult == null) {
      throw Exception(kInvalidArgumentErr);
    }
    if (reconstructionDetailsResult.error != null) {
      throw Exception(reconstructionDetailsResult.error);
    }
    final data = jsonDecode(reconstructionDetailsResult.value);
    return ReconstructionDetails(
      key: data['privKey'],
      allKeys: (data['allKeys'] as List<dynamic>?)
              ?.map((d) => d as String)
              .toList() ??
          [],
      seedPhrase: (data['seedPhrase'] as List<dynamic>?)
              ?.map((d) => d as String)
              .toList() ??
          [],
    );
  }

  @override
  Future<String> generateNewShare() async {
    assert(headlessWebView != null, kDefaultUninitializedError);
    final result = await headlessWebView!.webViewController
        .callAsyncJavaScript(functionBody: '''
        const share = await window.thresholdKey.generateNewShare();
        return share.newShareIndex.toString("hex");
  ''');
    if (result == null) {
      throw Exception(kInvalidArgumentErr);
    }
    if (result.error != null) {
      throw Exception(result.error);
    }
    return result.value;
  }

  @override
  Future<KeyDetails> deleteShare(String index) async {
    assert(headlessWebView != null, kDefaultUninitializedError);
    final keyDetailsResult = await headlessWebView!.webViewController
        .callAsyncJavaScript(functionBody: '''
        await window.thresholdKey.deleteShare(i);
        return JSON.stringify(thresholdKey.getKeyDetails());
      ''', arguments: {'i': index});
    if (keyDetailsResult == null) {
      throw Exception(kInvalidArgumentErr);
    }
    if (keyDetailsResult.error != null) {
      throw Exception(keyDetailsResult.error);
    }

    return keyDetailResultToJson(keyDetailsResult.value);
  }

  @override
  Future<void> inputShare(String share) async {
    assert(headlessWebView != null, kDefaultUninitializedError);
    final result = await headlessWebView!.webViewController
        .callAsyncJavaScript(functionBody: '''
        await window.thresholdKey.inputShare(i);
      ''', arguments: {'i': share});
    if (result?.error != null) {
      throw Exception(result!.error);
    }
  }

  @override
  Future<String> outputShare(String index) async {
    assert(headlessWebView != null, kDefaultUninitializedError);
    final result = await headlessWebView!.webViewController
        .callAsyncJavaScript(functionBody: '''
        const share = await window.thresholdKey.outputShare(i);
        return share.toString('hex');
      ''', arguments: {'i': index});
    if (result == null) {
      throw Exception(kInvalidArgumentErr);
    }
    if (result.error != null) {
      throw Exception(result.error);
    }
    return result.value;
  }

  @override
  Future<List<String>> getSharesIndexes() async {
    assert(headlessWebView != null, kDefaultUninitializedError);
    final result = await headlessWebView!.webViewController
        .callAsyncJavaScript(functionBody: '''
        return await window.thresholdKey.getCurrentShareIndexes();
      ''');
    if (result == null) {
      throw Exception(kInvalidArgumentErr);
    }
    if (result.error != null) {
      throw Exception(result.error);
    }
    return result.value.cast<String>();
  }

  @override
  Future<String> generateSecurityQuestion(
      String question, String answer) async {
    assert(headlessWebView != null, kDefaultUninitializedError);
    final result = await headlessWebView!.webViewController
        .callAsyncJavaScript(functionBody: '''
        const share = await window.thresholdKey.modules.securityQuestions.generateNewShareWithSecurityQuestions(a, q);
        return share.newShareIndex.toString("hex");
      ''', arguments: {'q': question, 'a': answer});
    if (result == null) {
      throw Exception(kInvalidArgumentErr);
    }
    if (result.error != null) {
      throw Exception(result.error);
    }
    return result.value;
  }

  @override
  Future<void> changeSecurityQuestion(String question, String answer) async {
    assert(headlessWebView != null, kDefaultUninitializedError);
    await headlessWebView!.webViewController
        .callAsyncJavaScript(functionBody: '''
        return await window.thresholdKey.modules.securityQuestions.changeSecurityQuestionAndAnswer(a, q);
      ''', arguments: {'q': question, 'a': answer});
  }

  @override
  Future<bool> inputSecurityQuestionShare(String answer) async {
    assert(headlessWebView != null, kDefaultUninitializedError);
    final result = await headlessWebView!.webViewController
        .callAsyncJavaScript(functionBody: '''
        return await window.thresholdKey.modules.securityQuestions.inputShareFromSecurityQuestions(a);
      ''', arguments: {'a': answer});
    if (result?.error != null) {
      throw Exception(result!.error);
    }
    return true;
  }

  @override
  Future<void> dispose() async {
    await headlessWebView?.dispose();
    headlessWebView = null;
  }

  Future<HeadlessInAppWebView> initJsEngine(String initialUrl,
      {InitProgressCallback? progressCallback}) async {
    Completer<InAppWebViewController> completer =
        Completer<InAppWebViewController>();
    final headlessWebView = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: Uri.tryParse(initialUrl)),
      onWebViewCreated: (controller) {},
      onConsoleMessage: (controller, consoleMessage) {
        print(consoleMessage);
      },
      onProgressChanged: (controller, progress) =>
          progressCallback?.call(progress),
      onLoadStop: (controller, url) async {
        completer.complete(controller);
      },
      onLoadError: (controller, url, code, message) =>
          completer.completeError(Exception('$code:$message')),
    );
    await headlessWebView.run();
    await completer.future;
    await (Future.wait([
      rootBundle
          .loadString("packages/web3_auth_ts_key/js/core.umd.min.js")
          .then(
            (script) => headlessWebView.webViewController
                .evaluateJavascript(source: script),
          ),
      rootBundle
          .loadString(
              "packages/web3_auth_ts_key/js/securityQuestions.umd.min.js")
          .then(
            (script) => headlessWebView.webViewController
                .evaluateJavascript(source: script),
          ),
      rootBundle
          .loadString(
              "packages/web3_auth_ts_key/js/serviceProviderSfa.umd.min.js")
          .then(
            (script) => headlessWebView.webViewController
                .evaluateJavascript(source: script),
          ),
      rootBundle
          .loadString("packages/web3_auth_ts_key/js/solanaProvider.umd.min.js")
          .then(
            (script) => headlessWebView.webViewController
                .evaluateJavascript(source: script),
          ),
      rootBundle
          .loadString(
              "packages/web3_auth_ts_key/js/storageLayerTorus.umd.min.js")
          .then(
            (script) => headlessWebView.webViewController
                .evaluateJavascript(source: script),
          ),
    ]));
    return headlessWebView;
  }

  KeyDetails keyDetailResultToJson(String keyDetailsResult) {
    final data = jsonDecode(keyDetailsResult);
    return KeyDetails(
      pubKeyX: data['pubKey']['x'],
      pubKeyY: data['pubKey']['y'],
      requiredShares: data['requiredShares'],
      threshold: data['threshold'],
      totalShares: data['totalShares'],
    );
  }
}
