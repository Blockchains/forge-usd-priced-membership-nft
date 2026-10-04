// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

/// Test double implementing the real Chainlink AggregatorV3Interface (used only in unit tests;
/// the fork test in the same suite reads the live ETH/USD feed when MAINNET_RPC_URL is set).
contract FixedPriceAggregator is AggregatorV3Interface {
    int256 public answer;
    uint256 public updatedAt;
    constructor(int256 a) { set(a, block.timestamp); }
    function set(int256 a, uint256 t) public { answer = a; updatedAt = t; }
    function decimals() external pure returns (uint8) { return 8; }
    function description() external pure returns (string memory) { return "ETH / USD (test)"; }
    function version() external pure returns (uint256) { return 4; }
    function getRoundData(uint80 id) external view returns (uint80, int256, uint256, uint256, uint80) { return (id, answer, updatedAt, updatedAt, id); }
    function latestRoundData() external view returns (uint80, int256, uint256, uint256, uint80) { return (1, answer, updatedAt, updatedAt, 1); }
}
