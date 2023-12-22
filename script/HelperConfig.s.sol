// SPDX-License-Identifier : MIT
// 1 . Deploy mocks
// 2. Keep track of contract address
// 2.1 Sepolia ETH/USD
// 2.2 Mainnet ETH/USD 

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    // if we are on a local anvil, we deploy mock
    // else grab existing address from the live network
    // pure - doesn't change state of the contract

    NetworkConfig public activeNetworkConfig;
    uint8 public constant DECIMALS = 8;
    int256 public constant INIT_PRICE = 2000e8;

    struct NetworkConfig {
        address priceFeed; // ETH/USD price feed address
    }

    constructor() {
        // Sepolia's chain id - 11155111
        if(block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        }
        else if(block.chainid == 1) {
            activeNetworkConfig = getMainnetEthConfig();
        }
        else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns(NetworkConfig memory){
        NetworkConfig memory sepoliaConfig = NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return sepoliaConfig;
    }

    function getMainnetEthConfig() public pure returns(NetworkConfig memory){
        NetworkConfig memory ethConfig = NetworkConfig({priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419});
        return ethConfig;
    }

    function getOrCreateAnvilEthConfig() public returns(NetworkConfig memory){
        // 1. Deploy the mocks
        // 2. Return the mock address
        if(activeNetworkConfig.priceFeed != address(0)){
            return activeNetworkConfig;
        }

        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INIT_PRICE);
        vm.stopBroadcast();
        return NetworkConfig({priceFeed: address(mockPriceFeed)});
    }
}