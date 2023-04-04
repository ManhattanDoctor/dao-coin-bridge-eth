let HDWalletProvider = require('@truffle/hdwallet-provider');
let artifacts = require('../build/contracts/HlfBridge.json');
let Contract = require('@truffle/contract')(artifacts);

let { ethers } = require('ethers');
let Web3 = require('web3');
let fs = require('fs');

require('dotenv').config();

let mnemonic = process.env['MNEMONIC'];
let infuraProjectId = process.env['INFURA_PROJECT_ID'];

let toWei = ether => web3.utils.toWei(ether, 'ether');
let fromWei = value => web3.utils.fromWei(value.toNumber(), 'ether');

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
    let coinUid = 'coin/company/15778540800000/0000000000000000000000000000000000000000000000000000000000000000/RUB';

    let to = owner;
    let amount = '10000000000000000';
    let privateKey = '0x096d59a4fa23e40e5b360aadd037fb7c61b1043852d79e018e4cd1f098658b25';

    // let hashed = hash(objectUid, coinUid, to, amount);
    // const sig = await signer.signMessage(web3.utils.arrayify(hashed))

    // console.log(await contract.verify(objectUid, coinUid, to, amount));
    // console.log(await sign(objectUid, coinUid, to, amount));
    // console.log(hash(objectUid, coinUid, to, amount));

    // let message = await contract.message(objectUid, coinUid, to, amount);
    let message = messageGet(objectUid, coinUid, to, amount);
    let signature = await web3.eth.accounts.sign(message, privateKey);
    console.log(signature);

    let messageHashed = await contract.verify(objectUid, coinUid, to, amount, signature.signature);
    console.log(messageHashed);

    // await deposit(userUid, coinUid, 4.25);
    // let events = await contract.getPastEvents('Deposited', { fromBlock: 0, toBlock: 'latest' });
    /*
    fs.writeFile('events.json', JSON.stringify(events, null, 4), 'utf8', error => {
        console.log(events[0].returnValues.data);
    });
    */

    // let transaction = await web3.eth.getTransactionReceipt('0x1b2c3e98e3fad7e20b42be89fb5e19d5526493d62708c40c57023adc43bd5179');
    // console.log(transaction);

    // let value = await contract.depositsGet(owner);
    // await contract.depositMinSet('10000000000000000', { from: owner });

    // --------------------------------------------------------------------------
    //
    //  Methods
    //
    // --------------------------------------------------------------------------

    function messageGet(objectUid, coinUid, to, amount) {
        return ethers.solidityPackedKeccak256(['string', 'string', 'address', 'uint256'], [objectUid, coinUid, to, amount]);
    }

    async function deposit(objectUid, coinUid, amount) {
        return contract.deposit(objectUid, coinUid, { value: toWei(amount.toString()), from: owner });
    }
};
