// --------------------------------------------------------------------------
//
//  Imports
//
// --------------------------------------------------------------------------

let HDWalletProvider = require('@truffle/hdwallet-provider');

// --------------------------------------------------------------------------
//
//  Properties
//
// --------------------------------------------------------------------------

require('dotenv').config();

let mnemonic = process.env['MNEMONIC'];
let infuraProjectId = process.env['INFURA_PROJECT_ID'];
let alchemyProjectId = process.env['ALCHEMY_PROJECT_ID'];

// --------------------------------------------------------------------------
//
//  Module
//
// --------------------------------------------------------------------------

module.exports = {
    networks: {
        development: {
            host: '127.0.0.1',
            port: 7545,
            network_id: 5777
        },
        goerli: {
            provider: () => new HDWalletProvider(mnemonic, `https://goerli.infura.io/v3/${infuraProjectId}`),
            // provider: () => new HDWalletProvider(mnemonic, `https://eth-goerli.g.alchemy.com/v2/${alchemyProjectId}`),
            // gas: 6721975,
            gasPrice: 200000000000, // 200 Gwei
            network_id: 5
        }
    },
    compilers: {
        solc: {
            version: '0.8.13' // Fetch exact version from solc-bin
        }
    },
    mocha: {
        // timeout: 100000
    },
    plugins: ['truffle-plugin-verify'],
    api_keys: {
        etherscan: 'G1YB2CKDTNFVNJZMG3G962933QGECF9K6C'
    }
};
