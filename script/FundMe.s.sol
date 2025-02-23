// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.28;

import { Script } from 'forge-std/Script.sol';
import { FundMe } from './../src/FundMe.sol';
import { HelperConfig } from './HelperConfig.s.sol';

contract FundMeScript is Script {
    constructor() {}

    function run() external returns(FundMe){
        /** We init the helper config b4 starting the broadcast bc we don't want to spend the gas to deploy the helper config onto a real chain. 
         * This is bc anything b4 the startBroadcast will not be treated like a real txn, it'll be simulated in an environment
         */
        HelperConfig helperConfig = new HelperConfig();
        address priceFeedAddress = helperConfig.activeNetworkConfig();

        /**
         * vm is a special keyword we can use when working with the foundry framework, it's not even part of solidity; 
         * so we can't use it unless we're using the foundry framework.
         */
        vm.startBroadcast();
        /** The code between the vm.startBroadcast and vm.stopBroadcast is what we want to deploy, any txn that we actually want to send is what will go in btwn the 
         * start and stop methods.
         */
        // the new keyword creates a new contract
        FundMe fundMe = new FundMe(priceFeedAddress);
        vm.stopBroadcast();
        return fundMe;
    }
}