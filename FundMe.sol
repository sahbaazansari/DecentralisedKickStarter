// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;


// imports the functionality of ETH/USD conversion rate from PriceConverter.sol library
import {PriceConverter} from "./PriceConverter.sol";

// error codes 
error NotOwner();


contract FundMe {
    // uint256 is given the properties of PriceConverter to access all the functions of the library
    using PriceConverter for uint256;


    // state variables that are gas efficient
    uint256 public constant MINIMUM_USD = 5e18;
    address public immutable i_owner;

    // array to keep track of funders
    address[] public funders;
    // mapping to map the funders to their amount funded.
    mapping(address funders => uint256 amountFunded) public funderToAmountFunded;

    // to inititalize the owner of the contract
    constructor() {
        i_owner = msg.sender;
    }

    // modifier to check that the function caller is the owner of the contract
    modifier onlyOwner() {
        if (msg.sender != i_owner) { revert NotOwner(); }
        _;
    }



    // fund function to send funds to th econtract in ETH
    function fund() public payable {
        require(msg.value.getConversionRate() > MINIMUM_USD, "Too low ether value");
        funders.push(msg.sender);
        funderToAmountFunded[msg.sender] = funderToAmountFunded[msg.sender] + msg.value;
    }

    // withdraw the funds from the contract 
    // only the owner of the contract is permissible to withdraw from contract
    // sepolia: ETH / USD : 0x694AA1769357215DE4FAC081bf1f309aDC325306
    function withdraw() public onlyOwner {
        for (uint256 i = 0; i < funders.length; i++) {
            address funder = funders[i];
            funderToAmountFunded[funder] = 0;
        }
        // nullifying the funders address
        funders = new address[](0);

        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call to withdraw failed");

    }


    // receive function routes the ETH received to fund() fn
    receive() external payable {
        fund();
    }

    // fallback function routes the ETH received to fund() fn as well
    fallback() external payable {
        fund();
    }
}
