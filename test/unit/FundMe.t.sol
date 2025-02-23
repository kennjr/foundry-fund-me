// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.28;

import { Test, console } from 'forge-std/Test.sol';
import { FundMe } from './../../src/FundMe.sol';
import { FundMeScript } from './../../script/FundMe.s.sol';

contract FundMeTest is Test {

    FundMe fundMe;
    /** Since we don't want to have an issue where we aren't sure who the sender of a txn is, we'll create the sender that we'll use for all our tests below */
    address sender = makeAddr("sally");
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

    /** The modifier below will help reduce the repetitiveness of our tests, since the code in it is shared by multiple tests that need the fund fun. called */
    modifier funded {
        assertEq(fundMe.getFunders().length, 0);
        vm.prank(sender);
        fundMe.fund{value: MIN_DOLLAR_AMT}();
        _;
    }

    function testIsDollarAmtFive() public view {
        assertEq(fundMe.MIN_DOLLAR_AMT(), 10e18);
    }

    function testOwnerIsMsgSender() public view{
        /**The reason we check whether the creator is this address is bc we aren't deploying the contract directly; 
         * we're doing it through the test which has it's own address. The commented test will pass if we don't use the deployment script for init the fundMe var. */
        // assertEq(fundMe.i_creator(), address(this));
        assertEq(fundMe.getCreator(), msg.sender);
    }

    /** This test will always fail because we don't have anvil running unless we pass a rpc url, 
     * so foundry spins up a new wallet that doesn't match what we pass to the PriceConverter  */
    function testIsVersionFour() public view{
        // console.log("The version", fundMe.version());
        // assertEq(fundMe.version(), 6);

        if (block.chainid == 11155111) {
            uint256 version = fundMe.version();
            assertEq(version, 4);
        } else if (block.chainid == 1) {
            uint256 version = fundMe.version();
            assertEq(version, 6);
        }else {
            uint256 version = fundMe.version();
            assertEq(version, 4);
        }
    }

    /** The test below will check whether a txn is reverted if not enough funds($10) are sent */
    function testFundFailsOnNotEnoughFunds() public {
        // the expect revert tells solidity that for the test to pass it should revert/fail(ironical)
        vm.expectRevert();
        // since we don't pass a value, the txn will be reverted(we're sending less than the minimum)
        fundMe.fund();
    }

    /** The work we do whenever a user sends funds(update the funders array and the mapping) will be tested below */
    function testFundUpdatesFundedDataStructures() public funded {
        // the line below tells the sys that the next txn will be sent by the specified user through their address
        // vm.prank(sender);
        // console.log(sender.balance); // 10,000,000,000,000,000,000 = 10,000,000,000,000,000,000
        
        // check whether the funder was added to the array
        assertEq(fundMe.getFunders().length, 1);
    }

    function testAddsFunderToFundersArray() public funded{
        //fundMe.fund{value: MIN_DOLLAR_AMT}();
        // check whether the funder was added to the array
        assertEq(fundMe.getFunder(0), sender);
    }

    function testAddsFunderToMappingDict() public funded{
        // check whether the funder was added to the array
        assertEq(fundMe.getAddressToAmtFunded(sender), MIN_DOLLAR_AMT);
    }

    function testOnlyOwnerCanWithdraw () public funded{
        // since this is expected to fail, we add the expect revert
        vm.expectRevert();
        vm.prank(sender);
        // the fun. that should fail and invoke the revert
        fundMe.withdraw();
    }

    function testWithdrawWithSingleFunder() public funded{
        // Arrange - do necessary setup for test
        uint256 startingCreatorBalance = fundMe.getCreator().balance;
        uint256 startingContractBalance = address(fundMe).balance; //  the balance should be 10 since we've already funded the contract
        // Act - run. the fun we want to test
        vm.prank(fundMe.getCreator());
        fundMe.withdraw();
        // Assert - check whether result matches what was expected
        uint256 endingCreatorBalance = fundMe.getCreator().balance;
        uint256 endingContractBalance = address(fundMe).balance; //  the balance should be 0 since we've already withdrawn
        assertEq(endingContractBalance, 0);
        assertEq(endingCreatorBalance, startingCreatorBalance+startingContractBalance);
    }

    function testWithdrawFromMultipleFunders() public funded{
        // Arrange
        // we use uint160 since that's the type that matches the address type
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for(uint160 i = startingFunderIndex; i < numberOfFunders; i++){
            /** The hoax fun. runs both vm.prank() & vm.deal(); giving us an address and loading it with eth */
            hoax(address(i), MIN_DOLLAR_AMT);
            // we then fund our contract
            fundMe.fund{value: MIN_DOLLAR_AMT}();
        }

        uint256 startingCreatorBalance = fundMe.getCreator().balance;
        uint256 startingContractBalance = address(fundMe).balance; //  the balance should be 10 since we've already funded the contract

        // Act
        // since we want to control how long the address we're using is considered the actual address, we'll use the vm.startPrank() & vm.stopPrank() fun.s
        vm.startPrank(fundMe.getCreator());
        fundMe.withdraw();
        vm.stopPrank();

        // Assert
        uint256 endingCreatorBalance = fundMe.getCreator().balance;
        uint256 endingContractBalance = address(fundMe).balance; //  the balance should be 0 since we've already withdrawn
        assertEq(endingContractBalance, 0);
        assertEq(endingCreatorBalance, startingCreatorBalance + startingContractBalance);
    }

}