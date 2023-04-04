let CoinBridge = artifacts.require('CoinBridge');

module.exports = async function (deployer, network, accounts) {
    await deployer.deploy(CoinBridge, 'ETH', 18, '1000000000000000', '1000000000000000');
    let instance = await CoinBridge.deployed();
};
