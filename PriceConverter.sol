// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;


// importing the ETH/USD price from chainlink oracles through AggregatorV3Interface contract.
import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

// library is created to store the functions that are most commonly used
library PriceConverter {

    // the getprice() function helps to get only the current price of ETH 
    function getPrice() internal view returns (uint256) {
        // creating a var of type AggregatorV3Interface and initiaizing it with ETH/USD contract address
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
        // calling the latestRoundData() fn
        (, int256 answer, , ,) = priceFeed.latestRoundData();
        // typecasted the answer into an uint type.
        return uint256(answer * 10000000000);
    }

    // the getConversionRate() fn converts the price of ETH into it's dollar value.
    function getConversionRate(uint256 ethAmount) internal view returns(uint256) {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
        // the actual ETH/USD conversion rate, after adjusting the extra 0s.
        return ethAmountInUsd;
    }
}
