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
  Future<void> init(InitializeParams params) async {
    this.params = params;
    final webview = headlessWebView ?? await initJsEngine();
    final result = await webview.webViewController.callAsyncJavaScript(
        functionBody: "window.init('${jsonEncode(params.toJson())}');");
    print("result: $result");
    headlessWebView = webview;
  }

  @override
  Future<String> getPostBoxKey() async {
    assert(headlessWebView != null, kDefaultUninitializedError);
    final postBoxResult = await headlessWebView!.webViewController
        .callAsyncJavaScript(functionBody: "window.getPostBoxKey();");
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
        .callAsyncJavaScript(functionBody: "window.initializeTsKey();");
    if (keyDetailsResult == null) {
      throw Exception(kInvalidArgumentErr);
    }
    if (keyDetailsResult.error != null) {
      throw Exception(keyDetailsResult.error);
    }
    print(keyDetailsResult);
    return keyDetailResultToJson(keyDetailsResult.value);
  }

  @override
  Future<ReconstructionDetails> reconstruct() async {
    assert(headlessWebView != null, kDefaultUninitializedError);
    final reconstructionDetailsResult = await headlessWebView!.webViewController
        .callAsyncJavaScript(functionBody: "window.reconstruct();");
    if (reconstructionDetailsResult == null) {
      throw Exception(kInvalidArgumentErr);
    }
    if (reconstructionDetailsResult.error != null) {
      throw Exception(reconstructionDetailsResult.error);
    }
    final data = jsonDecode(reconstructionDetailsResult.value);
    return ReconstructionDetails(
      key: data['key'],
      allKeys: data['allKeys'],
      seedPhrase: data['seedPhrase'],
    );
  }

  @override
  Future<String> generateNewShare() async {
    assert(headlessWebView != null, kDefaultUninitializedError);
    final index = await headlessWebView!.webViewController
        .evaluateJavascript(source: "window.generateNewShare();");
    return index;
  }

  @override
  Future<KeyDetails> deleteShare(String index) async {
    assert(headlessWebView != null, kDefaultUninitializedError);
    final keyDetailsResult = await headlessWebView!.webViewController
        .evaluateJavascript(source: "window.deleteShare('$index');");
    return keyDetailResultToJson(keyDetailsResult);
  }

  @override
  Future<void> inputShare(String share) async {
    assert(headlessWebView != null, kDefaultUninitializedError);
    await headlessWebView!.webViewController
        .evaluateJavascript(source: "window.inputShare('$share');");
  }

  @override
  Future<String> outputShare(String index) async {
    assert(headlessWebView != null, kDefaultUninitializedError);
    return await headlessWebView!.webViewController
        .evaluateJavascript(source: "window.outputShare('$index');");
  }

  @override
  Future<List<String>> getSharesIndexes() async {
    assert(headlessWebView != null, kDefaultUninitializedError);
    final data = await headlessWebView!.webViewController
        .evaluateJavascript(source: "window.getSharesIndexes();");
    return jsonDecode(data);
  }

  @override
  Future<String> generateSecurityQuestion(
      String question, String answer) async {
    assert(headlessWebView != null, kDefaultUninitializedError);
    return await headlessWebView!.webViewController.evaluateJavascript(
        source: "window.generateSecurityQuestion('$question','$answer');");
  }

  @override
  Future<bool> changeSecurityQuestion(String question, String answer) async {
    assert(headlessWebView != null, kDefaultUninitializedError);
    return await headlessWebView!.webViewController.evaluateJavascript(
        source: "window.changeSecurityQuestion('$question','$answer');");
  }

  @override
  Future<bool> inputSecurityQuestionShare(String answer) async {
    assert(headlessWebView != null, kDefaultUninitializedError);
    await headlessWebView!.webViewController.evaluateJavascript(
        source: "window.inputSecurityQuestionShare('$answer');");
    return true;
  }

  @override
  Future<void> dispose() async {
    await headlessWebView?.dispose();
    headlessWebView = null;
  }

  Future<HeadlessInAppWebView> initJsEngine() async {
    Completer<InAppWebViewController> completer =
        Completer<InAppWebViewController>();
    final headlessWebView = HeadlessInAppWebView(
      initialUrlRequest:
          URLRequest(url: Uri.tryParse('https://dev.web.gotok.app/tkey.html')),
      onWebViewCreated: (controller) {},
      onConsoleMessage: (controller, consoleMessage) {
        print(consoleMessage);
      },
      onLoadStop: (controller, url) async {
        completer.complete(controller);
      },
    );
    await headlessWebView.run();
    await completer.future;
    await (Future.wait([
      // rootBundle
      //     .loadString("packages/web3_auth_ts_key/js/core.umd.min.js")
      //     .then(
      //       (script) => headlessWebView.webViewController
      //           .evaluateJavascript(source: script),
      //     ),
      // rootBundle
      //     .loadString(
      //         "packages/web3_auth_ts_key/js/securityQuestions.umd.min.js")
      //     .then(
      //       (script) => headlessWebView.webViewController
      //           .evaluateJavascript(source: script),
      //     ),
      // rootBundle
      //     .loadString(
      //         "packages/web3_auth_ts_key/js/serviceProviderSfa.umd.min.js")
      //     .then(
      //       (script) => headlessWebView.webViewController
      //           .evaluateJavascript(source: script),
      //     ),
      // rootBundle
      //     .loadString("packages/web3_auth_ts_key/js/solanaProvider.umd.min.js")
      //     .then(
      //       (script) => headlessWebView.webViewController
      //           .evaluateJavascript(source: script),
      //     ),
      // rootBundle
      //     .loadString(
      //         "packages/web3_auth_ts_key/js/storageLayerTorus.umd.min.js")
      //     .then(
      //       (script) => headlessWebView.webViewController
      //           .evaluateJavascript(source: script),
      //     ),
      // rootBundle
      //     .loadString("packages/web3_auth_ts_key/js/webStorage.umd.min.js")
      //     .then(
      //       (script) => headlessWebView.webViewController
      //           .evaluateJavascript(source: script),
      //     ),
      // rootBundle.loadString("packages/web3_auth_ts_key/js/worker.js").then(
      //       (script) => headlessWebView.webViewController
      //           .evaluateJavascript(source: script),
      //     ),
    ]));
    return headlessWebView;
  }

  String getScript() {
    return ''' 
  <!DOCTYPE html>
  <html>
    <head>
      <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
      <script src="https://unpkg.com/@solana/web3.js@latest/lib/index.iife.min.js"></script>
      <script src="https://unpkg.com/@tkey-mpc/core@9.0.2/dist/core.umd.min.js"></script>
      <script src="https://unpkg.com/@web3auth/solana-provider@7.2.0/dist/solanaProvider.umd.min.js"></script>
      <script src="https://unpkg.com/@tkey-mpc/storage-layer-torus@9.0.2/dist/storageLayerTorus.umd.min.js"></script>
      <script src="https://unpkg.com/@tkey-mpc/share-serialization@9.0.2/dist/shareSerialization.umd.min.js"></script>
      <script src="https://unpkg.com/@tkey/web-storage@12.0.0/dist/webStorage.umd.min.js"></script>
      <script src="https://unpkg.com/@tkey/security-questions@12.0.0/dist/securityQuestions.umd.min.js"></script>
      <script src="https://unpkg.com/@tkey/service-provider-sfa@11.0.0/dist/serviceProviderSfa.umd.min.js"></script>
    </head>
    <body>
    </body>
  </html>
  ''';
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
