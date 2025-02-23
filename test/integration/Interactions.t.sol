// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.28;

import { Test, console } from 'forge-std/Test.sol';
import { FundMe } from './../../src/FundMe.sol';
import { FundMeScript } from './../../script/FundMe.s.sol';
import { FundFundMe } from './../../script/Interactions.s.sol';

contract InteractionTests is Test {
    FundMe fundMe;
    /** Since we don't want to have an issue where we aren't sure who the sender of a txn is, we'll create the sender that we'll use for all our tests below */
    address sender = makeAddr("sandy");
    uint constant private MIN_DOLLAR_AMT = 10e18;

    constructor() {}

    /** The setUp fun. will run before any thing else, it's where we deploy the test contract before we begin running tests on it
     * We'll eventually import our deploy scripts and set up a similar environment(for the tests) to the one we use with the deployed contract
     */
    function setUp() external {
        /** In order to avoid the small mistakes that could be made when testing and deploying our contracts, we're gonna use the deployment script to get the fundMe contract,
         *  so that any changes made there will apply whenever we're deploying or testing a contract.
         */
        FundMeScript fundMeScript = new FundMeScript();
        fundMe = fundMeScript.run();
        vm.deal(sender, 10 ether);
        // we're gonna deploy a local priceFeed mock in our anvil that we can use for testing purposes
    }

    function testUserCanFund() public {
        FundFundMe fundFundMe = new FundFundMe();
        // vm.prank(sender);
        vm.deal(address(this), 100e18); //1,000,000,000,000,000,000
        console.log("The balance %s", address(this).balance);
        fundFundMe.fundFundMe(address(this));
    }
}