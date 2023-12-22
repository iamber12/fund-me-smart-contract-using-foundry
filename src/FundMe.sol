// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

error FundMe__NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 5e18;
    address[] private s_funders;
    mapping(address funder => uint256 amountFunded) private s_addressToAmountFunded;
    address private immutable i_owner;
    AggregatorV3Interface private s_priceFeed;

    constructor(address priceFeed) {
        // set owner of the contract
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    function fund() public payable {
        // Allow users to send $
        // Have a minimum $ sent
        // has 18 decimal places
        require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD, "Amount should atleast be 1 ETH"); // 1e18 = 1 ETH
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;
        // Reverts any actions that have been done and send the remaining gas back
    }

    function getVersion() public returns(uint256) {
        return s_priceFeed.version();
    }

    function withdraw() public onlyOwner {
        uint256 fundersLength =  s_funders.length;

        for(uint256 i=0; i < fundersLength; i++) {
            address funder = s_funders[i];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);

        // withdraw the fund
        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Withdraw failed");
    }

    // modifier
    modifier onlyOwner() {
        // require(msg.sender == i_owner, "Permission Denied: \"Sender is not the owner");
        if(msg.sender != i_owner) {revert FundMe__NotOwner();}
        _;
    }

    receive() external payable {
        fund();
    }

    fallback() external payable { 
        fund();
    }

    // getters
    function getAddressToAmountFunded(address fundingAddress) external view returns(uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getFunder(uint256 index) external view returns(address) {
        return s_funders[index];
    }

    function getOwner() external view returns(address) {
        return i_owner;
    }
}