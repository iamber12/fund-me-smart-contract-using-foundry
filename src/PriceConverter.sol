// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    // Getting prices from chainlink
    function getPrice(AggregatorV3Interface priceFeed) internal view returns(uint256) {
        (,int256 price,,,) = priceFeed.latestRoundData();
        return uint256(price * 1e10);
    }

    function getConversionRate(uint256 ethAmount , AggregatorV3Interface priceFeed) internal view returns(uint256){
        uint256 ethPrice = getPrice(priceFeed);
        return (ethPrice*ethAmount) / 1e18;
    }
}