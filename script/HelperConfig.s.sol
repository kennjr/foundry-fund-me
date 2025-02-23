// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.28;

/**
 * This helper config will:
 * a.) Deploy mocks when we are on a local anvil chain.
 * b.) Monitor contract addresses across diff. chains
 */

import { Script } from 'forge-std/Script.sol';
import { MockV3Aggregator } from './../test/mock/MockV3Aggregator.sol';

contract HelperConfig is Script {

    // below we have the number of decimal places that the eth usd converter has, which is what we'll use for our conversions
    uint8 ethUsdDecimal = 8;
    // this is the initial price in usd of eth
    int initialPriceFeedAnswer = 2000e8;

    

    /** We're gonna use this type to capture and return all the relevant data that a config should return */
    struct NetworkConfig {
        address priceFeedAddress;
    }

    NetworkConfig public activeNetworkConfig;

    // we're gonna use an if/else block to check whether we're on an anvil chain; 
    // and of so then we'll deploy mocks otherwise we'll get existing addresses from the live networks

    constructor() {
        // the block.chainid will give us the current chain's id. the 11155111 is sepolia's id
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory){
        /** NOTE: the address used below is temporary, it's the same as the one from anvil */
        NetworkConfig memory sepoliaConfig = NetworkConfig({priceFeedAddress: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return sepoliaConfig;
    }
    
    // this can't be a public pure since we're using vm
    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory){
        /** We're gonna deploy the mock contracts, then return their addresses.
         * The start & stop broadcast methods will let us deploy the mock contracts we create to the local anvil chain
         */

        // the if clause checks to ensure that we don't have a deployed mock address, and if we do then we'll return that 
        // since we don't want to create multiple mock addresses. we passed 0 as the address bc that's what the address always defaults to
        if(activeNetworkConfig.priceFeedAddress != address(0)){
            return activeNetworkConfig;
        }

        vm.startBroadcast();
        // the mockPriceFeed is the address that we'll pass into the network config
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(ethUsdDecimal, initialPriceFeedAnswer);
        vm.stopBroadcast();
        NetworkConfig memory anvilConfig = NetworkConfig({priceFeedAddress: address(mockPriceFeed)});
        return anvilConfig;
    }
}