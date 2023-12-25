var thresholdKey;
var initParams;

var init = async (params) => {
  try {
    initParams = JSON.parse(params);
    console.log("params", params);
    const serviceProvider = new ServiceProviderSfa.SfaServiceProvider({
      web3AuthOptions: {
        clientId: initParams.web3AuthClientId,
        enableLogging: initParams.enableLogging,
        web3AuthNetwork: initParams.network,
      },
      // postboxKey: initParams.postboxKey,
      enableLogging: true,
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
    thresholdKey = new Core.default({
      enableLogging: true,
      serviceProvider: serviceProvider,
      storageLayer: new StorageLayerTorus.TorusStorageLayer({
        hostUrl: "https://metadata.tor.us",
        enableLogging: initParams.enableLogging,
      }),
      modules: {
        securityQuestions: new SecurityQuestions.SecurityQuestionsModule(),
        //shareSerialization: new ShareSerialization.ShareSerializationModule(),
        //webStorage: new WebStorage.WebStorageModule(),
      },
    });
    const privateKeyProvider = new SolanaProvider.SolanaPrivateKeyProvider({
      config: {
        chainConfig,
      },
    });
    await serviceProvider.init(privateKeyProvider);
  } catch (error) {
    console.log("error", error);
    throw error;
  }
};

var getPostBoxKey = async () => {
  try {
    console.log("start getPostBoxKey:verifierName", initParams.verifierName);
    console.log("start getPostBoxKey:verifierId", initParams.verifierId);
    console.log("start getPostBoxKey:idToken", initParams.idToken);
    const oauthShare = await thresholdKey.serviceProvider.connect({
      verifier: initParams.verifierName,
      verifierId: initParams.verifierId,
      idToken: initParams.idToken,
    });
    console.log("oauthShare", oauthShare.toString("hex"));
    return oauthShare.toString("hex");
  } catch (error) {
    console.log("error", error);
    throw error;
  }
};

var initializeTsKey = async () => {
  await thresholdKey.initialize();
  return JSON.stringify(thresholdKey.getKeyDetails());
};

var reconstructKey = async () => {
  const reconstructionDetails = await thresholdKey.reconstructKey();
  return JSON.stringify(reconstructionDetails);
};

var generateNewShare = async () => {
  const share = await thresholdKey.generateNewShare();
  return share.newShareIndex.toString("hex");
};

var deleteShare = async (index) => {
  await thresholdKey.deleteShare(index);
  return JSON.stringify(thresholdKey.getKeyDetails());
};

var inputShare = async (share) => {
  await thresholdKey.inputShare(share);
};

var outputShare = async (index) => {
  return await thresholdKey.outputShare(index);
};

var getSharesIndexes = async () => {
  return JSON.stringify(await thresholdKey.getCurrentShareIndexes());
};

var generateSecurityQuestion = async (question, answer) => {
  const share =
    await thresholdKey.modules.securityQuestions.generateNewShareWithSecurityQuestions(
      answer,
      question
    );
  return share.newShareIndex.toString("hex");
};

var changeSecurityQuestion = async (question, answer) => {
  const result =
    await thresholdKey.modules.securityQuestions.changeSecurityQuestionAndAnswer(
      answer,
      question
    );
  return result;
};

var inputSecurityQuestionShare = async (answer) => {
  await thresholdKey.modules.securityQuestions.inputShareFromSecurityQuestions(
    answer
  );
};
