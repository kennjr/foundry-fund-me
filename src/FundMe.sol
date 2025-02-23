// SPDX-License-Identifier: SEE LICENSE in LICENSE
pragma solidity 0.8.28;

import {PriceConverter} from "./PriceConverter.sol";
import { AggregatorV3Interface } from '@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol';

// the custom error for unauthorized errors
error FundMe_Unauthorized();

contract FundMe {

    /**
     * we can now use our library methods in all uint256 variables. so rather than using the getConversion() and passing the arg. we can use it like a uint256 method
     * 189.getConversion(), the uint256 var's value will be the first arg. in the method, any others will be passed in the parentheses.
     */
    using PriceConverter for uint256;


    // we add the e18 since we are doing everything in wei, we made this a constant var. to save on gas since we won't change its value during the lifetime of the 
    // contract. so we set the value at compile time. constant variables don't take up space in the storage, they're part of the contract's byte code
    uint public constant MIN_DOLLAR_AMT = 10e18;

    // we want to keep track of the people who send us eth and we'll do so by adding their wallet addresses to the array below. the s_ denotes that it's a storage var.
    address[] private s_funders;
    // we can make a mapping to know how much each funder sent. the s_ denotes that it's a storage var. we make the fun.s private for gas efficiency
    mapping(address funder => uint weiSent) private s_addressToAmountFunded;

    // we made this address immutable to save on gas since we set its value once(at runtime) in the constructor
    address private immutable i_creator;

    /** The reason we're introducing this is to simplify testing and deployment. With the priceFeed address being passed in through the constructor, 
     * we can easily pass in whatever address we need for whichever chain & environment we are in. */
    AggregatorV3Interface private s_priceFeed;

    /**
     * The constructor is called in the same transaction that's used to deploy our contract
     */
    constructor(
        address priceFeed
    ) {
        i_creator = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    /**
     * The fun. below will execute the main functionality of the contract i.e fund the creator of the contract. 
     * The payable keyword is what will allow us to charge anyone to invoke the fun. and just like wallets can hold funds contracts can do so too.
     * So whenever we deploy a contract it acts similarly to how a wallet with an address does; that's what allows it to hold funds.
     * 
     * We set a minimum $ amt that can be sent
     */
    function fund() public payable{
        /** we can access the value amt of a transaction using the 'msg.value' global that solidity provides 
         * for us to set a minimum amt we use 'require(msg.value >= 1e18)'. what that means is that for this payable fun. to execute successfully the user has to send 
         * the creator of the contract at least 1ETH(that's the 1e18), which we usually write in wei so the actual value we pass is 1000000000000000000
         * Whenever we use require() and it fails, a reversion occurs. The gas used will be refunded to the initiator of the contract. 
         * NOTE - if the require() call isn't in the first line then some gas will be used to execute every line b4 the require where it fails and aborts, 
         * so a refund will be made but it'll be of whatever's left and not the full amt.
        */
       require(msg.value.getConversionRate(s_priceFeed) >= MIN_DOLLAR_AMT, "A minimum of 1ETH is required");
       // just like the msg.value is made available to us by solidity for every invocation of this contract, the msg.sender is too.
       // the value of the msg.sender is the wallet address of the person who sent the eth
       s_funders.push(msg.sender);
       // we can update our mapping with the value too
       s_addressToAmountFunded[msg.sender] = s_addressToAmountFunded[msg.sender] + msg.value;
    }

    /**
     * Withdraw the funds from the contract wallet
     * we add the isCreator modifier
     */
    function withdraw() public isCreator {
        // since we don't want anyone else withdrawing funds from this contract the require below will ensure that only the creator can do so
        // require(msg.sender == creator, "Unauthorized access");

        // we create the length var. below to reduce the gas spent reading the array's length; 
        // this is bc we spend a lot more gas reading from storage and it'll be more efficient to do it once
        uint fundersLength = s_funders.length;

        /**
         * We're gonna use a for-loop to go through the mapping with all the sender & amt data and replace the amt sent with 0 since we're withdrawing the eth
         */
        for (uint i = 0; i < fundersLength; i++) {
            address funder = s_funders[i];
            s_addressToAmountFunded[funder] = 0;
        }
        // reset the array of funders addresses back to 0 i.e remove all the elements in the array and start it off at the 0th index
        s_funders = new address[](0);

        // there are 3 diff. ways of sending funds from our contract: transfer, send, call
        /** transfer has a gas limit of 2300 and if we use more than that then the transaction will fail(after spending the 2300 gas)
         * in solidity in order to send the native token like eth we can only work with payable addresses that's why we wrap msg.sender with payable, to type-cast it from an address type 
         * to a payable address type
         * The address(this).balance gives us the total amount of tokens available in the contract
        */
        ////////////////payable(msg.sender).transfer(address(this).balance);
        /**
         * For the send method, we get back a bool for the success state, so we won't get an error but instead if the transaction fails we'll get a false
         */
        ////////////////bool sendState = payable(msg.sender).send(address(this).balance);
        // we need this require below to check whether the txn was a success, if not then we revert
        ///////////////require(sendState, "Transaction failed-exceeded gas limit");

        /**
         * We can use .call() to invoke any ethereum fun. without the need for an ABI
         * call is a good choice when sending eth/any other native token bc it doesn't have a gas limit, it returns 2 values whenever called: 
         * the state(was it a success or not) and any other data that night be associated with a specific ethereum fun.
         * we pass the amt we want to send through the obj right b4 the fun parentheses, in the value property
         */
        (bool callState, bytes memory data) = payable(msg.sender).call{value: address(this).balance}("");
        // since we get the call state, we need to check whether the txn was a success
        require(callState, "Transaction failed");
    }

    function version() public view returns(uint){
        return PriceConverter.getVersion(s_priceFeed);
    }


    /** View getter fun.s */
    function getAddressToAmtFunded (address fundingAddress) external view returns (uint){
        return s_addressToAmountFunded[fundingAddress];
    }

    function getFunders () external view returns (address[] memory){
        return s_funders;
    }

    function getFunder(uint index) external view returns (address){
        return s_funders[index];
    }

    function getCreator() external view returns(address){
        return i_creator;
    }


    /**
     * The modifier will allow us to create a custom word that we can put in the fun. declaration that will add the functionality specified in it to said fun.
     */
    modifier isCreator() {
        // require(msg.sender == i_creator, "Unauthorized access");
        if (msg.sender != i_creator) {
            /** This if statement is a new way of catching errors and aborting code execution, we use custom errors that we create. */
            revert FundMe_Unauthorized();
        }
        // the line below simply tells solidity to continue with the rest of the code that's in the fun.
        // we could have it abv the require statement and in that case the fun.'s code will be executed first, then the modifier's logic gets executed
        _;
    }

    /**
     * The receive fun. is a special fun. that is called any time a user sends a transaction without any data(the fun. will be invoked whether or not the user has sent 
     * any eth through the txn or not). Since a user can transact without using any one of the fun.s that we provided (fund in our case), we need a fun. like this to 
     * catch any transactions that have no data and weren't sent to any of the contract's defined fun.s
     */
    receive() external payable{
        // we can do whatever in here
        if(msg.value.getConversionRate(s_priceFeed) >= MIN_DOLLAR_AMT){
            fund();
        }
    }

    /**
     * The fallback fun. is one used when the user sends a txn with data but not to any one of the contract's defined fun.s
     */
    fallback() external payable{
        // we can do whatever in here
        if(msg.value.getConversionRate(s_priceFeed) >= MIN_DOLLAR_AMT){
            fund();
        }
    }
}