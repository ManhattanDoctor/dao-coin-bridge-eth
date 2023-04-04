let HDWalletProvider = require('@truffle/hdwallet-provider');
let artifacts = require('../build/contracts/CoinBridge.json');
let Contract = require('@truffle/contract')(artifacts);

let Web3 = require('web3');
let fs = require('fs');

require('dotenv').config();

let mnemonic = process.env['MNEMONIC'];
let infuraProjectId = process.env['INFURA_PROJECT_ID'];

let toWei = ether => web3.utils.toWei(ether, 'ether');
let fromWei = value => web3.utils.fromWei(value.toString(), 'ether');

module.exports = async function (callback) {
    // --------------------------------------------------------------------------
    //
    //  Properties
    //
    // --------------------------------------------------------------------------

    let provider = web3.currentProvider;
    provider = new Web3.providers.HttpProvider('http://localhost:7545');
    // provider = new HDWalletProvider(mnemonic, `https://goerli.infura.io/v3/${infuraProjectId}`);

    Contract.setProvider(provider);
    let contract = await Contract.deployed();

    let owner = await contract.owner();

    let objectUid = 'user/15778540800000/0000000000000000000000000000000000000000000000000000000000000000';
    let coinUid = 'coin/company/15778540800000/0000000000000000000000000000000000000000000000000000000000000000/ETH';

    let to = owner;
    let amount = '10000000000000000';
    let privateKey = '0x096d59a4fa23e40e5b360aadd037fb7c61b1043852d79e018e4cd1f098658b25';

    console.log(messageGet(objectUid, coinUid, to, amount));
    console.log(messageGet2(objectUid, coinUid, to, amount));

    // await deposit(objectUid, coinUid, 3.5);
    // await withdraw(objectUid, coinUid, owner, 3);
    // console.log(await withdraw(objectUid, coinUid, to, 0.0999));
    // let events = await contract.getPastEvents('Operation', { fromBlock: 0, toBlock: 'latest' });
    // console.log(events[events.length - 1]);
    // let transaction = await web3.eth.getTransactionReceipt('0x1b2c3e98e3fad7e20b42be89fb5e19d5526493d62708c40c57023adc43bd5179');
    // console.log(transaction);

    // console.log(fromWei(await contract.balance()));

    // let value = await contract.depositsGet(owner);
    // await contract.depositMinSet('10000000000000000', { from: owner });

    // --------------------------------------------------------------------------
    //
    //  Methods
    //
    // --------------------------------------------------------------------------

    async function signatureGet(objectUid, coinUid, to, amount) {
        let message = messageGet(objectUid, coinUid, to, amount);
        let item = await web3.eth.accounts.sign(message, privateKey);
        return item.signature;
    }
    /*
    function messageGet(objectUid, coinUid, to, amount) {
        return ethers.solidityPackedKeccak256(['string', 'string', 'address', 'uint256'], [objectUid, coinUid, to, amount]);
    }
    */
    function messageGet(objectUid, coinUid, to, amount) {
        // return ethers.solidityPackedKeccak256(['string', 'string', 'address', 'uint256'], [objectUid, coinUid, to, amount]);
        return web3.utils.keccak256(
            web3.utils.encodePacked(
                { value: objectUid, type: 'string' },
                { value: coinUid, type: 'string' },
                { value: to, type: 'address' },
                { value: amount, type: 'uint256' }
            )
        );
    }

    async function deposit(objectUid, coinUid, amount) {
        return contract.deposit(objectUid, coinUid, { value: toWei(amount.toString()), from: owner });
    }

    async function withdraw(objectUid, coinUid, to, amount) {
        amount = toWei(amount.toString());
        let signature = await signatureGet(objectUid, coinUid, to, amount);
        return contract.withdraw(objectUid, coinUid, to, amount, [signature], { from: owner });
    }
};
