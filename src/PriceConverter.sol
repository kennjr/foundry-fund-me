// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.28;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {

    // address private constant priceSmartContractAddress = 0x694AA1769357215DE4FAC081bf1f309aDC325306;

    /**
     * we use this fun. to get the current price of ether. All lib fun.s have to be internal
     */
    function getCurrentPrice(AggregatorV3Interface priceFeed) internal view returns (uint){
        // Address(for the smart contract that'll give us the current price) - 0x694AA1769357215DE4FAC081bf1f309aDC325306
        // ABI(this is the interface that we'll need when making price requests to the smart contract) - AggregatorV3Interface
        ////////////////// AggregatorV3Interface priceFeed = AggregatorV3Interface(priceSmartContractAddress);
        // we get the current price of ETH in USD
        (,int currentPrice,,,) = priceFeed.latestRoundData();
        // in order to harmonize the numbers we're working with we have to increase the number of 0s in the currentPrice value since the 
        // msg.value(which gives us the amt a user has spent) gives us the amt spent in wei(
        // NOTE - the price value comes with 8 decimal places so we add the 0 needed to get it to 18 which is what wei uses
        return uint(currentPrice * 1e10);
    }

    /**
     * the fun. below will convert the passed @param ethAmt into bucks. All lib fun.s have to be internal
     */
    function getConversionRate(uint ethAmt, AggregatorV3Interface priceFeed) internal view returns(uint){
        // we first get the current price of eth
        uint currentEthPrice = getCurrentPrice(priceFeed);
        // then we use that value to do the conversion, since the values we've been working with are in wei, we divide by 1e18 to get rid of the 2nd set of 18 0s
        uint ethAmtInBucks = (ethAmt * currentEthPrice) / 1e18;
        return ethAmtInBucks;
    }

    function getVersion(AggregatorV3Interface priceFeed) public view returns(uint){
        ////////////////////AggregatorV3Interface priceFeed = AggregatorV3Interface(priceSmartContractAddress);
        return priceFeed.version();
    }
}