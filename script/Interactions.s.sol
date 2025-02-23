// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.28;

import { Script, console } from 'forge-std/Script.sol';
import { DevOpsTools } from '@foundry-devops/src/DevOpsTools.sol';
import { FundMe } from './../src/FundMe.sol';

contract FundFundMe is Script {

    uint private constant SEND_VALUE = 10e18;

    constructor() {}

    function fundFundMe(address recentlyDeployedContract) public{
        console.log("The fundfund balance", recentlyDeployedContract.balance - SEND_VALUE);
        FundMe(payable(recentlyDeployedContract)).fund{value: SEND_VALUE}();
    }

    function run() external {
        // we get the latest contract address below. the way we get it is the method get_most_recent_deployment() checks through our broadcast dir 
        // and finds the contract address in the run-latest json file.
        address mostRecentDeployment = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        vm.startBroadcast();
        fundFundMe(mostRecentDeployment);
        vm.stopBroadcast();
    }
}

contract WithdrawFundMe is Script{

    constructor() {}

    function withdraw(address recentlyDeployedContract) public{
        FundMe(payable(recentlyDeployedContract)).withdraw();
    }

    function run() external {
        // we get the latest contract address below. the way we get it is the method get_most_recent_deployment() checks through our broadcast dir 
        // and finds the contract address in the run-latest json file.
        address mostRecentDeployment = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        vm.startBroadcast();
        withdraw(mostRecentDeployment);
        vm.stopBroadcast();
    }
}